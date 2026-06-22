import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: ApiConstants.connectTimeoutSeconds),
        receiveTimeout: const Duration(seconds: ApiConstants.receiveTimeoutSeconds),
      ),
    );

    dio.interceptors.add(
      LogInterceptor(requestBody: false, responseBody: false, error: true),
    );
  }
}
