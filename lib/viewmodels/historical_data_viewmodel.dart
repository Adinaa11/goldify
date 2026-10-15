import 'package:flutter/material.dart';

import '../models/historical_data_model.dart';
import '../repositories/historical_data_repository.dart';

class HistoricalDataViewModel extends ChangeNotifier {
  final HistoricalDataRepository repository;

  HistoricalDataViewModel(
    this.repository,
  );

  List<HistoricalDataModel> historicalData = [];

  DateTime? startDate;

  DateTime? endDate;

  String selectedCategory = 'LGD Daily';

  int currentPage = 1;

  static const int itemsPerPage = 10;

  bool loading = false;

  Object? error;

  final List<String> categories = [
    'LGD Daily',
    'HSI — Hang Seng Hong Kong',
    'SNI — Nikkei Jepang',
  ];

  Future<void> loadHistoricalData() async {
    currentPage = 1;

    loading = true;
    error = null;

    notifyListeners();

    try {
      historicalData =
          await repository.getHistoricalData(
        category: selectedCategory,
        startDate: formatDateForApi(startDate),
        endDate: formatDateForApi(endDate),
      );
    } catch (e) {
      error = e;
      historicalData = [];

      debugPrint(
        'Error load historical data: $e',
      );
    }

    loading = false;

    notifyListeners();
  }

  Future<void> changeCategory(
    String? value,
  ) async {
    if (value == null ||
        value == selectedCategory) {
      return;
    }

    selectedCategory = value;
    currentPage = 1;

    notifyListeners();

    await loadHistoricalData();
  }

  void setStartDate(DateTime selected) {
    startDate = selected;

    if (endDate != null &&
        endDate!.isBefore(selected)) {
      endDate = null;
    }

    notifyListeners();
  }

  void setEndDate(DateTime selected) {
    endDate = selected;

    notifyListeners();
  }

  String? formatDateForApi(
    DateTime? date,
  ) {
    if (date == null) {
      return null;
    }

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String formatDateDisplay(
    DateTime? date,
  ) {
    if (date == null) {
      return 'dd/mm/yyyy';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String getCategorySubtitle() {
    switch (selectedCategory) {
      case 'SNI — Nikkei Jepang':
        return 'Indeks Nikkei Jepang';

      case 'HSI — Hang Seng Hong Kong':
        return 'Indeks Hang Seng Hong Kong';

      default:
        return 'Harga emas LGD Daily';
    }
  }

  String getValue(
    HistoricalDataModel item,
    String key,
  ) {
    dynamic value;

    switch (key) {
      case 'tanggal':
        value = item.tanggal;
        break;

      case 'open':
        value = item.open;
        break;

      case 'high':
        value = item.high;
        break;

      case 'low':
        value = item.low;
        break;

      case 'close':
        value = item.close;
        break;

      default:
        value = null;
    }

    if (value == null) {
      return '-';
    }

    if (value.toString().trim().isEmpty) {
      return '-';
    }

    return value.toString();
  }

  int get totalPages {
    if (historicalData.isEmpty) {
      return 1;
    }

    return (
      historicalData.length / itemsPerPage
    ).ceil();
  }

  List<HistoricalDataModel> get pageData {
    final int start =
        (currentPage - 1) * itemsPerPage;

    if (start >= historicalData.length) {
      return [];
    }

    final int end =
        (start + itemsPerPage)
            .clamp(0, historicalData.length);

    return historicalData.sublist(
      start,
      end,
    );
  }

  void previousPage() {
    if (currentPage <= 1) {
      return;
    }

    currentPage--;

    notifyListeners();
  }

  void nextPage() {
    if (currentPage >= totalPages) {
      return;
    }

    currentPage++;

    notifyListeners();
  }

  String formatTableDate(
    String value,
  ) {
    if (value == '-') {
      return '-';
    }

    try {
      final DateTime date =
          DateTime.parse(value);

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return value;
    }
  }
}