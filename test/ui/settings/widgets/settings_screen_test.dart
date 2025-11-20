import 'dart:async';

import 'package:cribe/core/constants/feature_flags.dart';
import 'package:cribe/core/constants/storage_keys.dart';
import 'package:cribe/data/providers/feature_flags_provider.dart';
import 'package:cribe/data/services/api_service.dart';
import 'package:cribe/data/services/storage_service.dart';
import 'package:cribe/ui/auth/widgets/auth_screen.dart';
import 'package:cribe/ui/settings/view_models/settings_view_model.dart';
import 'package:cribe/ui/settings/widgets/settings_screen.dart';
import 'package:cribe/ui/shared/widgets/styled_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'settings_screen_test.mocks.dart';

@GenerateMocks([StorageService, FeatureFlagsProvider, ApiService])
void main() {
  late SettingsViewModel settingsViewModel;
  late MockStorageService mockStorageService;
  late MockFeatureFlagsProvider mockFeatureFlagsProvider;
  late MockApiService mockApiService;

  setUp(() {
    mockStorageService = MockStorageService();
    mockFeatureFlagsProvider = MockFeatureFlagsProvider();
    mockApiService = MockApiService();
    settingsViewModel = SettingsViewModel(storageService: mockStorageService);

    when(mockFeatureFlagsProvider.getFlag<bool>(FeatureFlagKey.booleanFlag))
        .thenReturn(true);
    when(mockFeatureFlagsProvider.getFlag<String>(FeatureFlagKey.abTestVariant))
        .thenReturn('A');
    when(mockFeatureFlagsProvider.getFlag<String>(FeatureFlagKey.apiEndpoint))
        .thenReturn('https://api.example.com');
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: mockApiService),
        Provider<StorageService>.value(value: mockStorageService),
        ChangeNotifierProvider<FeatureFlagsProvider>.value(
          value: mockFeatureFlagsProvider,
        ),
        ChangeNotifierProvider<SettingsViewModel>.value(
          value: settingsViewModel,
        ),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            return const SettingsScreen();
          },
        ),
      ),
    );
  }

  group('SettingsScreen', () {
    testWidgets('should display all UI elements', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      expect(find.byType(StyledButton), findsOneWidget);
      expect(find.text('Current Feature Flags'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should display feature flags correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Boolean Flag:'), findsOneWidget);
      expect(find.text('ON'), findsOneWidget);
      expect(find.text('A/B Variant:'), findsOneWidget);
      expect(find.textContaining('Variant A'), findsOneWidget);
      expect(find.text('API Endpoint:'), findsOneWidget);
      expect(find.text('https://api.example.com'), findsOneWidget);
    });

    testWidgets('should display OFF when boolean flag is false',
        (tester) async {
      when(mockFeatureFlagsProvider.getFlag<bool>(FeatureFlagKey.booleanFlag))
          .thenReturn(false);

      await tester.pumpWidget(createTestWidget());

      expect(find.text('OFF'), findsOneWidget);
    });

    testWidgets('should call logout when button is tapped', (tester) async {
      when(mockStorageService.setSecureValue(any, any))
          .thenAnswer((_) async => true);

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Logout'));
      await tester.pump();

      verify(
        mockStorageService.setSecureValue(
          SecureStorageKey.accessToken,
          '',
        ),
      ).called(1);
      verify(
        mockStorageService.setSecureValue(
          SecureStorageKey.refreshToken,
          '',
        ),
      ).called(1);
    });

    testWidgets('should show loading state when logout is in progress',
        (tester) async {
      final completer = Completer<bool>();
      when(mockStorageService.setSecureValue(any, any))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Logout'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the completer for cleanup
      completer.complete(true);
    });

    testWidgets('should show error snackbar on logout failure', (tester) async {
      when(mockStorageService.setSecureValue(any, any))
          .thenThrow(Exception('Logout failed'));

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Logout'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Logout failed'), findsOneWidget);
    });

    testWidgets('should clear tokens and reach success state on logout',
        (tester) async {
      when(mockStorageService.setSecureValue(any, any))
          .thenAnswer((_) async => true);
      when(mockStorageService.getSecureValue(any)).thenAnswer((_) async => '');

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Logout'));

      verify(
        mockStorageService.setSecureValue(
          SecureStorageKey.accessToken,
          '',
        ),
      ).called(1);
      verify(
        mockStorageService.setSecureValue(
          SecureStorageKey.refreshToken,
          '',
        ),
      ).called(1);

      expect(settingsViewModel.isSuccess, true);
    });

    testWidgets('should navigate to AuthScreen on successful logout',
        (tester) async {
      when(mockStorageService.setSecureValue(any, any))
          .thenAnswer((_) async => true);
      when(mockStorageService.getSecureValue(any)).thenAnswer((_) async => '');

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Assert - Should navigate to AuthScreen
      expect(find.byType(AuthScreen), findsOneWidget);
      verify(
        mockStorageService.setSecureValue(
          SecureStorageKey.accessToken,
          '',
        ),
      ).called(1);
      verify(
        mockStorageService.setSecureValue(
          SecureStorageKey.refreshToken,
          '',
        ),
      ).called(1);
    });

    testWidgets('should use Consumer2 for reactive updates', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(
        find.byType(Consumer2<SettingsViewModel, FeatureFlagsProvider>),
        findsOneWidget,
      );
    });

    testWidgets('should have proper layout structure', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Spacer), findsOneWidget);
    });

    testWidgets('should handle widget disposal', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(SettingsScreen), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      expect(find.byType(SettingsScreen), findsNothing);
    });
  });
}
