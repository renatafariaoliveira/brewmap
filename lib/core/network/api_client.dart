import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio);

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return _unwrapResponseData(response, 'get', path);
  }

  Future<T> post<T>(
    String path,
    dynamic data, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return _unwrapResponseData(response, 'post', path);
  }

  T _unwrapResponseData<T>(Response<T> response, String method, String path) {
    final data = response.data;
    if (data == null) {
      throw StateError('ApiClient.$method($path) returned null response body');
    }

    try {
      return data as T;
    } on TypeError {
      throw StateError(
        'ApiClient.$method($path) returned ${data.runtimeType}, expected $T',
      );
    }
  }
}
