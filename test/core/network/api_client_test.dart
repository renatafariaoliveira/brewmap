import 'package:brewmap/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _FakeOptions extends Fake implements Options {}

class _FakeCancelToken extends Fake implements CancelToken {}

void main() {
  late Dio dio;
  late ApiClient client;

  setUpAll(() {
    registerFallbackValue(_FakeOptions());
    registerFallbackValue(_FakeCancelToken());
  });

  setUp(() {
    dio = _MockDio();
    client = ApiClient(dio);
  });

  group('ApiClient.get', () {
    test('repassa parâmetros e retorna response.data', () async {
      final response = Response<List<dynamic>>(
        data: const ['ok'],
        requestOptions: RequestOptions(path: '/x'),
      );

      when(
        () => dio.get<List<dynamic>>(
          '/breweries/search',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => response);

      final data = await client.get<List<dynamic>>(
        '/breweries/search',
        queryParameters: const {'query': 'porto'},
        options: Options(headers: const {'x': 'y'}),
        cancelToken: CancelToken(),
      );

      expect(data, const ['ok']);
      verify(
        () => dio.get<List<dynamic>>(
          '/breweries/search',
          queryParameters: const {'query': 'porto'},
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).called(1);
    });

    test('lança StateError quando response.data é null', () async {
      final response = Response<List<dynamic>>(
        requestOptions: RequestOptions(path: '/x'),
      );

      when(
        () => dio.get<List<dynamic>>(
          '/breweries/search',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => response);

      expect(
        () => client.get<List<dynamic>>('/breweries/search'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('null response body'),
          ),
        ),
      );
    });

  });

  group('ApiClient.post', () {
    test('repassa parâmetros e retorna response.data', () async {
      final response = Response<Map<String, dynamic>>(
        data: const {'ok': true},
        requestOptions: RequestOptions(path: '/x'),
      );

      when(
        () => dio.post<Map<String, dynamic>>(
          '/breweries',
          data: 'payload',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => response);

      final data = await client.post<Map<String, dynamic>>(
        '/breweries',
        'payload',
        queryParameters: const {'a': 1},
        options: Options(contentType: 'application/json'),
        cancelToken: CancelToken(),
      );

      expect(data, const {'ok': true});
      verify(
        () => dio.post<Map<String, dynamic>>(
          '/breweries',
          data: 'payload',
          queryParameters: const {'a': 1},
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).called(1);
    });
  });
}

