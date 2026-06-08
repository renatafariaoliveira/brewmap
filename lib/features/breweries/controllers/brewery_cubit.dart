import 'dart:async';

import 'package:brewmap/core/logging/logger.dart';
import 'package:brewmap/core/storage/hive_service.dart';
import 'package:brewmap/core/utils/cubit.dart';
import 'package:brewmap/core/utils/error_message.dart';
import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:brewmap/features/breweries/services/brewery_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';

part 'brewery_cubit.g.dart';
part 'brewery_state.dart';

class BreweryCubit extends Cubit<BreweryState> {
  final BreweryApiService service;
  final HiveStorageService storageService;

  CancelToken? _searchCancelToken;
  int _searchGeneration = 0;
  Future<void> _favoriteLock = Future<void>.value();

  BreweryCubit({required this.service, required this.storageService})
    : super(BreweryState.initial());

  Future<void> loadFavorites() async {
    try {
      final favorites = await storageService.loadFavorites();
      safeEmit(state.copyWith(favoriteBreweries: favorites));
    } catch (e, st) {
      logWarning(
        'Failed to load favorite breweries.',
        extras: {'error': e.toString()},
        stackTrace: st,
      );
      safeEmit(state.copyWith(favoriteBreweries: []));
    }
  }

  Future<void> toggleFavorite(Brewery brewery) async {
    final previous = _favoriteLock;
    final completer = Completer<void>();
    _favoriteLock = completer.future;

    await previous;
    try {
      await _toggleFavoriteImpl(brewery);
      completer.complete();
    } catch (e, st) {
      completer.completeError(e, st);
      rethrow;
    }
  }

  Future<void> _toggleFavoriteImpl(Brewery brewery) async {
    final updated = List<Brewery>.from(state.favoriteBreweries);
    final index = updated.indexWhere((b) => b.id == brewery.id);
    if (index >= 0) {
      updated.removeAt(index);
    } else {
      updated.add(brewery);
    }

    try {
      await storageService.saveFavorite(updated);
      safeEmit(
        state.copyWith(
          favoriteBreweries: updated,
          favoriteErrorMessage: null,
        ),
      );
    } catch (e) {
      safeEmit(
        state.copyWith(
          favoriteErrorMessage: userFacingErrorMessage(
            e,
            fallback: favoriteErrorMessage,
          ),
        ),
      );
    }
  }

  void clearFavoriteError() {
    if (state.favoriteErrorMessage == null) return;
    safeEmit(state.copyWith(favoriteErrorMessage: null));
  }

  void clearSearch() {
    _invalidateSearch();
    safeEmit(
      state.copyWith(
        status: BreweryStateStatus.initial,
        breweries: [],
        errorMessage: null,
      ),
    );
  }

  void _invalidateSearch() {
    _searchCancelToken?.cancel();
    _searchCancelToken = null;
    _searchGeneration++;
  }

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return;
    }

    _invalidateSearch();
    final generation = _searchGeneration;
    final cancelToken = CancelToken();
    _searchCancelToken = cancelToken;

    safeEmit(
      state.copyWith(
        status: BreweryStateStatus.loading,
        breweries: [],
        errorMessage: null,
      ),
    );

    try {
      final result = await service.searchBreweries(
        query: trimmed,
        cancelToken: cancelToken,
      );

      if (!_isCurrentSearch(generation)) return;

      safeEmit(
        state.copyWith(
          status: BreweryStateStatus.loaded,
          breweries: result,
          errorMessage: null,
        ),
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e) || !_isCurrentSearch(generation)) return;
      safeEmit(
        state.copyWith(
          status: BreweryStateStatus.error,
          breweries: [],
          errorMessage: userFacingErrorMessage(
            e,
            fallback: searchErrorMessage,
          ),
        ),
      );
    } catch (e) {
      if (!_isCurrentSearch(generation)) return;
      safeEmit(
        state.copyWith(
          status: BreweryStateStatus.error,
          breweries: [],
          errorMessage: userFacingErrorMessage(
            e,
            fallback: searchErrorMessage,
          ),
        ),
      );
    } finally {
      if (_searchCancelToken == cancelToken) {
        _searchCancelToken = null;
      }
    }
  }

  bool _isCurrentSearch(int generation) => generation == _searchGeneration;
}
