@Tags(['integration', 'network'])
library;

import 'package:brewmap/core/network/api_client.dart';
import 'package:brewmap/core/network/dio_client.dart';
import 'package:brewmap/features/breweries/services/brewery_api_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Opt-in live API test. Run with:
/// `fvm flutter test test/integration --dart-define=BREWMAP_LIVE_API_TEST=true`
void main() {
  final runLive = const bool.fromEnvironment('BREWMAP_LIVE_API_TEST');

  group('Open Brewery DB (live)', () {
    test(
      'searchBreweries retorna resultados para query conhecida',
      skip: runLive ? false : 'Defina BREWMAP_LIVE_API_TEST=true',
      () async {
        final dio = DioClient.create(enableLogging: false).dio;
        final service = BreweryApiService(ApiClient(dio));

        final results = await service.searchBreweries(
          query: 'portland',
          perPage: 5,
        );

        expect(results, isNotEmpty);
        expect(results.first.name, isNotEmpty);
        expect(results.first.id, isNotEmpty);
      },
    );
  });
}
