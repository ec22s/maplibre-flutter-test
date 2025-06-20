import 'dart:async';
// import 'package:flutter/material.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'trip_geojson.dart';

class TripLayers {
  late TripGeoJSON _geoJson;
  late MapLibreMapController _controller;
  final _lines = GeoJSONFeatureCollection([]);
  final String geoJsonPointsLayerId = "geoJsonPointsLayer";
  final String geoJsonLinesLayerId = "geoJsonLinesLayer";
  List<DateTime> get ascUniqueDateTimes => _geoJson.ascUniqueDateTimes;
  List<Circle> animatedCircles = [];
  List<Line> animatedLines = [];

  TripLayers(
      {required TripGeoJSON geoJson,
      required MapLibreMapController controller}) {
    _geoJson = geoJson;
    _controller = controller;
    _prepareGeoJsonLineLayer();
    // _buildLines();
  }

  Future<void> init() async {
    final List<dynamic> currentLayerIds = await _controller.getLayerIds();
    final List<String> layerIds = [geoJsonPointsLayerId, geoJsonLinesLayerId];
    layerIds.forEach((layerId) async {
      try {
        if (currentLayerIds.any((id) => id.toString() == layerId)) {
          await _controller.removeLayer(layerId);
        }
      } catch (e) {
        print("unexpected error in init()");
      }
    });
    await _controller.clearCircles();
    await _controller.clearLines();
    // clearしてもlayerは消えない
  }

  // 日付変更線対応
  // https://maplibre.org/maplibre-gl-js/docs/examples/line-across-180th-meridian/
  List<List<double>> _checkCrossAntimeridian(List<List<double>> coordinates) {
    final startLng = coordinates[0][0];
    final endLng = coordinates[1][0];
    if (startLng.sign == endLng.sign || (startLng - endLng).abs() <= 180) {
      // 同符号か, 最短距離が日付変更線を越えない時はそのまま
      return coordinates;
    }
    coordinates[1][0] += 360 * ((startLng > endLng) ? 1 : -1);
    return coordinates;
  }

  Future<void> rewindAnimation() async {
    await _controller.removeCircles(animatedCircles);
    await _controller.removeLines(animatedLines);
    // await _controller.clearCircles();
    // await _controller.clearLines();
    // clearしてもlayerは消えない
  }

  Future<void> plotAtDateTime(DateTime dateTime) async {
    final String color = "#ff0000";
    final double radius = 5;
    final double lineWidth = 2;
    _geoJson.getFeaturesAtDateTime(dateTime).forEach((feature) async {
      final String? id = feature?.properties?[_geoJson.idKey].toString();
      if (id == null) {
        print("unexpected null id: $feature");
        return;
      }
      List<double>? lngLat = feature?.geometry?.toMap()["coordinates"];
      if (lngLat == null) return;
      final Circle circle = await _controller.addCircle(
        CircleOptions(
          geometry: LatLng(lngLat[1], lngLat[0]),
          circleColor: color,
          circleRadius: radius,
        ),
      );
      animatedCircles.add(circle);
      List<double> preLngLat = _geoJson.getPrePointCoordinates(id, dateTime);
      if (preLngLat.isEmpty) return;
      final double startLng = preLngLat[0];
      final double endLng = lngLat[0];

      // 異符号かつ最短距離が日付変更線を越える時
      // 日付変更線対策したいがaddLineではできない
      // LatLngのLngがー180〜180に丸めてしまう
      // https://pub.dev/documentation/maplibre_gl/latest/maplibre_gl/LatLng-class.html
      // if (startLng > 180 && endLng > 180) {
      //   // なぜかあった
      //   print("startLng=$startLng");
      //   print("endLng=$endLng");
      //   preLngLat[0] -= 360;
      //   lngLat[0] -= 360;
      // } else if (startLng < -180 && endLng < -180) {
      //   print("startLng=$startLng");
      //   print("endLng=$endLng");
      //   preLngLat[0] += 360;
      //   lngLat[0] += 360;
      // } else if ((startLng.sign != endLng.sign) &&
      if ((startLng.sign != endLng.sign) && (startLng - endLng).abs() > 180) {
        final List<List<double>> coordinates = [preLngLat, lngLat];
        print("startLng=$startLng");
        print("endLng=$endLng");
        coordinates[1][0] += 360 * ((startLng > endLng) ? 1 : -1);
        print("coordinates=$coordinates");
        // _lines.features.add(GeoJSONFeature(
        //   GeoJSONLineString(coordinates),
        // ));
        // return; // あえて放置時はコメントアウト
      }
      final line = await _controller.addLine(
        LineOptions(
          geometry: [
            LatLng(preLngLat[1], preLngLat[0]),
            LatLng(lngLat[1], lngLat[0]),
          ],
          lineColor: color,
          lineWidth: lineWidth,
        ),
      );
      animatedLines.add(line);
    });
  }

  void _prepareGeoJsonLineLayer() {
    plotGeoJsonLines(LineLayerProperties(
      lineWidth: 3,
      lineColor: "#ff0000",
    ));
    // この時点では何も描画されない
  }

  void _buildLines() {
    String? idKey = _geoJson.idKey;
    String dateTimeKey = _geoJson.dateTimeKey;

    // TODO: 以下はTripJson._getDateSortedFeaturesByIdに置き替えできるはず
    // linesは余り使わないが
    _geoJson.uniqueIds.forEach((id) {
      final String idString = id.toString();
      final List<GeoJSONFeature> tmpFeatures = _geoJson.features
          .where((elem) => elem?.properties?[idKey].toString() == idString)
          .map((elem) => elem!)
          .toList();
      tmpFeatures.sort((a, b) =>
          a.properties?[dateTimeKey].compareTo(b.properties?[dateTimeKey]));
      final List<List<double>> coordinates = tmpFeatures
          .map((elem) => elem.geometry?.toMap()["coordinates"])
          .where((elem) => elem != null)
          .map((elem) => elem! as List<double>)
          .toList();

      // 日付変更線対応
      coordinates.asMap().forEach((int index, List<double> coordinate) {
        if (index == 0) return;
        _checkCrossAntimeridian([coordinates[index - 1], coordinates[index]]);
      });

      _lines.features.add(GeoJSONFeature(
        GeoJSONLineString(coordinates),
        properties: {"idString": idString},
      ));
    });
  }

  void fitBounds() {
    final List<double>? bbox = _geoJson.bbox;
    if (bbox == null) {
      print("unexpected null: bbox");
      return;
    }
    final bounds = LatLngBounds(
      southwest: LatLng(bbox[1], bbox[0]),
      northeast: LatLng(bbox[3], bbox[2]),
    );
    _controller.moveCamera(CameraUpdate.newLatLngBounds(bounds));
    // TODO: 日付変更線が範囲内にある場合の検討
    // 実際データがある地点を考慮して中心を移動する必要あり. bboxだけでは判断つかない
    // print(_geoJson.bbox);
    // print(bounds);
    // _controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(...)));
  }

  Future<String> _layer(String layerId) async {
    final List<dynamic> currentLayerIds = await _controller.getLayerIds();
    try {
      if (currentLayerIds.any((id) => id == layerId)) {
        await _controller.removeLayer(layerId);
      }
      return layerId;
    } catch (e) {
      print("unexpected error in _layer");
      return "";
    }
  }

  Future<String> _geoJsonSource(
      String sourceId, GeoJSONFeatureCollection geoJson) async {
    final List<String> currentSourceIds = await _controller.getSourceIds();
    final Map<String, dynamic> source = geoJson.toMap();
    try {
      if (currentSourceIds.any((id) => id == sourceId)) {
        await _controller.setGeoJsonSource(sourceId, source);
      } else {
        await _controller.addGeoJsonSource(sourceId, source);
      }
      return sourceId;
    } catch (e) {
      print("unexpected error in _geoJsonSource");
      return "";
    }
  }

  // 簡易用
  Future<void> plotGeoJsonLines(LineLayerProperties lineProps) async {
    final String sourceId = await _geoJsonSource("geoJsonLinesSource", _lines);
    if (sourceId.isEmpty) {
      print("failed to add(set) source from LineLayerProperties");
      return;
    }
    final String layerId = await _layer("geoJsonLinesLayer");
    if (layerId.isEmpty) {
      print("failed to remove existing layer in plotGeoJsonLines");
      return;
    }
    try {
      await _controller.addLineLayer(sourceId, layerId, lineProps);
    } catch (e) {
      print("unexpected error in plotGeoJsonLines");
    }
  }

  // 簡易用
  Future<void> plotGeoJsonPoints(CircleLayerProperties circleProps) async {
    final String sourceId =
        await _geoJsonSource("geoJsonPointsSource", _geoJson);
    if (sourceId.isEmpty) {
      print("failed to add(set) source from plotPoints");
      return;
    }
    final String layerId = await _layer("geoJsonPointsLayer");
    if (layerId.isEmpty) {
      print("failed to remove existing layer in plotGeoJsonPoints");
      return;
    }
    try {
      await _controller.addCircleLayer(sourceId, layerId, circleProps);
    } catch (e) {
      print("unexpected error in plotGeoJsonPoints");
    }
  }
}
