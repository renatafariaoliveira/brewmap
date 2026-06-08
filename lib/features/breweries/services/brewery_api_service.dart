import 'package:brewmap/core/logging/logger.dart';
import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:brewmap/core/network/api_client.dart';
import 'package:dio/dio.dart';

class BreweryApiService {
  final ApiClient api;

  BreweryApiService(this.api);

  Future<List<Brewery>> searchBreweries({
    required String query,
    int perPage = 20,
    CancelToken? cancelToken,
  }) async {
    final queryParams = <String, dynamic>{'query': query, 'per_page': perPage};

    try {
      final response = await api.get<List<dynamic>>(
        '/breweries/search',
        queryParameters: queryParams,
        cancelToken: cancelToken,
      );

      final breweries = <Brewery>[];
      for (final item in response) {
        if (item is! Map<String, dynamic>) continue;
        try {
          breweries.add(Brewery.fromJson(item));
        } catch (e, st) {
          logWarning(
            'Skipping invalid brewery from API response.',
            extras: {'error': e.toString()},
            stackTrace: st,
          );
        }
      }
      return breweries;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) rethrow;
      throw Exception(
        'Failed to search breweries [/breweries/search]. Error: $e',
      );
    } catch (e) {
      throw Exception(
        'Failed to search breweries [/breweries/search]. Error: $e',
      );
    }
  }
}
