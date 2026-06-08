import 'package:brewmap/core/theme/theme.dart';
import 'package:flutter/material.dart';

class AboutRichText extends StatelessWidget {
  const AboutRichText({
    super.key,
    required this.children,
  });

  final List<InlineSpan> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    final baseStyle = kBodyTextStyle.copyWith(
      fontSize: 14,
      height: 1.6,
      color: colors.textSecondary,
    );
    final boldStyle = baseStyle.copyWith(
      color: colors.textPrimary,
      fontWeight: FontWeight.w700,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: children.map((span) {
          if (span is! TextSpan) return span;
          final isBold = span.style?.fontWeight == FontWeight.w700;
          return TextSpan(
            text: span.text,
            style: isBold ? boldStyle : baseStyle,
          );
        }).toList(),
      ),
    );
  }
}

