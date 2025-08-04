import 'package:cribe/ui/core/themes/app_colors.dart';
import 'package:cribe/ui/core/themes/app_typography.dart';
import 'package:cribe/ui/core/themes/color_utils.dart';
import 'package:cribe/ui/core/themes/theme_config.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // Get the base colors
  static Color get _basePrimary => AppColors.basePrimary;
  static Color get _baseSecondary => AppColors.baseSecondary;

  // Get theme configuration values
  static double get _borderRadius => ThemeConfig.borderRadius;
  static double get _elevation => ThemeConfig.elevation;

  static ThemeData get lightTheme {
    // Create a color scheme based on the base primary color
    final colorScheme =
        ColorUtils.createColorScheme(_basePrimary, _baseSecondary, false);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceBright,
        foregroundColor: colorScheme.onSurface,
        elevation: _elevation,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(_borderRadius),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          elevation: _elevation,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.secondary,
          side: BorderSide(color: colorScheme.secondary),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceDim,
        elevation: _elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
      ),
      scaffoldBackgroundColor: colorScheme.surface,
    );
  }

  static ThemeData get darkTheme {
    // Create a color scheme based on the base primary color
    final colorScheme =
        ColorUtils.createColorScheme(_basePrimary, _baseSecondary, true);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceBright,
        foregroundColor: colorScheme.onSurface,
        elevation: _elevation,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(_borderRadius),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          elevation: _elevation,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.error,
          side: BorderSide(color: colorScheme.secondary),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceDim,
        elevation: _elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
      ),
      scaffoldBackgroundColor: colorScheme.surface,
    );
  }
}
