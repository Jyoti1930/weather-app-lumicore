import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/error/exceptions.dart';
import '../models/weather_model.dart';

abstract class WeatherLocalDataSource {
  Future<void> cacheWeather(WeatherModel weather);
  Future<WeatherModel> getLastCachedWeather();
  Future<void> addRecentSearch(String cityName);
  Future<List<String>> getRecentSearches();
}

/// Both boxes store plain JSON strings under a single key. This keeps the
/// app free of generated Hive TypeAdapters (no build_runner step needed)
/// while still getting Hive's fast, persistent key-value storage.
class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  static const String weatherCacheKey = 'CACHED_WEATHER';
  static const String recentSearchesKey = 'RECENT_SEARCHES';
  static const int maxRecentSearches = 10;

  final Box<String> weatherBox;
  final Box<String> searchesBox;

  WeatherLocalDataSourceImpl({
    required this.weatherBox,
    required this.searchesBox,
  });

  @override
  Future<void> cacheWeather(WeatherModel weather) async {
    await weatherBox.put(weatherCacheKey, jsonEncode(weather.toJson()));
  }

  @override
  Future<WeatherModel> getLastCachedWeather() async {
    final jsonString = weatherBox.get(weatherCacheKey);
    if (jsonString == null) {
      throw CacheException('No cached weather data found.');
    }
    return WeatherModel.fromCacheJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> addRecentSearch(String cityName) async {
    final current = await getRecentSearches();
    final updated = List<String>.from(current)
      ..removeWhere((city) => city.toLowerCase() == cityName.toLowerCase());
    updated.insert(0, cityName);
    if (updated.length > maxRecentSearches) {
      updated.removeRange(maxRecentSearches, updated.length);
    }
    await searchesBox.put(recentSearchesKey, jsonEncode(updated));
  }

  @override
  Future<List<String>> getRecentSearches() async {
    final jsonString = searchesBox.get(recentSearchesKey);
    if (jsonString == null) return [];
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list.cast<String>();
  }
}
