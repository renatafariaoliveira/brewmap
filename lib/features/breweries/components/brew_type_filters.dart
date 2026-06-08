import 'package:brewmap/core/theme/theme.dart';
import 'package:brewmap/features/breweries/components/brewery_filter.dart';
import 'package:brewmap/features/breweries/models/brewery_type_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrewTypeFilters extends StatelessWidget {
  const BrewTypeFilters({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  final BreweryType? selectedType;
  final ValueChanged<BreweryType?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TIPO',
            style: GoogleFonts.dmMono(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              BrewFilterChip(
                label: 'Todos',
                selected: selectedType == null,
                onTap: () => onChanged(null),
              ),
              ...BreweryType.values.map(
                (t) => BrewFilterChip(
                  label: t.label,
                  selected: selectedType == t,
                  onTap: () => onChanged(selectedType == t ? null : t),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

