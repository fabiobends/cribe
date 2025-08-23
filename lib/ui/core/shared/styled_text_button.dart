import 'package:flutter/material.dart';

class StyledTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isEnabled;

  const StyledTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: isEnabled ? onPressed : null,
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isEnabled
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
