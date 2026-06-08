/// Minimal key-value storage abstraction used by [HiveStorageService].
///
/// Purpose: keep the production implementation (Hive) while allowing simple
/// unit tests via fakes without having to implement Hive's full [Box] API.
abstract interface class KeyValueStore {
  dynamic get(String key);

  Future<void> put(String key, dynamic value);
}

