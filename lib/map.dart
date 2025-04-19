import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

const initCenter = LatLng(35.0, 138.5);
const initZoom = 4.0;
const initialCameraPosition =
    CameraPosition(target: initCenter, zoom: initZoom);

const mapStyleUrl = // MapLibreStyles.demo // default
    // 'styles/tile_openstreetmap.json'
    'styles/maplibre_demo.json'
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
  MapLibreMapController? mapController;
  static const clusterLayer = "clusters";
  static const unclusteredPointLayer = "unclustered-point";

  @override
  void dispose() {
    // mapController?.onFeatureTapped.remove(_onFeatureTapped);
    super.dispose();
  }

  void _onMapCreated(MapLibreMapController controller) async {
    mapController = controller;
  }

  void _onStyleLoadedCallback() async {
    // await addRaster(mapController!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapLibreMap(
        styleString: mapStyleUrl,
        myLocationEnabled: true,
        initialCameraPosition: initialCameraPosition,
        onMapCreated: _onMapCreated,
        onStyleLoadedCallback: _onStyleLoadedCallback,
        // onMapClick: _onMapClick,
        trackCameraPosition: true,
      ),
    );
  }
}
