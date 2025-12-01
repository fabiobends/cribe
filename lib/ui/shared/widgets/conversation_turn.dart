import 'package:cribe/core/constants/spacing.dart';
import 'package:cribe/ui/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';

enum TurnAlignment { left, right }

class ConversationTurn extends StatelessWidget {
  final String speakerName;
  final List<Widget> contentWidgets;
  final TurnAlignment alignment;
  final Color? accentColor;
  final double maxWidthFraction;

  const ConversationTurn({
    super.key,
    required this.speakerName,
    required this.contentWidgets,
    this.alignment = TurnAlignment.left,
    this.accentColor,
    this.maxWidthFraction = 0.75,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alignLeft = alignment == TurnAlignment.left;
    final defaultAccentColor =
        alignLeft ? theme.colorScheme.primary : theme.colorScheme.secondary;
    final effectiveAccentColor = accentColor ?? defaultAccentColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.small),
      child: Row(
        mainAxisAlignment:
            alignLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * maxWidthFraction,
            ),
            child: Column(
              crossAxisAlignment:
                  alignLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                // Speaker name
                StyledText(
                  text: speakerName,
                  variant: TextVariant.label,
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                ),
                // Accent underline
                Container(
                  height: Spacing.tiny,
                  width: Spacing.large,
                  color: effectiveAccentColor,
                ),
                const SizedBox(height: Spacing.extraSmall),
                // Content
                Wrap(
                  alignment:
                      alignLeft ? WrapAlignment.start : WrapAlignment.end,
                  children: contentWidgets,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
