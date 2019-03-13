# FitKit

[![pub package](https://img.shields.io/pub/v/fit_kit.svg)](https://pub.dartlang.org/packages/fit_kit)

Flutter plugin for reading health and fitness data. Wraps HealthKit on iOS and GoogleFit on Android. Currently only supports reading heart rate, step count, height and weight.

## Usage

To use this plugin, add `fit_kit` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Getting Started
##### Android
[Enable Fitness API](https://developers.google.com/fit/android/get-started) and obtain an OAuth 2.0 client ID.

##### iOS
[Enable HealthKit](https://developer.apple.com/documentation/healthkit/setting_up_healthkit) and add NSHealthShareUsageDescription key to the Info.plist file.

### Sample Usage

```dart
import 'package:fit_kit/fit_kit.dart';

void read() async {
    final results = await FitKit.read(
        DataType.HEART_RATE,
        DateTime.now().subtract(Duration(days: 5)),
        DateTime.now(),
    );
}
```