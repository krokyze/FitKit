
# FitKit (<img src="https://www.gstatic.com/images/branding/product/1x/gfit_512dp.png" height="24"/> + <img src="https://developer.apple.com/assets/elements/icons/healthkit/healthkit-96x96_2x.png" height="24"/>)

[![pub package](https://img.shields.io/pub/v/fit_kit.svg)](https://pub.dartlang.org/packages/fit_kit)

Flutter plugin for reading health and fitness data. Wraps HealthKit on iOS and GoogleFit on Android.

## Usage

To use this plugin, add `fit_kit` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Getting Started
##### Android
[Enable Fitness API](https://developers.google.com/fit/android/get-started) and obtain an OAuth 2.0 client ID.

##### iOS
[Enable HealthKit](https://developer.apple.com/documentation/healthkit/setting_up_healthkit) and add NSHealthShareUsageDescription key to the Info.plist file.

## Sample Usage
If you're using more than one DataType it's advised to call requestPermissions with all the data types once, otherwise iOS HealthKit will ask to approve every permission one by one in separate screens.

```dart
import 'package:fit_kit/fit_kit.dart';

void read() async {
    final results = await FitKit.read(
        DataType.HEART_RATE,
        DateTime.now().subtract(Duration(days: 5)),
        DateTime.now(),
    );
}

void readAll() async {
    if (await FitKit.requestPermissions(DataType.values)) {
      for (DataType type in DataType.values) {
        final results = await FitKit.read(
          type,
          DateTime.now().subtract(Duration(days: 5)),
          DateTime.now(),
        );
      }
    }
}
```

## Supported data types

These are currently available data types and their corresponding GoogleFit/HealthKit types. 

| Data Type | Android (GoogleFit) | iOS (HealthKit) | Unit | 
| --------------------------: | ----------------- | ----------------- | -------------- |
| **HEART_RATE** | [TYPE_HEART_RATE_BPM](https://developers.google.com/android/reference/com/google/android/gms/fitness/data/DataType.html#TYPE_HEART_RATE_BPM) | [heartRate](https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier/1615138-heartrate) | _count/min_ |
| **STEP_COUNT** | [TYPE_STEP_COUNT_DELTA](https://developers.google.com/android/reference/com/google/android/gms/fitness/data/DataType.html#TYPE_STEP_COUNT_DELTA) | [stepCount](https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier/1615548-stepcount) | _count_ |
| **HEIGHT** | [TYPE_HEIGHT](https://developers.google.com/android/reference/com/google/android/gms/fitness/data/DataType.html#TYPE_HEIGHT) | [height](https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier/1615039-height) | _meter_ |
| **WEIGHT** | [TYPE_WEIGHT](https://developers.google.com/android/reference/com/google/android/gms/fitness/data/DataType.html#TYPE_WEIGHT) | [bodyMass](https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier/1615693-bodymass) | _kilogram_ |
| **DISTANCE** | [TYPE_DISTANCE_DELTA](https://developers.google.com/android/reference/com/google/android/gms/fitness/data/DataType.html#TYPE_DISTANCE_DELTA) | [distanceWalkingRunning](https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier/1615230-distancewalkingrunning) | _meter_ |
| **ENERGY** | [TYPE_CALORIES_EXPENDED](https://developers.google.com/android/reference/com/google/android/gms/fitness/data/DataType.html#TYPE_CALORIES_EXPENDED) | [activeEnergyBurned](https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier/1615771-activeenergyburned) | _kilocalorie_ |
| **WATER** | [TYPE_HYDRATION](https://developers.google.com/android/reference/com/google/android/gms/fitness/data/DataType.html#TYPE_HYDRATION) | [dietaryWater](https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier/1615313-dietarywater) <sup>>= iOS 9</sup> | liter |

## BE AWARE

There's some differences on iOS for these methods:
* `FitKit.hasPermissions` - false means no, true means user has approved or declined permissions.
	> To help prevent possible leaks of sensitive health information, your app cannot determine whether or not a user has granted permission to read data. If you are not given permission, it simply appears as if there is no data of the requested type in the HealthKit store. [https://developer.apple.com/documentation/healthkit/hkhealthstore/1614154-authorizationstatus](https://developer.apple.com/documentation/healthkit/hkhealthstore/1614154-authorizationstatus)
* `FitKit.revokePermissions` - isn't supported by HealthKit, method does nothing.
