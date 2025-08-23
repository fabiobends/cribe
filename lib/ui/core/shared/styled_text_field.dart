import 'package:cribe/core/constants/spacing.dart';
import 'package:cribe/ui/core/shared/styled_text.dart';
import 'package:flutter/material.dart';

class StyledTextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscureText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool enabled;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;

  const StyledTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.enabled = true,
    this.textInputAction,
    this.focusNode,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StyledText(
          text: label,
          variant: TextVariant.label,
        ),
        const SizedBox(height: Spacing.small),
        FormField<String>(
          validator: validator,
          autovalidateMode: AutovalidateMode.disabled,
          builder: (formFieldState) {
            final hasError = formFieldState.errorText != null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  enabled: enabled,
                  focusNode: focusNode,
                  textInputAction: textInputAction,
                  onSubmitted: onFieldSubmitted,
                  onChanged: (value) => formFieldState.didChange(value),
                  decoration: InputDecoration(
                    hintText: hint,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Spacing.small),
                      borderSide: BorderSide(
                        color: hasError
                            ? theme.colorScheme.error
                            : theme.colorScheme
                                .outline, // or onSurface with opacity
                      ),
                    ),
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Spacing.small),
                      borderSide: BorderSide(
                        color: hasError
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        width: Spacing.extraTiny,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Spacing.small),
                      borderSide: BorderSide(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Spacing.small),
                      borderSide: BorderSide(
                        color: theme.colorScheme.error,
                        width: Spacing.extraTiny,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.tiny),
                StyledText(
                  text: formFieldState.errorText ?? '',
                  variant: TextVariant.caption,
                  color: formFieldState.hasError
                      ? theme.colorScheme.error
                      : Colors.transparent,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
