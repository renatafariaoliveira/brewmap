// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brewery_cubit.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BreweryStateCWProxy {
  BreweryState breweries(List<Brewery> breweries);

  BreweryState status(BreweryStateStatus status);

  BreweryState errorMessage(String? errorMessage);

  BreweryState favoriteErrorMessage(String? favoriteErrorMessage);

  BreweryState favoriteBreweries(List<Brewery> favoriteBreweries);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BreweryState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BreweryState(...).copyWith(id: 12, name: "My name")
  /// ```
  BreweryState call({
    List<Brewery> breweries,
    BreweryStateStatus status,
    String? errorMessage,
    String? favoriteErrorMessage,
    List<Brewery> favoriteBreweries,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfBreweryState.copyWith(...)` or call `instanceOfBreweryState.copyWith.fieldName(value)` for a single field.
class _$BreweryStateCWProxyImpl implements _$BreweryStateCWProxy {
  const _$BreweryStateCWProxyImpl(this._value);

  final BreweryState _value;

  @override
  BreweryState breweries(List<Brewery> breweries) => call(breweries: breweries);

  @override
  BreweryState status(BreweryStateStatus status) => call(status: status);

  @override
  BreweryState errorMessage(String? errorMessage) =>
      call(errorMessage: errorMessage);

  @override
  BreweryState favoriteErrorMessage(String? favoriteErrorMessage) =>
      call(favoriteErrorMessage: favoriteErrorMessage);

  @override
  BreweryState favoriteBreweries(List<Brewery> favoriteBreweries) =>
      call(favoriteBreweries: favoriteBreweries);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BreweryState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BreweryState(...).copyWith(id: 12, name: "My name")
  /// ```
  BreweryState call({
    Object? breweries = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? errorMessage = const $CopyWithPlaceholder(),
    Object? favoriteErrorMessage = const $CopyWithPlaceholder(),
    Object? favoriteBreweries = const $CopyWithPlaceholder(),
  }) {
    return BreweryState(
      breweries: breweries == const $CopyWithPlaceholder() || breweries == null
          ? _value.breweries
          // ignore: cast_nullable_to_non_nullable
          : breweries as List<Brewery>,
      status: status == const $CopyWithPlaceholder() || status == null
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as BreweryStateStatus,
      errorMessage: errorMessage == const $CopyWithPlaceholder()
          ? _value.errorMessage
          // ignore: cast_nullable_to_non_nullable
          : errorMessage as String?,
      favoriteErrorMessage: favoriteErrorMessage == const $CopyWithPlaceholder()
          ? _value.favoriteErrorMessage
          // ignore: cast_nullable_to_non_nullable
          : favoriteErrorMessage as String?,
      favoriteBreweries:
          favoriteBreweries == const $CopyWithPlaceholder() ||
              favoriteBreweries == null
          ? _value.favoriteBreweries
          // ignore: cast_nullable_to_non_nullable
          : favoriteBreweries as List<Brewery>,
    );
  }
}

extension $BreweryStateCopyWith on BreweryState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfBreweryState.copyWith(...)` or `instanceOfBreweryState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BreweryStateCWProxy get copyWith => _$BreweryStateCWProxyImpl(this);
}
