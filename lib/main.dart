import 'dart:io';

import 'package:cribe/core/constants/feature_flags.dart';
import 'package:cribe/core/ui/themes/app_theme.dart';
import 'package:cribe/data/providers/feature_flags_provider.dart';
import 'package:cribe/data/repositories/auth_repository.dart';
import 'package:cribe/data/services/api_service.dart';
import 'package:cribe/data/services/logger_service.dart';
import 'package:cribe/data/services/storage_service.dart';
import 'package:cribe/ui/auth/view_models/login_view_model.dart';
import 'package:cribe/ui/auth/view_models/register_view_model.dart';
import 'package:cribe/ui/auth/widgets/auth_screen.dart';
import 'package:cribe/ui/auth/widgets/login_screen.dart';
import 'package:cribe/ui/auth/widgets/register_screen.dart';
import 'package:cribe/ui/dev_helper/widgets/dev_helper_wrapper.dart';
import 'package:cribe/ui/home/view_models/home_view_model.dart';
import 'package:cribe/ui/home/widgets/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final storageService = StorageService();
  await storageService.init();

  // Initialize logger service
  await LoggerService.instance.init();

  final apiService = ApiService(
    storageService: storageService,
    httpClient: HttpClient(),
  );
  await apiService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        ChangeNotifierProvider<FeatureFlagsProvider>(
          create: (context) {
            final provider = FeatureFlagsProvider(storageService);
            // Set up listener to update services when flags change
            provider.addListener(() {
              final apiEndpoint = provider.getFlag(FeatureFlagKey.apiEndpoint);
              apiService.updateBaseUrl(apiEndpoint);

              // Update logger when log level changes
              final logLevel = provider.getFlag(FeatureFlagKey.logFilter);
              LoggerService.instance.setLogLevelByName(logLevel);
            });
            final logLevel = provider.getFlag(FeatureFlagKey.logFilter);
            LoggerService.instance.setLogLevelByName(logLevel);
            return provider;
          },
        ),
        ChangeNotifierProvider<LoginViewModel>(
          create: (context) => LoginViewModel(AuthRepository(apiService)),
        ),
        ChangeNotifierProvider<RegisterViewModel>(
          create: (context) => RegisterViewModel(AuthRepository(apiService)),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (context) => HomeViewModel(storageService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cribe App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const DevHelperWrapper(child: AuthScreen()),
        '/login': (context) => const DevHelperWrapper(child: LoginScreen()),
        '/register': (context) =>
            const DevHelperWrapper(child: RegisterScreen()),
        '/home': (context) => const DevHelperWrapper(child: HomeScreen()),
      },
    );
  }
}
