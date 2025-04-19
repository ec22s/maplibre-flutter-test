import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'data_bboxes.dart';

final String BBOX_SOURCE_ID = "bboxes";
final String BBOX_LAYER_ID = "$BBOX_SOURCE_ID-layer";
final String bboxColor = "#987654";
final String bboxFillOpacityHex = "22";
final String bboxLineOpacityHex = "FF";

final List<dynamic> bboxFeatures = BBOXES.asMap().entries.map((entry) {
  dynamic bbox = entry.value;
  List<double> ys = bbox.latitudes;
  List<double> xs = bbox.longitudes;
  double x0 = xs.reduce(min);
  double x1 = xs.reduce(max);
  double y0 = ys.reduce(min);
  double y1 = ys.reduce(max);
  List<List<List<double>>> polygonCoords = [ [
    [ x0, y0 ],
    [ x1, y0 ],
    [ x1, y1 ],
    [ x0, y1 ],
    [ x0, y0 ],
  ] ];
  return {
    "type": "Feature",
    // "properties": {
    //   "name": bbox.name,
    //   "info": bbox.info,
    // },
    "id": entry.key,
    "geometry": {
      "type": "Polygon",
      "coordinates": polygonCoords,
    }
  };
}).toList();

final Map<String, dynamic> bboxesGeoJson = {
  "type": "FeatureCollection",
  "features": bboxFeatures,
};

Future<void> onClickBbox(BuildContext context, MapLibreMapController controller, Point<double> point) async {
  final color = Theme.of(context).primaryColor;
  final messenger = ScaffoldMessenger.of(context);
  final features = await controller.queryRenderedFeatures(
    point,
    [BBOX_LAYER_ID],
    null
  );
  if (features.isNotEmpty) {
    final Map<String, dynamic> feature = features.first;
    final Bbox bbox = BBOXES[feature['id']];
    final String info = (bbox.latitudes + bbox.longitudes).toString();
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: Text(info),
      backgroundColor: color,
      duration: const Duration(days: 1),
    ));
  }
}

Future<void> addBboxes(MapLibreMapController controller) async {
  await controller.addGeoJsonSource(BBOX_SOURCE_ID, bboxesGeoJson);
  await controller.addLayer(
    BBOX_SOURCE_ID,
    BBOX_LAYER_ID,
    FillLayerProperties(
      fillColor: "$bboxColor$bboxFillOpacityHex",
      fillOutlineColor: "$bboxColor$bboxLineOpacityHex",
    ),
  );
  print(bboxesGeoJson); // GeoJsonファイル要る時はこれをコピペ
  // TODO: クリックされた時用のソースとレイヤーを作る. ここから再開!!
}
