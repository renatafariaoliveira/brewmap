import 'package:brewmap/core/theme/theme.dart';
import 'package:brewmap/features/breweries/components/brew_search_header.dart';
import 'package:brewmap/features/breweries/components/brew_type_filters.dart';
import 'package:brewmap/features/breweries/models/brewery_type_model.dart';
import 'package:flutter/material.dart';

class BrewerySearchFiltersBlock extends StatelessWidget {
  const BrewerySearchFiltersBlock({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.selectedType,
    required this.onTypeChanged,
    this.showDivider = false,
  });

  final TextEditingController searchController;
  final VoidCallback onSearch;
  final BreweryType? selectedType;
  final ValueChanged<BreweryType?> onTypeChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BrewSearchHeader(controller: searchController, onSearch: onSearch),
        BrewTypeFilters(selectedType: selectedType, onChanged: onTypeChanged),
        if (showDivider)
          Divider(color: context.brewColors.border, height: 1),
      ],
    );
  }
}
