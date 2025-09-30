import 'package:flutter/material.dart';

enum TextVariant {
  body,
  title,
  subtitle,
  caption,
  headline,
  label,
}

class StyledText extends StatelessWidget {
  final String text;
  final TextVariant variant;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;

  const StyledText({
    super.key,
    required this.text,
    required this.variant,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
  });

  TextStyle? _getTextStyle(BuildContext context) {
    final theme = Theme.of(context);

    switch (variant) {
      case TextVariant.headline:
        return theme.textTheme.headlineLarge?.copyWith(
          color: color ?? theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        );

      case TextVariant.title:
        return theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: color ?? theme.colorScheme.onSurface,
        );

      case TextVariant.subtitle:
        return theme.textTheme.bodyLarge?.copyWith(
          color: color ?? theme.colorScheme.onSurface.withValues(alpha: 0.9),
        );

      case TextVariant.body:
        return theme.textTheme.bodyMedium?.copyWith(
          color: color ?? theme.colorScheme.onSurface,
        );

      case TextVariant.caption:
        return theme.textTheme.bodySmall?.copyWith(
          color: color ?? theme.colorScheme.onSurface.withValues(alpha: 0.6),
        );

      case TextVariant.label:
        return theme.textTheme.labelLarge?.copyWith(
          color: color ?? theme.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _getTextStyle(context),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
