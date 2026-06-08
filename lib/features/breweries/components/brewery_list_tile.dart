import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:brewmap/core/theme/theme.dart';
import 'package:brewmap/features/breweries/components/type_badge_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BreweryListTile extends StatelessWidget {
  final Brewery brewery;
  final bool isSelected;
  final VoidCallback onTap;

  const BreweryListTile({
    super.key,
    required this.brewery,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: isSelected ? colors.selectedItem : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: isSelected ? kAccent : Colors.transparent,
            width: 3,
          ),
          bottom: BorderSide(color: colors.border, width: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                brewery.name,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  TypeBadge(type: brewery.type, small: true),
                  const SizedBox(width: 8),
                  Text(
                    brewery.fullLocation,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                  ),
                  if (brewery.rating != null) ...[
                    const Spacer(),
                    const Icon(Icons.star_rounded, size: 13, color: kAccent),
                    const SizedBox(width: 3),
                    Text(
                      brewery.rating!.toStringAsFixed(1),
                      style: GoogleFonts.dmMono(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
