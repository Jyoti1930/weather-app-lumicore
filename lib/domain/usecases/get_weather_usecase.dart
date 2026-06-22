import '../repositories/weather_repository.dart';

class GetWeatherUseCase {
  final WeatherRepository repository;

  GetWeatherUseCase(this.repository);

  Future<WeatherResult> call(String cityName) {
    return repository.getCurrentWeather(cityName);
  }
}
