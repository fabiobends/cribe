import 'package:cribe/ui/core/themes/color_utils.dart';
import 'package:cribe/ui/core/themes/theme_config.dart';
import 'package:flutter/material.dart';

/// AppColors class provides a centralized place for all color definitions.
/// To change the app's color scheme, just modify the values in ThemeConfig.
class AppColors {
  // Base Colors - Derived from ThemeConfig
  static Color get basePrimary => ThemeConfig.primaryColor;
  static Color get baseSecondary => ThemeConfig.secondaryColor;

  // Light Theme Colors - Derived from base colors
  static Color get lightPrimary => basePrimary;
  static Color get lightOnPrimary =>
      ColorUtils.getContrastingColor(lightPrimary);
  static Color get lightSecondary => baseSecondary;
  static Color get lightOnSecondary =>
      ColorUtils.getContrastingColor(lightSecondary);
  static Color get lightSurface => ColorUtils.lighten(basePrimary, 95);
  static Color get lightOnSurface =>
      ColorUtils.getContrastingColor(lightSurface);
  static Color get lightSurfaceVariant => ColorUtils.lighten(basePrimary, 98);
  static Color get lightOnSurfaceVariant =>
      ColorUtils.getContrastingColor(lightSurfaceVariant);
  static Color get lightError => ColorUtils.darken(Colors.red, 20);
  static Color get lightOnError => Colors.white;

  // Dark Theme Colors - Derived from base colors
  static Color get darkPrimary => basePrimary.withAlpha(204); // 0.8 * 255 = 204
  static Color get darkOnPrimary => ColorUtils.getContrastingColor(darkPrimary);
  static Color get darkSecondary =>
      baseSecondary.withAlpha(204); // 0.8 * 255 = 204
  static Color get darkOnSecondary =>
      ColorUtils.getContrastingColor(darkSecondary);
  static Color get darkSurface => ColorUtils.darken(basePrimary, 80);
  static Color get darkOnSurface => ColorUtils.getContrastingColor(darkSurface);
  static Color get darkSurfaceVariant => ColorUtils.darken(basePrimary, 90);
  static Color get darkOnSurfaceVariant =>
      ColorUtils.getContrastingColor(darkSurfaceVariant);
  static Color get darkError => ColorUtils.lighten(Colors.red, 20);
  static Color get darkOnError => ColorUtils.getContrastingColor(darkError);

  // Additional Colors (Common for both themes)
  static Color get success => ColorUtils.lighten(Colors.green, 20);
  static Color get warning => ColorUtils.lighten(Colors.orange, 20);
  static Color get info => basePrimary.withAlpha(204); // 0.8 * 255 = 204

  // Neutral Colors - Light Theme
  static Color get lightNeutral100 => ColorUtils.lighten(basePrimary, 95);
  static Color get lightNeutral200 => ColorUtils.lighten(basePrimary, 90);
  static Color get lightNeutral300 => ColorUtils.lighten(basePrimary, 85);
  static Color get lightNeutral400 => ColorUtils.lighten(basePrimary, 80);
  static Color get lightNeutral500 => ColorUtils.lighten(basePrimary, 75);
  static Color get lightNeutral600 => ColorUtils.lighten(basePrimary, 70);
  static Color get lightNeutral700 => ColorUtils.lighten(basePrimary, 65);
  static Color get lightNeutral800 => ColorUtils.lighten(basePrimary, 60);
  static Color get lightNeutral900 => ColorUtils.lighten(basePrimary, 55);

  // Neutral Colors - Dark Theme
  static Color get darkNeutral100 => ColorUtils.darken(basePrimary, 55);
  static Color get darkNeutral200 => ColorUtils.darken(basePrimary, 60);
  static Color get darkNeutral300 => ColorUtils.darken(basePrimary, 65);
  static Color get darkNeutral400 => ColorUtils.darken(basePrimary, 70);
  static Color get darkNeutral500 => ColorUtils.darken(basePrimary, 75);
  static Color get darkNeutral600 => ColorUtils.darken(basePrimary, 80);
  static Color get darkNeutral700 => ColorUtils.darken(basePrimary, 85);
  static Color get darkNeutral800 => ColorUtils.darken(basePrimary, 90);
  static Color get darkNeutral900 => ColorUtils.darken(basePrimary, 95);
}
