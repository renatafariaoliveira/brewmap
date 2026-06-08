import 'package:brewmap/features/breweries/components/brewery_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gherkart/gherkart.dart';

import '../bdd_pump.dart';
import '../bdd_world.dart';

StepRegistry<WidgetTester> createBrewmapSteps(BddWorld world) {
  return StepRegistry<WidgetTester>.fromMap({
    'o app está aberto'.mapper(): ($, ctx) async {
      await world.openApp($);
    },
    'a API retorna erro'.mapper(): ($, ctx) async {
      world.fakeApi.shouldThrow = true;
    },
    'eu busco por "{query}"'.mapper(types: {'query': String}): ($, ctx) async {
      final query = ctx.arg<String>(0);
      await bddEnterText($, find.byKey(const Key('brew_search_field')), query);
      await bddTap($, find.byKey(const Key('brew_search_button')));
      if (world.fakeApi.shouldThrow) {
        await bddPumpUntil($, find.textContaining('Erro'));
        expect(find.textContaining('Erro'), findsAtLeastNWidgets(1));
        return;
      }
      await bddPumpUntil($, find.byType(BreweryListTile));
      expect(find.byType(BreweryListTile), findsWidgets);
    },
    'eu seleciono a primeira cervejaria da lista'.mapper(): ($, ctx) async {
      final tile = find.byType(BreweryListTile).first;
      await bddTap($, tile);
    },
    'eu marco como favorito'.mapper(): ($, ctx) async {
      final button = find.text('Adicionar aos Favoritos');
      if (button.evaluate().isEmpty) {
        // Already favorited
        return;
      }
      await bddTap($, button);
    },
    'a cervejaria aparece na lista de favoritos'.mapper(): ($, ctx) async {
      await bddTap($, find.byKey(const Key('nav_favorites')));
      expect(find.text('Porto Brew'), findsOneWidget);
    },
    'existe uma cervejaria favoritada'.mapper(): ($, ctx) async {
      await world.openApp($);
      final breweries = await world.fakeApi.searchBreweries(query: 'seed');
      await world.seedFavorite(breweries.first);
      await bddPump($);
    },
    'eu reinicio o app'.mapper(): ($, ctx) async {
      await world.restartApp($);
    },
    'a cervejaria continua na lista de favoritos'.mapper(): ($, ctx) async {
      await bddTap($, find.byKey(const Key('nav_favorites')));
      expect(find.text('Porto Brew'), findsOneWidget);
    },
    'eu vejo uma mensagem de erro'.mapper(): ($, ctx) async {
      expect(find.textContaining('Erro'), findsAtLeastNWidgets(1));
    },
    'nenhum resultado é exibido'.mapper(): ($, ctx) async {
      expect(find.byType(BreweryListTile), findsNothing);
    },
  });
}

