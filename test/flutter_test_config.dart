import 'dart:async';

import 'package:brewmap/core/theme/google_fonts_setup.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  configureOfflineGoogleFonts();
  await testMain();
}
