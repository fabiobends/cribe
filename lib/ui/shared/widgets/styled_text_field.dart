import 'package:cribe/core/constants/spacing.dart';
import 'package:cribe/ui/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';

class StyledTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final bool obscureText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool enabled;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onPressedSuffixIcon;
  final VoidCallback? onPressedPrefixIcon;
  final String? helperText;

  const StyledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.enabled = true,
    this.textInputAction,
    this.focusNode,
    this.onFieldSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.onPressedSuffixIcon,
    this.onPressedPrefixIcon,
    this.helperText,
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
            // Ensure FormField stays in sync with the controller, even for
            // programmatic changes (e.g., defaults loaded in initState).
            return ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                if (formFieldState.value != value.text) {
                  // Avoid calling setState during build; schedule update next frame.
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (formFieldState.mounted &&
                        formFieldState.value != value.text) {
                      formFieldState.didChange(value.text);
                    }
                  });
                }

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
                      onChanged: (v) => formFieldState.didChange(v),
                      decoration: InputDecoration(
                        hintText: hint,
                        prefixIcon: prefixIcon,
                        suffixIcon: suffixIcon != null
                            ? IconButton(
                                onPressed: onPressedSuffixIcon,
                                icon: suffixIcon!,
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Spacing.small),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Spacing.small),
                          borderSide: BorderSide(
                            color: hasError
                                ? theme.colorScheme.error
                                : theme.colorScheme.outline,
                          ),
                        ),
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Spacing.small),
                          borderSide: BorderSide(
                            color: hasError
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                            width: Spacing.tiny,
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
                            width: Spacing.tiny,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.extraSmall),
                    StyledText(
                      text: formFieldState.hasError
                          ? (formFieldState.errorText ?? '')
                          : (helperText ?? ''),
                      variant: TextVariant.caption,
                      color: formFieldState.hasError
                          ? theme.colorScheme.error
                          : (helperText != null
                              ? theme.colorScheme.onSurfaceVariant
                              : Colors.transparent),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
