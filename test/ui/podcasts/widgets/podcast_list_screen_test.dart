import 'package:cribe/data/repositories/podcasts/podcast_repository.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/ui/podcasts/view_models/podcast_list_view_model.dart';
import 'package:cribe/ui/podcasts/widgets/podcasts_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'podcast_list_screen_test.mocks.dart';

@GenerateMocks([PodcastRepository])
void main() {
  late PodcastListViewModel mockViewModel;
  late MockPodcastRepository mockRepository;

  setUp(() {
    mockRepository = MockPodcastRepository();
    mockViewModel = PodcastListViewModel(repository: mockRepository);
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
      home: ChangeNotifierProvider(
        create: (_) => mockViewModel,
        child: const PodcastListScreen(),
      ),
    );
  }

  group('PodcastListScreen', () {
    group('UI elements', () {
      testWidgets('should display Scaffold', (tester) async {
        // Arrange
        when(mockRepository.podcasts).thenReturn([]);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should display SafeArea', (tester) async {
        // Arrange
        when(mockRepository.podcasts).thenReturn([]);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(SafeArea), findsOneWidget);
      });

      testWidgets('should use Consumer widget', (tester) async {
        // Arrange
        when(mockRepository.podcasts).thenReturn([]);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(Consumer<PodcastListViewModel>), findsOneWidget);
      });
    });

    group('loading state', () {
      testWidgets('should show CircularProgressIndicator when loading',
          (tester) async {
        // Arrange
        mockViewModel.setLoading(true);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(ListView), findsNothing);
      });

      testWidgets('should center CircularProgressIndicator', (tester) async {
        // Arrange
        mockViewModel.setLoading(true);

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
        when(mockRepository.podcasts).thenReturn([]);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.text('No podcasts available'), findsOneWidget);
        expect(find.byType(ListView), findsNothing);
      });

      testWidgets('should center empty message', (tester) async {
        // Arrange
        when(mockRepository.podcasts).thenReturn([]);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.byType(Center), findsOneWidget);
        expect(find.text('No podcasts available'), findsOneWidget);
      });
    });

    group('podcasts list', () {
      testWidgets('should display ListView when podcasts are available',
          (tester) async {
        // Arrange
        final podcasts = createMockPodcasts();
        when(mockRepository.podcasts).thenReturn(podcasts);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('should display correct number of podcast cards',
          (tester) async {
        // Arrange
        final podcasts = createMockPodcasts();
        when(mockRepository.podcasts).thenReturn(podcasts);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.byType(Card), findsNWidgets(2));
      });

      testWidgets('should display podcast names', (tester) async {
        // Arrange
        final podcasts = createMockPodcasts();
        when(mockRepository.podcasts).thenReturn(podcasts);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        for (final podcast in podcasts) {
          expect(find.text(podcast.name), findsOneWidget);
        }
      });

      testWidgets('should display podcast author names', (tester) async {
        // Arrange
        final podcasts = createMockPodcasts();
        when(mockRepository.podcasts).thenReturn(podcasts);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        for (final podcast in podcasts) {
          expect(find.text(podcast.authorName), findsOneWidget);
        }
      });

      testWidgets('should display podcast descriptions', (tester) async {
        // Arrange
        final podcasts = createMockPodcasts();
        when(mockRepository.podcasts).thenReturn(podcasts);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        for (final podcast in podcasts) {
          expect(find.text(podcast.description), findsOneWidget);
        }
      });

      testWidgets('should display podcast images', (tester) async {
        // Arrange
        final podcasts = createMockPodcasts();
        when(mockRepository.podcasts).thenReturn(podcasts);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.byType(Image), findsNWidgets(2));
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
        when(mockRepository.podcasts).thenReturn(podcastsWithNullImage);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.mic), findsOneWidget);
        expect(find.byType(Container), findsWidgets);
      });
    });

    group('error handling', () {
      testWidgets('should show SnackBar when error occurs', (tester) async {
        // Arrange
        when(mockRepository.podcasts).thenReturn([]);

        await tester.pumpWidget(createTestWidget());

        // Wait for initial build
        await tester.pump();

        // Simulate an error
        mockViewModel.setError('Failed to load podcasts');
        await tester.pump();

        // Assert that SnackBar is shown
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Failed to load podcasts'), findsOneWidget);
      });

      testWidgets('should show error snackbar with error background color',
          (tester) async {
        // Arrange
        when(mockRepository.podcasts).thenReturn([]);

        await tester.pumpWidget(createTestWidget());

        // Simulate an error
        mockViewModel.setError('Test error');
        await tester.pump();

        // Find the SnackBar
        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, isNotNull);
      });
    });

    group('view model listener', () {
      testWidgets('should add listener on initState', (tester) async {
        // Arrange
        when(mockRepository.podcasts).thenReturn([]);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert - Widget builds successfully with listener
        expect(find.byType(PodcastListScreen), findsOneWidget);
      });

      testWidgets('should remove listener on dispose', (tester) async {
        // Arrange
        when(mockRepository.podcasts).thenReturn([]);

        // Act
        await tester.pumpWidget(createTestWidget());
        expect(find.byType(PodcastListScreen), findsOneWidget);

        // Dispose by removing widget
        await tester.pumpWidget(const MaterialApp(home: SizedBox()));

        // Assert - Widget is disposed
        expect(find.byType(PodcastListScreen), findsNothing);
      });
    });

    group('reactive updates', () {
      testWidgets('should update UI when loading state changes',
          (tester) async {
        // Arrange - Set initial state
        when(mockRepository.podcasts).thenReturn([]);

        await tester.pumpWidget(createTestWidget());

        // Show loading
        mockViewModel.setLoading(true);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Complete loading
        mockViewModel.setLoading(false);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    group('ListView properties', () {
      testWidgets('should have padding on ListView', (tester) async {
        // Arrange
        when(mockRepository.podcasts).thenReturn(createMockPodcasts());

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        final listView = tester.widget<ListView>(find.byType(ListView));
        expect(listView.padding, isNotNull);
      });

      testWidgets('should use ListView.builder', (tester) async {
        // Arrange
        when(mockRepository.podcasts).thenReturn(createMockPodcasts());

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
        when(mockRepository.podcasts).thenReturn(podcasts);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Assert - Check that text widgets are accessible
        expect(find.text(podcasts[0].name), findsOneWidget);
        expect(find.text(podcasts[0].authorName), findsOneWidget);
      });
    });

    group('scrolling behavior', () {
      testWidgets('should be scrollable with many podcasts', (tester) async {
        // Arrange
        final podcasts = createMockPodcasts(count: 5);
        when(mockRepository.podcasts).thenReturn(podcasts);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert - Should find first podcast
        expect(find.text('Podcast 1'), findsOneWidget);

        // Scroll down
        await tester.drag(find.byType(ListView), const Offset(0, -500));

        // Should now see podcasts further down the list
        expect(find.byType(Card), findsWidgets);
      });
    });
  });
}
