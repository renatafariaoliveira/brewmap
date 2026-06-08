part of 'brewery_cubit.dart';

enum BreweryStateStatus { loading, loaded, error, initial }

@CopyWith()
class BreweryState {
  final List<Brewery> breweries;
  final BreweryStateStatus status;
  final String? errorMessage;
  final String? favoriteErrorMessage;
  final List<Brewery> favoriteBreweries;

  BreweryState({
    required this.breweries,
    required this.status,
    this.errorMessage,
    this.favoriteErrorMessage,
    required this.favoriteBreweries,
  });

  factory BreweryState.initial() => BreweryState(
    status: BreweryStateStatus.initial,
    breweries: [],
    errorMessage: null,
    favoriteErrorMessage: null,
    favoriteBreweries: [],
  );

  Set<String> get favoriteIds =>
      favoriteBreweries.map((brewery) => brewery.id).toSet();

  bool isFavorite(String breweryId) => favoriteIds.contains(breweryId);

  /// Breweries to show in explore UI (empty unless search succeeded).
  List<Brewery> get searchResults =>
      status == BreweryStateStatus.loaded ? breweries : [];
}

bool didSearchPresentationChange(
  BreweryState previous,
  BreweryState current,
) =>
    previous.status != current.status ||
    previous.breweries != current.breweries ||
    previous.errorMessage != current.errorMessage;
