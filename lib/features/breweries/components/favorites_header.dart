import 'package:brewmap/core/theme/theme.dart';
import 'package:flutter/material.dart';

class FavoritesHeader extends StatelessWidget {
  const FavoritesHeader({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            'Minhas cervejarias',
            style: kHeadingTextStyle.copyWith(
              fontSize: 20,
              color: colors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            '$count salva${count != 1 ? 's' : ''}',
            style: kMonoTextStyle.copyWith(
              fontSize: 12,
              color: colors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

