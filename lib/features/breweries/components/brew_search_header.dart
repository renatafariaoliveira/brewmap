import 'package:brewmap/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrewSearchHeader extends StatelessWidget {
  const BrewSearchHeader({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  final TextEditingController controller;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Encontre cervejarias perto de você',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Busque por cidade, país ou nome:',
            style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('brew_search_field'),
                  controller: controller,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: colors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'San Diego, Portugal, Stone...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: colors.textSecondary,
                      size: 18,
                    ),
                    isDense: true,
                  ),
                  onSubmitted: (_) => onSearch(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                key: const Key('brew_search_button'),
                onTap: onSearch,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: kAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Buscar',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.onAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

