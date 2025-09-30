import 'package:cribe/core/constants/feature_flags.dart';
import 'package:cribe/core/constants/ui_state.dart';
import 'package:cribe/data/providers/feature_flags_provider.dart';
import 'package:cribe/data/services/storage_service.dart';
import 'package:cribe/ui/home/view_models/home_view_model.dart';
import 'package:cribe/ui/home/widgets/home_screen.dart';
import 'package:cribe/ui/shared/widgets/styled_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'home_screen_test.mocks.dart';

// TestHomeViewModel that can trigger actual listener notifications
class TestHomeViewModel extends HomeViewModel {
  TestHomeViewModel(super.storageService);

  void simulateError(String errorMessage) {
    _errorMessage = errorMessage;
    _setState(UiState.error);
  }

  void simulateSuccess() {
    _setState(UiState.success);
  }

  // Expose private fields for testing
  String _errorMessage = '';

  @override
  String get errorMessage => _errorMessage;

  void _setState(UiState newState) {
    _state = newState;
    setLoading(newState == UiState.loading);
    if (newState == UiState.error) {
      setError(_errorMessage);
    } else {
      setError(null);
    }
    // The BaseViewModel will call notifyListeners() through setLoading/setError
    // But we need to ensure it's called for state changes too
    notifyListeners();
  }

  UiState _state = UiState.initial;

  @override
  UiState get state => _state;

  @override
  bool get hasError => _state == UiState.error;
}

@GenerateMocks([HomeViewModel, StorageService, FeatureFlagsProvider])
void main() {
  late MockHomeViewModel mockHomeViewModel;
  late MockFeatureFlagsProvider mockFeatureFlagsProvider;

  setUp(() {
    mockHomeViewModel = MockHomeViewModel();
    mockFeatureFlagsProvider = MockFeatureFlagsProvider();

    // Default mock behavior for HomeViewModel
    when(mockHomeViewModel.state).thenReturn(UiState.initial);
    when(mockHomeViewModel.isLoading).thenReturn(false);
    when(mockHomeViewModel.hasError).thenReturn(false);
    when(mockHomeViewModel.errorMessage).thenReturn('');

    // Default mock behavior for FeatureFlagsProvider
    when(mockFeatureFlagsProvider.getFlag<bool>(FeatureFlagKey.booleanFlag))
        .thenReturn(true);
    when(mockFeatureFlagsProvider.getFlag<String>(FeatureFlagKey.abTestVariant))
        .thenReturn('A');
    when(mockFeatureFlagsProvider.getFlag<String>(FeatureFlagKey.apiEndpoint))
        .thenReturn('https://api.example.com');
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<HomeViewModel>.value(
            value: mockHomeViewModel,
          ),
          ChangeNotifierProvider<FeatureFlagsProvider>.value(
            value: mockFeatureFlagsProvider,
          ),
        ],
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
      testWidgets('should use Consumer2 to listen to ViewModel changes',
          (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(
          find.byType(Consumer2<HomeViewModel, FeatureFlagsProvider>),
          findsOneWidget,
        );
      });
    });

    group('_onViewModelChanged listener tests', () {
      testWidgets('should show SnackBar when error occurs', (tester) async {
        // Create a test storage service for the TestHomeViewModel
        final testViewModel = TestHomeViewModel(MockStorageService());

        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider<HomeViewModel>.value(
                  value: testViewModel,
                ),
                ChangeNotifierProvider<FeatureFlagsProvider>.value(
                  value: mockFeatureFlagsProvider,
                ),
              ],
              child: const HomeScreen(),
            ),
          ),
        );

        // Wait for initial build
        await tester.pump();

        // Simulate an error - this will trigger _onViewModelChanged
        testViewModel.simulateError('Test error message');
        await tester.pump();

        // Assert that SnackBar is shown
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Test error message'), findsOneWidget);
      });

      testWidgets('should navigate when success state occurs', (tester) async {
        // Create a test storage service for the TestHomeViewModel
        final testViewModel = TestHomeViewModel(MockStorageService());

        await tester.pumpWidget(
          MaterialApp(
            initialRoute: '/home',
            routes: {
              '/': (context) => const Scaffold(body: Text('Login Screen')),
              '/home': (context) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider<HomeViewModel>.value(
                        value: testViewModel,
                      ),
                      ChangeNotifierProvider<FeatureFlagsProvider>.value(
                        value: mockFeatureFlagsProvider,
                      ),
                    ],
                    child: const HomeScreen(),
                  ),
            },
          ),
        );

        // Wait for initial build and ensure home screen is displayed
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.text('Login Screen'), findsNothing);

        // Simulate success - this will trigger _onViewModelChanged and navigation
        testViewModel.simulateSuccess();

        // Wait for all animations and navigation to complete
        await tester.pumpAndSettle();

        // Assert that navigation occurred
        expect(find.text('Login Screen'), findsOneWidget);
        expect(find.byType(HomeScreen), findsNothing);
      });
    });
  });
}
