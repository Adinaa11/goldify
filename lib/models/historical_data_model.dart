class HistoricalDataModel {
  final String tanggal;
  final dynamic open;
  final dynamic high;
  final dynamic low;
  final dynamic close;

  HistoricalDataModel({
    required this.tanggal,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  factory HistoricalDataModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return HistoricalDataModel(
      tanggal: json['tanggal']?.toString() ?? '',
      open: json['open'],
      high: json['high'],
      low: json['low'],
      close: json['close'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tanggal': tanggal,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
    };
  }
}