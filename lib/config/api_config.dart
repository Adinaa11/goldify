
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3000',
  );

  static const String liveQuotes =
      '$baseUrl/api/live-quotes';

  static const String historicalGold =
      '$baseUrl/api/market/gold';
}
