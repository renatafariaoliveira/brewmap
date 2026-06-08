import 'package:brewmap/features/breweries/components/pagination_widget.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/brewmap_test_harness.dart';

void main() {
  group('PaginationBar', () {
    testWidgets('exibe contagem e dispara onPageChanged', (tester) async {
      var selectedPage = 1;

      await tester.pumpWidget(
        wrapWithBrewTheme(
          PaginationBar(
            currentPage: 1,
            totalPages: 3,
            totalResults: 12,
            showing: 4,
            onPageChanged: (page) => selectedPage = page,
          ),
        ),
      );
      await pumpWidgetFrames(tester);

      expect(find.text('12'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.text('2'));
      await pumpWidgetFrames(tester);

      expect(selectedPage, 2);
    });

    testWidgets('destaca página atual', (tester) async {
      await tester.pumpWidget(
        wrapWithBrewTheme(
          PaginationBar(
            currentPage: 2,
            totalPages: 3,
            totalResults: 12,
            showing: 4,
            onPageChanged: (_) {},
          ),
        ),
      );
      await pumpWidgetFrames(tester);

      expect(find.text('2'), findsWidgets);
      expect(find.text('3'), findsOneWidget);
    });
  });
}
