import 'package:flutter/material.dart';
import '../models/history_model.dart';
import '../repositories/history_repository.dart';

class HistoryViewModel extends ChangeNotifier {
  final HistoryRepository repository;

  HistoryViewModel(this.repository);

  List<HistoryModel> history = [];

  String selectedFilter = "Semua";
  bool loading = false;
  String? errorMessage;

  Future<void> loadHistory() async {
    loading = true;
    errorMessage = null;

    notifyListeners();

    try {
      history = await repository.getHistory();
    } catch (e) {
      errorMessage = e.toString();
      history = [];
      debugPrint('Error load history: $e');
    }

    loading = false;

    notifyListeners();
  }

  void changeFilter(String value) {
    selectedFilter = value;
    notifyListeners();
  }

  List<HistoryModel> get filteredHistory {
    if (selectedFilter == "Semua") {
      return history;
    }

    return history.where((item) {
      final type = item.type.toLowerCase();

      if (selectedFilter == "Pivot") {
        return type.contains("pivot");
      }

      if (selectedFilter == "Hangseng") {
        return type.contains("hangseng") ||
            type.contains("hsi");
      }

      if (selectedFilter == "Emas Fisik") {
        return type.contains("emas");
      }

      if (selectedFilter == "NEST") {
        return type.contains("nest");
      }

      return true;
    }).toList();
  }

  double? toDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    return double.tryParse(
      value.toString().replaceAll(',', '.'),
    );
  }

  DateTime? parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(text);
    } catch (_) {
      return null;
    }
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(
      const Duration(days: 1),
    );

    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  String monthName(int month) {
    const months = [
      'JANUARI',
      'FEBRUARI',
      'MARET',
      'APRIL',
      'MEI',
      'JUNI',
      'JULI',
      'AGUSTUS',
      'SEPTEMBER',
      'OKTOBER',
      'NOVEMBER',
      'DESEMBER',
    ];

    if (month < 1 || month > 12) {
      return '-';
    }

    return months[month - 1];
  }

  String dateHeader(DateTime date) {
    if (isToday(date)) {
      return 'HARI INI';
    }

    if (isYesterday(date)) {
      return 'KEMARIN';
    }

    return '${date.day} '
        '${monthName(date.month)} '
        '${date.year}';
  }

  String dateKey(HistoryModel item) {
    final date = item.createdAt;

    if (date == null) {
      return 'LAINNYA';
    }

    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  List<MapEntry<String, List<HistoryModel>>> get groupedHistory {
    final groups = <String, List<HistoryModel>>{};

    // Kelompokkan berdasarkan tanggal
    for (final item in filteredHistory) {
      final key = dateKey(item);

      groups.putIfAbsent(key, () => []);
      groups[key]!.add(item);
    }

    for (final group in groups.values) {
      group.sort((a, b) {
        final dateA = a.createdAt;
        final dateB = b.createdAt;

        if (dateA == null && dateB == null) {
          return 0;
        }

        if (dateA == null) {
          return 1;
        }

        if (dateB == null) {
          return -1;
        }

        return dateB.compareTo(dateA);
      });
    }

    final entries = groups.entries.toList();

    // Urutkan kelompok tanggal
    entries.sort((a, b) {
      final dateA = a.value.isNotEmpty
          ? a.value.first.createdAt
          : null;

      final dateB = b.value.isNotEmpty
          ? b.value.first.createdAt
          : null;

      if (dateA == null && dateB == null) {
        return 0;
      }

      if (dateA == null) {
        return 1;
      }

      if (dateB == null) {
        return -1;
      }

      return dateB.compareTo(dateA);
    });

    return entries;
  }

  Color getResultColor(HistoryModel item) {
    final type = item.type.toLowerCase();

    final result = item.result;

    if (type.contains('emas')) {
      final status =
          result['status']?.toString().toLowerCase() ?? '';

      if (status.contains('profit')) {
        return Colors.green;
      }

      if (status.contains('loss') ||
          status.contains('rugi')) {
        return Colors.red;
      }
    }

    if (type.contains('nest')) {
      final status =
          result['status']?.toString().toLowerCase() ?? '';

      if (status.contains('buy')) {
        return Colors.green;
      }

      if (status.contains('sell')) {
        return Colors.red;
      }
    }

    if (type.contains('hangseng') ||
        type.contains('hsi')) {
      final status =
          result['status']?.toString().toLowerCase() ?? '';

      if (status.contains('buy')) {
        return Colors.green;
      }

      if (status.contains('sell')) {
        return Colors.red;
      }

      final change = toDouble(
        result['change'] ??
            result['profit'] ??
            result['value'],
      );

      if (change != null) {
        return change >= 0
            ? Colors.green
            : Colors.red;
      }
    }

    if (type.contains('pivot')) {
      final change = toDouble(
        result['change'] ??
            result['profit'] ??
            result['value'],
      );

      if (change != null) {
        return change >= 0
            ? Colors.green
            : Colors.red;
      }
    }

    return const Color.fromARGB(
      255,
      245,
      157,
      33,
    );
  }

  String formatRupiah(dynamic value) {
    final number =
        double.tryParse(value?.toString() ?? '') ?? 0;

    final text = number
        .truncate()
        .abs()
        .toString();

    String result = "";

    for (int i = 0; i < text.length; i++) {
      if (i > 0 &&
          (text.length - i) % 3 == 0) {
        result += ".";
      }
      result += text[i];
    }
    return result;
  }

  String formatPivot(dynamic value) {
    final number =
        double.tryParse(value?.toString() ?? '');

    if (number == null) {
      return '-';
    }

    return number
        .toStringAsFixed(2)
        .replaceAll('.', ',');
  }

  String formatDateTime(dynamic value) {
    if (value == null) {
      return '-';
    }

    try {
      final date =
          DateTime.parse(value.toString()).toLocal();

      return "${date.day.toString().padLeft(2, '0')}/"
          "${date.month.toString().padLeft(2, '0')}/"
          "${date.year} "
          "${date.hour.toString().padLeft(2, '0')}:"
          "${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return value.toString();
    }
  }

  Future<void> deleteHistory(String id) async {
    await repository.deleteHistory(id);

    history.removeWhere(
      (item) => item.id == id,
    );

    notifyListeners();
  }
}