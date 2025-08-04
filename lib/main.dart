import 'package:cribe/core/config/app_config.dart';
import 'package:cribe/data/repositories/auth_repository.dart';
import 'package:cribe/data/services/api_service.dart';
import 'package:cribe/data/services/storage_service.dart';
import 'package:cribe/ui/auth/view_model/login_view_model.dart';
import 'package:cribe/ui/auth/view_model/register_view_model.dart';
import 'package:cribe/ui/auth/widgets/login_screen.dart';
import 'package:cribe/ui/auth/widgets/register_screen.dart';
import 'package:cribe/ui/core/themes/app_theme.dart';
import 'package:cribe/ui/core/wrappers/auth_wrapper.dart';
import 'package:cribe/ui/home/view_model/home_view_model.dart';
import 'package:cribe/ui/home/widgets/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final apiUrl = AppConfig.apiUrl;
  final storageService = StorageService();
  await storageService.init();
  final apiService = ApiService(apiUrl: apiUrl, storageService: storageService);
  await apiService.init();
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        Provider<StorageService>.value(value: storageService),
        ChangeNotifierProvider<LoginViewModel>(
          create: (context) => LoginViewModel(AuthRepository(apiService)),
        ),
        ChangeNotifierProvider<RegisterViewModel>(
          create: (context) => RegisterViewModel(AuthRepository(apiService)),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (context) =>
              HomeViewModel(AuthRepository(apiService), storageService),
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
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
