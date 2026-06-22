import 'package:mocktail/mocktail.dart';
import 'package:weather_app/core/network/network_info.dart';
import 'package:weather_app/data/datasources/weather_local_data_source.dart';
import 'package:weather_app/data/datasources/weather_remote_data_source.dart';
import 'package:weather_app/data/models/weather_model.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';

class MockWeatherRemoteDataSource extends Mock implements WeatherRemoteDataSource {}

class MockWeatherLocalDataSource extends Mock implements WeatherLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockWeatherRepository extends Mock implements WeatherRepository {}

/// A representative weather model used across tests.
final testWeather = WeatherModel(
  cityName: 'Dubai',
  country: 'United Arab Emirates',
  temperatureCelsius: 38.0,
  condition: 'Sunny',
  conditionIconUrl: 'https://cdn.weatherapi.com/weather/64x64/day/113.png',
  humidity: 45,
  windKph: 12.0,
  lastUpdated: '2026-06-20 12:00',
);
