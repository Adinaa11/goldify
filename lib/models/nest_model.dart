class NestModel {

  final double? open;
  final double close;
  final String status;
  final String? date;

  NestModel({

    this.open,
    required this.close,
    required this.status,
    this.date,
  });

  Map<String, dynamic> toMap(){

    return {
      'open': open,
      'close': close,
      'status': status,
      'date': date,
    };
  }
}