import 'package:brewmap/core/utils/url_launcher_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.flutter.io/url_launcher');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('launchExternalUrl', () {
    testWidgets('retorna true quando o canal responde com sucesso', (
      tester,
    ) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'canLaunch') return true;
        if (call.method == 'launch') return true;
        return null;
      });

      late bool launched;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  launched = await launchExternalUrl(
                    context,
                    'https://example.com',
                  );
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();

      expect(launched, isTrue);
    });

    testWidgets('mostra SnackBar quando launch falha', (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'canLaunch') return true;
        if (call.method == 'launch') return false;
        return null;
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => launchExternalUrl(context, 'https://x.com'),
                  child: const Text('open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();

      expect(find.text('Não foi possível abrir o link.'), findsOneWidget);
    });

    testWidgets('retorna false para URL inválida', (tester) async {
      late bool launched;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  launched = await launchExternalUrl(context, '   ');
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();

      expect(launched, isFalse);
    });
  });
}
