import 'package:brewmap/features/breweries/controllers/brewery_cubit.dart';
import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BreweryState.searchResults', () {
    test('retorna breweries apenas quando status é loaded', () {
      final brewery = Brewery(id: '1', name: 'A');

      expect(
        BreweryState(
          status: BreweryStateStatus.loaded,
          breweries: [brewery],
          favoriteBreweries: [],
        ).searchResults,
        [brewery],
      );

      for (final status in [
        BreweryStateStatus.initial,
        BreweryStateStatus.loading,
        BreweryStateStatus.error,
      ]) {
        expect(
          BreweryState(
            status: status,
            breweries: [brewery],
            favoriteBreweries: [],
          ).searchResults,
          isEmpty,
        );
      }
    });
  });

  group('didSearchPresentationChange', () {
    test('detecta mudanças de status, breweries e errorMessage', () {
      final base = BreweryState.initial();
      final loaded = base.copyWith(
        status: BreweryStateStatus.loaded,
        breweries: [Brewery(id: '1', name: 'A')],
      );

      expect(didSearchPresentationChange(base, loaded), isTrue);
      expect(
        didSearchPresentationChange(
          loaded,
          loaded.copyWith(errorMessage: 'err'),
        ),
        isTrue,
      );
      expect(
        didSearchPresentationChange(
          loaded,
          loaded.copyWith(
            breweries: [Brewery(id: '2', name: 'B')],
          ),
        ),
        isTrue,
      );
    });

    test('ignora mudanças só em favoritos', () {
      final before = BreweryState.initial();
      final after = before.copyWith(
        favoriteBreweries: [Brewery(id: 'f', name: 'Fav')],
      );

      expect(didSearchPresentationChange(before, after), isFalse);
    });
  });
}
