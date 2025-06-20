import 'package:geojson_vi/geojson_vi.dart';

class TripGeoJSON extends GeoJSONFeatureCollection {
  TripGeoJSON({required List<GeoJSONFeature> features}) : super(features) {
    _initData();
  }

  final _idReg = RegExp(r'id|name', caseSensitive: false);
  final _dateTimeKeyReg = RegExp(r'date|time', caseSensitive: false);
  final _parseDateTimeReg = RegExp(
      r"^(\d{4})[/-]?(\d{2})[/-]?(\d{2})[ T]?(\d{2})?:?(\d{2})?:?((\d{2})(\.\d+)?)?(Z|\+\d{2}:\d{2})?$",
      caseSensitive: false);
  late String idKey;
  late String originalDateTimeKey;
  String dateTimeKey = "tripDateTime";

  final List<GeoJSONFeature> omittedFeatures = [];
  bool get isEmpty => features.isEmpty;
  List<Map<String, dynamic>> get allProps => features
      .map((feature) => feature?.properties)
      .where((props) => props != null)
      .map((props) => props!)
      .toList();
  Set<String> get uniqueIds =>
      Set.from(allProps.map((props) => props[idKey].toString()).toList());
  List<List<double>> get coordinates => features
      .map((feature) => feature?.geometry)
      .where((geometry) => geometry != null)
      .map((geometry) => geometry!.toMap()["coordinates"] as List<double>)
      .toList();

  List<DateTime> get ascUniqueDateTimes {
    final Set<DateTime> tmpSet =
        Set.from(allProps.map((props) => DateTime.parse(props[dateTimeKey])));
    final List<DateTime> tmpList = tmpSet.toList();
    tmpList.sort((a, b) => a.compareTo(b));
    return tmpList;
  }

  List<DateTime> get dateTimeRange =>
      [ascUniqueDateTimes.first, ascUniqueDateTimes.last];
  List<Duration> get intervalRange {
    final Duration zero = Duration(hours: 0);
    if (ascUniqueDateTimes.length < 2) return [zero, zero];
    final Duration initIntv =
        ascUniqueDateTimes[1].difference(ascUniqueDateTimes.first);
    final List<Duration> tmpList = [initIntv, initIntv];
    ascUniqueDateTimes.asMap().forEach((int i, DateTime d) {
      if (i <= 1) return;
      final Duration tmpIntv = d.difference(ascUniqueDateTimes[i - 1]);
      if (tmpIntv < tmpList[0]) tmpList[0] = tmpIntv;
      if (tmpList[1] < tmpIntv) tmpList[1] = tmpIntv;
    });
    return tmpList;
  }

  Iterable<String> get _firstPropertyKeys => allProps.first.keys;

  void _initData() {
    if (isEmpty) {
      print("unexpected empty: TripGeoJSON - features");
      return;
    }
    final String? _idKey =
        _firstPropertyKeys.firstWhere((key) => _idReg.hasMatch(key));
    final String? _originalDateTimeKey =
        _firstPropertyKeys.firstWhere((key) => _dateTimeKeyReg.hasMatch(key));
    if (_idKey == null) {
      print("unexpected null: TripGeoJSON - idKey");
      return;
    }
    if (_originalDateTimeKey == null) {
      print("unexpected null: TripGeoJSON - originalDateTimeKey");
      return;
    }
    idKey = _idKey;
    originalDateTimeKey = _originalDateTimeKey;
    _setNewDateTimeKey();
    _checkFeatures();
    if (omittedFeatures.isNotEmpty) {
      print("some features omitted: ${omittedFeatures.toString()}");
    }
  }

  void _checkFeatures() {
    features.asMap().forEach((int index, GeoJSONFeature? feature) {
      if (feature == null) return;
      final Map<String, dynamic>? props = feature.properties;
      if (props == null || !_hasId(props) || !_isPoint(feature)) {
        _omitFeature(feature, index);
      }
      _setTripDateTime(feature, index);
    });
  }

  void _omitFeature(GeoJSONFeature feature, int index) {
    omittedFeatures.add(feature);
    features.removeAt(index);
  }

  bool _hasId(Map<String, dynamic> props) {
    return props.containsKey(idKey);
  }

  bool _isPoint(GeoJSONFeature feature) {
    return feature.geometry?.type == GeoJSONType.point;
  }

  void _setTripDateTime(GeoJSONFeature feature, int index) {
    final Map<String, dynamic>? props = feature.properties;
    dynamic originalDateTime = props?[originalDateTimeKey].toString();
    if (props == null || originalDateTime == "null") {
      _omitFeature(feature, index);
      return;
    }
    originalDateTime = originalDateTime.toString();
    DateTime? parsedDateTime;
    // https://api.flutter.dev/flutter/dart-core/DateTime/parse.html
    // DateTime.parseは10桁数字の先頭6桁を年と判断するため使わない
    try {
      RegExpMatch? match = _parseDateTimeReg.firstMatch(originalDateTime);
      if (match != null) {
        int year = int.parse(match.group(1) ?? "0");
        int month = int.parse(match.group(2) ?? "0");
        int day = int.parse(match.group(3) ?? "0");
        int hour = int.parse(match.group(4) ?? "0");
        int minute = int.parse(match.group(5) ?? "0");
        int second = int.parse(match.group(7) ?? "0");
        // String timezone = match.group(9) ?? "";
        // 秒未満とtimezoneは未使用
        parsedDateTime = DateTime(year, month, day, hour, minute, second);
        // print("parsed: $originalDateTime -> $parsedDateTime");
      }
    } catch (e) {
      print("failed parse: $originalDateTime, ${e.toString()}");
    }
    if (parsedDateTime == null) {
      _omitFeature(feature, index);
      return;
    }
    props[dateTimeKey] = parsedDateTime.toString();
  }

  void _setNewDateTimeKey() {
    while (true) {
      if (_firstPropertyKeys.every((key) => key != dateTimeKey)) break;
      dateTimeKey += "_";
    }
  }

  List<GeoJSONFeature> _getDateSortedFeaturesById(String id) {
    final List<GeoJSONFeature> tmpFeatures = features
        .where((elem) => elem?.properties?[idKey].toString() == id)
        .map((elem) => elem!)
        .toList();
    tmpFeatures.sort((a, b) =>
        a.properties?[dateTimeKey].compareTo(b.properties?[dateTimeKey]));
    return tmpFeatures;
  }

  GeoJSONFeature? _getPreFeature(String id, DateTime dateTime) {
    final List<GeoJSONFeature> features = _getDateSortedFeaturesById(id);
    final int length = features.length;
    if (length < 2) return null;
    for (var i = 1; i < length; i++) {
      final GeoJSONFeature feature = features[i];
      final String? dateTimeString =
          feature.properties?[dateTimeKey].toString();
      if (dateTimeString == dateTime.toString()) {
        return features[i - 1];
      }
    }
  }

  List<GeoJSONFeature> getFeaturesAtDateTime(DateTime dateTime) {
    return features
        .where((elem) =>
            elem?.properties?[dateTimeKey].toString() == dateTime.toString())
        .map((elem) => elem!)
        .toList();
  }

  List<double> getPrePointCoordinates(String id, DateTime dateTime) {
    final List<double>? coordinates =
        _getPreFeature(id, dateTime)?.geometry?.toMap()["coordinates"];
    return coordinates ?? [];
  }
}
