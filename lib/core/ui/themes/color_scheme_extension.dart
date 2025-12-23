import 'package:cribe/core/ui/themes/color_utils.dart';
import 'package:cribe/core/ui/themes/theme_config.dart';
import 'package:flutter/material.dart';

/// Extension to add custom colors to ColorScheme
/// This allows us to add success, warning, and other custom colors to the theme
extension CustomColorScheme on ColorScheme {
  /// Success color for positive feedback
  Color get success => ThemeConfig.success;

  /// Container color for success states
  Color get successContainer => brightness == Brightness.light
      ? ColorUtils.lighten(ThemeConfig.success, 80)
      : ColorUtils.darken(ThemeConfig.success, 60);

  /// Text color on success backgrounds
  Color get onSuccess => ColorUtils.getContrastingColor(success);

  /// Text color on success container backgrounds
  Color get onSuccessContainer =>
      ColorUtils.getContrastingColor(successContainer);

  /// Warning color for cautionary feedback
  Color get warning => ThemeConfig.warning;

  /// Container color for warning states
  Color get warningContainer => brightness == Brightness.light
      ? ColorUtils.lighten(ThemeConfig.warning, 80)
      : ColorUtils.darken(ThemeConfig.warning, 60);

  /// Text color on warning backgrounds
  Color get onWarning => ColorUtils.getContrastingColor(warning);

  /// Text color on warning container backgrounds
  Color get onWarningContainer =>
      ColorUtils.getContrastingColor(warningContainer);

  /// Info color for informational feedback
  Color get info => ThemeConfig.info;

  /// Container color for info states
  Color get infoContainer => brightness == Brightness.light
      ? ColorUtils.lighten(ThemeConfig.info, 80)
      : ColorUtils.darken(ThemeConfig.info, 60);

  /// Text color on info backgrounds
  Color get onInfo => ColorUtils.getContrastingColor(info);

  /// Text color on info container backgrounds
  Color get onInfoContainer => ColorUtils.getContrastingColor(infoContainer);
}
