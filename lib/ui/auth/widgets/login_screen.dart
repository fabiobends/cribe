import 'package:cribe/core/constants/spacing.dart';
import 'package:cribe/core/enums/ui_state.dart';
import 'package:cribe/ui/auth/view_model/login_view_model.dart';
import 'package:cribe/ui/auth/widgets/register_screen.dart';
import 'package:cribe/ui/core/shared/styled_button.dart';
import 'package:cribe/ui/core/shared/styled_text.dart';
import 'package:cribe/ui/core/shared/styled_text_button.dart';
import 'package:cribe/ui/core/shared/styled_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<LoginViewModel>();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (_viewModel.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      _viewModel.clearError();
    } else if (_viewModel.state == UiState.success) {
      // Navigate to home screen after successful login
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      _viewModel.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final screenHeight = mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
    final contentHeight = isLandscape ? null : screenHeight;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: contentHeight,
            child: Form(
              key: _formKey,
              child: Consumer<LoginViewModel>(
                builder: (context, viewModel, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: Spacing.huge,
                        width: Spacing.huge,
                        child: Placeholder(),
                      ),
                      const SizedBox(height: Spacing.large),
                      const StyledText(
                        text: 'Sign in to your account',
                        variant: TextVariant.subtitle,
                      ),
                      const SizedBox(height: Spacing.large),
                      StyledTextField(
                        label: 'Email',
                        hint: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !viewModel.isLoading,
                        validator: viewModel.validateEmail,
                        focusNode: _emailFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            _passwordFocusNode.requestFocus(),
                      ),
                      const SizedBox(height: Spacing.medium),
                      StyledTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        controller: _passwordController,
                        obscureText: true,
                        enabled: !viewModel.isLoading,
                        validator: viewModel.validatePassword,
                        focusNode: _passwordFocusNode,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _onLoginPressed(),
                      ),
                      const SizedBox(height: Spacing.medium),
                      StyledButton(
                        text: 'Sign In',
                        onPressed: _onLoginPressed,
                        isLoading: viewModel.isLoading,
                        variant: ButtonVariant.primary,
                      ),
                      const SizedBox(height: Spacing.large),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const StyledText(
                            text: "Don't have an account?",
                            variant: TextVariant.body,
                          ),
                          const SizedBox(width: Spacing.small),
                          StyledTextButton(
                            text: 'Sign Up',
                            onPressed: _navigateToRegister,
                            isEnabled: !viewModel.isLoading,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
