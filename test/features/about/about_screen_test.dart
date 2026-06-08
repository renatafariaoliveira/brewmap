import 'package:brewmap/features/about/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/brewmap_test_harness.dart';

void main() {
  group('AboutScreen', () {
    testWidgets('renderiza informações principais do projeto', (tester) async {
      await pumpBrewmapMaterialApp(
        tester,
        home: const AboutScreen(),
      );

      expect(find.text('BrewMap'), findsWidgets);
      expect(find.text('Renata Oliveira'), findsOneWidget);
      expect(find.text('Filipe Barroso'), findsOneWidget);
      expect(find.text('O QUE É'), findsOneWidget);
      expect(find.textContaining('Open Brewery DB'), findsWidgets);
    });

    testWidgets('botão voltar fecha a tela', (tester) async {
      await pumpBrewmapMaterialApp(
        tester,
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AboutScreen(),
                  ),
                );
              },
              child: const Text('open-about'),
            );
          },
        ),
      );

      await tester.tap(find.text('open-about'));
      await pumpWidgetFrames(tester);

      expect(find.byType(AboutScreen), findsOneWidget);

      await tester.tap(find.text('Voltar'));
      await pumpWidgetFrames(tester);

      expect(find.byType(AboutScreen), findsNothing);
    });
  });
}
