import 'package:brewmap/features/breweries/components/brew_query_badge.dart';
import 'package:brewmap/features/breweries/components/brewery_filter.dart' show BrewFilterChip;
import 'package:brewmap/features/breweries/components/brewery_list_tile.dart';
import 'package:brewmap/features/breweries/components/brewery_results_badge.dart';
import 'package:brewmap/features/breweries/components/favorites_empty_state.dart';
import 'package:brewmap/features/breweries/components/favorites_header.dart';
import 'package:brewmap/features/breweries/components/map_zoom_controls.dart';
import 'package:brewmap/features/breweries/components/type_badge_widget.dart';
import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:brewmap/features/breweries/models/brewery_type_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/brewmap_test_harness.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(wrapWithBrewTheme(child));
    await pumpWidgetFrames(tester);
  }

  group('componentes breweries — smoke', () {
    testWidgets('BrewQueryBadge mostra query em maiúsculas', (tester) async {
      await pump(tester, const BrewQueryBadge(query: 'porto'));
      expect(find.text('PORTO'), findsOneWidget);
    });

    testWidgets('BrewQueryBadge fallback BUSCA', (tester) async {
      await pump(tester, const BrewQueryBadge(query: '  '));
      expect(find.text('BUSCA'), findsOneWidget);
    });

    testWidgets('BreweryResultsBadge exibe contagem', (tester) async {
      await pump(tester, const BreweryResultsBadge(count: 7));
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('FavoritesHeader exibe contagem', (tester) async {
      await pump(tester, const FavoritesHeader(count: 3));
      expect(find.text('3 salvas'), findsOneWidget);
    });

    testWidgets('FavoritesEmptyState', (tester) async {
      await pump(tester, const FavoritesEmptyState());
      expect(find.text('Nenhuma cervejaria favoritada ainda.'), findsOneWidget);
    });

    testWidgets('BrewFilterChip dispara onTap', (tester) async {
      var tapped = false;
      await pump(
        tester,
        BrewFilterChip(
          label: 'Micro',
          selected: false,
          onTap: () => tapped = true,
        ),
      );
      await tester.tap(find.text('Micro'));
      expect(tapped, isTrue);
    });

    testWidgets('BreweryListTile exibe nome e cidade', (tester) async {
      await pump(
        tester,
        BreweryListTile(
          brewery: Brewery(id: '1', name: 'Porto Brew', city: 'Porto'),
          isSelected: false,
          onTap: () {},
        ),
      );
      expect(find.text('Porto Brew'), findsOneWidget);
      expect(find.text('Porto'), findsOneWidget);
    });

    testWidgets('TypeBadge renderiza label do tipo', (tester) async {
      await pump(
        tester,
        const TypeBadge(
          type: BreweryType.brewpub,
          variant: TypeBadgeVariant.soft,
        ),
      );
      expect(find.text('Brewpub'), findsOneWidget);
    });

    testWidgets('MapZoomControls dispara callbacks', (tester) async {
      var zoomIn = 0;
      var zoomOut = 0;
      await pump(
        tester,
        MapZoomControls(
          onZoomIn: () => zoomIn++,
          onZoomOut: () => zoomOut++,
        ),
      );

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.tap(find.byIcon(Icons.remove_rounded));
      expect(zoomIn, 1);
      expect(zoomOut, 1);
    });
  });
}
