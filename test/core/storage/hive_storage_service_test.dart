import 'dart:convert';

import 'package:brewmap/core/storage/hive_service.dart';
import 'package:brewmap/core/storage/key_value_store.dart';
import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeStore implements KeyValueStore {
  final Map<String, dynamic> _data = {};

  @override
  dynamic get(String key) => _data[key];

  @override
  Future<void> put(String key, dynamic value) async {
    _data[key] = value;
  }
}

void main() {
  group('HiveStorageService', () {
    test('loadFavorites retorna [] quando não há valor', () async {
      final store = _FakeStore();
      final service = HiveStorageService.forTesting(store);

      final result = await service.loadFavorites();
      expect(result, isEmpty);
    });

    test('loadFavorites retorna [] quando JSON é inválido', () async {
      final store = _FakeStore().._data['favorite_breweries'] = '{invalid json';
      final service = HiveStorageService.forTesting(store);

      final result = await service.loadFavorites();
      expect(result, isEmpty);
    });

    test('loadFavorites retorna [] quando JSON não é uma lista', () async {
      final store = _FakeStore()
        .._data['favorite_breweries'] = jsonEncode({'a': 1});
      final service = HiveStorageService.forTesting(store);

      final result = await service.loadFavorites();
      expect(result, isEmpty);
    });

    test('preserva favoritos válidos quando um item está corrompido', () async {
      final store = _FakeStore()
        .._data['favorite_breweries'] = jsonEncode([
          {'id': '1', 'name': 'Porto Brew', 'brewery_type': 'micro'},
          {'id': '2'},
          {'id': '3', 'name': 'Lisboa Beer', 'brewery_type': 'large'},
        ]);
      final service = HiveStorageService.forTesting(store);

      final loaded = await service.loadFavorites();

      expect(loaded.map((b) => b.id).toList(), ['1', '3']);
    });

    test('saveFavorite persiste lista e loadFavorites recupera', () async {
      final store = _FakeStore();
      final service = HiveStorageService.forTesting(store);

      final breweries = [
        Brewery(
          id: '1',
          name: 'Porto Brew',
          city: 'Porto',
          state: 'Porto',
          country: 'Portugal',
        ),
        Brewery(
          id: '2',
          name: 'Lisboa Beer',
          city: 'Lisboa',
          state: 'Lisboa',
          country: 'Portugal',
        ),
      ];

      await service.saveFavorite(breweries);
      final loaded = await service.loadFavorites();

      expect(loaded.map((b) => b.id).toList(), ['1', '2']);
      expect(loaded.first.name, 'Porto Brew');
    });

    test('loadThemeMode retorna dark quando não há valor', () async {
      final service = HiveStorageService.forTesting(_FakeStore());

      expect(await service.loadThemeMode(), ThemeMode.dark);
    });

    test('loadThemeMode retorna dark quando valor é inválido', () async {
      final store = _FakeStore().._data['theme_mode'] = 'invalid';
      final service = HiveStorageService.forTesting(store);

      expect(await service.loadThemeMode(), ThemeMode.dark);
    });

    test('saveThemeMode persiste e loadThemeMode recupera', () async {
      final store = _FakeStore();
      final service = HiveStorageService.forTesting(store);

      await service.saveThemeMode(ThemeMode.light);
      expect(await service.loadThemeMode(), ThemeMode.light);

      await service.saveThemeMode(ThemeMode.dark);
      expect(await service.loadThemeMode(), ThemeMode.dark);
    });
  });
}

