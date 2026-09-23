import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class Kicker extends StatelessWidget {
  const Kicker(
    this.text, {
    super.key,
    this.color = AppColors.accent,
    this.fontSize = 11.0,
  });

  final String text;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTypography.kicker.copyWith(
        color: color,
        fontSize: fontSize,
      ),
    );
  }
}
