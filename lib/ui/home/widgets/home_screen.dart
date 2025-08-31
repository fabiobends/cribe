import 'package:cribe/core/constants/feature_flags.dart';
import 'package:cribe/core/constants/spacing.dart';
import 'package:cribe/core/constants/ui_state.dart';
import 'package:cribe/data/providers/feature_flags_provider.dart';
import 'package:cribe/ui/home/view_models/home_view_model.dart';
import 'package:cribe/ui/shared/widgets/styled_button.dart';
import 'package:cribe/ui/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<HomeViewModel>();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (_viewModel.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: StyledText(
            text: _viewModel.errorMessage,
            variant: TextVariant.body,
            color: Colors.white,
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      _viewModel.clearError();
    } else if (_viewModel.state == UiState.success) {
      // Navigate back to login screen after successful logout
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  void _onLogoutPressed() {
    _viewModel.logout();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: SafeArea(
        child: Consumer2<HomeViewModel, FeatureFlagsProvider>(
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
