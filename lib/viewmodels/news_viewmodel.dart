
import 'package:flutter/foundation.dart';

import '../models/news_model.dart';
import '../repositories/news_repository.dart';

enum NewsFilter {
  terpopuler,
  hariIni,
  seminggu,
  sebulan,
}

class NewsViewModel extends ChangeNotifier {
  final NewsRepository _repository;

  NewsViewModel({
    NewsRepository? repository,
  }) : _repository = repository ?? NewsRepository();

  List<NewsModel> _news = [];
  bool _isLoading = false;
  String? _errorMessage;
  NewsFilter _selectedFilter = NewsFilter.terpopuler;

  List<NewsModel> get news => _news;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  NewsFilter get selectedFilter => _selectedFilter;

  List<NewsModel> get filteredNews {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedFilter) {
      case NewsFilter.terpopuler:
        // Mempertahankan urutan dari sumber berita.
        // Belum menunjukkan popularitas yang terverifikasi.
        return List<NewsModel>.from(_news);

      case NewsFilter.hariIni:
        return _news.where((item) {
          final date = item.publishedAt?.toLocal();
          if (date == null) return false;

          return !date.isBefore(today) &&
              date.isBefore(today.add(const Duration(days: 1)));
        }).toList();

      case NewsFilter.seminggu:
        return _filterByPeriod(now, 7);

      case NewsFilter.sebulan:
        return _filterByPeriod(now, 30);
    }
  }

  List<NewsModel> _filterByPeriod(DateTime now, int days) {
    final startDate = now.subtract(Duration(days: days));

    return _news.where((item) {
      final date = item.publishedAt?.toLocal();
      if (date == null) return false;

      return !date.isBefore(startDate) &&
          !date.isAfter(now);
    }).toList();
  }

  void setFilter(NewsFilter filter) {
    if (_selectedFilter == filter) return;

    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> loadNews() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _news = await _repository.getMarketNews();
    } catch (e) {
      _errorMessage =
          'Gagal memuat berita. Periksa koneksi dan coba lagi.';
      debugPrint('ERROR NEWS VIEWMODEL: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}