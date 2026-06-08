import 'package:brewmap/core/theme/theme.dart';
import 'package:flutter/material.dart';

class AboutHeroSection extends StatelessWidget {
  const AboutHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kAccent, width: 2),
          ),
          child: Icon(Icons.sports_bar_rounded, size: 48, color: kAccent),
        ),
        const SizedBox(height: 20),
        Text(
          'BrewMap',
          style: kHeadingTextStyle.copyWith(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: kAccent,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'DISCOVER CRAFT BREWERIES WORLDWIDE',
          style: kBodyTextStyle.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: MediaQuery.sizeOf(context).width * .15,
          height: 3,
          decoration: BoxDecoration(
            color: kAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

