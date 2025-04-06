import 'package:flutter/material.dart';
import '../view_model/counter_view_model.dart';

class CounterScreen extends StatelessWidget {
  final CounterViewModel viewModel;

  const CounterScreen({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Counter Example'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (viewModel.isLoading)
                  const CircularProgressIndicator()
                else
                  Text(
                    'Count: ${viewModel.count}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                if (viewModel.error != null)
                  Text(
                    viewModel.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: viewModel.decrement,
                      child: const Text('Decrement'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: viewModel.increment,
                      child: const Text('Increment'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
