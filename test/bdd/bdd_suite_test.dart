import 'package:brewmap/core/theme/google_fonts_setup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gherkart/gherkart.dart';
import 'package:flutter/services.dart';

import '../../integration_test/bdd/bdd_world.dart';
import '../../integration_test/bdd/steps/brewmap_steps.dart';

Future<void> _missingCallback(WidgetTester _) async {
  throw StateError('BDD adapter callback was not provided.');
}

/// Host-side BDD suite (VM). Same steps as [integration_test/bdd_suite_test.dart]
/// but uses [AutomatedTestWidgetsFlutterBinding] so pumps do not wait on device frames.
///
/// Run with:
/// `fvm flutter test test/bdd/bdd_suite_test.dart --dart-define=BREWMAP_BDD_TEST=true`
Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
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
