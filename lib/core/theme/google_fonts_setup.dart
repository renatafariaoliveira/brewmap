import 'package:google_fonts/google_fonts.dart';

/// Uses only fonts listed under [google_fonts/] in `pubspec.yaml` (no HTTP).
///
/// Call from test/bootstrap entrypoints so widget and integration tests run
/// without network access.
void configureOfflineGoogleFonts() {
  GoogleFonts.config.allowRuntimeFetching = false;
}
