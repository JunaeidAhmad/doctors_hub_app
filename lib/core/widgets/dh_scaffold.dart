import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class DhScaffold extends StatelessWidget {
  const DhScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor = AppColors.surface,
    this.statusBarColor,
    this.statusBarIconBrightness = Brightness.dark,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Color backgroundColor;
  final Color? statusBarColor;
  final Brightness statusBarIconBrightness;

  @override
  Widget build(BuildContext context) {
    final effectiveStatusBarColor = statusBarColor ??
        (appBar != null ? AppColors.paper : backgroundColor);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: effectiveStatusBarColor,
        statusBarIconBrightness: statusBarIconBrightness,
        systemNavigationBarColor: AppColors.paper,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        bottomSheet: bottomSheet,
      ),
    );
  }
}
