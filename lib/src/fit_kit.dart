part of fit_kit;

class FitKit {
  static const MethodChannel _channel = const MethodChannel('fit_kit');

  /// iOS isn't completely supported by HealthKit, false means no, true means user has approved or declined permissions.
  /// In case user has declined permissions read will just return empty list for declined data types.
  static Future<bool> hasPermissions(List<DataType> types) async {
    return await _channel.invokeMethod('hasPermissions', {
      "types": types.map((type) => _dataTypeToString(type)).toList(),
    });
  }

  /// If you're using more than one DataType it's advised to call requestPermissions with all the data types once,
  /// otherwise iOS HealthKit will ask to approve every permission one by one in separate screens.
  ///
  /// `await FitKit.requestPermissions(DataType.values)`
  static Future<bool> requestPermissions(List<DataType> types) async {
    return await _channel.invokeMethod('requestPermissions', {
      "types": types.map((type) => _dataTypeToString(type)).toList(),
    });
  }

  /// iOS isn't supported by HealthKit, method does nothing.
  static Future<void> revokePermissions() async {
    return await _channel.invokeMethod('revokePermissions');
  }

  /// #### It's not advised to call `await FitKit.read(dataType)` without any extra parameters. This can lead to FAILED BINDER TRANSACTION on Android devices because of the data batch size being too large.
  static Future<List<FitData>> read(
    DataType type, {
    DateTime dateFrom,
    DateTime dateTo,
    int limit,
  }) async {
    return await _channel
        .invokeListMethod('read', {
          "type": _dataTypeToString(type),
          "date_from": dateFrom?.millisecondsSinceEpoch ?? 1,
          "date_to": (dateTo ?? DateTime.now()).millisecondsSinceEpoch,
          "limit": limit,
        })
        .then(
          (response) => response.map((item) => FitData.fromJson(item)).toList(),
        )
        .catchError(
          (_) => throw UnsupportedException(type),
          test: (e) {
            if (e is PlatformException) return e.code == 'unsupported';
            return false;
          },
        );
  }

  static Future<FitData> readLast(DataType type) async {
    return await read(type, limit: 1)
        .then((results) => results.isEmpty ? null : results[0]);
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
      case DataType.SLEEP:
        return "sleep";
      case DataType.STAND_TIME:
        return "stand_time";
      case DataType.EXERCISE_TIME:
        return "exercise_time";
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
  WATER,
  SLEEP,
  STAND_TIME,
  EXERCISE_TIME
}

class UnsupportedException implements Exception {
  final DataType dataType;
  UnsupportedException(this.dataType);

  @override
  String toString() => 'UnsupportedException: dataType $dataType not supported';
}
