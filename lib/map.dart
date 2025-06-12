import 'dart:math';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'map_funcs.dart';

const LatLng initCenter = LatLng(35.0, 138.5);
const double initZoom = 4.0;
const CameraPosition initialCameraPosition =
    CameraPosition(target: initCenter, zoom: initZoom);

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

  @override
  void dispose() {
    super.dispose();
  }

  void _onMapCreated(MapLibreMapController controller) async {
    this.controller = controller;
  }

  void _onStyleLoadedCallback() async {
    await addBboxes(controller!);
  }

  void _onMapClick(Point<double> point, LatLng coordinates) async {
    print("TODO: 一部デバイスでbbox上のタップが検知されず, ここに来ない");
    await onClickBbox(context, controller!, point);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapLibreMap(
        compassEnabled: true, // TODO: 一部デバイスで無効
        myLocationEnabled: true, // 同上? 右下にアイコンが出ない
        styleString: mapStyleUrl,
        initialCameraPosition: initialCameraPosition,
        onMapCreated: _onMapCreated,
        onStyleLoadedCallback: _onStyleLoadedCallback,
        onMapClick: _onMapClick,
        trackCameraPosition: true,
      ),
    );
  }
}
