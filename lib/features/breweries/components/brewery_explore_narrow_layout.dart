import 'package:brewmap/core/theme/theme.dart';
import 'package:brewmap/features/breweries/components/brewery_list_panel.dart';
import 'package:brewmap/features/breweries/components/brewery_map_panel.dart';
import 'package:brewmap/features/breweries/components/brewery_search_filters_block.dart';
import 'package:brewmap/features/breweries/components/detail_panel.dart';
import 'package:brewmap/features/breweries/controllers/brewery_cubit.dart';
import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:brewmap/features/breweries/models/brewery_type_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class BreweryExploreNarrowLayout extends StatelessWidget {
  const BreweryExploreNarrowLayout({
    super.key,
    required this.mapController,
    required this.mapInitialCenter,
    required this.mapInitialZoom,
    required this.selectedBrewery,
    required this.onBack,
    required this.searchController,
    required this.onSearch,
    required this.selectedType,
    required this.onTypeChanged,
    required this.cubit,
    required this.filteredBreweries,
    required this.paginatedItems,
    required this.selectedBreweryId,
    required this.onBrewerySelect,
    required this.query,
    required this.onMapTap,
    required this.currentPage,
    required this.totalPages,
    required this.totalResults,
    required this.onPageChanged,
    required this.searchStatus,
    required this.resultsCount,
  });

  final MapController mapController;
  final LatLng mapInitialCenter;
  final double mapInitialZoom;
  final Brewery? selectedBrewery;
  final VoidCallback onBack;
  final TextEditingController searchController;
  final VoidCallback onSearch;
  final BreweryType? selectedType;
  final ValueChanged<BreweryType?> onTypeChanged;
  final BreweryCubit cubit;
  final List<Brewery> filteredBreweries;
  final List<Brewery> paginatedItems;
  final String? selectedBreweryId;
  final ValueChanged<Brewery> onBrewerySelect;
  final String query;
  final VoidCallback onMapTap;
  final int currentPage;
  final int totalPages;
  final int totalResults;
  final ValueChanged<int> onPageChanged;
  final BreweryStateStatus searchStatus;
  final int resultsCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;

    return Column(
      children: [
        if (selectedBrewery == null)
          Flexible(
            fit: FlexFit.loose,
            flex: 0,
            child: SingleChildScrollView(
              child: BrewerySearchFiltersBlock(
                searchController: searchController,
                onSearch: onSearch,
                selectedType: selectedType,
                onTypeChanged: onTypeChanged,
              ),
            ),
          ),
        Expanded(
          flex: 2,
          child: BreweryMapPanel(
            mapController: mapController,
            initialCenter: mapInitialCenter,
            initialZoom: mapInitialZoom,
            breweries: filteredBreweries,
            selectedBreweryId: selectedBreweryId,
            query: query,
            onBrewerySelect: onBrewerySelect,
            onMapTap: onMapTap,
            searchStatus: searchStatus,
            resultsCount: resultsCount,
          ),
        ),
        if (selectedBrewery == null)
          Expanded(
            flex: 2,
            child: BreweryListPanel(
              cubit: cubit,
              items: paginatedItems,
              selectedBreweryId: selectedBreweryId,
              onSelect: onBrewerySelect,
              currentPage: currentPage,
              totalPages: totalPages,
              totalResults: totalResults,
              onPageChanged: onPageChanged,
            ),
          )
        else
          Expanded(
            flex: 2,
            child: ColoredBox(
              color: colors.surface,
              child: BreweryDetailPanel(
                brewery: selectedBrewery!,
                onBack: onBack,
              ),
            ),
          ),
      ],
    );
  }
}
