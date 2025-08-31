import 'package:cribe/core/constants/spacing.dart';
import 'package:cribe/ui/dev_helper/widgets/feature_flags_view.dart';
import 'package:cribe/ui/dev_helper/widgets/storybook_view.dart';
import 'package:cribe/ui/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';

class DevSettingsModal extends StatelessWidget {
  const DevSettingsModal({super.key});
  static const tabs = [
    'Feature Flags',
    'Storybook',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: DefaultTabController(
        length: tabs.length,
        child: Container(
          padding: const EdgeInsets.all(Spacing.small),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceBright,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(Spacing.large),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: Spacing.small),
                width: Spacing.extraLarge,
                height: Spacing.extraSmall,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(Spacing.tiny),
                ),
              ),
              const StyledText(
                text: 'Dev Settings',
                variant: TextVariant.title,
              ),
              TabBar(
                tabs: tabs.map((tab) => Tab(text: tab)).toList(),
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    FeatureFlagsView(),
                    StorybookView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
