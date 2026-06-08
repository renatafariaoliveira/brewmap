import 'package:brewmap/core/network/dio_client.dart';
import 'package:brewmap/core/network/interceptors/logging_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DioClient.create', () {
    test('configura baseUrl, timeouts e headers', () {
      final client = DioClient.create(enableLogging: false);
      final options = client.dio.options;

      expect(options.baseUrl, 'https://api.openbrewerydb.org/v1/');
      expect(options.connectTimeout, const Duration(seconds: 10));
      expect(options.receiveTimeout, const Duration(seconds: 10));
      expect(options.headers['Content-Type'], 'application/json');
    });

    test('inclui LoggingInterceptor quando enableLogging=true', () {
      final client = DioClient.create(enableLogging: true);
      expect(
        client.dio.interceptors.any((i) => i is LoggingInterceptor),
        isTrue,
      );
    });

    test('não inclui LoggingInterceptor quando enableLogging=false', () {
      final client = DioClient.create(enableLogging: false);
      expect(
        client.dio.interceptors.any((i) => i is LoggingInterceptor),
        isFalse,
      );
    });
  });
}

