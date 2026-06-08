import 'package:brewmap/core/theme/theme.dart';
import 'package:flutter/material.dart';

class BrewCard extends StatelessWidget {
  const BrewCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 12,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: colors.border),
      ),
      child: child,
    );
  }
}

