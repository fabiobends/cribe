import 'package:cribe/core/constants/spacing.dart';
import 'package:flutter/material.dart';

/// ThemeConfig provides a simple way to change the app's theme colors.
/// Just modify the values in this class to update the entire app's color scheme.
class ThemeConfig {
  // Primary brand color - Change this to update the entire theme
  static const Color primaryColor = Color(0xFF2196F3);

  // Secondary brand color - Change this to update secondary elements
  static const Color secondaryColor = Color(0xFF03DAC6);

  static Color get success => Colors.green;
  static Color get warning => Colors.orange;
  static Color get info => primaryColor.withValues(alpha: 0.8);

  // Font family - Change this to update the entire app's font
  static const String fontFamily = 'Roboto';

  // Border radius - Change this to update the entire app's border radius
  static const double borderRadius = Spacing.small;

  // Elevation - Change this to update the entire app's elevation
  static const double elevation = 0.0;
}
