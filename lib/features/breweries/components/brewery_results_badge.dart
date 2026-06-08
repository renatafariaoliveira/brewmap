import 'package:brewmap/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BreweryResultsBadge extends StatelessWidget {
  const BreweryResultsBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kAccent,
            ),
          ),
          Text(
            ' cervejarias encontradas',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

