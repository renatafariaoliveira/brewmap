import 'package:brewmap/core/components/brew_map_logo.dart';
import 'package:brewmap/core/theme/theme.dart';
import 'package:flutter/material.dart';

class AboutHeader extends StatelessWidget {
  const AboutHeader({super.key});

  static const double compactBreakpoint = 700;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < compactBreakpoint;
    final logoSize = isCompact ? 40.0 : 48.0;
    final colors = context.brewColors;

    return SafeArea(
      bottom: false,
      child: Container(
        height: isCompact ? 56 : 80,
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 20),
        child: Row(
          children: [
            BrewMapLogo(size: logoSize),
            const SizedBox(width: 14),
            Text(
              'BrewMap',
              style: kBrandTitleTextStyle.copyWith(
                fontSize: isCompact ? 22 : 26,
                color: kAccent,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: colors.textSecondary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(
                'Voltar',
                style: kBodyTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

