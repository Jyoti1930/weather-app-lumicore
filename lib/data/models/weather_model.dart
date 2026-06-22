import '../../domain/entities/weather_entity.dart';

/// Data-layer model. Knows how to parse the WeatherAPI.com response shape
/// and how to (de)serialize itself for the local cache.
class WeatherModel extends WeatherEntity {
  const WeatherModel({
    required super.cityName,
    required super.country,
    required super.temperatureCelsius,
    required super.condition,
    required super.conditionIconUrl,
    required super.humidity,
    required super.windKph,
    required super.lastUpdated,
  });

  /// Parses the raw response from WeatherAPI.com's `/current.json` endpoint.
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>;
    final condition = current['condition'] as Map<String, dynamic>;

    return WeatherModel(
      cityName: location['name'] as String,
      country: location['country'] as String,
      temperatureCelsius: (current['temp_c'] as num).toDouble(),
      condition: condition['text'] as String,
      conditionIconUrl: 'https:${condition['icon']}',
      humidity: (current['humidity'] as num).toInt(),
      windKph: (current['wind_kph'] as num).toDouble(),
      lastUpdated: current['last_updated'] as String,
    );
  }

  /// Rebuilds a [WeatherModel] from our own cached JSON shape (see [toJson]).
  /// Kept separate from [fromJson] because the cache shape is flat, while
  /// the API response is nested.
  factory WeatherModel.fromCacheJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['cityName'] as String,
      country: json['country'] as String,
      temperatureCelsius: (json['temperatureCelsius'] as num).toDouble(),
      condition: json['condition'] as String,
      conditionIconUrl: json['conditionIconUrl'] as String,
      humidity: (json['humidity'] as num).toInt(),
      windKph: (json['windKph'] as num).toDouble(),
      lastUpdated: json['lastUpdated'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'country': country,
      'temperatureCelsius': temperatureCelsius,
      'condition': condition,
      'conditionIconUrl': conditionIconUrl,
      'humidity': humidity,
      'windKph': windKph,
      'lastUpdated': lastUpdated,
    };
  }
}
