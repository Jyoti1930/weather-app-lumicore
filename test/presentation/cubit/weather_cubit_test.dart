import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/core/error/failures.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';
import 'package:weather_app/domain/usecases/get_initial_weather_usecase.dart';
import 'package:weather_app/domain/usecases/get_recent_searches_usecase.dart';
import 'package:weather_app/domain/usecases/get_weather_usecase.dart';
import 'package:weather_app/presentation/cubit/weather_cubit.dart';
import 'package:weather_app/presentation/cubit/weather_state.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockWeatherRepository repository;
  late GetWeatherUseCase getWeatherUseCase;
  late GetRecentSearchesUseCase getRecentSearchesUseCase;
  late GetInitialWeatherUseCase getInitialWeatherUseCase;

  setUp(() {
    repository = MockWeatherRepository();
    getWeatherUseCase = GetWeatherUseCase(repository);
    getRecentSearchesUseCase = GetRecentSearchesUseCase(repository);
    getInitialWeatherUseCase = GetInitialWeatherUseCase(repository);

    // Default stub so the cubit's constructor-time call succeeds in every test.
    when(() => repository.getRecentSearches()).thenAnswer((_) async => []);
    when(() => repository.loadCachedWeatherOnStartup())
        .thenAnswer((_) async => null);
  });

  WeatherCubit buildCubit() => WeatherCubit(
        getWeatherUseCase: getWeatherUseCase,
        getRecentSearchesUseCase: getRecentSearchesUseCase,
        getInitialWeatherUseCase: getInitialWeatherUseCase,
      );

  blocTest<WeatherCubit, WeatherState>(
    'emits [WeatherLoading, WeatherLoaded] when search succeeds',
    setUp: () {
      when(() => repository.getCurrentWeather('Dubai'))
          .thenAnswer((_) async => WeatherSuccess(testWeather));
    },
    build: buildCubit,
    act: (cubit) => cubit.searchCity('Dubai'),
    expect: () => [
      isA<WeatherLoading>(),
      isA<WeatherLoaded>().having((s) => s.weather.cityName, 'cityName', 'Dubai'),
    ],
  );

  blocTest<WeatherCubit, WeatherState>(
    'emits [WeatherLoading, WeatherFailure] when search fails',
    setUp: () {
      when(() => repository.getCurrentWeather('Unknownville')).thenAnswer(
        (_) async => WeatherError(const CityNotFoundFailure('City not found.')),
      );
    },
    build: buildCubit,
    act: (cubit) => cubit.searchCity('Unknownville'),
    expect: () => [
      isA<WeatherLoading>(),
      isA<WeatherFailure>(),
    ],
  );

  blocTest<WeatherCubit, WeatherState>(
    'ignores a search call while one is already in flight',
    setUp: () {
      when(() => repository.getCurrentWeather('Dubai')).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return WeatherSuccess(testWeather);
      });
    },
    build: buildCubit,
    act: (cubit) {
      cubit.searchCity('Dubai');
      cubit.searchCity('Dubai'); // duplicate while first is in flight
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      isA<WeatherLoading>(),
      isA<WeatherLoaded>(),
    ],
    verify: (_) {
      verify(() => repository.getCurrentWeather('Dubai')).called(1);
    },
  );

  blocTest<WeatherCubit, WeatherState>(
    'does nothing on an empty city name',
    build: buildCubit,
    act: (cubit) => cubit.searchCity('   '),
    expect: () => <WeatherState>[],
  );

  blocTest<WeatherCubit, WeatherState>(
    'emits cached weather on startup when offline and a cache exists',
    setUp: () {
      when(() => repository.loadCachedWeatherOnStartup()).thenAnswer(
        (_) async => WeatherSuccess(
          testWeather,
          isFromCache: true,
          cacheMessage: 'No internet connection. Showing last saved weather.',
        ),
      );
    },
    build: buildCubit,
    expect: () => [
      isA<WeatherLoaded>()
          .having((s) => s.isFromCache, 'isFromCache', true)
          .having((s) => s.weather.cityName, 'cityName', 'Dubai'),
    ],
  );

  blocTest<WeatherCubit, WeatherState>(
    'stays in initial state on startup when online (nothing to preload)',
    // loadCachedWeatherOnStartup already stubbed to return null in setUp().
    build: buildCubit,
    expect: () => <WeatherState>[],
  );
}
