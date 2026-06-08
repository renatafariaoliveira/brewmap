import 'package:brewmap/core/theme/google_fonts_setup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gherkart/gherkart.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/services.dart';

import 'bdd/bdd_world.dart';
import 'bdd/steps/brewmap_steps.dart';

Future<void> _missingCallback(WidgetTester _) async {
  throw StateError('BDD adapter callback was not provided.');
}

/// Device integration BDD. Requires a connected device/emulator.
///
/// Prefer the VM suite when developing offline:
/// `fvm flutter test test/bdd/bdd_suite_test.dart --dart-define=BREWMAP_BDD_TEST=true`
///
/// Device run:
/// `fvm flutter test integration_test/bdd_suite_test.dart -d <device> --dart-define=BREWMAP_BDD_TEST=true`
Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  configureOfflineGoogleFonts();

  final world = BddWorld();
  final registry = createBrewmapSteps(world);

  await runBddTests<WidgetTester>(
    rootPaths: const [
      'features/bdd/favorites.feature',
      'features/bdd/search.feature',
    ],
    registry: registry,
    source: AssetSource.fromLoader((path) => rootBundle.loadString(path)),
    adapter: TestAdapter<WidgetTester>(
      testFunction: (
        String name, {
        List<String>? tags,
        bool skip = false,
        Future<void> Function(WidgetTester context) callback = _missingCallback,
      }) {
        testWidgets(name, (tester) async => callback(tester), skip: skip);
      },
      group: group,
      setUpAll: setUpAll,
      tearDownAll: tearDownAll,
      fail: (message) => fail(message),
    ),
    output: const BddOutput.steps(),
  );
}

