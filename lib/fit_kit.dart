import 'dart:async';

import 'package:fit_kit/fit_data.dart';
import 'package:flutter/services.dart';

class FitKit {
  static const MethodChannel _channel = const MethodChannel('fit_kit');

  static Future<List<FitData>> read(
    DataType type,
    DateTime dateFrom,
    DateTime dateTo,
  ) async {
    String typeString;
    switch (type) {
      case DataType.HEART_RATE:
        typeString = "heart_rate";
        break;
      case DataType.STEP_COUNT:
        typeString = "step_count";
        break;
      case DataType.HEIGHT:
        typeString = "height";
        break;
      case DataType.WEIGHT:
        typeString = "weight";
        break;
    }

    return await _channel.invokeListMethod('read', {
      "type": typeString,
      "date_from": dateFrom.millisecondsSinceEpoch,
      "date_to": dateTo.millisecondsSinceEpoch,
    }).then(
      (response) => response.map((item) => FitData.fromJson(item)).toList(),
    );
  }
}

enum DataType { HEART_RATE, STEP_COUNT, HEIGHT, WEIGHT }
