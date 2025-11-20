import 'package:cribe/core/constants/spacing.dart';
import 'package:cribe/ui/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';

enum ButtonVariant {
  primary,
  secondary,
  danger,
}

class StyledButton extends StatelessWidget {
  final String text;
  final ButtonVariant variant;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;

  const StyledButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.variant,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color getBackgroundColor() {
      if (!isEnabled) {
        return theme.colorScheme.onSurface.withValues(alpha: 0.12);
      }

      switch (variant) {
        case ButtonVariant.primary:
          return theme.colorScheme.primary;
        case ButtonVariant.secondary:
          return theme.colorScheme.secondary;
        case ButtonVariant.danger:
          return theme.colorScheme.error;
      }
    }

    Color getForegroundColor() {
      if (!isEnabled) {
        return theme.colorScheme.onSurface.withValues(alpha: 0.38);
      }

      switch (variant) {
        case ButtonVariant.primary:
          return theme.colorScheme.onPrimary;
        case ButtonVariant.secondary:
          return theme.colorScheme.onSecondary;
        case ButtonVariant.danger:
          return theme.colorScheme.onError;
      }
    }

    return ElevatedButton(
      onPressed: (isEnabled && !isLoading) ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: getBackgroundColor(),
        foregroundColor: getForegroundColor(),
        elevation: isEnabled ? 2 : 0,
        shadowColor: theme.colorScheme.shadow,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.large,
          vertical: Spacing.medium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.small),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          StyledText(
            text: text,
            variant: TextVariant.label,
            color: isLoading ? Colors.transparent : getForegroundColor(),
          ),
          Visibility(
            visible: isLoading,
            child: SizedBox(
              height: Spacing.medium,
              width: Spacing.medium,
              child: CircularProgressIndicator(
                strokeWidth: Spacing.tiny,
                valueColor: AlwaysStoppedAnimation<Color>(
                  getForegroundColor(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
