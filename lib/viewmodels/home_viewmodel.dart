import 'package:flutter/material.dart';

import '../repositories/home_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository repository;

  HomeViewModel(this.repository);

  String _userName = '';
  String get userName => _userName;

  late Future<List<Map<String, dynamic>>>
      _historicalGoldFuture;

  Future<List<Map<String, dynamic>>>
      get historicalGoldFuture =>
          _historicalGoldFuture;

  bool _loadingUserName = false;
  bool get loadingUserName =>
      _loadingUserName;

  Future<void> loadHomeData() async {
    await Future.wait([
      loadUserName(),
      loadHistoricalData(),
    ]);
  }

  Future<void> loadUserName() async {
    _loadingUserName = true;
    notifyListeners();

    try {
      _userName =
          await repository.getUserName();
    } catch (e) {
      debugPrint(
        'Gagal mengambil nama dari profiles: $e',
      );

      _userName = '';
    } finally {
      _loadingUserName = false;
      notifyListeners();
    }
  }

  Future<void> loadHistoricalData() async {
    _historicalGoldFuture =
        repository.getHistoricalGoldData();

    notifyListeners();

    try {
      await _historicalGoldFuture;
    } catch (e) {
      debugPrint(
        'Gagal mengambil historical gold data: $e',
      );
    }
  }

  Future<void> refreshHistoricalData() async {
    await loadHistoricalData();
  }
}