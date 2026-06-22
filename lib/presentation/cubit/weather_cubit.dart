import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/usecases/get_recent_searches_usecase.dart';
import '../../domain/usecases/get_weather_usecase.dart';
import '../../domain/usecases/get_initial_weather_usecase.dart';
import 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final GetWeatherUseCase getWeatherUseCase;
  final GetRecentSearchesUseCase getRecentSearchesUseCase;
  final GetInitialWeatherUseCase getInitialWeatherUseCase;

  bool _isFetching = false;

  WeatherCubit({
    required this.getWeatherUseCase,
    required this.getRecentSearchesUseCase,
    required this.getInitialWeatherUseCase,
  }) : super(const WeatherInitial()) {
        _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    final searches = await getRecentSearchesUseCase();
    if (searches.isNotEmpty) {
      emit(WeatherInitial(recentSearches: searches));
    }

    final initialResult = await getInitialWeatherUseCase();
    if (initialResult is WeatherSuccess) {
      emit(WeatherLoaded(
        weather: initialResult.weather,
        isFromCache: initialResult.isFromCache,
        cacheMessage: initialResult.cacheMessage,
        recentSearches: searches,
      ));
    }
  }

  /// Searches weather for [cityName]. Ignores calls while a request is
  /// already in flight to prevent duplicate/overlapping requests.
  Future<void> searchCity(String cityName) async {
    if (_isFetching) return;
    final trimmed = cityName.trim();
    if (trimmed.isEmpty) return;

    _isFetching = true;
    emit(WeatherLoading(recentSearches: state.recentSearches));

    final result = await getWeatherUseCase(trimmed);
    await _emitResult(result);

    _isFetching = false;
  }

  /// Re-fetches weather for the currently displayed city (used by
  /// pull-to-refresh). No-op if nothing is currently loaded.
  Future<void> refreshWeather() async {
    final current = state;
    if (current is! WeatherLoaded) return;
    await searchCity(current.weather.cityName);
  }

  Future<void> _emitResult(WeatherResult result) async {
    final recentSearches = await getRecentSearchesUseCase();

    switch (result) {
      case WeatherSuccess():
        emit(WeatherLoaded(
          weather: result.weather,
          isFromCache: result.isFromCache,
          cacheMessage: result.cacheMessage,
          recentSearches: recentSearches,
        ));
      case WeatherError():
        emit(WeatherFailure(
          message: result.failure.message,
          recentSearches: recentSearches,
        ));
    }
  }
}
