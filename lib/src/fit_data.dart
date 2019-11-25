part of fit_kit;

class FitData {
  final num value;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String source;
  final bool userEntered;

  FitData(
    this.value,
    this.dateFrom,
    this.dateTo,
    this.source,
    this.userEntered,
  );

  FitData.fromJson(Map<dynamic, dynamic> json)
      : value = json['value'],
        dateFrom = DateTime.fromMillisecondsSinceEpoch(json['date_from']),
        dateTo = DateTime.fromMillisecondsSinceEpoch(json['date_to']),
        source = json['source'],
        userEntered = json['user_entered'];

  @override
  String toString() =>
      'FitData(value: $value, dateFrom: $dateFrom, dateTo: $dateTo, source: $source, userEntered: $userEntered)';
}
