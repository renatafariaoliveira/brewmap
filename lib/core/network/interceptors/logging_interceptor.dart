import 'package:brewmap/core/logging/logger.dart';
import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logInfo(
      'REQUEST: ${options.method} ${options.uri}',
      extras: {
        'headers': options.headers,
        if (options.queryParameters.isNotEmpty) 'query': options.queryParameters,
      },
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logInfo(
      'RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logError(
      'ERROR: ${err.requestOptions.method} ${err.requestOptions.uri}',
      extras: {
        'type': err.type.toString(),
        'message': err.message,
        'statusCode': err.response?.statusCode,
        'response': err.response?.data,
      },
      stackTrace: err.stackTrace,
    );
    super.onError(err, handler);
  }
}
