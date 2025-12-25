import 'package:cribe/core/constants/feature_flags.dart';
import 'package:cribe/data/providers/feature_flags_provider.dart';
import 'package:cribe/data/services/api_service.dart';
import 'package:cribe/data/services/storage_service.dart';
import 'package:cribe/ui/navigation/widgets/main_navigation_screen.dart';
import 'package:cribe/ui/podcasts/view_models/podcast_list_view_model.dart';
import 'package:cribe/ui/podcasts/widgets/podcasts_list_screen.dart';
import 'package:cribe/ui/settings/view_models/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'main_navigation_screen_test.mocks.dart';

@GenerateMocks([
  PodcastListViewModel,
  SettingsViewModel,
  FeatureFlagsProvider,
  ApiService,
  StorageService,
])
void main() {
  late MockPodcastListViewModel mockPodcastsViewModel;
  late MockSettingsViewModel mockSettingsViewModel;
  late MockFeatureFlagsProvider mockFeatureFlagsProvider;
  late MockApiService mockApiService;
  late MockStorageService mockStorageService;

  setUp(() {
    mockPodcastsViewModel = MockPodcastListViewModel();
    mockSettingsViewModel = MockSettingsViewModel();
    mockFeatureFlagsProvider = MockFeatureFlagsProvider();
    mockApiService = MockApiService();
    mockStorageService = MockStorageService();

    // Default mock behavior for PodcastListViewModel
    when(mockPodcastsViewModel.isLoading).thenReturn(false);
    when(mockPodcastsViewModel.podcasts).thenReturn([]);

    // Default mock behavior for SettingsViewModel
    when(mockSettingsViewModel.isLoading).thenReturn(false);
    when(mockSettingsViewModel.error).thenReturn(null);

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
          Provider<ApiService>.value(value: mockApiService),
          Provider<StorageService>.value(value: mockStorageService),
          ChangeNotifierProvider<FeatureFlagsProvider>.value(
            value: mockFeatureFlagsProvider,
          ),
          ChangeNotifierProvider<PodcastListViewModel>.value(
            value: mockPodcastsViewModel,
          ),
          ChangeNotifierProvider<SettingsViewModel>.value(
            value: mockSettingsViewModel,
          ),
        ],
        child: const MainNavigationScreen(),
      ),
    );
  }

  group('MainNavigationScreen', () {
    testWidgets('should display BottomNavigationBar', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('should have IndexedStack for screen management',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(IndexedStack), findsOneWidget);
    });

    testWidgets('should display navigation items', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final bottomNav =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNav.items.length, equals(3));
    });

    testWidgets('should have Home and Settings tabs', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('should start with first tab selected', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final bottomNav =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNav.currentIndex, equals(0));
    });

    testWidgets('should display PodcastListScreen initially', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(PodcastListScreen), findsOneWidget);
    });

    testWidgets('should switch tab index when second tab is tapped',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap on Settings tab
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      // Verify currentIndex changed
      final bottomNav =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNav.currentIndex, equals(1));
    });

    testWidgets('should switch back to first tab when tapped', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Switch to Settings
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      // Switch back to Home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      final bottomNav =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNav.currentIndex, equals(0));
    });

    testWidgets('should have appropriate icons for navigation items',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('should use BottomNavigationBarType.fixed', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final bottomNav =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNav.type, equals(BottomNavigationBarType.fixed));
    });
  });
}
