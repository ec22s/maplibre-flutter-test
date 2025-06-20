import 'package:csv/csv.dart';
import 'package:geojson_vi/geojson_vi.dart';

class ColumnIndex {
  int? latitude;
  int? longitude;

  final latReg = RegExp(r'lat(itude)?', caseSensitive: false);
  final lngReg = RegExp(r'lon(gitude)?', caseSensitive: false);

  ColumnIndex(List<String> row) {
    latitude = row.indexWhere((column) => latReg.hasMatch(column));
    longitude = row.indexWhere((column) => lngReg.hasMatch(column));
  }

  String get info => "ColumnIndex: latitude=$latitude, longitude=$longitude";

  bool isValid() {
    if (latitude == null) {
      print("unexpected null: ColumnIndex.latitude");
      return false;
    }
    if (longitude == null) {
      print("unexpected null: ColumnIndex.longitude");
      return false;
    }
    return true;
  }
}

List<GeoJSONFeature> csvToGeoJSONPointFeatures(String data) {
  final List<List<dynamic>> rows = getCsvRows(data);
  final List<String> header =
      rows.first.map((column) => column.toString()).toList();
  final List<GeoJSONFeature> features = [];
  final columnIndex = ColumnIndex(header);
  if (!columnIndex.isValid()) return features;
  for (var row in rows.sublist(1)) {
    final List<double> coordinates = [double.nan, double.nan];
    final Map<String, dynamic> properties = {};
    header.asMap().forEach((int index, String key) {
      if (index == columnIndex.latitude) {
        coordinates[1] = row[index].toDouble();
      } else if (index == columnIndex.longitude) {
        coordinates[0] = row[index].toDouble();
      } else {
        properties[key] = row[index];
      }
    });
    features.add(GeoJSONFeature(
      GeoJSONPoint(coordinates),
      properties: properties,
    ));
  }
  return features;
}

List<List<dynamic>> getCsvRows(String data) {
  // 暫定的な改行自動判別
  final defaultConverter = CsvToListConverter();
  final cumstomConverter1 = CsvToListConverter(eol: '\n');
  final List<List<dynamic>> rows0 = defaultConverter.convert(data);
  final List<List<dynamic>> rows1 = cumstomConverter1.convert(data);
  if (rows0.length < rows1.length) {
    print("using custom EOL '\\n' in CsvToListConverter");
    return rows1;
  }
  print("using default EOL '\\r\\n' in csvToListConverter");
  return rows0;
}
