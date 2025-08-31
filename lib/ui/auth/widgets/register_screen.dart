import 'package:cribe/core/constants/spacing.dart';
import 'package:cribe/ui/auth/view_models/register_view_model.dart';
import 'package:cribe/ui/shared/widgets/styled_button.dart';
import 'package:cribe/ui/shared/widgets/styled_text.dart';
import 'package:cribe/ui/shared/widgets/styled_text_button.dart';
import 'package:cribe/ui/shared/widgets/styled_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late RegisterViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<RegisterViewModel>();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
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
    }
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      _viewModel.register(
        _emailController.text.trim(),
        _passwordController.text,
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
      );
    }
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: _viewModel.isLoading ? null : _navigateBack,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.large),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const StyledText(
                  text: 'Create Account',
                  variant: TextVariant.headline,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.small),
                const StyledText(
                  text: 'Sign up to get started',
                  variant: TextVariant.subtitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.extraLarge),
                Column(
                  spacing: Spacing.extraSmall,
                  children: [
                    StyledTextField(
                      label: 'First Name',
                      hint: 'John',
                      controller: _firstNameController,
                      keyboardType: TextInputType.name,
                      enabled: !_viewModel.isLoading,
                      validator: _viewModel.validateFirstName,
                      focusNode: _firstNameFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          _lastNameFocusNode.requestFocus(),
                    ),
                    StyledTextField(
                      label: 'Last Name',
                      hint: 'Doe',
                      controller: _lastNameController,
                      keyboardType: TextInputType.name,
                      enabled: !_viewModel.isLoading,
                      validator: _viewModel.validateLastName,
                      focusNode: _lastNameFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
                    ),
                    StyledTextField(
                      label: 'Email',
                      hint: 'john.doe@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_viewModel.isLoading,
                      validator: _viewModel.validateEmail,
                      focusNode: _emailFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          _passwordFocusNode.requestFocus(),
                    ),
                    StyledTextField(
                      label: 'Password',
                      hint: 'Create a password',
                      controller: _passwordController,
                      obscureText: true,
                      enabled: !_viewModel.isLoading,
                      validator: _viewModel.validatePassword,
                      focusNode: _passwordFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          _confirmPasswordFocusNode.requestFocus(),
                    ),
                  ],
                ),
                StyledTextField(
                  label: 'Confirm Password',
                  hint: 'Confirm your password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  enabled: !_viewModel.isLoading,
                  validator: (value) => _viewModel.validateConfirmPassword(
                    _passwordController.text,
                    value,
                  ),
                  focusNode: _confirmPasswordFocusNode,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _onRegisterPressed(),
                ),
                const SizedBox(height: Spacing.large),
                StyledButton(
                  text: 'Create Account',
                  onPressed: _onRegisterPressed,
                  isLoading: _viewModel.isLoading,
                  variant: ButtonVariant.primary,
                ),
                const SizedBox(height: Spacing.large),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const StyledText(
                      text: 'Already have an account?',
                      variant: TextVariant.body,
                    ),
                    const SizedBox(width: Spacing.small),
                    StyledTextButton(
                      text: 'Sign In',
                      onPressed: _navigateBack,
                      isEnabled: !_viewModel.isLoading,
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.large),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
