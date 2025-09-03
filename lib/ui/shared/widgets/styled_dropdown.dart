import 'package:cribe/core/constants/spacing.dart';
import 'package:cribe/ui/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';

typedef DropdownItem<T> = ({T value, String label});

class StyledDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownItem<T>> options;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final bool enabled;
  final String? subtitle;

  const StyledDropdown({
    super.key,
    required this.label,
    required this.options,
    this.value,
    this.onChanged,
    this.hint,
    this.enabled = true,
    this.subtitle,
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
        DropdownButtonFormField<T>(
          value: value,
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Spacing.small),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Spacing.small),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: Spacing.tiny,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Spacing.small),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceBright,
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          dropdownColor: theme.colorScheme.surface,
          items: options.map((option) {
            return DropdownMenuItem<T>(
              value: option.value,
              child: StyledText(
                text: option.label,
                variant: TextVariant.body,
              ),
            );
          }).toList(),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: Spacing.extraSmall),
          StyledText(
            text: subtitle!,
            variant: TextVariant.caption,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ],
    );
  }
}
