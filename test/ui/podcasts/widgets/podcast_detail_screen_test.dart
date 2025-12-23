import 'package:cribe/data/services/api_service.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/ui/podcasts/view_models/podcast_detail_view_model.dart';
import 'package:cribe/ui/podcasts/widgets/podcast_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'podcast_detail_screen_test.mocks.dart';

@GenerateMocks([PodcastDetailViewModel, ApiService])
void main() {
  late MockPodcastDetailViewModel mockViewModel;
  const testPodcastId = 1;

  setUp(() {
    mockViewModel = MockPodcastDetailViewModel();

    // Default mock behavior
    when(mockViewModel.isLoading).thenReturn(false);
    when(mockViewModel.error).thenReturn('');
    when(mockViewModel.podcast).thenReturn(null);
    when(mockViewModel.episodes).thenReturn([]);
  });

  Podcast createMockPodcast() {
    return Podcast(
      id: testPodcastId,
      authorName: 'Joe Rogan',
      name: 'The Joe Rogan Experience',
      imageUrl: 'https://picsum.photos/400/400?random=1',
      description:
          'The official podcast of comedian Joe Rogan. Long form conversations.',
      externalId: 'ext-1',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );
  }

  List<FormattedEpisode> createMockFormattedEpisodes({int count = 3}) {
    return List.generate(
      count,
      (index) => FormattedEpisode(
        Episode(
          id: index + 1,
          externalId: 'ep-1-${index + 1}',
          podcastId: testPodcastId,
          name: 'Episode ${index + 1}',
          description: 'Description for episode ${index + 1}',
          audioUrl: 'https://example.com/audio/1/${index + 1}.mp3',
          imageUrl: 'https://picsum.photos/200/200?random=${100 + index}',
          datePublished: DateTime.now()
              .subtract(Duration(days: index * 7))
              .toIso8601String(),
          duration: 3600 + (index * 300),
          createdAt: DateTime.now().subtract(Duration(days: index * 7)),
          updatedAt: DateTime.now(),
        ),
      ),
    );
  }

  Widget createWidgetUnderTest(PodcastDetailViewModel viewModel) {
    return MaterialApp(
      home: ChangeNotifierProvider<PodcastDetailViewModel>(
        create: (_) => viewModel,
        child: const PodcastDetailScreen(),
      ),
    );
  }

  group('PodcastDetailScreen', () {
    group('loading state', () {
      testWidgets('should show loading indicator when loading',
          (WidgetTester tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(true);

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('empty state', () {
      testWidgets('should show not found message when podcast is null',
          (WidgetTester tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcast).thenReturn(null);

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Assert
        expect(find.text('Podcast not found'), findsOneWidget);
      });
    });

    group('success state with data', () {
      testWidgets('should display podcast details with sliver app bar',
          (WidgetTester tester) async {
        // Arrange
        final mockPodcast = createMockPodcast();
        final mockEpisodes = createMockFormattedEpisodes();

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcast).thenReturn(mockPodcast);
        when(mockViewModel.episodes).thenReturn(mockEpisodes);

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Assert - CustomScrollView and SliverAppBar
        expect(find.byType(CustomScrollView), findsOneWidget);
        expect(find.byType(SliverAppBar), findsOneWidget);
      });

      testWidgets('should display podcast info section',
          (WidgetTester tester) async {
        // Arrange
        final mockPodcast = createMockPodcast();
        final mockEpisodes = createMockFormattedEpisodes();

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcast).thenReturn(mockPodcast);
        when(mockViewModel.episodes).thenReturn(mockEpisodes);

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Assert
        expect(find.text('By ${mockPodcast.authorName}'), findsOneWidget);
        expect(find.text(mockPodcast.description), findsOneWidget);
        expect(find.text('Episodes (${mockEpisodes.length})'), findsOneWidget);
      });

      testWidgets('should display all episodes in list',
          (WidgetTester tester) async {
        // Arrange
        final mockPodcast = createMockPodcast();
        final mockEpisodes = createMockFormattedEpisodes();

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcast).thenReturn(mockPodcast);
        when(mockViewModel.episodes).thenReturn(mockEpisodes);

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));
        await tester.pumpAndSettle();

        // Assert - Check that episode cards are present
        expect(find.byType(Card), findsWidgets);
        expect(find.text(mockEpisodes[0].episode.name), findsOneWidget);
      });

      testWidgets('should display episode duration and date',
          (WidgetTester tester) async {
        // Arrange
        final mockPodcast = createMockPodcast();
        final mockEpisodes = createMockFormattedEpisodes(count: 1);

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcast).thenReturn(mockPodcast);
        when(mockViewModel.episodes).thenReturn(mockEpisodes);

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Assert - Check that formatted properties are displayed
        expect(find.text(mockEpisodes[0].duration), findsOneWidget);
        expect(find.text(mockEpisodes[0].datePublished), findsOneWidget);
      });

      testWidgets('should display episode cards as tappable',
          (WidgetTester tester) async {
        // Arrange
        final mockPodcast = createMockPodcast();
        final mockEpisodes = createMockFormattedEpisodes(count: 1);

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcast).thenReturn(mockPodcast);
        when(mockViewModel.episodes).thenReturn(mockEpisodes);

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Assert
        expect(find.byType(Card), findsWidgets);
        expect(find.byType(InkWell), findsWidgets);
      });

      testWidgets('should display back button in app bar',
          (WidgetTester tester) async {
        // Arrange
        final mockPodcast = createMockPodcast();

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcast).thenReturn(mockPodcast);
        when(mockViewModel.episodes).thenReturn([]);

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Assert
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });
    });

    group('image handling', () {
      testWidgets('should show placeholder when podcast has no image',
          (WidgetTester tester) async {
        // Arrange
        final mockPodcast = Podcast(
          id: testPodcastId,
          authorName: 'Test Author',
          name: 'Test Podcast',
          description: 'Test description',
          externalId: 'ext-1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcast).thenReturn(mockPodcast);
        when(mockViewModel.episodes).thenReturn([]);

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Assert
        expect(find.byIcon(Icons.mic), findsOneWidget);
      });

      testWidgets('should show placeholder when episode has no image',
          (WidgetTester tester) async {
        // Arrange
        final mockPodcast = createMockPodcast();
        final mockEpisode = FormattedEpisode(
          Episode(
            id: 1,
            externalId: 'ep-1',
            podcastId: testPodcastId,
            name: 'Episode 1',
            description: 'Description',
            audioUrl: 'https://example.com/audio.mp3',
            datePublished: DateTime.now().toIso8601String(),
            duration: 3600,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcast).thenReturn(mockPodcast);
        when(mockViewModel.episodes).thenReturn([mockEpisode]);

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Assert
        expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
      });
    });

    group('navigation', () {
      testWidgets('should have back button that pops navigation',
          (WidgetTester tester) async {
        // Arrange
        final mockPodcast = createMockPodcast();

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcast).thenReturn(mockPodcast);
        when(mockViewModel.episodes).thenReturn([]);

        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Act
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Assert - Navigation should work (though we can't verify pop in this test)
      });
    });

    group('scrolling behavior', () {
      testWidgets('should be scrollable with CustomScrollView',
          (WidgetTester tester) async {
        // Arrange
        final mockPodcast = createMockPodcast();
        final mockEpisodes = createMockFormattedEpisodes(count: 10);

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcast).thenReturn(mockPodcast);
        when(mockViewModel.episodes).thenReturn(mockEpisodes);

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Assert
        expect(find.byType(CustomScrollView), findsOneWidget);
      });
    });

    group('episode navigation', () {
      testWidgets('should have tappable episode cards',
          (WidgetTester tester) async {
        // Arrange
        final mockPodcast = createMockPodcast();
        final mockEpisodes = createMockFormattedEpisodes(count: 1);

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcast).thenReturn(mockPodcast);
        when(mockViewModel.episodes).thenReturn(mockEpisodes);

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Assert - verify card exists and is tappable
        final cardFinder = find.byType(Card).first;
        expect(cardFinder, findsOneWidget);

        final inkWellFinder = find.descendant(
          of: cardFinder,
          matching: find.byType(InkWell),
        );
        expect(inkWellFinder, findsOneWidget);
      });
    });

    group('error handling', () {
      testWidgets('should show snackbar and clear error on error',
          (WidgetTester tester) async {
        // Arrange
        final mockPodcast = createMockPodcast();
        final mockEpisodes = createMockFormattedEpisodes(count: 1);
        const errorMessage = 'Test error message';

        // Capture the listener that gets registered
        VoidCallback? capturedListener;
        when(mockViewModel.addListener(any)).thenAnswer((invocation) {
          capturedListener = invocation.positionalArguments[0] as VoidCallback;
        });

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.podcast).thenReturn(mockPodcast);
        when(mockViewModel.episodes).thenReturn(mockEpisodes);
        when(mockViewModel.error).thenReturn(null);

        // Act - Build the screen
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));
        await tester.pumpAndSettle();

        // Verify listener was captured
        expect(capturedListener, isNotNull);

        // Trigger an error by changing mock return value
        when(mockViewModel.error).thenReturn(errorMessage);

        // Manually trigger the listener (simulates notifyListeners)
        capturedListener!();
        await tester.pump();

        // Assert - SnackBar should be visible
        expect(find.text(errorMessage), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);

        // Verify error was cleared
        verify(mockViewModel.setError(null)).called(1);
      });
    });
  });
}
