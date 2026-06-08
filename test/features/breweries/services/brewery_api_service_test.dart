import 'package:brewmap/core/network/api_client.dart';
import 'package:brewmap/features/breweries/services/brewery_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _FakeOptions extends Fake implements Options {}

class _FakeCancelToken extends Fake implements CancelToken {}

void main() {
  late _MockApiClient api;
  late BreweryApiService service;

  setUpAll(() {
    registerFallbackValue(_FakeOptions());
    registerFallbackValue(_FakeCancelToken());
  });

  setUp(() {
    api = _MockApiClient();
    service = BreweryApiService(api);
  });

  group('BreweryApiService.searchBreweries', () {
    test('parseia resultados válidos e repassa query/per_page', () async {
      when(
        () => api.get<List<dynamic>>(
          '/breweries/search',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((invocation) async {
        final params =
            invocation.namedArguments[#queryParameters] as Map<String, dynamic>?;
        expect(params?['query'], 'porto');
        expect(params?['per_page'], 10);
        return [
          {
            'id': '1',
            'name': 'Porto Brew',
            'brewery_type': 'micro',
            'latitude': '41.15',
            'longitude': '-8.62',
          },
        ];
      });

      final result = await service.searchBreweries(
        query: 'porto',
        perPage: 10,
        cancelToken: CancelToken(),
      );

      expect(result, hasLength(1));
      expect(result.first.id, '1');
      expect(result.first.name, 'Porto Brew');
    });

    test('ignora itens inválidos e mantém os válidos', () async {
      when(
        () => api.get<List<dynamic>>(
          '/breweries/search',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => [
          {
            'id': '1',
            'name': 'Valid',
            'brewery_type': 'micro',
          },
          {'id': '2'},
          'not-a-map',
          {
            'id': '3',
            'name': 'Also Valid',
            'brewery_type': 'large',
          },
        ],
      );

      final result = await service.searchBreweries(query: 'x');

      expect(result.map((b) => b.id).toList(), ['1', '3']);
    });

    test('propaga cancelamento do Dio', () async {
      when(
        () => api.get<List<dynamic>>(
          '/breweries/search',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/breweries/search'),
          type: DioExceptionType.cancel,
        ),
      );

      expect(
        () => service.searchBreweries(query: 'porto'),
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'type',
            DioExceptionType.cancel,
          ),
        ),
      );
    });

    test('embrulha falhas genéricas em Exception', () async {
      when(
        () => api.get<List<dynamic>>(
          '/breweries/search',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenThrow(StateError('boom'));

      expect(
        () => service.searchBreweries(query: 'porto'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to search breweries'),
          ),
        ),
      );
    });
  });
}
