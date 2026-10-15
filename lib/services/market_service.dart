import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class MarketService {
  static const String liveQuotesUrl =
      'https://www.newsmaker.id/api/live-quotes';

  static String _normalizeCategory(String category) {
    final String value =
        category.trim().toLowerCase();

    // GOLD
    if (value == 'lgd daily') {
      return 'lgd daily';
    }

    // HANG SENG
    if (value == 'hsi daily' ||
        value == 'hsi — hang seng hong kong' ||
        value == 'hsi - hang seng hong kong' ||
        value == 'hang seng hong kong') {
      return 'hsi daily';
    }

    if (value == 'sni — nikkei jepang' ||
        value == 'sni - nikkei jepang' ||
        value == 'sni daily' ||
        value == 'nikkei daily' ||
        value == 'nikkei jepang' ||
        value == 'nikkei') {
      return 'sni';
    }

    return value;
  }

  static bool _isSameCategory(
    dynamic itemCategory,
    String requestedCategory,
  ) {
    if (itemCategory == null) {
      return false;
    }

    final String apiCategory =
        itemCategory.toString().trim().toLowerCase();

    final String normalizedRequested =
        _normalizeCategory(requestedCategory);

    // GOLD
    if (normalizedRequested == 'lgd daily') {
      return apiCategory == 'lgd daily';
    }

    // HANG SENG
    if (normalizedRequested == 'hsi daily') {
      return apiCategory == 'hsi daily';
    }

    // NIKKEI / SNI
    if (normalizedRequested == 'sni') {
      return apiCategory == 'sni' ||
          apiCategory == 'sni daily' ||
          apiCategory == 'nikkei' ||
          apiCategory == 'nikkei daily' ||
          apiCategory == 'nikkei jepang' ||
          apiCategory == 'nikkei japan';
    }

    return apiCategory == normalizedRequested;
  }

  // ============================================================
  // LIVE QUOTES
  // ============================================================

  static Future<List<Map<String, dynamic>>>
      _fetchLiveQuotes() async {
    try {
      final response = await http
          .get(
            Uri.parse(liveQuotesUrl),
            headers: const {
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal mengambil live quotes.',
        );
      }

      final Map<String, dynamic> decoded =
          jsonDecode(response.body);

      final dynamic raw = decoded['data'];

      if (raw is! List) {
        throw Exception(
          'Format live quotes tidak valid.',
        );
      }

      return raw
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();
    } catch (e) {
      print('ERROR LIVE QUOTES: $e');
      rethrow;
    }
  }

  // HISTORICAL DATA
  static Future<List<Map<String, dynamic>>>
      _fetchHistoricalData() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              ApiConfig.historicalGold,
            ),
            headers: const {
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal mengambil historical data.',
        );
      }

      final decoded = jsonDecode(response.body);

      dynamic raw = decoded['data'];

      if (raw is Map) {
        raw = raw['data'];
      }

      if (raw is! List) {
        throw Exception(
          'Format historical tidak valid.',
        );
      }

      return raw
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();
    } catch (e) {
      print('ERROR HISTORICAL: $e');
      rethrow;
    }
  }

  static Map<String, dynamic>?
      _findHistoricalData({
    required List<Map<String, dynamic>> data,
    required String date,
    required String category,
  }) {
    for (final item in data) {
      final String itemDate =
          item['tanggal']
                  ?.toString()
                  .trim() ??
              '';

      final bool sameCategory =
          _isSameCategory(
        item['category'],
        category,
      );

      if (itemDate == date &&
          sameCategory) {
        return item;
      }
    }
    return null;
  }

  static Map<String, dynamic>?
      _findPreviousHistoricalData({
    required List<Map<String, dynamic>> data,
    required String date,
    required String category,
  }) {
    final List<Map<String, dynamic>> filtered =
        data.where((item) {
      return _isSameCategory(
        item['category'],
        category,
      );
    }).toList();

    filtered.sort((a, b) {
      final String dateA =
          a['tanggal']
                  ?.toString()
                  .trim() ??
              '';

      final String dateB =
          b['tanggal']
                  ?.toString()
                  .trim() ??
              '';

      return dateB.compareTo(dateA);
    });

    for (final item in filtered) {
      final String itemDate =
          item['tanggal']
                  ?.toString()
                  .trim() ??
              '';

      if (itemDate.compareTo(date) < 0) {
        return item;
      }
    }

    return null;
  }

  static Map<String, dynamic>?
      _findNextHistoricalData({
    required List<Map<String, dynamic>> data,
    required String date,
    required String category,
  }) {
    final List<Map<String, dynamic>> filtered =
        data.where((item) {
      return _isSameCategory(
        item['category'],
        category,
      );
    }).toList();

    filtered.sort((a, b) {
      final String dateA =
          a['tanggal']
                  ?.toString()
                  .trim() ??
              '';

      final String dateB =
          b['tanggal']
                  ?.toString()
                  .trim() ??
              '';

      return dateA.compareTo(dateB);
    });

    for (final item in filtered) {
      final String itemDate =
          item['tanggal']
                  ?.toString()
                  .trim() ??
              '';

      if (itemDate.compareTo(date) > 0) {
        return item;
      }
    }

    return null;
  }

  static String _getLiveDate(
    Map<String, dynamic> liveData,
  ) {
    final String dateTime =
        liveData['date_time']
                ?.toString()
                .trim() ??
            '';

    if (dateTime.length >= 10) {
      return dateTime.substring(0, 10);
    }

    final String serverDateTime =
        liveData['serverDateTime']
                ?.toString()
                .trim() ??
            '';

    if (serverDateTime.length >= 10) {
      return serverDateTime.substring(0, 10);
    }

    return '';
  }

  // GOLD XUL10
  static Future<Map<String, dynamic>>
      getLatestGoldData({
    String? date,
  }) async {
    final historical =
        await _fetchHistoricalData();

    if (date != null &&
        date.trim().isNotEmpty) {
      final String selectedDate =
          date.trim();

      final selected =
          _findHistoricalData(
        data: historical,
        date: selectedDate,
        category: 'LGD Daily',
      );

      if (selected == null) {
        throw Exception(
          'Data Gold tanggal '
          '$selectedDate tidak ditemukan.',
        );
      }

      final dynamic high =
          selected['high'];

      final dynamic low =
          selected['low'];

      final dynamic close =
          selected['close'];

      final next =
          _findNextHistoricalData(
        data: historical,
        date: selectedDate,
        category: 'LGD Daily',
      );

      if (next == null) {
        throw Exception(
          'Data Gold setelah tanggal '
          '$selectedDate tidak ditemukan.',
        );
      }

      return {
        'open': next['open'],
        'high': high,
        'low': low,
        'close': close,
        'tanggal': selected['tanggal'],
        'ohlcDate': selected['tanggal'],
      };
    }

    final live =
        await _fetchLiveQuotes();

    final gold = live.firstWhere(
      (item) => item['symbol'] == 'XUL10',
      orElse: () => {},
    );

    if (gold.isEmpty) {
      throw Exception(
        'Data Gold XUL10 tidak ditemukan.',
      );
    }

    final String liveDate =
        _getLiveDate(gold);

    if (liveDate.isEmpty) {
      throw Exception(
        'Tanggal live Gold tidak tersedia.',
      );
    }

    final previous =
        _findPreviousHistoricalData(
      data: historical,
      date: liveDate,
      category: 'LGD Daily',
    );

    if (previous == null) {
      throw Exception(
        'Historical Gold sebelum tanggal '
        '$liveDate tidak ditemukan.',
      );
    }

    return {
      'open': gold['open'],
      'high': previous['high'],
      'low': previous['low'],
      'close': previous['close'],
      'tanggal': gold['date_time'],
      'ohlcDate': previous['tanggal'],
    };
  }

  static Future<Map<String, dynamic>>
      getLatestHangsengData({
    String? date,
  }) async {
    final historical =
        await _fetchHistoricalData();

    if (date != null &&
        date.trim().isNotEmpty) {
      final String selectedDate =
          date.trim();

      final selected =
          _findHistoricalData(
        data: historical,
        date: selectedDate,
        category: 'HSI Daily',
      );

      if (selected == null) {
        throw Exception(
          'Data Hangseng tanggal '
          '$selectedDate tidak ditemukan.',
        );
      }

      final dynamic high =
          selected['high'];

      final dynamic low =
          selected['low'];

      final dynamic close =
          selected['close'];

      final next =
          _findNextHistoricalData(
        data: historical,
        date: selectedDate,
        category: 'HSI Daily',
      );

      if (next == null) {
        throw Exception(
          'Data Hangseng setelah tanggal '
          '$selectedDate tidak ditemukan.',
        );
      }

      return {
        'open': next['open'],
        'high': high,
        'low': low,
        'close': close,
        'tanggal': selected['tanggal'],
        'ohlcDate': selected['tanggal'],
      };
    }

    final live =
        await _fetchLiveQuotes();

    final hangseng = live.firstWhere(
      (item) =>
          item['symbol'] == 'HKK50_BBJ',
      orElse: () => {},
    );

    if (hangseng.isEmpty) {
      throw Exception(
        'Data Hangseng HKK50_BBJ '
        'tidak ditemukan.',
      );
    }

    final String liveDate =
        _getLiveDate(hangseng);

    if (liveDate.isEmpty) {
      throw Exception(
        'Tanggal live Hangseng '
        'tidak tersedia.',
      );
    }

    final previous =
        _findPreviousHistoricalData(
      data: historical,
      date: liveDate,
      category: 'HSI Daily',
    );

    if (previous == null) {
      throw Exception(
        'Historical Hangseng sebelum tanggal '
        '$liveDate tidak ditemukan.',
      );
    }

    return {
      'open': hangseng['open'],
      'high': previous['high'],
      'low': previous['low'],
      'close': previous['close'],
      'tanggal': hangseng['date_time'],
      'ohlcDate': previous['tanggal'],
    };
  }

  static Future<List<Map<String, dynamic>>>
      getHistoricalMarketData({
    required String category,
    String? startDate,
    String? endDate,
  }) async {
    final historical =
        await _fetchHistoricalData();

    List<Map<String, dynamic>> result =
        historical.where((item) {
      return _isSameCategory(
        item['category'],
        category,
      );
    }).toList();

    if (startDate != null &&
        startDate.trim().isNotEmpty) {
      result = result.where((item) {
        final String tanggal =
            item['tanggal']
                    ?.toString()
                    .trim() ??
                '';

        return tanggal.compareTo(
              startDate.trim(),
            ) >=
            0;
      }).toList();
    }

    if (endDate != null &&
        endDate.trim().isNotEmpty) {
      result = result.where((item) {
        final String tanggal =
            item['tanggal']
                    ?.toString()
                    .trim() ??
                '';

        return tanggal.compareTo(
              endDate.trim(),
            ) <=
            0;
      }).toList();
    }

    result.sort((a, b) {
      final String dateA =
          a['tanggal']
                  ?.toString()
                  .trim() ??
              '';

      final String dateB =
          b['tanggal']
                  ?.toString()
                  .trim() ??
              '';

      return dateB.compareTo(dateA);
    });

    return result;
  }

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

  static Future<List<Map<String, dynamic>>>
      getHistoricalHangsengData({
    String? startDate,
    String? endDate,
  }) async {
    return getHistoricalMarketData(
      category: 'HSI Daily',
      startDate: startDate,
      endDate: endDate,
    );
  }

  static Future<List<Map<String, dynamic>>>
      getHistoricalSniData({
    String? startDate,
    String? endDate,
  }) async {
    return getHistoricalMarketData(
      category: 'SNI — Nikkei Jepang',
      startDate: startDate,
      endDate: endDate,
    );
  }
}