import 'package:brewmap/features/breweries/models/brewery_type_model.dart';
import 'package:brewmap/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum TypeBadgeVariant { typeColor, accent, soft }

class TypeBadge extends StatelessWidget {
  final BreweryType type;
  final bool small;
  final TypeBadgeVariant variant;

  const TypeBadge({
    super.key,
    required this.type,
    this.small = false,
    this.variant = TypeBadgeVariant.typeColor,
  });

  ({Color bg, Color border, Color text}) get _colors {
    switch (variant) {
      case TypeBadgeVariant.accent:
        return (
          bg: kAccent.withValues(alpha: 0.15),
          border: kAccent.withValues(alpha: 0.35),
          text: kAccent,
        );
      case TypeBadgeVariant.soft:
        switch (type) {
          case BreweryType.regional:
            return (
              bg: kAccent.withValues(alpha: 0.12),
              border: kAccent.withValues(alpha: 0.32),
              text: kAccent,
            );
          case BreweryType.micro:
            return (
              bg: const Color(0x193AABEE),
              border: const Color(0x4D3AABEE),
              text: const Color(0xFF3AABEE),
            );
          case BreweryType.brewpub:
            return (
              bg: const Color(0x192ECC88),
              border: const Color(0x472ECC88),
              text: const Color(0xFF2ECC88),
            );
          case BreweryType.large:
            return (
              bg: const Color(0x19C87AE8),
              border: const Color(0x47C87AE8),
              text: const Color(0xFFC87AE8),
            );
        }
      case TypeBadgeVariant.typeColor:
        final c = switch (type) {
          BreweryType.micro => kMicroColor,
          BreweryType.brewpub => kBrewpubColor,
          BreweryType.regional => kRegionalColor,
          BreweryType.large => kLargeColor,
        };
        return (
          bg: c.withValues(alpha: 0.2),
          border: c.withValues(alpha: 0.5),
          text: c,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors;
    final useLegacySize =
        variant == TypeBadgeVariant.typeColor ||
        variant == TypeBadgeVariant.accent;
    final horizontal = useLegacySize ? (small ? 6.0 : 8.0) : 8.0;
    final vertical = useLegacySize ? (small ? 2.0 : 3.0) : 3.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: colors.border,
          width: variant == TypeBadgeVariant.typeColor ? 0.5 : 0.8,
        ),
      ),
      child: Text(
        type.label,
        style: GoogleFonts.dmMono(
          fontSize: variant == TypeBadgeVariant.soft ? 10 : (small ? 10 : 11),
          fontWeight: variant == TypeBadgeVariant.typeColor
              ? FontWeight.w500
              : FontWeight.w600,
          color: colors.text,
          letterSpacing: variant == TypeBadgeVariant.typeColor ? 0.3 : 0.5,
        ),
      ),
    );
  }
}
