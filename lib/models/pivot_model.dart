class PivotModel {
  final double open;
  final double high;
  final double low;
  final double close;

  final double pivot;
  final double r1;
  final double r2;
  final double r3;
  final double r4;

  final double s1;
  final double s2;
  final double s3;
  final double s4;

  final String? date;

  PivotModel({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.pivot,
    required this.r1,
    required this.r2,
    required this.r3,
    required this.r4,
    required this.s1,
    required this.s2,
    required this.s3,
    required this.s4,
    this.date,
  });

  Map<String,dynamic> toResultJson(){

    return {
      'pivot': pivot,
      'r1': r1,
      'r2': r2,
      'r3': r3,
      'r4': r4,
      's1': s1,
      's2': s2,
      's3': s3,
      's4': s4,
      'date': date,
    };
  }
}