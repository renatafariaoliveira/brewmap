import 'package:brewmap/core/config/locator.dart';
import 'package:brewmap/core/network/api_client.dart';
import 'package:brewmap/core/storage/hive_service.dart';
import 'package:brewmap/core/theme/theme.dart';
import 'package:brewmap/features/breweries/controllers/brewery_cubit.dart';
import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:brewmap/features/breweries/services/brewery_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shared fakes for widget and service tests (same contract as BDD fakes).
class FakeBreweryApiService implements BreweryApiService {
  bool shouldThrow = false;
  List<Brewery> results = _defaultResults;

  static List<Brewery> get defaultResults => List.unmodifiable(_defaultResults);

  static final List<Brewery> _defaultResults = [
    Brewery(
      id: 'brew-1',
      name: 'Porto Brew',
      city: 'Porto',
      state: 'Porto',
      country: 'Portugal',
      latitude: 41.1579,
      longitude: -8.6291,
    ),
    Brewery(
      id: 'brew-2',
      name: 'Lisboa Beer',
      city: 'Lisboa',
      state: 'Lisboa',
      country: 'Portugal',
      latitude: 38.7223,
      longitude: -9.1393,
    ),
  ];

  @override
  ApiClient get api => throw UnimplementedError();

  @override
  Future<List<Brewery>> searchBreweries({
    required String query,
    int perPage = 20,
    CancelToken? cancelToken,
  }) async {
    if (shouldThrow) {
      throw Exception('Erro ao buscar cervejarias');
    }
    return List<Brewery>.from(results);
  }
}

class InMemoryHiveStorageService implements HiveStorageService {
  List<Brewery> favorites = [];
  ThemeMode themeMode = ThemeMode.dark;

  @override
  Future<void> init() async {}

  @override
  Future<List<Brewery>> loadFavorites() async =>
      List<Brewery>.from(favorites);

  @override
  Future<void> saveFavorite(List<Brewery> breweries) async {
    favorites = List<Brewery>.from(breweries);
  }

  @override
  Future<ThemeMode> loadThemeMode() async => themeMode;

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    themeMode = mode;
  }
}

Future<void> resetBrewmapTestHarness({
  FakeBreweryApiService? api,
  InMemoryHiveStorageService? storage,
  bool resetFakes = true,
}) async {
  await getIt.reset(dispose: true);

  final fakeApi = api ?? FakeBreweryApiService();
  final fakeStorage = storage ?? InMemoryHiveStorageService();

  if (resetFakes) {
    fakeApi.shouldThrow = false;
    fakeApi.results = FakeBreweryApiService._defaultResults;
    fakeStorage.favorites = [];
  }

  getIt.registerSingleton<HiveStorageService>(fakeStorage);
  getIt.registerSingleton<BreweryApiService>(fakeApi);

  final cubit = BreweryCubit(
    service: fakeApi,
    storageService: fakeStorage,
  );
  await cubit.loadFavorites();
  getIt.registerSingleton<BreweryCubit>(cubit);
}

void prepareWidgetTestBinding(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(
        disableAnimations: true,
        reduceMotion: true,
      );
}

Future<void> pumpWidgetFrames(
  WidgetTester tester, {
  int frames = 8,
  Duration frameTime = const Duration(milliseconds: 100),
}) async {
  await tester.pump();
  for (var i = 0; i < frames; i++) {
    await tester.pump(frameTime);
  }
}

Future<void> pumpBrewmapMaterialApp(
  WidgetTester tester, {
  required Widget home,
}) async {
  prepareWidgetTestBinding(tester);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildBrewDarkTheme(),
      home: home,
    ),
  );
  await pumpWidgetFrames(tester);
}

Widget wrapWithBrewTheme(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildBrewDarkTheme(),
    home: Scaffold(body: child),
  );
}

/// Map UI tests need the compile-time BDD flag to avoid network tiles.
bool get skipMapWidgetTests =>
    !const bool.fromEnvironment('BREWMAP_BDD_TEST');

/// Runs cubit async work outside the fake async zone (avoids deadlocks when
/// [BreweryFavoriteCard] animation controllers are mounted).
Future<void> runCubitAsync(
  WidgetTester tester,
  Future<void> Function() action,
) =>
    tester.runAsync(action);
