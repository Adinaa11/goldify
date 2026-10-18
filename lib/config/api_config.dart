class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://goldify-backend.onrender.com',
  );

  static const String liveQuotes =
      '$baseUrl/api/live-quotes';

  static const String historicalGold =
      '$baseUrl/api/market/gold';
}