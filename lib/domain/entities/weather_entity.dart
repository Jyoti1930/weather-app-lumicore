import 'package:equatable/equatable.dart';

/// Pure domain representation of weather data — no JSON, no storage concerns.
class WeatherEntity extends Equatable {
  final String cityName;
  final String country;
  final double temperatureCelsius;
  final String condition;
  final String conditionIconUrl;
  final int humidity;
  final double windKph;
  final String lastUpdated;

  const WeatherEntity({
    required this.cityName,
    required this.country,
    required this.temperatureCelsius,
    required this.condition,
    required this.conditionIconUrl,
    required this.humidity,
    required this.windKph,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        cityName,
        country,
        temperatureCelsius,
        condition,
        conditionIconUrl,
        humidity,
        windKph,
        lastUpdated,
      ];
}
