class HistoryModel {
  final String id;
  final String type;
  final DateTime? createdAt;
  final Map<String, dynamic> input;
  final Map<String, dynamic> result;

  HistoryModel({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.input,
    required this.result,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;

    if (json['created_at'] != null) {
      try {
        parsedDate = DateTime.parse(
          json['created_at'].toString(),
        );
      } catch (_) {
        parsedDate = null;
      }
    }

    return HistoryModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      createdAt: parsedDate,

      input: json['input'] is Map
          ? Map<String, dynamic>.from(json['input'])
          : {},

      result: json['result'] is Map
          ? Map<String, dynamic>.from(json['result'])
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'created_at': createdAt?.toIso8601String(),
      'input': input,
      'result': result,
    };
  }

  Map<String, dynamic> toHistoryMap() {
    return {
      'id': id,
      'type': type,
      'created_at': createdAt?.toIso8601String(),
      'input': input,
      'result': result,
    };
  }
}