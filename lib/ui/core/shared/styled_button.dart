import 'package:cribe/core/constants/spacing.dart';
import 'package:cribe/ui/core/shared/styled_text.dart';
import 'package:flutter/material.dart';

enum ButtonVariant {
  primary,
  secondary,
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

    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isEnabled ? theme.colorScheme.primary : theme.colorScheme.onSurface,
        foregroundColor: isEnabled
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface,
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
            color: isLoading ? Colors.transparent : null,
          ),
          Visibility(
            visible: isLoading,
            child: SizedBox(
              height: Spacing.medium,
              width: Spacing.medium,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
