import 'package:cribe/data/services/auth_service.dart';
import 'package:cribe/data/services/storage_service.dart';
import 'package:cribe/ui/auth/widgets/login_screen.dart';
import 'package:cribe/ui/home/widgets/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final storageService = context.read<StorageService>();
    final authService = AuthService(storageService);

    if (mounted) {
      setState(() {
        _isAuthenticated = authService.isAuthenticated;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return _isAuthenticated ? const HomeScreen() : const LoginScreen();
  }

  Widget _buildLoadingScreen() {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
