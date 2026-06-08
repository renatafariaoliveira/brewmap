import 'package:brewmap/core/theme/theme.dart';
import 'package:flutter/material.dart';

class BrewMapLogo extends StatelessWidget {
  const BrewMapLogo({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: kAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.sports_bar_rounded,
        color: colors.onAccent,
        size: size * 0.75,
      ),
    );
  }
}
