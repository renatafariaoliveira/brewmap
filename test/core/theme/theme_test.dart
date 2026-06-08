import 'package:brewmap/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildBrewDarkTheme/buildBrewLightTheme', () {
    testWidgets('inclui BrewColors como ThemeExtension (dark)', (tester) async {
      late BrewColors? ext;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildBrewDarkTheme(),
          home: Builder(
            builder: (context) {
              ext = Theme.of(context).extension<BrewColors>();
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(ext, isNotNull);
      expect(ext!.background, BrewColors.dark.background);
      expect(ext!.mapTileUrlTemplate, BrewColors.dark.mapTileUrlTemplate);
    });

    testWidgets('inclui BrewColors como ThemeExtension (light)', (tester) async {
      late BrewColors? ext;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildBrewLightTheme(),
          home: Builder(
            builder: (context) {
              ext = Theme.of(context).extension<BrewColors>();
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(ext, isNotNull);
      expect(ext!.background, BrewColors.light.background);
      expect(ext!.mapTileUrlTemplate, BrewColors.light.mapTileUrlTemplate);
    });
  });

  group('BrewColorsContext', () {
    testWidgets('context.brewColors retorna o extension registrado', (tester) async {
      late BrewColors colors;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildBrewDarkTheme(),
          home: Builder(
            builder: (context) {
              colors = context.brewColors;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(colors.background, BrewColors.dark.background);
      expect(colors.onAccent, BrewColors.dark.onAccent);
    });
  });
}

