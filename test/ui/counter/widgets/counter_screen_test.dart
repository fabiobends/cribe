import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cribe/data/repositories/counter_repository.dart';
import 'package:cribe/ui/counter/view_model/counter_view_model.dart';
import 'package:cribe/ui/counter/widgets/counter_screen.dart';

void main() {
  late CounterViewModel viewModel;
  late CounterRepository repository;

  setUp(() {
    repository = CounterRepository();
    viewModel = CounterViewModel(repository);
  });

  group('CounterScreen', () {
    testWidgets('should display initial counter value of 0', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: CounterScreen(viewModel: viewModel),
        ),
      );

      // Assert
      expect(find.text('Count: 0'), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: CounterScreen(viewModel: viewModel),
        ),
      );

      // Act - Start loading
      viewModel.setLoading(true);
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Count: 0'), findsNothing);

      // Act - Stop loading
      viewModel.setLoading(false);
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Count: 0'), findsOneWidget);
    });

    testWidgets('should show error message when error occurs', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: CounterScreen(viewModel: viewModel),
        ),
      );

      // Act
      viewModel.setError('Test error message');
      await tester.pump();

      // Assert
      expect(find.text('Test error message'), findsOneWidget);
    });

    testWidgets('should increment counter when increment button is pressed',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: CounterScreen(viewModel: viewModel),
        ),
      );

      // Act
      await tester.tap(find.text('Increment'));
      await tester.pump();

      // Assert
      expect(find.text('Count: 1'), findsOneWidget);
    });

    testWidgets('should decrement counter when decrement button is pressed',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: CounterScreen(viewModel: viewModel),
        ),
      );

      // Act
      await tester.tap(find.text('Decrement'));
      await tester.pump();

      // Assert
      expect(find.text('Count: -1'), findsOneWidget);
    });

    testWidgets('should update counter value after multiple operations',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: CounterScreen(viewModel: viewModel),
        ),
      );

      // Act - Increment twice
      await tester.tap(find.text('Increment'));
      await tester.pump();
      await tester.tap(find.text('Increment'));
      await tester.pump();

      // Assert
      expect(find.text('Count: 2'), findsOneWidget);

      // Act - Decrement once
      await tester.tap(find.text('Decrement'));
      await tester.pump();

      // Assert
      expect(find.text('Count: 1'), findsOneWidget);
    });

    testWidgets('should have proper app bar title', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: CounterScreen(viewModel: viewModel),
        ),
      );

      // Assert
      expect(find.text('Counter Example'), findsOneWidget);
    });

    testWidgets('should have properly styled buttons', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: CounterScreen(viewModel: viewModel),
        ),
      );

      // Assert
      final incrementButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Increment'),
          matching: find.byType(ElevatedButton),
        ),
      );
      final decrementButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Decrement'),
          matching: find.byType(ElevatedButton),
        ),
      );

      expect(incrementButton, isNotNull);
      expect(decrementButton, isNotNull);
    });
  });
}
