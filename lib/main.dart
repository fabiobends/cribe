import 'package:flutter/material.dart';
import 'data/repositories/counter_repository.dart';
import 'ui/counter/view_model/counter_view_model.dart';
import 'ui/counter/widgets/counter_screen.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: CounterScreen(viewModel: counterViewModel),
    );
  }
}
