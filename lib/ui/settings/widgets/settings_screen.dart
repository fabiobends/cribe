import 'package:cribe/core/constants/feature_flags.dart';
import 'package:cribe/core/constants/spacing.dart';
import 'package:cribe/core/logger/logger_mixins.dart';
import 'package:cribe/data/providers/feature_flags_provider.dart';
import 'package:cribe/ui/auth/widgets/auth_screen.dart';
import 'package:cribe/ui/settings/view_models/settings_view_model.dart';
import 'package:cribe/ui/shared/widgets/styled_button.dart';
import 'package:cribe/ui/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with ScreenLogger {
  late SettingsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    logger.info('SettingsScreen initialized');
    _viewModel = context.read<SettingsViewModel>();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    logger.info('Disposing SettingsScreen');
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    logger.debug('SettingsScreen view model changed');
    if (_viewModel.error != null) {
      logger.warn(
        'SettingsScreen encountered an error: ${_viewModel.error}',
      );
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: StyledText(
            text: _viewModel.error!,
            variant: TextVariant.body,
            color: theme.colorScheme.onError,
          ),
          backgroundColor: theme.colorScheme.error,
        ),
      );
      _viewModel.setError(null);
    } else if (_viewModel.isSuccess) {
      logger.info('Logout successful');
      // Navigate back to auth screen after successful logout
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AuthScreen(),
        ),
      );
    }
  }

  void _onLogoutPressed() {
    logger.info('Logout button pressed');
    _viewModel.logout();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Consumer2<SettingsViewModel, FeatureFlagsProvider>(
          builder: (context, viewModel, featureFlags, child) {
            return Padding(
              padding: const EdgeInsets.all(Spacing.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.medium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const StyledText(
                            text: 'Current Feature Flags',
                            variant: TextVariant.title,
                          ),
                          const SizedBox(height: Spacing.medium),
                          Row(
                            children: [
                              const Expanded(
                                child: StyledText(
                                  text: 'Boolean Flag:',
                                  variant: TextVariant.label,
                                ),
                              ),
                              StyledText(
                                text: featureFlags
                                        .getFlag(FeatureFlagKey.booleanFlag)
                                    ? 'ON'
                                    : 'OFF',
                                variant: TextVariant.body,
                              ),
                            ],
                          ),
                          const SizedBox(height: Spacing.small),
                          Row(
                            children: [
                              const Expanded(
                                child: StyledText(
                                  text: 'A/B Variant:',
                                  variant: TextVariant.label,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Spacing.small,
                                  vertical: Spacing.extraSmall,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(Spacing.small),
                                ),
                                child: StyledText(
                                  text:
                                      'Variant ${featureFlags.getFlag(FeatureFlagKey.abTestVariant)}',
                                  variant: TextVariant.caption,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: Spacing.small),
                          const StyledText(
                            text: 'API Endpoint:',
                            variant: TextVariant.label,
                          ),
                          const SizedBox(height: Spacing.extraSmall),
                          StyledText(
                            text: featureFlags
                                .getFlag(FeatureFlagKey.apiEndpoint),
                            variant: TextVariant.caption,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  StyledButton(
                    text: 'Logout',
                    onPressed: _onLogoutPressed,
                    isLoading: viewModel.isLoading,
                    variant: ButtonVariant.primary,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
