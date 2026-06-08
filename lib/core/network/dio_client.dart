import 'package:dio/dio.dart';
import 'package:brewmap/core/network/interceptors/logging_interceptor.dart';

class DioClient {
  final Dio dio;

  DioClient._(this.dio);

  factory DioClient.create({bool enableLogging = true}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.openbrewerydb.org/v1/',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    if (enableLogging) {
      dio.interceptors.add(LoggingInterceptor());
    }

    return DioClient._(dio);
  }
}
