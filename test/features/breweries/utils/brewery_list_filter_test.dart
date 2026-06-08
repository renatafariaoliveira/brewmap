import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:brewmap/features/breweries/models/brewery_type_model.dart';
import 'package:brewmap/features/breweries/utils/brewery_list_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BreweryListFilter.apply', () {
    test('filtra por tipo quando informado', () {
      final items = [
        Brewery(id: '1', name: 'A', type: BreweryType.micro),
        Brewery(id: '2', name: 'B', type: BreweryType.large),
      ];

      final result = BreweryListFilter.apply(
        items,
        type: BreweryType.large,
        query: '',
      );

      expect(result.map((e) => e.id), ['2']);
    });

    test('filtra por query (case-insensitive) em nome e local', () {
      final items = [
        Brewery(
          id: '1',
          name: 'Porto Brew',
          city: 'Porto',
          country: 'Portugal',
        ),
        Brewery(
          id: '2',
          name: 'Lisboa Beer',
          city: 'Lisboa',
          country: 'Portugal',
        ),
      ];

      expect(
        BreweryListFilter.apply(items, query: 'porto').map((e) => e.id),
        ['1'],
      );
      expect(
        BreweryListFilter.apply(items, query: 'PORTUGAL').map((e) => e.id),
        ['1', '2'],
      );
    });
  });

  group('BreweryListFilter.paginate', () {
    test('retorna sublista da página', () {
      final items =
          List.generate(10, (i) => Brewery(id: '$i', name: 'B$i')).toList();

      final page2 = BreweryListFilter.paginate(items, page: 2, perPage: 4);
      expect(page2.map((e) => e.id), ['4', '5', '6', '7']);
    });

    test('retorna [] quando start >= length', () {
      final items =
          List.generate(3, (i) => Brewery(id: '$i', name: 'B$i')).toList();

      final page2 = BreweryListFilter.paginate(items, page: 2, perPage: 4);
      expect(page2, isEmpty);
    });

    test('retorna [] quando page ou perPage são inválidos', () {
      final items =
          List.generate(3, (i) => Brewery(id: '$i', name: 'B$i')).toList();

      expect(BreweryListFilter.paginate(items, page: 0, perPage: 4), isEmpty);
      expect(BreweryListFilter.paginate(items, page: 1, perPage: 0), isEmpty);
      expect(BreweryListFilter.paginate(const [], page: 1, perPage: 4), isEmpty);
    });
  });

  group('BreweryListFilter.totalPages', () {
    test('retorna 0 quando não há resultados', () {
      expect(BreweryListFilter.totalPages(0, 4), 0);
    });

    test('calcula corretamente para múltiplas páginas', () {
      expect(BreweryListFilter.totalPages(1, 4), 1);
      expect(BreweryListFilter.totalPages(4, 4), 1);
      expect(BreweryListFilter.totalPages(5, 4), 2);
    });
  });

  group('BreweryListFilter.paginationPageSlots', () {
    test('retorna todas as páginas quando total cabe na janela', () {
      expect(BreweryListFilter.paginationPageSlots(1, 4), [1, 2, 3, 4]);
    });

    test('centraliza janela na página atual com ellipsis', () {
      expect(
        BreweryListFilter.paginationPageSlots(5, 10),
        [1, null, 3, 4, 5, 6, 7, null, 10],
      );
    });

    test('destaca página atual no fim da lista', () {
      expect(
        BreweryListFilter.paginationPageSlots(10, 10),
        [1, null, 6, 7, 8, 9, 10],
      );
    });

    test('retorna vazio quando não há páginas', () {
      expect(BreweryListFilter.paginationPageSlots(1, 0), isEmpty);
    });
  });

  group('BreweryListFilter.findById', () {
    test('retorna null para id nulo', () {
      final items = [Brewery(id: '1', name: 'A')];
      expect(BreweryListFilter.findById(items, null), isNull);
    });

    test('encontra pelo id', () {
      final items = [Brewery(id: '1', name: 'A'), Brewery(id: '2', name: 'B')];
      expect(BreweryListFilter.findById(items, '2')?.name, 'B');
    });
  });
}

