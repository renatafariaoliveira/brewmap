import 'package:brewmap/core/utils/error_message.dart';
import 'package:brewmap/features/breweries/components/brewery_map_panel.dart';
import 'package:brewmap/features/breweries/controllers/brewery_cubit.dart';
import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import '../../../helpers/brewmap_test_harness.dart';

void main() {
  group('BreweryMapPanel', () {
    testWidgets(
      'usa stub do mapa com flag BDD e exibe badge de resultados',
      skip: skipMapWidgetTests,
      (tester) async {
        final mapController = MapController();
        addTearDown(mapController.dispose);

        await pumpBrewmapMaterialApp(
          tester,
          home: BreweryMapPanel(
            mapController: mapController,
            initialCenter: const LatLng(41.15, -8.62),
            initialZoom: 10,
            breweries: [
              Brewery(
                id: '1',
                name: 'Porto Brew',
                latitude: 41.15,
                longitude: -8.62,
              ),
            ],
            selectedBreweryId: null,
            query: 'porto',
            onBrewerySelect: (_) {},
            onMapTap: () {},
            searchStatus: BreweryStateStatus.loaded,
            resultsCount: 1,
          ),
        );

        expect(find.byType(FlutterMap), findsNothing);
        expect(find.text('1'), findsOneWidget);
        expect(find.text('PORTO'), findsOneWidget);
      },
    );

    testWidgets(
      'mostra overlay de erro no layout wide',
      skip: skipMapWidgetTests,
      (tester) async {
        final mapController = MapController();
        addTearDown(mapController.dispose);

        await pumpBrewmapMaterialApp(
          tester,
          home: BreweryMapPanel(
            mapController: mapController,
            initialCenter: const LatLng(20, 0),
            initialZoom: 3,
            breweries: const [],
            selectedBreweryId: null,
            query: 'ipa',
            onBrewerySelect: (_) {},
            onMapTap: () {},
            searchStatus: BreweryStateStatus.error,
            resultsCount: 0,
            showSearchError: true,
            errorMessage: searchErrorMessage,
          ),
        );

        expect(find.text(searchErrorMessage), findsOneWidget);
      },
    );
  });
}
