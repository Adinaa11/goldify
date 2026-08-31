import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class MarketService {
  // AMBIL DATA DARI API
  static Future<List<Map<String, dynamic>>> _fetchGoldData() async {
    try {
      final Uri uri = Uri.parse(
        ApiConfig.historicalGold,
      );

      print('========================================');
      print('REQUEST DATA GOLD');
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

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Response API bukan object JSON.',
        );
      }

      // AMBIL DATA
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

      // FILTER LGD DAILY
      final List<Map<String, dynamic>> goldData = rawData
          .where((item) {
            if (item is! Map) {
              return false;
            }

            final category = item['category']
                ?.toString()
                .trim()
                .toLowerCase();

            return category == 'lgd daily';
          })
          .map(
            (item) => Map<String, dynamic>.from(
              item as Map,
            ),
          )
          .toList();

      print(
        'JUMLAH DATA LGD DAILY : ${goldData.length}',
      );

      if (goldData.isEmpty) {
        throw Exception(
          'Data LGD Daily tidak ditemukan.',
        );
      }

      // SORT BARU KE LAMA
      goldData.sort((a, b) {
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
              .compareTo(DateTime.parse(dateA));
        } catch (_) {
          return dateB.compareTo(dateA);
        }
      });

      return goldData;
    } catch (error) {
      print('========================================');
      print('ERROR MARKET SERVICE');
      print(error);
      print('========================================');

      rethrow;
    }
  }

  // DATA BARU PP
  static Future<Map<String, dynamic>> getLatestGoldData({
    String? date,
  }) async {
    final List<Map<String, dynamic>> goldData =
        await _fetchGoldData();

    // Jika user memilih tanggal
    if (date != null && date.trim().isNotEmpty) {
      final String selectedDate = date.trim();

      final selectedData = goldData.where(
        (item) {
          final itemDate =
              item['tanggal']?.toString().trim();

          return itemDate == selectedDate;
        },
      ).toList();

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

  // DATA HISTORIS BERANDA
  static Future<List<Map<String, dynamic>>>
      getHistoricalGoldData({
    String? startDate,
    String? endDate,
  }) async {
    final List<Map<String, dynamic>> goldData =
        await _fetchGoldData();

    // FILTER TANGGAL AWAL
    List<Map<String, dynamic>> result =
        goldData;

    if (startDate != null &&
        startDate.trim().isNotEmpty) {
      final DateTime start =
          DateTime.parse(startDate.trim());

      result = result.where((item) {
        final String? tanggal =
            item['tanggal']?.toString();

        if (tanggal == null) {
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

        if (tanggal == null) {
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
      'DATA HISTORIS DIKEMBALIKAN : ${result.length}',
    );

    return result;
  }
}