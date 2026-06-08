import 'package:brewmap/core/config/locator.dart';
import 'package:brewmap/features/breweries/components/brewery_list_tile.dart';
import 'package:brewmap/features/breweries/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/brewmap_test_harness.dart';

Future<void> _submitSearch(WidgetTester tester, String query) async {
  await tester.tap(find.byKey(const Key('brew_search_field')));
  await pumpWidgetFrames(tester);
  tester.testTextInput.enterText(query);
  await pumpWidgetFrames(tester);
  await tester.tap(find.byKey(const Key('brew_search_button')));
  await pumpWidgetFrames(tester, frames: 12);
}

void main() {
  late FakeBreweryApiService api;

  setUp(() async {
    api = FakeBreweryApiService();
    await resetBrewmapTestHarness(api: api);
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  group('MapScreen', () {
    testWidgets(
      'mostra prompt inicial de busca',
      skip: skipMapWidgetTests,
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await pumpBrewmapMaterialApp(
          tester,
          home: const MapScreen(),
        );

        expect(find.text('Digite uma cidade para buscar'), findsOneWidget);
      },
    );

    testWidgets(
      'busca exibe resultados na lista',
      skip: skipMapWidgetTests,
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await pumpBrewmapMaterialApp(
          tester,
          home: const MapScreen(),
        );

        await _submitSearch(tester, 'porto');

        expect(find.byType(BreweryListTile), findsWidgets);
        expect(find.text('Porto Brew'), findsOneWidget);
      },
    );

    testWidgets(
      'API com erro mostra mensagem e esconde resultados',
      skip: skipMapWidgetTests,
      (tester) async {
        api.shouldThrow = true;
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await pumpBrewmapMaterialApp(
          tester,
          home: const MapScreen(),
        );

        await _submitSearch(tester, 'ipa');

        expect(
          find.textContaining('Erro ao buscar cervejarias'),
          findsWidgets,
        );
        expect(find.byType(BreweryListTile), findsNothing);
      },
    );

    testWidgets(
      'navega para aba de favoritos',
      skip: skipMapWidgetTests,
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await pumpBrewmapMaterialApp(
          tester,
          home: const MapScreen(),
        );

        await tester.tap(find.byKey(const Key('nav_favorites')));
        await pumpWidgetFrames(tester);

        expect(find.text('Nenhuma cervejaria favoritada ainda.'), findsOneWidget);
      },
    );
  });
}
