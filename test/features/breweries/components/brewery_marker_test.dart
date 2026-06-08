import 'package:brewmap/features/breweries/components/brewery_marker.dart';
import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import '../../../helpers/brewmap_test_harness.dart';

void main() {
  group('buildMarkers', () {
    test('ignora cervejarias sem coordenadas', () {
      final markers = buildMarkers(
        breweries: [
          Brewery(id: '1', name: 'No GPS'),
          Brewery(
            id: '2',
            name: 'With GPS',
            latitude: 41.15,
            longitude: -8.62,
          ),
        ],
        selectedId: null,
        onSelect: (_) {},
      );

      expect(markers, hasLength(1));
      expect(markers.first.point, const LatLng(41.15, -8.62));
    });

    test('marcador selecionado tem altura maior', () {
      final markers = buildMarkers(
        breweries: [
          Brewery(
            id: '1',
            name: 'A',
            latitude: 1,
            longitude: 1,
          ),
        ],
        selectedId: '1',
        onSelect: (_) {},
      );

      expect(markers.first.height, 75);
      final child = markers.first.child;
      expect(child, isA<BreweryMarker>());
      expect((child as BreweryMarker).isSelected, isTrue);
    });
  });

  group('BreweryMarker', () {
    testWidgets('dispara onTap', (tester) async {
      var tapped = false;
      await tester.binding.setSurfaceSize(const Size(400, 400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        wrapWithBrewTheme(
          Center(
            child: BreweryMarker(
              brewery: Brewery(id: '1', name: 'Porto Brew'),
              isSelected: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await pumpWidgetFrames(tester);

      await tester.tap(find.text('Porto Brew'));
      expect(tapped, isTrue);
    });
  });
}
