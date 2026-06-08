import 'package:brewmap/features/breweries/models/brewery_model.dart';
import 'package:brewmap/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class BreweryMarker extends StatelessWidget {
  final Brewery brewery;
  final bool isSelected;
  final VoidCallback onTap;

  const BreweryMarker({
    super.key,
    required this.brewery,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.only(bottom: 4),
              child: isSelected
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: colors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        brewery.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: colors.border, width: 0.5),
                      ),
                      child: Text(
                        brewery.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w300,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 2),
            Container(
              width: isSelected ? 18 : 14,
              height: isSelected ? 18 : 14,
              decoration: BoxDecoration(
                color: isSelected ? kAccent : kAccent.withValues(alpha: 0.7),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : kAccentDark,
                  width: isSelected ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kAccent.withValues(alpha: isSelected ? 0.5 : 0.2),
                    blurRadius: isSelected ? 10 : 4,
                    spreadRadius: isSelected ? 2 : 0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Marker> buildMarkers({
  required List<Brewery> breweries,
  required String? selectedId,
  required Function(Brewery) onSelect,
}) {
  return breweries.where((b) => b.location != null).map((b) {
    final selected = b.id == selectedId;
    return Marker(
      point: b.location!,
      width: 120,
      height: selected ? 75 : 60,
      alignment: Alignment.bottomCenter,
      child: BreweryMarker(
        brewery: b,
        isSelected: selected,
        onTap: () => onSelect(b),
      ),
    );
  }).toList();
}
