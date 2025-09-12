import 'package:cribe/core/logger/logger_mixins.dart';
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

class _AuthScreenState extends State<AuthScreen> with ScreenLogger {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    logger.info('AuthScreen initialized');
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    logger.debug('Checking authentication status');
    final storageService = context.read<StorageService>();
    final authService = AuthService(storageService);

    if (mounted) {
      try {
        final isAuthenticated = await authService.isAuthenticated;
        logger.info(
          'Authentication check completed',
          extra: {
            'isAuthenticated': isAuthenticated,
          },
        );

        setState(() {
          _isAuthenticated = isAuthenticated;
          _isLoading = false;
        });
      } catch (e) {
        logger.error('Failed to check authentication status', error: e);
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    } else {
      logger.warn('Widget unmounted during authentication check');
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.debug(
      'Building AuthScreen',
      extra: {
        'isLoading': _isLoading,
        'isAuthenticated': _isAuthenticated,
      },
    );

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
