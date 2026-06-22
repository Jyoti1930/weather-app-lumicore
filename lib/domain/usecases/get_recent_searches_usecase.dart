import '../repositories/weather_repository.dart';

class GetRecentSearchesUseCase {
  final WeatherRepository repository;

  GetRecentSearchesUseCase(this.repository);

  Future<List<String>> call() {
    return repository.getRecentSearches();
  }
}
