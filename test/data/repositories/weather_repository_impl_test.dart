import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/core/error/exceptions.dart';
import 'package:weather_app/data/repositories/weather_repository_impl.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';

import '../../helpers/mocks.dart';

void main() {
  late WeatherRepositoryImpl repository;
  late MockWeatherRemoteDataSource remoteDataSource;
  late MockWeatherLocalDataSource localDataSource;
  late MockNetworkInfo networkInfo;

  setUpAll(() {
    registerFallbackValue(testWeather);
  });

  setUp(() {
    remoteDataSource = MockWeatherRemoteDataSource();
    localDataSource = MockWeatherLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = WeatherRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
    );
  });

  group('getCurrentWeather', () {
    test('returns WeatherSuccess (not from cache) and caches data on success', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remoteDataSource.getCurrentWeather('Dubai'))
          .thenAnswer((_) async => testWeather);
      when(() => localDataSource.cacheWeather(any())).thenAnswer((_) async {});
      when(() => localDataSource.addRecentSearch(any())).thenAnswer((_) async {});

      final result = await repository.getCurrentWeather('Dubai');

      expect(result, isA<WeatherSuccess>());
      final success = result as WeatherSuccess;
      expect(success.weather.cityName, 'Dubai');
      expect(success.isFromCache, false);
      verify(() => localDataSource.cacheWeather(testWeather)).called(1);
      verify(() => localDataSource.addRecentSearch('Dubai')).called(1);
    });

    test('returns WeatherError with CityNotFoundFailure for an invalid city', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remoteDataSource.getCurrentWeather('Unknownville'))
          .thenThrow(CityNotFoundException('City not found.'));

      final result = await repository.getCurrentWeather('Unknownville');

      expect(result, isA<WeatherError>());
      verifyNever(() => localDataSource.getLastCachedWeather());
    });

    test('falls back to cached data when offline and a cache exists', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => localDataSource.getLastCachedWeather())
          .thenAnswer((_) async => testWeather);

      final result = await repository.getCurrentWeather('Dubai');

      expect(result, isA<WeatherSuccess>());
      final success = result as WeatherSuccess;
      expect(success.isFromCache, true);
      expect(success.weather.cityName, 'Dubai');
    });

    test('returns WeatherError when offline and no cache exists', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => localDataSource.getLastCachedWeather())
          .thenThrow(CacheException('No cached weather data found.'));

      final result = await repository.getCurrentWeather('Dubai');

      expect(result, isA<WeatherError>());
    });

    test('falls back to cache on server error when online', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remoteDataSource.getCurrentWeather('Dubai'))
          .thenThrow(ServerException('Server unavailable.'));
      when(() => localDataSource.getLastCachedWeather())
          .thenAnswer((_) async => testWeather);

      final result = await repository.getCurrentWeather('Dubai');

      expect(result, isA<WeatherSuccess>());
      expect((result as WeatherSuccess).isFromCache, true);
    });
  });
  group('loadCachedWeatherOnStartup', () {
    test('returns cached WeatherSuccess when offline and a cache exists', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => localDataSource.getLastCachedWeather())
          .thenAnswer((_) async => testWeather);

      final result = await repository.loadCachedWeatherOnStartup();

      expect(result, isA<WeatherSuccess>());
      final success = result as WeatherSuccess;
      expect(success.isFromCache, true);
      expect(success.weather.cityName, 'Dubai');
    });

    test('returns null when offline and no cache exists', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => localDataSource.getLastCachedWeather())
          .thenThrow(CacheException('No cached weather data found.'));

      final result = await repository.loadCachedWeatherOnStartup();

      expect(result, isNull);
    });

    test('returns null when online (nothing to preload)', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);

      final result = await repository.loadCachedWeatherOnStartup();

      expect(result, isNull);
      verifyNever(() => localDataSource.getLastCachedWeather());
    });
  });
}
