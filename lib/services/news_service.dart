import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  static const String _baseUrl =
      'http://192.168.1.47:3000/api/news';

  static Future<List<Map<String, dynamic>>> getMarketNews() async {
    try {
      final response = await http
          .get(
            Uri.parse(_baseUrl),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal mengambil berita (HTTP ${response.statusCode}).',
        );
      }

      final Map<String, dynamic> decoded =
          jsonDecode(response.body);

      if (decoded['success'] != true || decoded['data'] is! List) {
        throw Exception('Format data Market News tidak valid.');
      }

      return (decoded['data'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (e) {
      print('ERROR MARKET NEWS: $e');
      rethrow;
    }
  }
}