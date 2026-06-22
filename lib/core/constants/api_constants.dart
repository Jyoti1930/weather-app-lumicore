class ApiConstants {
  ApiConstants._();

  /// Get a free key at https://www.weatherapi.com/
  /// Replace this before running the app.
  static const String apiKey = '3804ddc050504d8c87f142324261906';

  static const String baseUrl = 'https://api.weatherapi.com/v1';
  static const String currentWeatherEndpoint = '/current.json';

  static const int connectTimeoutSeconds = 10;
  static const int receiveTimeoutSeconds = 10;
}
