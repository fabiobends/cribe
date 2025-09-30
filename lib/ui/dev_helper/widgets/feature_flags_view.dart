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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiController = TextEditingController();

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  void initState() {
    super.initState();
    final featureFlags = context.read<FeatureFlagsProvider>();
    _emailController.text =
        featureFlags.getFlag(FeatureFlagKey.defaultEmail) ?? '';
    _passwordController.text =
        featureFlags.getFlag(FeatureFlagKey.defaultPassword) ?? '';
    _apiController.text =
        featureFlags.getFlag(FeatureFlagKey.apiEndpoint) ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _apiController.dispose();
    super.dispose();
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
              spacing: Spacing.extraSmall,
              children: [
                StyledTextField(
                  label: 'Default user email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onFieldSubmitted: (value) =>
                      featureFlags.setFlag(FeatureFlagKey.defaultEmail, value),
                ),
                StyledTextField(
                  label: 'Default user password',
                  controller: _passwordController,
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
                  controller: _apiController,
                  keyboardType: TextInputType.url,
                  suffixIcon: const Icon(Icons.link),
                  helperText: 'Override the default API endpoint for testing',
                  onFieldSubmitted: (value) =>
                      featureFlags.setFlag(FeatureFlagKey.apiEndpoint, value),
                ),
                StyledDropdown<String>(
                  label: 'Log Level',
                  value: featureFlags.getFlag(FeatureFlagKey.logFilter),
                  onChanged: (v) {
                    if (v != null) {
                      featureFlags.setFlag(
                        FeatureFlagKey.logFilter,
                        v,
                      );
                    }
                  },
                  options: const [
                    (value: 'DEBUG', label: 'Debug'),
                    (value: 'INFO', label: 'Info'),
                    (value: 'WARN', label: 'Warning'),
                    (value: 'ERROR', label: 'Error'),
                    (value: 'NONE', label: 'No Logs'),
                  ],
                  subtitle: 'Filter logs by level for debugging',
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
