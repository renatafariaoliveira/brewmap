import 'package:brewmap/features/breweries/services/brewery_api_service.dart';
import 'package:brewmap/core/network/api_client.dart';
import 'package:brewmap/core/network/dio_client.dart';
import 'package:brewmap/core/storage/hive_service.dart';
import 'package:brewmap/features/breweries/controllers/brewery_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> bootstrap() async {
  if (!getIt.isRegistered<ApiClient>()) {
    final dioClient = DioClient.create(enableLogging: kDebugMode);
    getIt.registerSingleton(ApiClient(dioClient.dio));
  }

  if (!getIt.isRegistered<HiveStorageService>()) {
    final hiveStorage = HiveStorageService();
    await hiveStorage.init();
    getIt.registerSingleton(hiveStorage);
  }

  if (!getIt.isRegistered<BreweryApiService>()) {
    getIt.registerLazySingleton(() => BreweryApiService(getIt<ApiClient>()));
  }

  if (!getIt.isRegistered<BreweryCubit>()) {
    final breweryCubit = BreweryCubit(
      service: getIt<BreweryApiService>(),
      storageService: getIt<HiveStorageService>(),
    );
    await breweryCubit.loadFavorites();
    getIt.registerSingleton<BreweryCubit>(
      breweryCubit,
      dispose: (cubit) => cubit.close(),
    );
  }
}
