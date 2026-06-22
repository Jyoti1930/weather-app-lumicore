import 'package:equatable/equatable.dart';
import '../../domain/entities/weather_entity.dart';

abstract class WeatherState extends Equatable {
  final List<String> recentSearches;
  const WeatherState({required this.recentSearches});

  @override
  List<Object?> get props => [recentSearches];
}

class WeatherInitial extends WeatherState {
  const WeatherInitial({super.recentSearches = const []});
}

class WeatherLoading extends WeatherState {
  const WeatherLoading({required super.recentSearches});
}

class WeatherLoaded extends WeatherState {
  final WeatherEntity weather;
  final bool isFromCache;
  final String? cacheMessage;

  const WeatherLoaded({
    required this.weather,
    required super.recentSearches,
    this.isFromCache = false,
    this.cacheMessage,
  });

  @override
  List<Object?> get props => [weather, isFromCache, cacheMessage, recentSearches];
}

class WeatherFailure extends WeatherState {
  final String message;

  const WeatherFailure({
    required this.message,
    required super.recentSearches,
  });

  @override
  List<Object?> get props => [message, recentSearches];
}
