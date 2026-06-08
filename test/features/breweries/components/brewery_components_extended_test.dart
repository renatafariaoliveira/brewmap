import 'package:brewmap/core/config/locator.dart';
import 'package:brewmap/features/breweries/components/brew_map_top_bar.dart';
import 'package:brewmap/features/breweries/components/brew_search_header.dart';
import 'package:brewmap/features/breweries/components/brew_type_filters.dart';
import 'package:brewmap/features/breweries/components/brewery_explore_sidebar.dart';
import 'package:brewmap/features/breweries/components/brewery_favorite_card.dart';
import 'package:brewmap/features/breweries/components/brewery_list_panel.dart';
import 'package:brewmap/features/breweries/components/brewery_paginated_list.dart';
import 'package:brewmap/features/breweries/components/brewery_pagination_section.dart';
import 'package:brewmap/features/breweries/components/brewery_search_filters_block.dart';
import 'package:brewmap/features/breweries/components/detail_panel.dart';
import 'package:brewmap/features/breweries/controllers/brewery_cubit.dart';
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

  group('componentes breweries — extended', () {
    testWidgets('BrewSearchHeader renderiza campo de busca', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await pump(
        tester,
        BrewSearchHeader(controller: controller, onSearch: () {}),
      );

      expect(find.byKey(const Key('brew_search_field')), findsOneWidget);
      expect(find.text('Encontre cervejarias perto de você'), findsOneWidget);
    });

    testWidgets('BrewTypeFilters exibe chips de tipo', (tester) async {
      await pump(
        tester,
        BrewTypeFilters(selectedType: null, onChanged: (_) {}),
      );

      expect(find.text('TIPO'), findsOneWidget);
      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Micro'), findsOneWidget);
    });

    testWidgets('BrewerySearchFiltersBlock agrupa busca e filtros', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await pump(
        tester,
        BrewerySearchFiltersBlock(
          searchController: controller,
          onSearch: () {},
          selectedType: BreweryType.micro,
          onTypeChanged: (_) {},
        ),
      );

      expect(find.byKey(const Key('brew_search_field')), findsOneWidget);
      expect(find.text('Micro'), findsWidgets);
    });

    testWidgets('BreweryPaginatedList mostra empty state', (tester) async {
      await pump(
        tester,
        const BreweryPaginatedList(
          items: [],
          selectedBreweryId: null,
          onSelect: _noopSelect,
        ),
      );

      expect(find.text('Nenhuma cervejaria encontrada'), findsOneWidget);
    });

    testWidgets('BreweryPaginatedList lista itens', (tester) async {
      await pump(
        tester,
        BreweryPaginatedList(
          items: [Brewery(id: '1', name: 'Porto Brew', city: 'Porto')],
          selectedBreweryId: null,
          onSelect: (_) {},
        ),
      );

      expect(find.text('Porto Brew'), findsOneWidget);
    });

    testWidgets('BreweryFavoriteCard exibe dados e remove', (tester) async {
      var removed = false;
      await pump(
        tester,
        BreweryFavoriteCard(
          brewery: Brewery(
            id: '1',
            name: 'Porto Brew',
            city: 'Porto',
            type: BreweryType.micro,
          ),
          onRemove: () => removed = true,
        ),
      );

      expect(find.text('Porto Brew'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.star_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(removed, isTrue);
    });

    testWidgets('BreweryDetailPanel exibe nome e botão voltar', (tester) async {
      await resetBrewmapTestHarness();
      addTearDown(() async => getIt.reset(dispose: true));

      var back = false;
      await pumpBrewmapMaterialApp(
        tester,
        home: BreweryDetailPanel(
          brewery: Brewery(id: '1', name: 'Porto Brew', city: 'Porto'),
          onBack: () => back = true,
        ),
      );

      expect(find.text('Porto Brew'), findsWidgets);
      await tester.tap(find.text('Voltar ao mapa'));
      expect(back, isTrue);
    });

    testWidgets('BreweryPaginationSection mostra barra quando loaded', (
      tester,
    ) async {
      await resetBrewmapTestHarness();
      final cubit = getIt<BreweryCubit>();
      addTearDown(() async => getIt.reset(dispose: true));

      cubit.emit(
        BreweryState(
          status: BreweryStateStatus.loaded,
          breweries: List.generate(12, (i) => Brewery(id: '$i', name: 'B$i')),
          favoriteBreweries: [],
        ),
      );

      await pump(
        tester,
        BreweryPaginationSection(
          cubit: cubit,
          currentPage: 1,
          totalPages: 2,
          totalResults: 12,
          showing: 10,
          onPageChanged: (_) {},
        ),
      );

      expect(find.text('12'), findsOneWidget);
      expect(find.text('Encontramos '), findsOneWidget);
    });

    testWidgets('BreweryListPanel integra lista e paginação', (tester) async {
      await resetBrewmapTestHarness();
      final cubit = getIt<BreweryCubit>();
      addTearDown(() async => getIt.reset(dispose: true));

      cubit.emit(
        BreweryState(
          status: BreweryStateStatus.loaded,
          breweries: [Brewery(id: '1', name: 'Porto Brew')],
          favoriteBreweries: [],
        ),
      );

      await pump(
        tester,
        BreweryListPanel(
          cubit: cubit,
          items: [Brewery(id: '1', name: 'Porto Brew')],
          selectedBreweryId: null,
          onSelect: (_) {},
          currentPage: 1,
          totalPages: 1,
          totalResults: 1,
          onPageChanged: (_) {},
        ),
      );

      expect(find.text('Porto Brew'), findsOneWidget);
    });

    testWidgets('BrewMapTopBar renderiza abas', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 80));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpBrewmapMaterialApp(
        tester,
        home: DefaultTabController(
          length: 2,
          child: Builder(
            builder: (context) {
              return BrewMapTopBar(
                tabController: DefaultTabController.of(context),
                onAboutTap: () {},
              );
            },
          ),
        ),
      );

      expect(find.text('BrewMap'), findsOneWidget);
      expect(find.text('Explorar'), findsOneWidget);
      expect(find.text('Favoritos'), findsOneWidget);
    });

    testWidgets('BreweryExploreSidebar mostra filtros e lista', (tester) async {
      await resetBrewmapTestHarness();
      final cubit = getIt<BreweryCubit>();
      final controller = TextEditingController();
      addTearDown(() async {
        controller.dispose();
        await getIt.reset(dispose: true);
      });

      cubit.emit(
        BreweryState(
          status: BreweryStateStatus.loaded,
          breweries: [Brewery(id: '1', name: 'Porto Brew')],
          favoriteBreweries: [],
        ),
      );

      await pump(
        tester,
        BreweryExploreSidebar(
          selectedBrewery: null,
          onBack: () {},
          searchController: controller,
          onSearch: () {},
          selectedType: null,
          onTypeChanged: (_) {},
          cubit: cubit,
          paginatedItems: [Brewery(id: '1', name: 'Porto Brew')],
          selectedBreweryId: null,
          onBrewerySelect: (_) {},
          currentPage: 1,
          totalPages: 1,
          totalResults: 1,
          onPageChanged: (_) {},
        ),
      );

      expect(find.byKey(const Key('brew_search_field')), findsOneWidget);
      expect(find.text('Porto Brew'), findsOneWidget);
    });
  });
}

void _noopSelect(Brewery _) {}
