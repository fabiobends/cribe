import 'package:cribe/ui/core/themes/theme_config.dart';
import 'package:flutter/material.dart';

/// AppTypography class provides a centralized place for all typography definitions.
/// To change the app's font family or text styles, just modify the values in ThemeConfig.
class AppTypography {
  // Font Family - Derived from ThemeConfig
  static String get fontFamily => ThemeConfig.fontFamily;

  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Text Theme
  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: regular,
        letterSpacing: -0.25,
        fontFamily: fontFamily,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: regular,
        letterSpacing: 0,
        fontFamily: fontFamily,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: regular,
        letterSpacing: 0,
        fontFamily: fontFamily,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: regular,
        letterSpacing: 0,
        fontFamily: fontFamily,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: regular,
        letterSpacing: 0,
        fontFamily: fontFamily,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: regular,
        letterSpacing: 0,
        fontFamily: fontFamily,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: medium,
        letterSpacing: 0,
        fontFamily: fontFamily,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: medium,
        letterSpacing: 0.15,
        fontFamily: fontFamily,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: medium,
        letterSpacing: 0.1,
        fontFamily: fontFamily,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: medium,
        letterSpacing: 0.1,
        fontFamily: fontFamily,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: medium,
        letterSpacing: 0.5,
        fontFamily: fontFamily,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: medium,
        letterSpacing: 0.5,
        fontFamily: fontFamily,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: regular,
        letterSpacing: 0.5,
        fontFamily: fontFamily,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: regular,
        letterSpacing: 0.25,
        fontFamily: fontFamily,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: regular,
        letterSpacing: 0.4,
        fontFamily: fontFamily,
      ),
    );
  }
}
