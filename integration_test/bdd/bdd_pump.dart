import 'package:flutter_test/flutter_test.dart';

/// Prepares the test binding for BDD runs (map tiles, panel animations).
void bddPrepareBinding(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(
        disableAnimations: true,
        reduceMotion: true,
      );
}

/// Pumps a bounded number of frames without [pumpAndSettle].
Future<void> bddPump(
  WidgetTester tester, {
  int frames = 8,
  Duration frameTime = const Duration(milliseconds: 100),
}) async {
  await tester.pump();
  for (var i = 0; i < frames; i++) {
    await tester.pump(frameTime);
  }
}

Future<void> bddTap(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await bddPump(tester);
}

/// Enters text without [WidgetTester.enterText], which awaits [idle] and can hang.
Future<void> bddEnterText(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.tap(finder);
  await bddPump(tester);
  tester.testTextInput.enterText(text);
  await bddPump(tester);
}

/// Pumps until [finder] matches or [maxAttempts] is reached (no [pumpAndSettle]).
Future<void> bddPumpUntil(
  WidgetTester tester,
  Finder finder, {
  int maxAttempts = 30,
}) async {
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    if (finder.evaluate().isNotEmpty) return;
    await bddPump(tester, frames: 2, frameTime: const Duration(milliseconds: 50));
  }
}
