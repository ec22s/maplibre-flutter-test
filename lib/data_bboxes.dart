import 'package:meta/meta.dart';

const List<List<dynamic>> seed = [
  [ 24.1, 28.6, 140.5, 142.7 ],
  [ 30.7, 34.9, 138.5, 140.2 ],
  [ 33, 34.9, 140.2, 142 ],
  [ 34.9, 37, 141, 143 ],
  [ 37, 39, 141, 143 ],
  [ 39, 41, 141.5, 143.5 ],
  [ 41, 42.5, 140.5, 143.5 ],
  [ 41, 43, 143.5, 145.5 ],
  [ 44, 45.5, 142.5, 145.5 ],
  [ 44, 45.75, 140, 142 ],
  [ 43, 44, 139, 141.5 ],
  [ 41, 43, 138, 140 ],
  [ 39, 41, 138, 140 ],
  [ 38, 39, 137, 139.75 ],
  [ 37, 38, 136.25, 139 ],
  [ 35.75, 37, 134, 136.25 ],
  [ 35.25, 36.5, 132, 134 ],
  [ 34.5, 36, 130.5, 132 ],
  [ 33.5, 34.5, 129.25, 130.5 ],
  [ 32.5, 33.5, 128, 129.5 ],
  [ 31, 32.5, 129, 130.5 ],
  [ 29, 31, 130.5, 132 ],
  [ 31, 32.75, 131.5, 133 ],
  [ 31.5, 33.5, 133, 134.75 ],
  [ 31.5, 33.5, 134.75, 136.5 ],
  [ 32.5, 34.5, 136.5, 138.5 ],
];

@immutable
class Bbox {
  final List<double> latitudes;
  final List<double> longitudes;
  // final String? name;
  // final String? info;

  const Bbox({
    required this.latitudes,
    required this.longitudes,
    // this.name = '',
    // this.info = '',
  });
}

final List<Bbox> BBOXES = seed.map((List<dynamic> t) => Bbox(
    latitudes: [ t[0], t[1] ],
    longitudes: [ t[2], t[3] ],
    // name: (t.length > 4 ? t[4] : ''),
    // info: (t.length > 5 ? t[5] : ''),
  )
).toList();

