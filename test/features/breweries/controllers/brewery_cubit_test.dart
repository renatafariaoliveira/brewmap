import 'package:bloc_test/bloc_test.dart';
import 'package:brewmap/core/storage/hive_service.dart';
import 'package:brewmap/core/utils/error_message.dart';
import 'package:brewmap/features/breweries/controllers/brewery_cubit.dart';
import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:brewmap/features/breweries/services/brewery_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBreweryApiService extends Mock implements BreweryApiService {}

class _MockHiveStorageService extends Mock implements HiveStorageService {}

void main() {
  late _MockBreweryApiService api;
  late _MockHiveStorageService storage;

  setUpAll(() {
    registerFallbackValue(CancelToken());
  });

  setUp(() {
    api = _MockBreweryApiService();
    storage = _MockHiveStorageService();
  });

  group('BreweryCubit.loadFavorites', () {
    blocTest<BreweryCubit, BreweryState>(
      'mantém lista vazia quando storage falha',
      build: () {
        when(() => storage.loadFavorites()).thenThrow(Exception('disk'));
        return BreweryCubit(service: api, storageService: storage);
      },
      act: (cubit) => cubit.loadFavorites(),
      expect: () => [
        isA<BreweryState>().having(
          (s) => s.favoriteBreweries,
          'favoriteBreweries',
          isEmpty,
        ),
      ],
    );

    blocTest<BreweryCubit, BreweryState>(
      'carrega favoritos do storage',
      build: () {
        when(() => storage.loadFavorites()).thenAnswer(
          (_) async => [Brewery(id: '1', name: 'A')],
        );
        return BreweryCubit(service: api, storageService: storage);
      },
      act: (cubit) => cubit.loadFavorites(),
      expect: () => [
        isA<BreweryState>().having(
          (s) => s.favoriteBreweries.map((e) => e.id).toList(),
          'favoriteBreweries',
          ['1'],
        ),
      ],
      verify: (_) => verify(() => storage.loadFavorites()).called(1),
    );
  });

  group('BreweryCubit.toggleFavorite', () {
    blocTest<BreweryCubit, BreweryState>(
      'adiciona favorito quando não existe',
      build: () {
        when(() => storage.saveFavorite(any())).thenAnswer((_) async {});
        return BreweryCubit(service: api, storageService: storage);
      },
      act: (cubit) => cubit.toggleFavorite(Brewery(id: '1', name: 'A')),
      expect: () => [
        isA<BreweryState>().having(
          (s) => s.favoriteBreweries.map((e) => e.id).toList(),
          'favoriteBreweries',
          ['1'],
        ),
      ],
      verify: (_) {
        verify(() => storage.saveFavorite(any())).called(1);
      },
    );

    blocTest<BreweryCubit, BreweryState>(
      'remove favorito quando já existe',
      build: () {
        when(() => storage.saveFavorite(any())).thenAnswer((_) async {});
        return BreweryCubit(service: api, storageService: storage);
      },
      act: (cubit) async {
        final brewery = Brewery(id: '1', name: 'A');
        await cubit.toggleFavorite(brewery);
        await cubit.toggleFavorite(brewery);
      },
      expect: () => [
        isA<BreweryState>().having(
          (s) => s.favoriteBreweries.map((e) => e.id).toList(),
          'favoriteBreweries',
          ['1'],
        ),
        isA<BreweryState>().having(
          (s) => s.favoriteBreweries,
          'favoriteBreweries',
          isEmpty,
        ),
      ],
      verify: (_) {
        verify(() => storage.saveFavorite(any())).called(2);
      },
    );

    blocTest<BreweryCubit, BreweryState>(
      'serializa toggles concorrentes sem perder favoritos',
      build: () {
        when(() => storage.saveFavorite(any())).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
        });
        return BreweryCubit(service: api, storageService: storage);
      },
      act: (cubit) async {
        final first = Brewery(id: '1', name: 'A');
        final second = Brewery(id: '2', name: 'B');
        await Future.wait([
          cubit.toggleFavorite(first),
          cubit.toggleFavorite(second),
        ]);
      },
      expect: () => [
        isA<BreweryState>().having(
          (s) => s.favoriteBreweries.map((e) => e.id).toList(),
          'favoriteBreweries',
          ['1'],
        ),
        isA<BreweryState>().having(
          (s) => s.favoriteBreweries.map((e) => e.id).toList(),
          'favoriteBreweries',
          ['1', '2'],
        ),
      ],
      verify: (_) {
        verify(() => storage.saveFavorite(any())).called(2);
      },
    );

    blocTest<BreweryCubit, BreweryState>(
      'mantém favoritos e emite erro quando storage falha',
      build: () {
        when(() => storage.saveFavorite(any())).thenThrow(Exception('disk'));
        return BreweryCubit(service: api, storageService: storage);
      },
      act: (cubit) => cubit.toggleFavorite(Brewery(id: '1', name: 'A')),
      expect: () => [
        isA<BreweryState>()
            .having((s) => s.favoriteBreweries, 'favoriteBreweries', isEmpty)
            .having(
              (s) => s.favoriteErrorMessage,
              'favoriteErrorMessage',
              favoriteErrorMessage,
            ),
      ],
    );
  });

  group('BreweryCubit.search', () {
    blocTest<BreweryCubit, BreweryState>(
      'não faz request quando query é vazia',
      build: () => BreweryCubit(service: api, storageService: storage),
      act: (cubit) => cubit.search('   '),
      expect: () => const <BreweryState>[],
      verify: (_) {
        verifyNever(
          () => api.searchBreweries(
            query: any(named: 'query'),
            cancelToken: any(named: 'cancelToken'),
          ),
        );
      },
    );

    blocTest<BreweryCubit, BreweryState>(
      'emite loading e depois loaded com resultados',
      build: () {
        when(
          () => api.searchBreweries(
            query: any(named: 'query'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer(
          (_) async => [Brewery(id: '1', name: 'A')],
        );
        return BreweryCubit(service: api, storageService: storage);
      },
      act: (cubit) => cubit.search('porto'),
      expect: () => [
        isA<BreweryState>().having((s) => s.status, 'status', BreweryStateStatus.loading),
        isA<BreweryState>()
            .having((s) => s.status, 'status', BreweryStateStatus.loaded)
            .having((s) => s.breweries.map((e) => e.id).toList(), 'breweries', ['1']),
      ],
      verify: (_) {
        verify(
          () => api.searchBreweries(
            query: 'porto',
            cancelToken: any(named: 'cancelToken'),
          ),
        ).called(1);
      },
    );

    blocTest<BreweryCubit, BreweryState>(
      'cancela busca anterior e executa nova',
      build: () {
        when(
          () => api.searchBreweries(
            query: any(named: 'query'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((invocation) async {
          final token =
              invocation.namedArguments[#cancelToken] as CancelToken?;
          final query = invocation.namedArguments[#query] as String;
          await Future<void>.delayed(const Duration(milliseconds: 50));
          if (token?.isCancelled ?? false) {
            throw DioException(
              requestOptions: RequestOptions(),
              type: DioExceptionType.cancel,
            );
          }
          return [
            Brewery(id: query, name: query),
          ];
        });
        return BreweryCubit(service: api, storageService: storage);
      },
      act: (cubit) async {
        final first = cubit.search('porto');
        await cubit.search('lisboa');
        await first;
      },
      expect: () => [
        isA<BreweryState>().having((s) => s.status, 'status', BreweryStateStatus.loading),
        isA<BreweryState>().having((s) => s.status, 'status', BreweryStateStatus.loading),
        isA<BreweryState>()
            .having((s) => s.status, 'status', BreweryStateStatus.loaded)
            .having((s) => s.breweries.map((e) => e.id).toList(), 'breweries', ['lisboa']),
      ],
      verify: (_) {
        verify(
          () => api.searchBreweries(
            query: any(named: 'query'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).called(2);
      },
    );
  });

  group('BreweryCubit.clearSearch', () {
    blocTest<BreweryCubit, BreweryState>(
      'volta para initial e limpa resultados',
      build: () => BreweryCubit(service: api, storageService: storage),
      seed: () => BreweryState(
        status: BreweryStateStatus.loaded,
        breweries: [Brewery(id: '1', name: 'A')],
        favoriteBreweries: [Brewery(id: 'fav', name: 'Fav')],
      ),
      act: (cubit) => cubit.clearSearch(),
      expect: () => [
        isA<BreweryState>()
            .having((s) => s.status, 'status', BreweryStateStatus.initial)
            .having((s) => s.breweries, 'breweries', isEmpty)
            .having(
              (s) => s.favoriteBreweries.map((e) => e.id).toList(),
              'favoriteBreweries',
              ['fav'],
            ),
      ],
    );

    blocTest<BreweryCubit, BreweryState>(
      'durante loading não restaura resultados obsoletos',
      build: () {
        when(
          () => api.searchBreweries(
            query: any(named: 'query'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((invocation) async {
          final token =
              invocation.namedArguments[#cancelToken] as CancelToken?;
          await Future<void>.delayed(const Duration(milliseconds: 50));
          if (token?.isCancelled ?? false) {
            throw DioException(
              requestOptions: RequestOptions(),
              type: DioExceptionType.cancel,
            );
          }
          return [Brewery(id: '1', name: 'A')];
        });
        return BreweryCubit(service: api, storageService: storage);
      },
      act: (cubit) async {
        final search = cubit.search('porto');
        cubit.clearSearch();
        await search;
      },
      expect: () => [
        isA<BreweryState>().having((s) => s.status, 'status', BreweryStateStatus.loading),
        isA<BreweryState>()
            .having((s) => s.status, 'status', BreweryStateStatus.initial)
            .having((s) => s.breweries, 'breweries', isEmpty),
      ],
      verify: (_) {
        verify(
          () => api.searchBreweries(
            query: 'porto',
            cancelToken: any(named: 'cancelToken'),
          ),
        ).called(1);
      },
    );
  });

  group('BreweryCubit.search errors', () {
    blocTest<BreweryCubit, BreweryState>(
      'emite loading e depois error quando service falha',
      build: () {
        when(
          () => api.searchBreweries(
            query: any(named: 'query'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenThrow(
          Exception('boom'),
        );
        return BreweryCubit(service: api, storageService: storage);
      },
      act: (cubit) => cubit.search('porto'),
      expect: () => [
        isA<BreweryState>()
            .having((s) => s.status, 'status', BreweryStateStatus.loading)
            .having((s) => s.breweries, 'breweries', isEmpty),
        isA<BreweryState>()
            .having((s) => s.status, 'status', BreweryStateStatus.error)
            .having((s) => s.breweries, 'breweries', isEmpty)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              searchErrorMessage,
            ),
      ],
    );

    blocTest<BreweryCubit, BreweryState>(
      'limpa errorMessage após busca bem-sucedida',
      build: () {
        when(
          () => api.searchBreweries(
            query: any(named: 'query'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer(
          (_) async => [Brewery(id: '1', name: 'A')],
        );
        return BreweryCubit(service: api, storageService: storage);
      },
      seed: () => BreweryState(
        status: BreweryStateStatus.error,
        errorMessage: searchErrorMessage,
        breweries: [Brewery(id: 'old', name: 'Old')],
        favoriteBreweries: [],
      ),
      act: (cubit) => cubit.search('porto'),
      expect: () => [
        isA<BreweryState>()
            .having((s) => s.status, 'status', BreweryStateStatus.loading)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        isA<BreweryState>()
            .having((s) => s.status, 'status', BreweryStateStatus.loaded)
            .having((s) => s.errorMessage, 'errorMessage', isNull)
            .having((s) => s.breweries.map((e) => e.id).toList(), 'breweries', ['1']),
      ],
    );
  });
}
