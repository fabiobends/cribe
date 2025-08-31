import 'package:cribe/core/constants/feature_flags.dart';
import 'package:cribe/core/constants/spacing.dart';
import 'package:cribe/data/providers/feature_flags_provider.dart';
import 'package:cribe/ui/shared/widgets/styled_button.dart';
import 'package:cribe/ui/shared/widgets/styled_dropdown.dart';
import 'package:cribe/ui/shared/widgets/styled_switch.dart';
import 'package:cribe/ui/shared/widgets/styled_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeatureFlagsView extends StatefulWidget {
  const FeatureFlagsView({super.key});

  @override
  State<FeatureFlagsView> createState() => _FeatureFlagsViewState();
}

class _FeatureFlagsViewState extends State<FeatureFlagsView> {
  bool _obscurePassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<FeatureFlagsProvider>(
      builder: (context, featureFlags, child) {
        return Scaffold(
          backgroundColor: theme.colorScheme.surfaceBright,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.medium),
            child: Column(
              children: [
                const SizedBox(height: Spacing.medium),
                StyledTextField(
                  label: 'Default user email',
                  controller: TextEditingController(
                    text: featureFlags.getFlag(FeatureFlagKey.defaultEmail),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onFieldSubmitted: (value) =>
                      featureFlags.setFlag(FeatureFlagKey.defaultEmail, value),
                ),
                StyledTextField(
                  label: 'Default user password',
                  controller: TextEditingController(
                    text: featureFlags.getFlag(FeatureFlagKey.defaultPassword),
                  ),
                  obscureText: _obscurePassword,
                  onFieldSubmitted: (value) => featureFlags.setFlag(
                    FeatureFlagKey.defaultPassword,
                    value,
                  ),
                  suffixIcon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressedSuffixIcon: _togglePasswordVisibility,
                ),
                StyledTextField(
                  label: 'API Endpoint',
                  hint: 'Enter custom API endpoint',
                  controller: TextEditingController(
                    text: featureFlags.getFlag(FeatureFlagKey.apiEndpoint),
                  ),
                  keyboardType: TextInputType.url,
                  suffixIcon: const Icon(Icons.link),
                  helperText: 'Override the default API endpoint for testing',
                  onFieldSubmitted: (value) =>
                      featureFlags.setFlag(FeatureFlagKey.apiEndpoint, value),
                ),
                StyledSwitch(
                  value: featureFlags.getFlag(FeatureFlagKey.booleanFlag),
                  onChanged: (v) =>
                      featureFlags.setFlag(FeatureFlagKey.booleanFlag, v),
                  title: 'Boolean Flag',
                  subtitle: 'Toggle this feature on/off',
                ),
                StyledDropdown<String>(
                  label: 'A/B Test Variant',
                  value: featureFlags.getFlag(FeatureFlagKey.abTestVariant),
                  onChanged: (v) {
                    if (v != null) {
                      featureFlags.setFlag(
                        FeatureFlagKey.abTestVariant,
                        v,
                      );
                    }
                  },
                  options: const [
                    (value: 'A', label: 'Variant A'),
                    (value: 'B', label: 'Variant B'),
                  ],
                  subtitle: 'Controls which version of the feature is shown',
                ),
                const SizedBox(height: Spacing.large),
                StyledButton(
                  text: 'Reset to Defaults',
                  variant: ButtonVariant.danger,
                  onPressed: () => featureFlags.resetToDefaults(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
