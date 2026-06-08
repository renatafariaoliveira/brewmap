import 'package:brewmap/core/theme/theme.dart';
import 'package:brewmap/features/breweries/components/brewery_list_section.dart';
import 'package:brewmap/features/breweries/components/brewery_paginated_list.dart';
import 'package:brewmap/features/breweries/components/brewery_pagination_section.dart';
import 'package:brewmap/features/breweries/controllers/brewery_cubit.dart';
import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:flutter/material.dart';

class BreweryListPanel extends StatelessWidget {
  const BreweryListPanel({
    super.key,
    required this.cubit,
    required this.items,
    required this.selectedBreweryId,
    required this.onSelect,
    required this.currentPage,
    required this.totalPages,
    required this.totalResults,
    required this.onPageChanged,
  });

  final BreweryCubit cubit;
  final List<Brewery> items;
  final String? selectedBreweryId;
  final ValueChanged<Brewery> onSelect;
  final int currentPage;
  final int totalPages;
  final int totalResults;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    return ColoredBox(
      color: colors.surface,
      child: SingleChildScrollView(
        child: Column(
          children: [
            BreweryListSection(
              cubit: cubit,
              child: BreweryPaginatedList(
                items: items,
                selectedBreweryId: selectedBreweryId,
                onSelect: onSelect,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
            ),
            BreweryPaginationSection(
              cubit: cubit,
              currentPage: currentPage,
              totalPages: totalPages,
              totalResults: totalResults,
              showing: items.length,
              onPageChanged: onPageChanged,
            ),
          ],
        ),
      ),
    );
  }
}
