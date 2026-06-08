import 'package:brewmap/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrewQueryBadge extends StatelessWidget {
  const BrewQueryBadge({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Text(
        query.trim().isEmpty ? 'BUSCA' : query.trim().toUpperCase(),
        style: GoogleFonts.dmMono(
          fontSize: 10,
          letterSpacing: 1.5,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}

