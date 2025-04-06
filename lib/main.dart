import 'package:flutter/material.dart';
import 'data/repositories/counter_repository.dart';
import 'ui/counter/view_model/counter_view_model.dart';
import 'ui/counter/widgets/counter_screen.dart';
import 'ui/core/themes/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create repository and view model instances
    final counterRepository = CounterRepository();
    final counterViewModel = CounterViewModel(counterRepository);

    return MaterialApp(
      title: 'Flutter Architecture Demo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: CounterScreen(viewModel: counterViewModel),
    );
  }
}
