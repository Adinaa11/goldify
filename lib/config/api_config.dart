class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://www.newsmaker.id',
  );

  static const String liveQuotes =
      '$baseUrl/api/live-quotes';

  static const String historicalGold =
      '$baseUrl/api/historical-data';
}