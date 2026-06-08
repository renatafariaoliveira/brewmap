import 'package:brewmap/core/config/locator.dart';
import 'package:brewmap/core/theme/theme.dart';
import 'package:brewmap/features/breweries/controllers/brewery_cubit.dart';
import 'package:brewmap/features/breweries/map_screen.dart';
import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:brewmap/features/breweries/services/brewery_api_service.dart';
import 'package:brewmap/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:brewmap/core/storage/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'bdd_pump.dart';

class BddWorld {
  BddWorld();

  final fakeApi = _FakeBreweryApiService();
  final fakeStorage = _InMemoryHiveStorageService();

  String? selectedBreweryName;

  Future<void> openApp(WidgetTester tester) async {
    bddPrepareBinding(tester);
    await _registerDependencies(resetState: true);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildBrewDarkTheme(),
        home: const MapScreen(),
      ),
    );
    await bddPump(tester);
  }

  Future<void> restartApp(WidgetTester tester) async {
    bddPrepareBinding(tester);
    // Simulate "app restart" while keeping storage in-memory instance.
    await tester.pumpWidget(const SizedBox.shrink());
    await bddPump(tester);

    await _registerDependencies(resetState: false);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildBrewDarkTheme(),
        home: const MapScreen(),
      ),
    );
    await bddPump(tester);
  }

  Future<void> seedFavorite(Brewery brewery) async {
    fakeStorage.favorites = [brewery];
    final cubit = getIt<BreweryCubit>();
    await cubit.loadFavorites();
  }

  Future<void> _registerDependencies({required bool resetState}) async {
    await getIt.reset(dispose: true);

    if (resetState) {
      fakeApi.shouldThrow = false;
      fakeStorage.favorites = [];
      fakeStorage.themeMode = ThemeMode.dark;
    }

    getIt.registerSingleton<HiveStorageService>(fakeStorage);
    getIt.registerSingleton<BreweryApiService>(fakeApi);
    final cubit = BreweryCubit(service: fakeApi, storageService: fakeStorage);
    await cubit.loadFavorites();
    getIt.registerSingleton<BreweryCubit>(cubit);
  }
}

class _InMemoryHiveStorageService implements HiveStorageService {
  List<Brewery> favorites = [];
  ThemeMode themeMode = ThemeMode.dark;

  @override
  Future<void> init() async {}

  @override
  Future<List<Brewery>> loadFavorites() async => List<Brewery>.from(favorites);

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

class _FakeBreweryApiService implements BreweryApiService {
  bool shouldThrow = false;

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

    return [
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
  }
}

