import '../repositories/weather_repository.dart';

class GetInitialWeatherUseCase {
  final WeatherRepository repository;

  GetInitialWeatherUseCase(this.repository);

  Future<WeatherResult?> call() => repository.loadCachedWeatherOnStartup();
}