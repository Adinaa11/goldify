class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://www.newsmaker.id',
  );

  static const String historicalGold =
      '$baseUrl/api/historical-data';
}