import 'package:flutter/material.dart';

/// Utility class for color manipulation
class ColorUtils {
  /// Lightens a color by a percentage (0-100)
  static Color lighten(Color color, [int percent = 10]) {
    assert(percent >= 0 && percent <= 100);
    final f = 1 - percent / 100;
    return Color.fromARGB(
      (color.a * 255).round(),
      255 * (color.r + ((1 - color.r) * f)).round(),
      255 * (color.g + ((1 - color.g) * f)).round(),
      255 * (color.b + ((1 - color.b) * f)).round(),
    );
  }

  /// Darkens a color by a percentage (0-100)
  static Color darken(Color color, [int percent = 10]) {
    assert(percent >= 0 && percent <= 100);
    final f = 1 - percent / 100;
    return Color.fromARGB(
      (color.a * 255).round(),
      (color.r * 255 * f).round(),
      (color.g * 255 * f).round(),
      (color.b * 255 * f).round(),
    );
  }

  /// Creates a contrasting color (black or white) based on the background color
  static Color getContrastingColor(Color backgroundColor) {
    // Calculate the perceptive luminance (perceived brightness)
    // See: https://www.w3.org/TR/WCAG20-TECHS/G18.html
    final double luminance = (0.299 * backgroundColor.r * 255 +
            0.587 * backgroundColor.g * 255 +
            0.114 * backgroundColor.b * 255) /
        255;

    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Creates a color scheme based on primary and secondary colors
  static ColorScheme createColorScheme(
    Color primaryColor,
    Color secondaryColor,
    bool isDark,
  ) {
    if (isDark) {
      return ColorScheme.dark(
        primary: primaryColor,
        onPrimary: getContrastingColor(primaryColor),
        secondary: secondaryColor,
        onSecondary: getContrastingColor(secondaryColor),
        surface: darken(primaryColor, 95),
        onSurface: getContrastingColor(darken(primaryColor, 80)),
        // Using surface instead of background as per deprecation notice
        surfaceDim: darken(primaryColor, 85),
        surfaceBright: darken(primaryColor, 75),
        onSurfaceVariant: getContrastingColor(darken(primaryColor, 90)),
        error: Colors.red,
        onError: Colors.white,
        outline: lighten(primaryColor, 70),
      );
    } else {
      return ColorScheme.light(
        primary: primaryColor,
        onPrimary: getContrastingColor(primaryColor),
        secondary: secondaryColor,
        onSecondary: getContrastingColor(secondaryColor),
        surface: lighten(primaryColor, 20),
        onSurface: getContrastingColor(lighten(primaryColor, 95)),
        // Using surface instead of background as per deprecation notice
        surfaceDim: lighten(primaryColor, 30),
        surfaceBright: lighten(primaryColor, 40),
        onSurfaceVariant: getContrastingColor(lighten(primaryColor, 98)),
        error: Colors.red,
        outline: darken(primaryColor, 30),
      );
    }
  }
}
