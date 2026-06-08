import 'package:brewmap/core/theme/theme.dart';
import 'package:brewmap/features/breweries/components/brewery_list_tile.dart';
import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BreweryPaginatedList extends StatelessWidget {
  const BreweryPaginatedList({
    super.key,
    required this.items,
    required this.selectedBreweryId,
    required this.onSelect,
    this.shrinkWrap = false,
    this.physics,
  });

  final List<Brewery> items;
  final String? selectedBreweryId;
  final ValueChanged<Brewery> onSelect;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    if (items.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma cervejaria encontrada',
          style: GoogleFonts.dmSans(color: colors.textSecondary),
        ),
      );
    }
    return ListView.builder(
      itemCount: items.length,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemBuilder: (context, index) {
        final brewery = items[index];
        return BreweryListTile(
          brewery: brewery,
          isSelected: brewery.id == selectedBreweryId,
          onTap: () => onSelect(brewery),
        );
      },
    );
  }
}
