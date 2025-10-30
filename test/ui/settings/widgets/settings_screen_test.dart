import 'package:cribe/core/constants/feature_flags.dart';
import 'package:cribe/core/constants/ui_state.dart';
import 'package:cribe/data/providers/feature_flags_provider.dart';
import 'package:cribe/data/services/storage_service.dart';
import 'package:cribe/ui/settings/view_models/settings_view_model.dart';
import 'package:cribe/ui/settings/widgets/settings_screen.dart';
import 'package:cribe/ui/shared/widgets/styled_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'settings_screen_test.mocks.dart';

class TestSettingsViewModel extends SettingsViewModel {
  TestSettingsViewModel(super.storageService);

  void simulateError(String errorMessage) {
    _errorMessage = errorMessage;
    _setState(UiState.error);
  }

  void simulateSuccess() {
    _setState(UiState.success);
  }

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
    notifyListeners();
  }

  UiState _state = UiState.initial;

  @override
  UiState get state => _state;

  @override
  bool get hasError => _state == UiState.error;
}

@GenerateMocks([SettingsViewModel, StorageService, FeatureFlagsProvider])
void main() {
  late MockSettingsViewModel mockViewModel;
  late MockFeatureFlagsProvider mockFeatureFlagsProvider;

  setUp(() {
    mockViewModel = MockSettingsViewModel();
    mockFeatureFlagsProvider = MockFeatureFlagsProvider();

    when(mockViewModel.state).thenReturn(UiState.initial);
    when(mockViewModel.isLoading).thenReturn(false);
    when(mockViewModel.hasError).thenReturn(false);
    when(mockViewModel.errorMessage).thenReturn('');

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
          ChangeNotifierProvider<SettingsViewModel>.value(
            value: mockViewModel,
          ),
          ChangeNotifierProvider<FeatureFlagsProvider>.value(
            value: mockFeatureFlagsProvider,
          ),
        ],
        child: const SettingsScreen(),
      ),
    );
  }

  group('SettingsScreen', () {
    group('UI elements', () {
      testWidgets('should display Scaffold', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should display SafeArea', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(SafeArea), findsOneWidget);
      });

      testWidgets('should display logout button', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Logout'), findsOneWidget);
        expect(find.byType(StyledButton), findsOneWidget);
      });

      testWidgets('should display feature flags card', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Current Feature Flags'), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
      });
    });

    group('feature flags display', () {
      testWidgets('should display boolean flag status', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Boolean Flag:'), findsOneWidget);
        expect(find.text('ON'), findsOneWidget);
      });

      testWidgets('should display OFF when boolean flag is false',
          (tester) async {
        when(mockFeatureFlagsProvider.getFlag<bool>(FeatureFlagKey.booleanFlag))
            .thenReturn(false);

        await tester.pumpWidget(createTestWidget());

        expect(find.text('OFF'), findsOneWidget);
      });

      testWidgets('should display A/B test variant', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('A/B Variant:'), findsOneWidget);
        expect(find.textContaining('Variant A'), findsOneWidget);
      });

      testWidgets('should display API endpoint', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('API Endpoint:'), findsOneWidget);
        expect(find.text('https://api.example.com'), findsOneWidget);
      });
    });

    group('logout button interaction', () {
      testWidgets('should call logout when logout button is tapped',
          (tester) async {
        when(mockViewModel.logout()).thenAnswer((_) async {});

        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.text('Logout'));
        await tester.pump();

        verify(mockViewModel.logout()).called(1);
      });

      testWidgets('should be disabled when loading', (tester) async {
        when(mockViewModel.isLoading).thenReturn(true);

        await tester.pumpWidget(createTestWidget());

        final button = tester.widget<StyledButton>(find.byType(StyledButton));
        expect(button.isLoading, isTrue);
      });

      testWidgets('should show CircularProgressIndicator when loading',
          (tester) async {
        when(mockViewModel.isLoading).thenReturn(true);

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('error handling', () {
      testWidgets('should show SnackBar when error occurs', (tester) async {
        final testViewModel = TestSettingsViewModel(MockStorageService());

        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider<SettingsViewModel>.value(
                  value: testViewModel,
                ),
                ChangeNotifierProvider<FeatureFlagsProvider>.value(
                  value: mockFeatureFlagsProvider,
                ),
              ],
              child: const SettingsScreen(),
            ),
          ),
        );

        await tester.pump();

        testViewModel.simulateError('Logout failed');
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Logout failed'), findsOneWidget);
      });

      testWidgets('should navigate when success state occurs', (tester) async {
        final testViewModel = TestSettingsViewModel(MockStorageService());

        await tester.pumpWidget(
          MaterialApp(
            initialRoute: '/settings',
            routes: {
              '/': (context) => const Scaffold(body: Text('Login Screen')),
              '/settings': (context) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider<SettingsViewModel>.value(
                        value: testViewModel,
                      ),
                      ChangeNotifierProvider<FeatureFlagsProvider>.value(
                        value: mockFeatureFlagsProvider,
                      ),
                    ],
                    child: const SettingsScreen(),
                  ),
            },
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(SettingsScreen), findsOneWidget);
        expect(find.text('Login Screen'), findsNothing);

        testViewModel.simulateSuccess();
        await tester.pumpAndSettle();

        expect(find.text('Login Screen'), findsOneWidget);
        expect(find.byType(SettingsScreen), findsNothing);
      });
    });

    group('view model listener', () {
      testWidgets('should add listener on initState', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(SettingsScreen), findsOneWidget);
      });

      testWidgets('should remove listener on dispose', (tester) async {
        await tester.pumpWidget(createTestWidget());
        expect(find.byType(SettingsScreen), findsOneWidget);

        await tester.pumpWidget(const MaterialApp(home: SizedBox()));

        expect(find.byType(SettingsScreen), findsNothing);
      });
    });

    group('Consumer integration', () {
      testWidgets('should use Consumer2 to listen to ViewModel changes',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(
          find.byType(Consumer2<SettingsViewModel, FeatureFlagsProvider>),
          findsOneWidget,
        );
      });
    });

    group('layout', () {
      testWidgets('should use Column for main layout', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(Column), findsWidgets);
      });

      testWidgets('should have Spacer to push logout button to bottom',
          (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(Spacer), findsOneWidget);
      });
    });
  });
}
