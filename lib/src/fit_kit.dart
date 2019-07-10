part of fit_kit;

class FitKit {
  static const MethodChannel _channel = const MethodChannel('fit_kit');

  static Future<bool> requestPermissions(List<DataType> types) async {
    return await _channel.invokeMethod('requestPermissions', {
      "types": types.map((type) => _dataTypeToString(type)).toList(),
    });
  }

  static Future<List<FitData>> read(
    DataType type,
    DateTime dateFrom,
    DateTime dateTo,
  ) async {
    return await _channel.invokeListMethod('read', {
      "type": _dataTypeToString(type),
      "date_from": dateFrom.millisecondsSinceEpoch,
      "date_to": dateTo.millisecondsSinceEpoch,
    }).then(
      (response) => response.map((item) => FitData.fromJson(item)).toList(),
    );
  }

  static String _dataTypeToString(DataType type) {
    switch (type) {
      case DataType.HEART_RATE:
        return "heart_rate";
      case DataType.STEP_COUNT:
        return "step_count";
      case DataType.HEIGHT:
        return "height";
      case DataType.WEIGHT:
        return "weight";
      case DataType.DISTANCE:
        return "distance";
      case DataType.ENERGY:
        return "energy";
      case DataType.WATER:
        return "water";
    }
    throw Exception('dataType $type not supported');
  }
}

enum DataType {
  HEART_RATE,
  STEP_COUNT,
  HEIGHT,
  WEIGHT,
  DISTANCE,
  ENERGY,
  WATER
}
