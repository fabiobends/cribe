import 'dart:io';

import 'package:cribe/core/constants/feature_flags.dart';
import 'package:cribe/core/ui/themes/app_theme.dart';
import 'package:cribe/data/providers/feature_flags_provider.dart';
import 'package:cribe/data/services/api_service.dart';
import 'package:cribe/data/services/logger_service.dart';
import 'package:cribe/data/services/storage_service.dart';
import 'package:cribe/ui/auth/widgets/auth_screen.dart';
import 'package:cribe/ui/dev_helper/widgets/dev_helper_wrapper.dart';
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
        Provider<ApiService>.value(value: apiService),
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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Cribe App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      builder: (context, child) => DevHelperWrapper(child: child!),
      home: const AuthScreen(),
    );
  }
}
