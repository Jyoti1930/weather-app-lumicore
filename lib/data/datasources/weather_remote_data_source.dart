import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/error/exceptions.dart';
import '../models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getCurrentWeather(String cityName);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final Dio dio;

  WeatherRemoteDataSourceImpl(this.dio);

  @override
  Future<WeatherModel> getCurrentWeather(String cityName) async {
    try {
      final response = await dio.get(
        ApiConstants.currentWeatherEndpoint,
        queryParameters: {
          'key': ApiConstants.apiKey,
          'q': cityName,
          'aqi': 'no',
        },
      );
      return WeatherModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Exception _mapDioException(DioException e) {
    final response = e.response;

    if (response != null) {
      final statusCode = response.statusCode;

      switch (statusCode) {
        case 400:
          return CityNotFoundException(
            'City not found. Please check the spelling and try again.',
          );
        case 401:
        case 403:
          return ServerException(
            'Invalid API key. Please check your WeatherAPI configuration.',
          );
        case 429:
          return RateLimitException(
            'Too many requests. Please wait a moment and try again.',
          );
        default:
          if (statusCode != null && statusCode >= 500) {
            return ServerException(
              'Weather service is currently unavailable. Please try again later.',
            );
          }
          return ServerException('Something went wrong. Please try again.');
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ServerException(
          'Connection timed out. Please check your internet connection.',
        );
      default:
        return ServerException(
          'Unable to reach the weather service. Please check your internet connection.',
        );
    }
  }
}
