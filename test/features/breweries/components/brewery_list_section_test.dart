import 'package:brewmap/core/config/locator.dart';
import 'package:brewmap/core/utils/error_message.dart';
import 'package:brewmap/features/breweries/components/brewery_list_section.dart';
import 'package:brewmap/features/breweries/controllers/brewery_cubit.dart';
import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/brewmap_test_harness.dart';

void main() {
  late BreweryCubit cubit;

  setUp(() async {
    await resetBrewmapTestHarness();
    cubit = getIt<BreweryCubit>();
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  Future<void> pumpSection(WidgetTester tester) async {
    await pumpBrewmapMaterialApp(
      tester,
      home: BreweryListSection(
        cubit: cubit,
        child: const Text('RESULTADOS'),
      ),
    );
  }

  group('BreweryListSection', () {
    testWidgets('mostra loading', (tester) async {
      cubit.emit(
        BreweryState(
          status: BreweryStateStatus.loading,
          breweries: [],
          favoriteBreweries: [],
        ),
      );
      await pumpSection(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('mostra erro', (tester) async {
      cubit.emit(
        BreweryState(
          status: BreweryStateStatus.error,
          breweries: [],
          errorMessage: searchErrorMessage,
          favoriteBreweries: [],
        ),
      );
      await pumpSection(tester);
      expect(find.text(searchErrorMessage), findsOneWidget);
    });

    testWidgets('mostra prompt inicial', (tester) async {
      await pumpSection(tester);
      expect(find.text('Digite uma cidade para buscar'), findsOneWidget);
    });

    testWidgets('mostra child quando loaded', (tester) async {
      cubit.emit(
        BreweryState(
          status: BreweryStateStatus.loaded,
          breweries: [Brewery(id: '1', name: 'A')],
          favoriteBreweries: [],
        ),
      );
      await pumpSection(tester);
      expect(find.text('RESULTADOS'), findsOneWidget);
    });
  });
}
