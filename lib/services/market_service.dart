import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class MarketService {
  static String _normalizeCategory(dynamic value) {
    return value
        ?.toString()
        .trim()
        .toLowerCase()
        .replaceAll('—', '-')
        .replaceAll('–', '-')
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s+'), ' ') ?? '';
  }

  static bool _categoryMatches(
    dynamic apiCategory,
    String selectedCategory,
  ) {
    final String category =
        _normalizeCategory(apiCategory);

    final String selected =
        _normalizeCategory(selectedCategory);

    if (selected == 'lgd daily') {
      return category == 'lgd daily' ||
          category == 'lgd';
    }

    if (selected.contains('sni')) {
      return category.contains('sni') ||
          category.contains('nikkei');
    }

    if (selected.contains('hsi')) {
      return category.contains('hsi') ||
          category.contains('hang seng');
    }

    return category == selected;
  }

  static Future<List<Map<String, dynamic>>>
      _fetchMarketData({
    required String category,
  }) async {
    try {
      final Uri uri = Uri.parse(
        ApiConfig.historicalGold,
      );

      print('========================================');
      print('REQUEST DATA MARKET');
      print('CATEGORY : $category');
      print('URL : $uri');
      print('========================================');

      final response = await http
          .get(
            uri,
            headers: const {
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 15),
          );

      print('STATUS : ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal mengambil data dari API '
          '(status ${response.statusCode}).',
        );
      }

      final dynamic decoded =
          jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Response API bukan object JSON.',
        );
      }

      dynamic rawData = decoded['data'];

      if (rawData is Map) {
        rawData = rawData['data'];
      }

      if (rawData is! List) {
        throw Exception(
          'Format data API tidak valid. '
          'Data bukan berupa List.',
        );
      }

      // TAMPILKAN CATEGORY YANG TERSEDIA DI API
      final Set<String> availableCategories = {};

      for (final item in rawData) {
        if (item is Map) {
          final value = item['category'];

          if (value != null &&
              value.toString().trim().isNotEmpty) {
            availableCategories.add(
              value.toString().trim(),
            );
          }
        }
      }

      print(
        'CATEGORY YANG TERSEDIA DI API: '
        '$availableCategories',
      );

      final List<Map<String, dynamic>> result =
          rawData
              .where((item) {
                if (item is! Map) {
                  return false;
                }

                return _categoryMatches(
                  item['category'],
                  category,
                );
              })
              .map(
                (item) => Map<String, dynamic>.from(
                  item as Map,
                ),
              )
              .toList();

      print(
        'JUMLAH DATA $category : ${result.length}',
      );

      if (result.isEmpty) {
        throw Exception(
          'Data $category tidak ditemukan di API.',
        );
      }

      // SORT BARU KE LAMA
      result.sort((a, b) {
        final String? dateA =
            a['tanggal']?.toString();

        final String? dateB =
            b['tanggal']?.toString();

        if (dateA == null || dateA.isEmpty) {
          return 1;
        }

        if (dateB == null || dateB.isEmpty) {
          return -1;
        }

        try {
          return DateTime.parse(dateB)
              .compareTo(
            DateTime.parse(dateA),
          );
        } catch (_) {
          return dateB.compareTo(dateA);
        }
      });

      return result;
    } catch (error) {
      print('========================================');
      print('ERROR MARKET SERVICE');
      print(error);
      print('========================================');

      rethrow;
    }
  }

  // =========================================================
  // DATA LGD DAILY
  // =========================================================

  static Future<List<Map<String, dynamic>>>
      _fetchGoldData() async {
    return _fetchMarketData(
      category: 'LGD Daily',
    );
  }

  // =========================================================
  // DATA TERBARU UNTUK PIVOT POINT
  // =========================================================

  static Future<Map<String, dynamic>>
      getLatestGoldData({
    String? date,
  }) async {
    final List<Map<String, dynamic>> goldData =
        await _fetchGoldData();

    if (date != null &&
        date.trim().isNotEmpty) {
      final String selectedDate =
          date.trim();

      final selectedData =
          goldData.where((item) {
        final String? itemDate =
            item['tanggal']
                ?.toString()
                .trim();

        return itemDate == selectedDate;
      }).toList();

      if (selectedData.isEmpty) {
        throw Exception(
          'Data LGD Daily untuk tanggal '
          '$selectedDate tidak ditemukan.',
        );
      }

      return selectedData.first;
    }

    return goldData.first;
  }

  // =========================================================
  // DATA HISTORIS MARKET
  // =========================================================

  static Future<List<Map<String, dynamic>>>
      getHistoricalMarketData({
    required String category,
    String? startDate,
    String? endDate,
  }) async {
    final List<Map<String, dynamic>> marketData =
        await _fetchMarketData(
      category: category,
    );

    List<Map<String, dynamic>> result =
        marketData;

    // FILTER TANGGAL AWAL
    if (startDate != null &&
        startDate.trim().isNotEmpty) {
      final DateTime start =
          DateTime.parse(startDate.trim());

      result = result.where((item) {
        final String? tanggal =
            item['tanggal']?.toString();

        if (tanggal == null ||
            tanggal.isEmpty) {
          return false;
        }

        try {
          final DateTime itemDate =
              DateTime.parse(tanggal);

          return !itemDate.isBefore(start);
        } catch (_) {
          return false;
        }
      }).toList();
    }

    // FILTER TANGGAL AKHIR
    if (endDate != null &&
        endDate.trim().isNotEmpty) {
      final DateTime end =
          DateTime.parse(endDate.trim());

      result = result.where((item) {
        final String? tanggal =
            item['tanggal']?.toString();

        if (tanggal == null ||
            tanggal.isEmpty) {
          return false;
        }

        try {
          final DateTime itemDate =
              DateTime.parse(tanggal);

          return !itemDate.isAfter(end);
        } catch (_) {
          return false;
        }
      }).toList();
    }

    print(
      'DATA HISTORIS $category '
      'DIKEMBALIKAN : ${result.length}',
    );

    return result;
  }

  // =========================================================
  // BACKWARD COMPATIBILITY
  // =========================================================

  static Future<List<Map<String, dynamic>>>
      getHistoricalGoldData({
    String? startDate,
    String? endDate,
  }) async {
    return getHistoricalMarketData(
      category: 'LGD Daily',
      startDate: startDate,
      endDate: endDate,
    );
  }
}