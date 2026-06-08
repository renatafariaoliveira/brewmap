import 'package:brewmap/core/theme/theme.dart';
import 'package:flutter/material.dart';

class AboutFooter extends StatelessWidget {
  const AboutFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.brewColors;
    return Text.rich(
      TextSpan(
        style: kBodyTextStyle.copyWith(
          fontSize: 12,
          color: colors.textSecondary.withValues(alpha: 0.7),
        ),
        children: [
          const TextSpan(text: 'Feito com '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Text(
              '🍺',
              style: kBodyTextStyle.copyWith(
                fontSize: 12,
                color: colors.textSecondary,
              ),
            ),
          ),
          const TextSpan(text: ' e Flutter · Dados via Open Brewery DB'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

