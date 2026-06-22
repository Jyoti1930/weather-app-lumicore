import '../../core/error/failures.dart';
import '../entities/weather_entity.dart';

/// Sealed-style result returned from the repository so the presentation
/// layer can distinguish between a clean success, a cache fallback, and
/// a hard failure — without relying on exceptions for control flow.
sealed class WeatherResult {}

class WeatherSuccess extends WeatherResult {
  final WeatherEntity weather;
  final bool isFromCache;
  final String? cacheMessage;

  WeatherSuccess(
    this.weather, {
    this.isFromCache = false,
    this.cacheMessage,
  });
}

class WeatherError extends WeatherResult {
  final Failure failure;

  WeatherError(this.failure);
}

abstract class WeatherRepository {
  Future<WeatherResult> getCurrentWeather(String cityName);
  Future<List<String>> getRecentSearches();
  Future<WeatherResult?> loadCachedWeatherOnStartup();

}
