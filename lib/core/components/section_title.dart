import 'package:brewmap/core/theme/theme.dart';
import 'package:flutter/material.dart';

class BrewSectionTitle extends StatelessWidget {
  const BrewSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: kBodyTextStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: kAccent,
      ),
    );
  }
}

