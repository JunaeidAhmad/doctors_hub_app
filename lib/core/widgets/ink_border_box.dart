import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class InkBorderBox extends StatelessWidget {
  const InkBorderBox({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.paper,
    this.borderColor = AppColors.ink,
    this.borderWidth = AppColors.borderWidth,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: child,
    );
  }
}
