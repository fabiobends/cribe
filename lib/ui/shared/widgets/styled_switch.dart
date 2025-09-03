import 'package:cribe/ui/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';

class StyledSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? title;
  final String? subtitle;
  final bool enabled;

  const StyledSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (title == null && subtitle == null) {
      // Simple switch without labels
      return Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: theme.colorScheme.primary,
      );
    }

    // Switch with labels (like SwitchListTile)
    return SwitchListTile(
      value: value,
      onChanged: enabled ? onChanged : null,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      contentPadding: EdgeInsets.zero,
      title: title != null
          ? StyledText(
              text: title!,
              variant: TextVariant.label,
            )
          : null,
      subtitle: subtitle != null
          ? StyledText(
              text: subtitle!,
              variant: TextVariant.caption,
            )
          : null,
      activeColor: theme.colorScheme.primary,
    );
  }
}
