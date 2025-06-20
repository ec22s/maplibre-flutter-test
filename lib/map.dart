import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'csv_to_geojson.dart';
// import 'map_funcs.dart';
import 'random_string.dart';
import 'trip_geojson.dart';
import 'trip_layers.dart';

const LatLng _initCenter = LatLng(35.0, 138.5);
const double _initZoom = 4.0;
const CameraPosition _initialCameraPosition =
    CameraPosition(target: _initCenter, zoom: _initZoom);

const double _buttonPadding = 16;
const String _buttonOpenCsvLabel = "Open CSV";
const double _buttonOpenCsvWidth = 64;
const double _buttonDateTimeWidth = 96;
const Color _buttonBackgroundDefault = Colors.white70;
const Color _buttonBackgroundActive = Colors.lime;
Color _buttonBackgroundAnimation = _buttonBackgroundDefault;

const mapStyleUrl =
    // MapLibreStyles.demo // default
    'styles/tile_openstreetmap.json'
    // 'styles/maplibre_demo.json'
    // 'https://api.maptiler.com/maps/019643c9-aea6-7b85-9565-0870684731f0/style.json?key=EZ0ds0SzFjV0svFuQ2Ki'
    // 'https://tile.openstreetmap.jp/styles/osm-bright-ja/style.json'
    ;

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Map();
  }
}

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State createState() => MapState();
}

class MapState extends State<Map> {
  MapLibreMapController? controller;
  late TripLayers tripLayers;
  DateTime? _animationDateTime;
  Timer? _timer;
  bool animating = false;
  bool animationLoop = true;
  int animationMsec = 256;
  int animationIndex = 0;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onMapCreated(MapLibreMapController controller) async {
    this.controller = controller;
  }

  Future<void> _onStyleLoadedCallback() async {
    // await addBboxes(controller!);
  }

  Future<void> _onMapClick(Point<double> point, LatLng coordinates) async {
    print("TODO: 一部デバイスでbbox上のタップが検知されず, ここに来ない");
    // await onClickBbox(context, controller!, point);
  }

  void animationStopped() {
    setState(() {
      _buttonBackgroundAnimation = _buttonBackgroundDefault;
    });
  }

  Future<void> startTripLayersAnimation() async {
    final List<DateTime> dateTimes = tripLayers.ascUniqueDateTimes;
    animating = true;
    setState(() {
      _buttonBackgroundAnimation = _buttonBackgroundActive;
    });
    _timer =
        Timer.periodic(Duration(milliseconds: animationMsec), (timer) async {
      if (animationIndex > dateTimes.length - 1) {
        await tripLayers.rewindAnimation();
        if (animationLoop) {
          animationIndex = 0; // loop
          print('animation repeated');
        } else {
          timer.cancel();
          animating = false;
          animationStopped();
          print('animation completed');
          return;
        }
      }
      if (animating == false) {
        timer.cancel();
        animationStopped();
        return;
      }
      setState(() {
        _animationDateTime = dateTimes[animationIndex];
      });
      if (_animationDateTime != null) {
        await tripLayers.plotAtDateTime(_animationDateTime!);
      }
      animationIndex++;
    });
  }

  Future<void> onPressButtonDateTime() async {
    animating = !animating;
    if (animating) {
      await startTripLayersAnimation();
    }
    print("animation ${animating ? "playing" : "paused"}");
  }

  Future<void> onPressButtonOpenCsv() async {
    if (controller == null) return; // 謎に以降で ! 必要
    final TripGeoJSON? tripGeoJSON = await csvToTripGeoJSON();
    if (tripGeoJSON == null) return;
    tripLayers = TripLayers(geoJson: tripGeoJSON, controller: controller!);
    await tripLayers.init();
    animationIndex = 0;
    setState(() {
      _animationDateTime = tripLayers.ascUniqueDateTimes[animationIndex];
    });
    // final String randomColor = randomColorHex();
    // await tripLayers.plotGeoJsonLines(LineLayerProperties(
    //   lineWidth: 3,
    //   lineColor: randomColor,
    //   // 謎にTripLayers内でColors使うとエラー. 後で調べる [TODO]
    // ));
    // テスト用 ほぼ使わない
    // await tripLayers.plotGeoJsonPoints(CircleLayerProperties(
    //   circleRadius: 5,
    //   circleColor: randomColor,
    // ));
    // tripLayers.fitBounds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter MapLibre Trajectory'),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          buttonDateTime(onPressButtonDateTime),
          buttonOpenCsv(onPressButtonOpenCsv),
        ],
      ),
      body: MapLibreMap(
        myLocationEnabled: true, // Web以外無効? 右下にアイコンが出ない
        styleString: mapStyleUrl,
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: _onMapCreated,
        onStyleLoadedCallback: _onStyleLoadedCallback,
        onMapClick: _onMapClick,
      ),
    );
  }

  Widget buttonDateTime(VoidCallback callback) {
    return Padding(
      padding: const EdgeInsets.all(_buttonPadding),
      child: FloatingActionButton.extended(
        backgroundColor: _buttonBackgroundAnimation,
        label: SizedBox(
            width: _buttonDateTimeWidth,
            child: Center(child: Text(_animationDateTime.toString()))),
        onPressed: callback,
      ),
    );
  }
}

Future<TripGeoJSON?> csvToTripGeoJSON() async {
  final FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.any,
    // type: FileType.custom,
    // allowedExtensions: ['csv'],
    // 上記だとファイルを選択できない謎
    // https://tachitutetonosuke.hatenablog.com/entry/2021/11/28/203159
  );
  if (result == null) {
    print("nothing loaded");
    return null;
  }
  final PlatformFile file = result.files.first;
  final String? ext = file.extension;
  if (ext != "csv") {
    print("unexpected file extension: $ext");
    // _showAlertDialog(buildContext);
    // TODO: show Alert
    return null;
  }
  final String path = file.path.toString();
  final File csvFile = File(path);
  if (!(await csvFile.exists())) {
    print("unexpectedly file '$path' not found");
    return null;
  }
  final String data = await csvFile.readAsString();
  final List<GeoJSONFeature> features = csvToGeoJSONPointFeatures(data);
  final tripGeoJSON = TripGeoJSON(features: features);
  if (tripGeoJSON.isEmpty) {
    print("no geojson feature from CSV");
    // TODO: show Alert
    return null;
  }
  return tripGeoJSON;
}

Widget buttonOpenCsv(VoidCallback callback) {
  return Padding(
    padding: const EdgeInsets.all(_buttonPadding),
    child: FloatingActionButton.extended(
      backgroundColor: _buttonBackgroundDefault,
      icon: const Icon(Icons.folder_open),
      label: SizedBox(
          width: _buttonOpenCsvWidth,
          child: Center(child: Text(_buttonOpenCsvLabel))),
      onPressed: callback,
    ),
  );
}
