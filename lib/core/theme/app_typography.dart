import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  const AppTypography._();

  static const String fontArchivo = 'Archivo';
  static const String fontMono = 'JetBrainsMono';
  static const List<String> fallbackBengali = ['NotoSansBengali'];

  // H1: 32 / 800, tracking -0.025em, line-height 1.02-1.05
  static const TextStyle h1 = TextStyle(
    fontFamily: fontArchivo,
    fontFamilyFallback: fallbackBengali,
    fontSize: 32.0,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8, // ~ -0.025em
    height: 1.04,
    color: AppColors.ink,
  );

  // H2: 18 / 800
  static const TextStyle h2 = TextStyle(
    fontFamily: fontArchivo,
    fontFamilyFallback: fallbackBengali,
    fontSize: 18.0,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: AppColors.ink,
  );

  // Body: 15 / 400
  static const TextStyle body = TextStyle(
    fontFamily: fontArchivo,
    fontFamilyFallback: fallbackBengali,
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: AppColors.ink,
  );

  // Body bold: 15 / 600
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontArchivo,
    fontFamilyFallback: fallbackBengali,
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.ink,
  );

  // Secondary: 13 / 400
  static const TextStyle secondary = TextStyle(
    fontFamily: fontArchivo,
    fontFamilyFallback: fallbackBengali,
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: AppColors.muted,
  );

  // Secondary bold: 13 / 600
  static const TextStyle secondaryBold = TextStyle(
    fontFamily: fontArchivo,
    fontFamilyFallback: fallbackBengali,
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.ink,
  );

  // Tag: 11 / 600
  static const TextStyle tag = TextStyle(
    fontFamily: fontArchivo,
    fontFamilyFallback: fallbackBengali,
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    color: AppColors.ink2,
  );

  // Tag accent: 11 / 600
  static const TextStyle tagAccent = TextStyle(
    fontFamily: fontArchivo,
    fontFamilyFallback: fallbackBengali,
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    color: AppColors.accentDeep,
  );

  // Kicker: Mono 11 / 500 uppercase
  static const TextStyle kicker = TextStyle(
    fontFamily: fontMono,
    fontFamilyFallback: fallbackBengali,
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    color: AppColors.accent,
  );

  // Grid number: Mono 13 / 500
  static const TextStyle gridNumber = TextStyle(
    fontFamily: fontMono,
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
    color: AppColors.muted,
  );

  // Button text: 15 / 600
  static const TextStyle button = TextStyle(
    fontFamily: fontArchivo,
    fontFamilyFallback: fallbackBengali,
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.paper,
  );
}
