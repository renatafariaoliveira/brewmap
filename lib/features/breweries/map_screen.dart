import 'package:brewmap/features/about/about_screen.dart';
import 'package:brewmap/features/breweries/components/brew_map_top_bar.dart';
import 'package:brewmap/features/breweries/components/brewery_explore_narrow_layout.dart';
import 'package:brewmap/features/breweries/components/brewery_explore_sidebar.dart';
import 'package:brewmap/features/breweries/components/brewery_map_panel.dart';
import 'package:brewmap/features/breweries/favorite_screen.dart';
import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:brewmap/features/breweries/models/brewery_type_model.dart';
import 'package:brewmap/core/config/brewmap_flags.dart';
import 'package:brewmap/core/config/locator.dart';
import 'package:brewmap/core/theme/theme.dart';
import 'package:brewmap/features/breweries/controllers/brewery_cubit.dart';
import 'package:brewmap/features/breweries/utils/brewery_list_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.onToggleTheme});
  final VoidCallback? onToggleTheme;

  @override
  State<MapScreen> createState() => _MapState();
}

class _MapState extends State<MapScreen> with SingleTickerProviderStateMixin {
  static const LatLng _kWorldMapCenter = LatLng(20, 0);
  static const double _kDefaultMapZoom = 13;
  static const double _kNoResultsMapZoom = 3;
  static const double _kSelectedBreweryZoom = 18;
  static const int _perPage = 4;

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final BreweryCubit _breweryCubit = getIt.get<BreweryCubit>();

  BreweryType? _selectedType;
  String? _selectedBreweryId;
  int _currentPage = 1;
  String _query = '';
  String? _lastSubmittedQuery;
  late final TabController _tabController;

  List<Brewery> _filteredFrom(List<Brewery> breweries) =>
      BreweryListFilter.apply(
        breweries,
        type: _selectedType,
        query: '',
      );

  List<Brewery> _paginatedFrom(List<Brewery> filtered) =>
      BreweryListFilter.paginate(
        filtered,
        page: _currentPage,
        perPage: _perPage,
      );

  Brewery? _selectedBreweryFrom(List<Brewery> breweries) =>
      BreweryListFilter.findById(breweries, _selectedBreweryId);

  void _selectBrewery(Brewery brewery) {
    setState(() => _selectedBreweryId = brewery.id);
    if (kBrewmapBddTest) return;
    final location = brewery.location;
    if (location != null) {
      _mapController.move(location, _kSelectedBreweryZoom);
    }
  }

  void _navigateMapToWorldView() {
    if (kBrewmapBddTest) return;
    _mapController.move(_kWorldMapCenter, _kNoResultsMapZoom);
  }

  void _navigateMapForSearchResults(List<Brewery> breweries) {
    if (kBrewmapBddTest) return;
    for (final brewery in breweries) {
      final location = brewery.location;
      if (location != null) {
        _mapController.move(location, _kDefaultMapZoom);
        return;
      }
    }
    _navigateMapToWorldView();
  }

  void _search() {
    final query = _searchController.text.trim();
    final status = _breweryCubit.state.status;

    if (query.isNotEmpty &&
        query == _lastSubmittedQuery &&
        (status == BreweryStateStatus.loading ||
            status == BreweryStateStatus.loaded)) {
      return;
    }

    setState(() {
      _query = query;
      _currentPage = 1;
      _selectedBreweryId = null;
    });

    if (query.isNotEmpty) {
      _lastSubmittedQuery = query;
      _breweryCubit.search(query);
    } else {
      _lastSubmittedQuery = null;
      _breweryCubit.clearSearch();
      _navigateMapToWorldView();
    }
  }

  void _onTypeChanged(BreweryType? next) {
    setState(() {
      _selectedType = next;
      _currentPage = 1;
      _selectedBreweryId = null;
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _selectedBreweryId = null;
    });
  }

  void _clearSelection() => setState(() => _selectedBreweryId = null);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == brewMapFavoritesTabIndex &&
        _selectedBreweryId != null) {
      _clearSelection();
    }
  }

  void _openAbout() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    final isNarrow =
        MediaQuery.sizeOf(context).width < BrewMapTopBar.compactBreakpoint;

    return BlocListener<BreweryCubit, BreweryState>(
      bloc: _breweryCubit,
      listenWhen: (previous, current) =>
          didSearchPresentationChange(previous, current) ||
          previous.favoriteErrorMessage != current.favoriteErrorMessage,
      listener: (context, state) {
        final favoriteError = state.favoriteErrorMessage;
        if (favoriteError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(favoriteError)),
          );
          _breweryCubit.clearFavoriteError();
        }

        if (state.status == BreweryStateStatus.loaded) {
          setState(() {
            _currentPage = 1;
            _selectedBreweryId = null;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _navigateMapForSearchResults(state.breweries);
          });
        }
        if (state.status == BreweryStateStatus.error) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _navigateMapForSearchResults(const []);
          });
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        body: Column(
          children: [
            ColoredBox(
              color: colors.surface,
              child: SafeArea(
                bottom: false,
                child: BrewMapTopBar(
                  tabController: _tabController,
                  onAboutTap: _openAbout,
                  onToggleTheme: widget.onToggleTheme,
                ),
              ),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                left: false,
                right: false,
                child: ListenableBuilder(
                  listenable: _tabController,
                  builder: (context, _) {
                    return IndexedStack(
                      index: _tabController.index,
                      sizing: StackFit.expand,
                      children: [
                        BlocBuilder<BreweryCubit, BreweryState>(
                          bloc: _breweryCubit,
                          buildWhen: didSearchPresentationChange,
                          builder: (context, state) {
                            return isNarrow
                                ? _buildNarrowLayout(state)
                                : _buildWideLayout(state);
                          },
                        ),
                        const FavoritesScreen(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(BreweryState state) {
    final breweries = state.searchResults;
    final filtered = _filteredFrom(breweries);
    final paginated = _paginatedFrom(filtered);

    return BreweryExploreNarrowLayout(
      mapController: _mapController,
      mapInitialCenter: _kWorldMapCenter,
      mapInitialZoom: _kNoResultsMapZoom,
      selectedBrewery: _selectedBreweryFrom(breweries),
      onBack: _clearSelection,
      searchController: _searchController,
      onSearch: _search,
      selectedType: _selectedType,
      onTypeChanged: _onTypeChanged,
      cubit: _breweryCubit,
      filteredBreweries: filtered,
      paginatedItems: paginated,
      selectedBreweryId: _selectedBreweryId,
      onBrewerySelect: _selectBrewery,
      query: _query,
      onMapTap: _clearSelection,
      currentPage: _currentPage,
      totalPages: BreweryListFilter.totalPages(filtered.length, _perPage),
      totalResults: filtered.length,
      onPageChanged: _onPageChanged,
      searchStatus: state.status,
      resultsCount: filtered.length,
    );
  }

  Widget _buildWideLayout(BreweryState state) {
    final breweries = state.searchResults;
    final filtered = _filteredFrom(breweries);
    final paginated = _paginatedFrom(filtered);

    return Row(
      children: [
        SizedBox(
          width: 480,
          child: BreweryExploreSidebar(
            selectedBrewery: _selectedBreweryFrom(breweries),
            onBack: _clearSelection,
            searchController: _searchController,
            onSearch: _search,
            selectedType: _selectedType,
            onTypeChanged: _onTypeChanged,
            cubit: _breweryCubit,
            paginatedItems: paginated,
            selectedBreweryId: _selectedBreweryId,
            onBrewerySelect: _selectBrewery,
            currentPage: _currentPage,
            totalPages: BreweryListFilter.totalPages(filtered.length, _perPage),
            totalResults: filtered.length,
            onPageChanged: _onPageChanged,
          ),
        ),
        Expanded(
          child: BreweryMapPanel(
            mapController: _mapController,
            initialCenter: _kWorldMapCenter,
            initialZoom: _kNoResultsMapZoom,
            breweries: filtered,
            selectedBreweryId: _selectedBreweryId,
            query: _query,
            onBrewerySelect: _selectBrewery,
            onMapTap: _clearSelection,
            showSearchError: true,
            searchStatus: state.status,
            errorMessage: state.errorMessage,
            resultsCount: filtered.length,
          ),
        ),
      ],
    );
  }
}
