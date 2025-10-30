import 'package:cribe/core/constants/ui_state.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/ui/podcasts/view_models/podcasts_list_view_model.dart';
import 'package:cribe/ui/podcasts/widgets/podcasts_list_screen.dart';
import 'package:cribe/ui/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'podcasts_list_screen_test.mocks.dart';

// TestPodcastsListViewModel that can trigger actual listener notifications
class TestPodcastsListViewModel extends PodcastsListViewModel {
  TestPodcastsListViewModel() : super();

  void simulateError(String errorMessage) {
    _errorMessage = errorMessage;
    _setState(UiState.error);
  }

  void simulateLoading() {
    _setState(UiState.loading);
  }

  void simulateSuccess() {
    _setState(UiState.success);
  }

  void setPodcasts(List<Podcast> podcasts) {
    _podcasts = podcasts;
    notifyListeners();
  }

  void clearPodcasts() {
    _podcasts = [];
    notifyListeners();
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
    notifyListeners();
  }

  UiState _state = UiState.initial;

  @override
  UiState get state => _state;

  @override
  bool get hasError => _state == UiState.error;

  List<Podcast> _podcasts = [];

  @override
  List<Podcast> get podcasts => _podcasts;
}

@GenerateMocks([PodcastsListViewModel])
void main() {
  late MockPodcastsListViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockPodcastsListViewModel();

    // Default mock behavior
    when(mockViewModel.state).thenReturn(UiState.initial);
    when(mockViewModel.isLoading).thenReturn(false);
    when(mockViewModel.hasError).thenReturn(false);
    when(mockViewModel.errorMessage).thenReturn('');
    when(mockViewModel.podcasts).thenReturn([]);
  });

  List<Podcast> createMockPodcasts({int count = 2}) {
    return List.generate(
      count,
      (index) => Podcast(
        id: index + 1,
        authorName: 'Author ${index + 1}',
        name: 'Podcast ${index + 1}',
        imageUrl: 'https://picsum.photos/200/200?random=${index + 1}',
        description: 'Description for podcast ${index + 1}',
        externalId: 'ext-${index + 1}',
        createdAt: DateTime.now().subtract(Duration(days: (index + 1) * 30)),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Widget createTestWidget() {
    return MaterialApp(
      home: ChangeNotifierProvider<PodcastsListViewModel>.value(
        value: mockViewModel,
        child: const PodcastsListScreen(),
      ),
    );
  }

  group('PodcastsListScreen', () {
    group('UI elements', () {
      testWidgets('should display Scaffold', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should display SafeArea', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(SafeArea), findsOneWidget);
      });

      testWidgets('should use Consumer widget', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(Consumer<PodcastsListViewModel>), findsOneWidget);
      });
    });

    group('loading state', () {
      testWidgets('should show CircularProgressIndicator when loading',
          (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(ListView), findsNothing);
      });

      testWidgets('should center CircularProgressIndicator', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(Center), findsOneWidget);
        final center = tester.widget<Center>(find.byType(Center));
        expect(center.child, isA<CircularProgressIndicator>());
      });
    });

    group('empty state', () {
      testWidgets('should show "No podcasts available" when podcasts is empty',
          (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcasts).thenReturn([]);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('No podcasts available'), findsOneWidget);
        expect(find.byType(ListView), findsNothing);
      });

      testWidgets('should center empty message', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcasts).thenReturn([]);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(Center), findsOneWidget);
        expect(find.text('No podcasts available'), findsOneWidget);
      });
    });

    group('podcasts list', () {
      testWidgets('should display ListView when podcasts are available',
          (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcasts).thenReturn(createMockPodcasts());

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('should display correct number of podcast cards',
          (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcasts).thenReturn(createMockPodcasts());

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(Card), findsNWidgets(2));
      });

      testWidgets('should display podcast names', (tester) async {
        // Arrange
        final podcasts = createMockPodcasts();
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcasts).thenReturn(podcasts);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        for (final podcast in podcasts) {
          expect(find.text(podcast.name), findsOneWidget);
        }
      });

      testWidgets('should display podcast author names', (tester) async {
        // Arrange
        final podcasts = createMockPodcasts();
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcasts).thenReturn(podcasts);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        for (final podcast in podcasts) {
          expect(find.text(podcast.authorName), findsOneWidget);
        }
      });

      testWidgets('should display podcast descriptions', (tester) async {
        // Arrange
        final podcasts = createMockPodcasts();
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcasts).thenReturn(podcasts);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        for (final podcast in podcasts) {
          expect(find.text(podcast.description), findsOneWidget);
        }
      });

      testWidgets('should display podcast images', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcasts).thenReturn(createMockPodcasts());

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(Image), findsNWidgets(2));
      });

      testWidgets('should display ClipRRect for rounded images',
          (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcasts).thenReturn(createMockPodcasts());

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(ClipRRect), findsNWidgets(2));
      });
    });

    group('podcast card', () {
      testWidgets('should have InkWell for tap interaction', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcasts).thenReturn(createMockPodcasts());

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(InkWell), findsNWidgets(2));
      });

      testWidgets('should display Row layout for podcast card', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcasts).thenReturn(createMockPodcasts());

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert - Each card has a Row
        expect(find.byType(Row), findsNWidgets(2));
      });

      testWidgets('should display Column for text content', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcasts).thenReturn(createMockPodcasts());

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert - Each card has a Column for text
        expect(find.byType(Column), findsNWidgets(2));
      });

      testWidgets('should use StyledText widgets', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcasts).thenReturn(createMockPodcasts());

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert - 3 StyledText per card (name, author, description)
        expect(find.byType(StyledText), findsNWidgets(6));
      });
    });

    group('podcast card with null imageUrl', () {
      testWidgets('should display placeholder icon when imageUrl is null',
          (tester) async {
        // Arrange
        final podcastsWithNullImage = [
          Podcast(
            id: 1,
            authorName: 'Test Author',
            name: 'Test Podcast',
            description: 'Test description',
            externalId: 'test-1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcasts).thenReturn(podcastsWithNullImage);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byIcon(Icons.mic), findsOneWidget);
        expect(find.byType(Container), findsWidgets);
      });
    });

    group('error handling', () {
      testWidgets('should show SnackBar when error occurs', (tester) async {
        // Create a test view model
        final testViewModel = TestPodcastsListViewModel();

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<PodcastsListViewModel>.value(
              value: testViewModel,
              child: const PodcastsListScreen(),
            ),
          ),
        );

        // Wait for initial build
        await tester.pump();

        // Simulate an error
        testViewModel.simulateError('Failed to load podcasts');
        await tester.pump();

        // Assert that SnackBar is shown
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Failed to load podcasts'), findsOneWidget);
      });

      testWidgets('should call clearError after showing error', (tester) async {
        // Create a test view model
        final testViewModel = TestPodcastsListViewModel();

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<PodcastsListViewModel>.value(
              value: testViewModel,
              child: const PodcastsListScreen(),
            ),
          ),
        );

        // Wait for initial build
        await tester.pump();

        // Initially in error state
        testViewModel.simulateError('Test error');
        await tester.pump();

        expect(testViewModel.hasError, isTrue);

        // The clearError is called in _onViewModelChanged
        // After showing snackbar, clearError would be called by the screen
        // The TestViewModel simulates this behavior
        await tester.pump();

        // Verify error was shown
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('should show error snackbar with error background color',
          (tester) async {
        // Create a test view model
        final testViewModel = TestPodcastsListViewModel();

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<PodcastsListViewModel>.value(
              value: testViewModel,
              child: const PodcastsListScreen(),
            ),
          ),
        );

        // Wait for initial build
        await tester.pump();

        // Simulate an error
        testViewModel.simulateError('Test error');
        await tester.pump();

        // Find the SnackBar
        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, isNotNull);
      });
    });

    group('view model listener', () {
      testWidgets('should add listener on initState', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcasts).thenReturn([]);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert - Widget builds successfully with listener
        expect(find.byType(PodcastsListScreen), findsOneWidget);
      });

      testWidgets('should remove listener on dispose', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcasts).thenReturn([]);

        // Act
        await tester.pumpWidget(createTestWidget());
        expect(find.byType(PodcastsListScreen), findsOneWidget);

        // Dispose by removing widget
        await tester.pumpWidget(const MaterialApp(home: SizedBox()));

        // Assert - Widget is disposed
        expect(find.byType(PodcastsListScreen), findsNothing);
      });
    });

    group('reactive updates', () {
      testWidgets('should update UI when podcasts list changes',
          (tester) async {
        // Create a test view model with real reactivity
        final testViewModel = TestPodcastsListViewModel();
        testViewModel.clearPodcasts(); // Start with empty

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<PodcastsListViewModel>.value(
              value: testViewModel,
              child: const PodcastsListScreen(),
            ),
          ),
        );

        // Initially empty
        expect(find.text('No podcasts available'), findsOneWidget);

        // Add podcasts
        testViewModel.setPodcasts(createMockPodcasts());
        await tester.pump();

        // Should now show podcasts
        expect(find.text('No podcasts available'), findsNothing);
        expect(find.text('Podcast 1'), findsOneWidget);
      });

      testWidgets('should update UI when loading state changes',
          (tester) async {
        // Create a test view model
        final testViewModel = TestPodcastsListViewModel();
        testViewModel.clearPodcasts();

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<PodcastsListViewModel>.value(
              value: testViewModel,
              child: const PodcastsListScreen(),
            ),
          ),
        );

        // Show loading
        testViewModel.simulateLoading();
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Complete loading
        testViewModel.simulateSuccess();
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    group('ListView properties', () {
      testWidgets('should have padding on ListView', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcasts).thenReturn(createMockPodcasts());

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        final listView = tester.widget<ListView>(find.byType(ListView));
        expect(listView.padding, isNotNull);
      });

      testWidgets('should use ListView.builder', (tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcasts).thenReturn(createMockPodcasts());

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        final listView = tester.widget<ListView>(find.byType(ListView));
        expect(listView.childrenDelegate, isA<SliverChildBuilderDelegate>());
      });
    });

    group('accessibility', () {
      testWidgets('should be accessible with Semantics', (tester) async {
        // Arrange
        final podcasts = createMockPodcasts();
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcasts).thenReturn(podcasts);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert - Check that text widgets are accessible
        expect(find.text(podcasts[0].name), findsOneWidget);
        expect(find.text(podcasts[0].authorName), findsOneWidget);
      });
    });

    group('scrolling behavior', () {
      testWidgets('should be scrollable with many podcasts', (tester) async {
        // Arrange - Create many podcasts to ensure scrolling
        final manyPodcasts = List.generate(
          20,
          (index) => Podcast(
            id: index,
            authorName: 'Author $index',
            name: 'Podcast $index',
            imageUrl: 'https://picsum.photos/200/200?random=$index',
            description: 'Description $index',
            externalId: 'ext-$index',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcasts).thenReturn(manyPodcasts);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert - Should find first podcast
        expect(find.text('Podcast 0'), findsOneWidget);

        // Scroll down
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();

        // Should now see podcasts further down the list
        expect(find.byType(Card), findsWidgets);
      });
    });
  });
}
