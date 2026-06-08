import 'package:brewmap/core/config/locator.dart';
import 'package:brewmap/features/breweries/controllers/brewery_cubit.dart';
import 'package:brewmap/features/breweries/favorite_screen.dart';
import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/brewmap_test_harness.dart';

void main() {
  late InMemoryHiveStorageService storage;

  setUp(() async {
    storage = InMemoryHiveStorageService();
    await resetBrewmapTestHarness(storage: storage);
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  group('FavoritesScreen', () {
    testWidgets('mostra estado vazio sem favoritos', (tester) async {
      await pumpBrewmapMaterialApp(
        tester,
        home: const FavoritesScreen(),
      );

      expect(find.text('Nenhuma cervejaria favoritada ainda.'), findsOneWidget);
      expect(find.text('0 salvas'), findsOneWidget);
    });

    testWidgets('lista favoritos do cubit', (tester) async {
      storage.favorites = [
        Brewery(id: '1', name: 'Porto Brew', city: 'Porto'),
        Brewery(id: '2', name: 'Lisboa Beer', city: 'Lisboa'),
      ];
      await getIt<BreweryCubit>().loadFavorites();

      await pumpBrewmapMaterialApp(
        tester,
        home: const FavoritesScreen(),
      );

      expect(find.text('Porto Brew'), findsOneWidget);
      expect(find.text('Lisboa Beer'), findsOneWidget);
      expect(find.text('2 salvas'), findsOneWidget);
    });

    testWidgets('atualiza UI quando favorito é removido', (tester) async {
      final brewery = Brewery(id: '1', name: 'Porto Brew', city: 'Porto');
      storage.favorites = [brewery];
      final cubit = getIt<BreweryCubit>();
      await cubit.loadFavorites();

      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpBrewmapMaterialApp(
        tester,
        home: const FavoritesScreen(),
      );

      await runCubitAsync(tester, () => cubit.toggleFavorite(brewery));
      await pumpWidgetFrames(tester);

      expect(cubit.state.favoriteBreweries, isEmpty);
      expect(find.text('Nenhuma cervejaria favoritada ainda.'), findsOneWidget);
    });
  });
}
