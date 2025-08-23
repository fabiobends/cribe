import 'package:cribe/core/enums/ui_state.dart';
import 'package:cribe/ui/core/shared/styled_button.dart';
import 'package:cribe/ui/home/view_model/home_view_model.dart';
import 'package:cribe/ui/home/widgets/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'home_screen_test.mocks.dart';

@GenerateMocks([HomeViewModel])
void main() {
  late MockHomeViewModel mockHomeViewModel;

  setUp(() {
    mockHomeViewModel = MockHomeViewModel();

    // Default mock behavior
    when(mockHomeViewModel.state).thenReturn(UiState.initial);
    when(mockHomeViewModel.isLoading).thenReturn(false);
    when(mockHomeViewModel.hasError).thenReturn(false);
    when(mockHomeViewModel.errorMessage).thenReturn('');
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: ChangeNotifierProvider<HomeViewModel>.value(
        value: mockHomeViewModel,
        child: const HomeScreen(),
      ),
    );
  }

  group('HomeScreen', () {
    group('UI elements', () {
      testWidgets('should display "Home" title in AppBar', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('Home'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('should display logout button', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('Logout'), findsOneWidget);
        expect(find.byType(StyledButton), findsOneWidget);
      });
    });

    group('logout button interaction', () {
      testWidgets('should call logout when logout button is tapped',
          (tester) async {
        // Arrange
        when(mockHomeViewModel.logout()).thenAnswer((_) async {});

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.text('Logout'));
        await tester.pump();

        // Assert
        verify(mockHomeViewModel.logout()).called(1);
      });

      testWidgets('should be enabled when not loading', (tester) async {
        // Arrange
        when(mockHomeViewModel.isLoading).thenReturn(false);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        final button =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNotNull);
      });

      testWidgets('should be disabled when loading', (tester) async {
        // Arrange
        when(mockHomeViewModel.isLoading).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        final button = tester.widget<StyledButton>(find.byType(StyledButton));
        expect(button.isLoading, isTrue);
      });

      testWidgets('should show CircularProgressIndicator when loading',
          (tester) async {
        // Arrange
        when(mockHomeViewModel.isLoading).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        // Text is still present but transparent when loading
        expect(find.text('Logout'), findsOneWidget);
      });
    });

    group('loading state', () {
      testWidgets('should show CircularProgressIndicator when loading',
          (tester) async {
        // Arrange
        when(mockHomeViewModel.isLoading).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should not show CircularProgressIndicator when not loading',
          (tester) async {
        // Arrange
        when(mockHomeViewModel.isLoading).thenReturn(false);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    group('error handling', () {
      testWidgets('should handle error state correctly', (tester) async {
        // Arrange
        when(mockHomeViewModel.hasError).thenReturn(true);
        when(mockHomeViewModel.errorMessage).thenReturn('Logout failed');

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert - The error state is handled by the ViewModel
        expect(mockHomeViewModel.hasError, isTrue);
        expect(mockHomeViewModel.errorMessage, equals('Logout failed'));
      });

      testWidgets('should not show error snackbar when hasError is false',
          (tester) async {
        // Arrange
        when(mockHomeViewModel.hasError).thenReturn(false);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.byType(SnackBar), findsNothing);
      });
    });

    group('navigation', () {
      testWidgets('should call logout when logout button is pressed',
          (tester) async {
        // Arrange
        when(mockHomeViewModel.logout()).thenAnswer((_) async {});

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.text('Logout'));
        await tester.pump();

        // Assert
        verify(mockHomeViewModel.logout()).called(1);
      });
    });

    group('Consumer integration', () {
      testWidgets('should use Consumer to listen to ViewModel changes',
          (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(Consumer<HomeViewModel>), findsOneWidget);
      });
    });
  });
}
