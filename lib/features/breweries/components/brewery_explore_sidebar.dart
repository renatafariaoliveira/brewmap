import 'package:brewmap/core/theme/theme.dart';
import 'package:brewmap/features/breweries/components/brewery_list_section.dart';
import 'package:brewmap/features/breweries/components/brewery_paginated_list.dart';
import 'package:brewmap/features/breweries/components/brewery_pagination_section.dart';
import 'package:brewmap/features/breweries/components/brewery_search_filters_block.dart';
import 'package:brewmap/features/breweries/components/detail_panel.dart';
import 'package:brewmap/features/breweries/controllers/brewery_cubit.dart';
import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:brewmap/features/breweries/models/brewery_type_model.dart';
import 'package:flutter/material.dart';

class BreweryExploreSidebar extends StatelessWidget {
  const BreweryExploreSidebar({
    super.key,
    required this.selectedBrewery,
    required this.onBack,
    required this.searchController,
    required this.onSearch,
    required this.selectedType,
    required this.onTypeChanged,
    required this.cubit,
    required this.paginatedItems,
    required this.selectedBreweryId,
    required this.onBrewerySelect,
    required this.currentPage,
    required this.totalPages,
    required this.totalResults,
    required this.onPageChanged,
  });

  final Brewery? selectedBrewery;
  final VoidCallback onBack;
  final TextEditingController searchController;
  final VoidCallback onSearch;
  final BreweryType? selectedType;
  final ValueChanged<BreweryType?> onTypeChanged;
  final BreweryCubit cubit;
  final List<Brewery> paginatedItems;
  final String? selectedBreweryId;
  final ValueChanged<Brewery> onBrewerySelect;
  final int currentPage;
  final int totalPages;
  final int totalResults;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;

    return Container(
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedBrewery == null) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: SingleChildScrollView(
                      child: BrewerySearchFiltersBlock(
                        searchController: searchController,
                        onSearch: onSearch,
                        selectedType: selectedType,
                        onTypeChanged: onTypeChanged,
                        showDivider: true,
                      ),
                    ),
                  ),
                  Expanded(
                    child: BreweryListSection(
                      cubit: cubit,
                      child: BreweryPaginatedList(
                        items: paginatedItems,
                        selectedBreweryId: selectedBreweryId,
                        onSelect: onBrewerySelect,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            BreweryPaginationSection(
              cubit: cubit,
              currentPage: currentPage,
              totalPages: totalPages,
              totalResults: totalResults,
              showing: paginatedItems.length,
              onPageChanged: onPageChanged,
            ),
          ] else
            Expanded(
              child: BreweryDetailPanel(
                brewery: selectedBrewery!,
                onBack: onBack,
              ),
            ),
        ],
      ),
    );
  }
}
