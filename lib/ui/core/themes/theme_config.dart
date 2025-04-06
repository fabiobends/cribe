import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ThemeConfig provides a simple way to change the app's theme colors.
/// Just modify the values in this class to update the entire app's color scheme.
class ThemeConfig {
  // Primary brand color - Change this to update the entire theme
  static const Color primaryColor = Color(0xFF2196F3); // Blue

  // Secondary brand color - Change this to update secondary elements
  static const Color secondaryColor = Color(0xFF03DAC6); // Teal

  // Font family - Change this to update the entire app's font
  static const String fontFamily = 'Roboto';

  // Border radius - Change this to update the entire app's border radius
  static const double borderRadius = 8.0;

  // Elevation - Change this to update the entire app's elevation
  static const double elevation = 0.0;

  // Apply the configuration to the app colors
  static void applyConfiguration() {
    // This is a workaround to update the static const values
    // In a real app, you would use a state management solution
    // or a theme provider to dynamically update the theme
    _updateAppColors();
  }

  // Private method to update the app colors
  static void _updateAppColors() {
    // This is a placeholder for the actual implementation
    // In a real app, you would use a state management solution
    // or a theme provider to dynamically update the theme
    print('Theme configuration applied:');
    print('Primary Color: $primaryColor');
    print('Secondary Color: $secondaryColor');
    print('Font Family: $fontFamily');
    print('Border Radius: $borderRadius');
    print('Elevation: $elevation');
  }
}
