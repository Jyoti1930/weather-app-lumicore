import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_local_data_source.dart';
import '../datasources/weather_remote_data_source.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;
  final WeatherLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  WeatherRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<WeatherResult> getCurrentWeather(String cityName) async {
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      return _fallbackToCache(
        const NetworkFailure(
          'No internet connection. Showing last saved weather, if available.',
        ),
      );
    }

    try {
      final weather = await remoteDataSource.getCurrentWeather(cityName);
      await localDataSource.cacheWeather(weather);
      await localDataSource.addRecentSearch(weather.cityName);
      return WeatherSuccess(weather);
    } on CityNotFoundException catch (e) {
      // Don't fall back to cache here — the user typed something invalid,
      // showing stale data for a different city would be misleading.
      return WeatherError(CityNotFoundFailure(e.message));
    } on RateLimitException catch (e) {
      return WeatherError(RateLimitFailure(e.message));
    } on ServerException catch (e) {
      return _fallbackToCache(ServerFailure(e.message));
    } catch (e) {
      return _fallbackToCache(UnknownFailure('Something went wrong: $e'));
    }
  }

  Future<WeatherResult> _fallbackToCache(Failure originalFailure) async {
    try {
      final cached = await localDataSource.getLastCachedWeather();
      return WeatherSuccess(
        cached,
        isFromCache: true,
        cacheMessage: originalFailure.message,
      );
    } on CacheException {
      return WeatherError(originalFailure);
    }
  }

  @override
  Future<List<String>> getRecentSearches() async {
    try {
      return await localDataSource.getRecentSearches();
    } on CacheException {
      return [];
    }
  }

  @override
  Future<WeatherResult?> loadCachedWeatherOnStartup() async {
    final isConnected = await networkInfo.isConnected;
    if (isConnected) return null;

    try {
      final cached = await localDataSource.getLastCachedWeather();
      return WeatherSuccess(
        cached,
        isFromCache: true,
        cacheMessage: 'No internet connection. Showing last saved weather.',
      );
    } on CacheException {
      return null;
    }
  }
}
