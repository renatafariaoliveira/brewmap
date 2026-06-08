import 'dart:convert';
import 'package:brewmap/core/logging/logger.dart';
import 'package:brewmap/core/storage/key_value_store.dart';
import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveStorageService {
  static const _boxName = 'app_storage';
  static const _favoriteBreweriesKey = 'favorite_breweries';
  static const _themeModeKey = 'theme_mode';

  late final KeyValueStore _store;

  HiveStorageService();

  Future<void> init() async {
    await Hive.initFlutter();
    final box = await Hive.openBox(_boxName);
    _store = _HiveBoxStore(box);
  }

  /// Test-only constructor hook to inject a store without initializing Hive.
  HiveStorageService.forTesting(KeyValueStore store) : _store = store;

  Future<List<Brewery>> loadFavorites() async =>
      _decodeBreweryList(_store.get(_favoriteBreweriesKey) as String?);

  Future<void> saveFavorite(List<Brewery> breweries) async {
    final encoded = jsonEncode(breweries.map((b) => b.toJson()).toList());
    await _store.put(_favoriteBreweriesKey, encoded);
  }

  Future<ThemeMode> loadThemeMode() async {
    final raw = _store.get(_themeModeKey);
    if (raw is! String) return ThemeMode.dark;

    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.dark,
    };
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'dark',
    };
    await _store.put(_themeModeKey, value);
  }

  List<Brewery> _decodeBreweryList(String? raw) {
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      final favorites = <Brewery>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        try {
          favorites.add(
            Brewery.fromJson(Map<String, dynamic>.from(item)),
          );
        } catch (e, st) {
          logWarning(
            'Skipping invalid favorite brewery from Hive.',
            extras: {'error': e.toString()},
            stackTrace: st,
          );
        }
      }
      return favorites;
    } catch (e, st) {
      logWarning(
        'Failed to decode favorite breweries from Hive.',
        extras: {'error': e.toString()},
        stackTrace: st,
      );
      return [];
    }
  }
}

class _HiveBoxStore implements KeyValueStore {
  _HiveBoxStore(this._box);

  final Box _box;

  @override
  dynamic get(String key) => _box.get(key);

  @override
  Future<void> put(String key, dynamic value) => _box.put(key, value);
}
