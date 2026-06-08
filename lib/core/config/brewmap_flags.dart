/// Compile-time flags for Brewmap test and tooling entrypoints.
///
/// Integration BDD runs with:
/// `fvm flutter test integration_test/bdd_suite_test.dart --dart-define=BREWMAP_BDD_TEST=true`
const bool kBrewmapBddTest = bool.fromEnvironment('BREWMAP_BDD_TEST');
