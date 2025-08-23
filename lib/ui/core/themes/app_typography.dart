import 'package:cribe/ui/core/themes/theme_config.dart';
import 'package:flutter/material.dart';

/// AppTypography class provides a centralized place for all typography definitions.
/// To change the app's font family or text styles, just modify the values in ThemeConfig.
class AppTypography {
  // Font Family - Derived from ThemeConfig
  static String get fontFamily => ThemeConfig.fontFamily;

  // Text Theme
  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        fontFamily: fontFamily,
      ),
      displayMedium: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        fontFamily: fontFamily,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        fontFamily: fontFamily,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        fontFamily: fontFamily,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        fontFamily: fontFamily,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        fontFamily: fontFamily,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        fontFamily: fontFamily,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        fontFamily: fontFamily,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        fontFamily: fontFamily,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        fontFamily: fontFamily,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        fontFamily: fontFamily,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        fontFamily: fontFamily,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        fontFamily: fontFamily,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        fontFamily: fontFamily,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        fontFamily: fontFamily,
      ),
    );
  }
}
