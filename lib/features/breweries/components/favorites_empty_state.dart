import 'package:brewmap/core/theme/theme.dart';
import 'package:flutter/material.dart';

class FavoritesEmptyState extends StatelessWidget {
  const FavoritesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_border_rounded, size: 48, color: colors.border),
          const SizedBox(height: 12),
          Text(
            'Nenhuma cervejaria favoritada ainda.',
            style: kBodyTextStyle.copyWith(
              fontSize: 14,
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Explore o mapa e salve as suas favoritas.',
            style: kBodyTextStyle.copyWith(
              fontSize: 13,
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

