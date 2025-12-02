import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/domain/models/transcript.dart';
import 'package:cribe/ui/podcasts/view_models/episode_detail_view_model.dart';
import 'package:cribe/ui/podcasts/widgets/episode_detail_screen.dart';
import 'package:cribe/ui/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'episode_detail_screen_test.mocks.dart';

@GenerateMocks([EpisodeDetailViewModel])
void main() {
  late MockEpisodeDetailViewModel mockViewModel;
  const testEpisodeId = 1;

  setUp(() {
    mockViewModel = MockEpisodeDetailViewModel();

    final testEpisode = Episode(
      id: testEpisodeId,
      externalId: 'test-episode-1',
      podcastId: 1,
      name: 'Test Episode',
      description: 'Test Description',
      audioUrl: 'test.mp3',
      imageUrl: 'test.jpg',
      datePublished: DateTime.now().toIso8601String(),
      duration: 3600,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Default mock behavior
    when(mockViewModel.isLoading).thenReturn(false);
    when(mockViewModel.error).thenReturn(null);
    when(mockViewModel.episode).thenReturn(testEpisode);
    when(mockViewModel.playbackProgress).thenReturn(0.0);
    when(mockViewModel.isPlaying).thenReturn(false);
    when(mockViewModel.isCompleted).thenReturn(false);
    when(mockViewModel.isBuffering).thenReturn(false);
    when(mockViewModel.chunks).thenReturn([]);
    when(mockViewModel.speakers).thenReturn({});
    when(mockViewModel.speakerTurns).thenReturn([]);
    when(mockViewModel.currentAudioPosition).thenReturn(0.0);
    when(mockViewModel.transcriptSyncOffset).thenReturn(0.4);
    when(mockViewModel.currentHighlightedChunkPosition).thenReturn(null);
    when(mockViewModel.autoScrollEnabled).thenReturn(true);
  });

  Episode createMockEpisode() {
    return Episode(
      id: testEpisodeId,
      externalId: 'ep-1',
      podcastId: 1,
      name: 'Episode 1: The Future of AI',
      description:
          'In this episode, we dive deep into fascinating topics that matter.',
      audioUrl: 'https://example.com/audio/1.mp3',
      imageUrl: 'https://picsum.photos/400/400?random=1',
      datePublished: DateTime.now().toIso8601String(),
      duration: 3900,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Widget createWidgetUnderTest(EpisodeDetailViewModel viewModel) {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<EpisodeDetailViewModel>(
          create: (_) => viewModel,
          child: const EpisodeDetailScreen(),
        ),
      ),
    );
  }

  group('EpisodeDetailScreen', () {
    group('success state with data', () {
      testWidgets('should display episode details with sliver app bar',
          (WidgetTester tester) async {
        // Arrange
        final mockEpisode = createMockEpisode();

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.episode).thenReturn(mockEpisode);
        when(mockViewModel.duration).thenReturn('1h 5m');
        when(mockViewModel.datePublished).thenReturn('2 days ago');
        when(mockViewModel.remainingTime).thenReturn('-1h 5m');
        when(mockViewModel.elapsedTime).thenReturn('0m 0s');
        when(mockViewModel.duration).thenReturn('1h 5m');

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Assert - CustomScrollView and SliverAppBar
        expect(find.byType(CustomScrollView), findsOneWidget);
        expect(find.byType(SliverAppBar), findsOneWidget);
      });

      testWidgets('should display episode metadata',
          (WidgetTester tester) async {
        // Arrange
        final mockEpisode = createMockEpisode();

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.episode).thenReturn(mockEpisode);
        when(mockViewModel.duration).thenReturn('1h 5m');
        when(mockViewModel.datePublished).thenReturn('2 days ago');
        when(mockViewModel.remainingTime).thenReturn('-1h 5m');
        when(mockViewModel.elapsedTime).thenReturn('0m 0s');
        when(mockViewModel.duration).thenReturn('1h 5m');

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Assert
        expect(find.text('2 days ago'), findsOneWidget);
        expect(find.text('1h 5m'), findsWidgets);
      });

      testWidgets('should display playback controls',
          (WidgetTester tester) async {
        // Arrange
        final mockEpisode = createMockEpisode();

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.episode).thenReturn(mockEpisode);
        when(mockViewModel.duration).thenReturn('1h 5m');
        when(mockViewModel.datePublished).thenReturn('2 days ago');
        when(mockViewModel.remainingTime).thenReturn('-1h 5m');
        when(mockViewModel.elapsedTime).thenReturn('0m');
        when(mockViewModel.playbackProgress).thenReturn(0.25);
        when(mockViewModel.isPlaying).thenReturn(false);

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Assert
        expect(find.byIcon(Icons.play_circle_filled), findsOneWidget);
        expect(find.byType(Slider), findsOneWidget);
        expect(find.text('0m'), findsOneWidget);
      });

      testWidgets('should display pause icon when playing',
          (WidgetTester tester) async {
        // Arrange
        final mockEpisode = createMockEpisode();

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.episode).thenReturn(mockEpisode);
        when(mockViewModel.duration).thenReturn('1h 5m');
        when(mockViewModel.datePublished).thenReturn('2 days ago');
        when(mockViewModel.remainingTime).thenReturn('-1h 5m');
        when(mockViewModel.elapsedTime).thenReturn('15m');
        when(mockViewModel.playbackProgress).thenReturn(0.25);
        when(mockViewModel.isPlaying).thenReturn(true);

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Assert
        expect(find.byIcon(Icons.pause_circle_filled), findsOneWidget);
      });

      testWidgets('should call togglePlayPause when play button tapped',
          (WidgetTester tester) async {
        // Arrange
        final mockEpisode = createMockEpisode();

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.episode).thenReturn(mockEpisode);
        when(mockViewModel.duration).thenReturn('1h 5m');
        when(mockViewModel.datePublished).thenReturn('2 days ago');
        when(mockViewModel.remainingTime).thenReturn('-1h 5m');
        when(mockViewModel.elapsedTime).thenReturn('0m 0s');
        when(mockViewModel.duration).thenReturn('1h 5m');
        when(mockViewModel.playbackProgress).thenReturn(0.0);
        when(mockViewModel.isPlaying).thenReturn(false);

        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Act
        await tester.tap(find.byIcon(Icons.play_circle_filled));
        await tester.pump();

        // Assert
        verify(mockViewModel.togglePlayPause()).called(1);
      });

      testWidgets('should display back button in app bar',
          (WidgetTester tester) async {
        // Arrange
        final mockEpisode = createMockEpisode();

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.episode).thenReturn(mockEpisode);
        when(mockViewModel.duration).thenReturn('1h 5m');
        when(mockViewModel.datePublished).thenReturn('2 days ago');
        when(mockViewModel.remainingTime).thenReturn('-1h 5m');
        when(mockViewModel.elapsedTime).thenReturn('0m 0s');
        when(mockViewModel.duration).thenReturn('1h 5m');

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Assert
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });
    });

    group('navigation', () {
      testWidgets('should have back button that pops navigation',
          (WidgetTester tester) async {
        // Arrange
        final mockEpisode = createMockEpisode();

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.episode).thenReturn(mockEpisode);
        when(mockViewModel.duration).thenReturn('1h 5m');
        when(mockViewModel.datePublished).thenReturn('2 days ago');
        when(mockViewModel.remainingTime).thenReturn('-1h 5m');
        when(mockViewModel.elapsedTime).thenReturn('0m');

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
        final mockEpisode = createMockEpisode();

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.episode).thenReturn(mockEpisode);
        when(mockViewModel.duration).thenReturn('1h 5m');
        when(mockViewModel.datePublished).thenReturn('2 days ago');
        when(mockViewModel.remainingTime).thenReturn('-1h 5m');
        when(mockViewModel.elapsedTime).thenReturn('0m 0s');
        when(mockViewModel.duration).thenReturn('1h 5m');

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Assert
        expect(find.byType(CustomScrollView), findsOneWidget);
      });
    });

    group('transcript display with speaker turns', () {
      Future<void> setupTranscriptTest(
        WidgetTester tester, {
        required List<TranscriptChunk> chunks,
        required List<SpeakerTurn> speakerTurns,
        Map<int, String> speakers = const {},
        double audioPosition = 0.0,
      }) async {
        final mockEpisode = createMockEpisode();
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.episode).thenReturn(mockEpisode);
        when(mockViewModel.duration).thenReturn('1h 5m');
        when(mockViewModel.datePublished).thenReturn('2 days ago');
        when(mockViewModel.remainingTime).thenReturn('-1h 5m');
        when(mockViewModel.elapsedTime).thenReturn('0m');
        when(mockViewModel.chunks).thenReturn(chunks);
        when(mockViewModel.speakerTurns).thenReturn(speakerTurns);
        when(mockViewModel.speakers).thenReturn(speakers);
        when(mockViewModel.currentAudioPosition).thenReturn(audioPosition);
        when(mockViewModel.transcriptSyncOffset).thenReturn(0.4);
        when(mockViewModel.currentHighlightedChunkPosition).thenReturn(null);

        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));
        await tester.pumpAndSettle();
      }

      testWidgets('should render speaker turns with names and transcript text',
          (WidgetTester tester) async {
        final chunks = [
          TranscriptChunk(
            position: 0,
            speakerIndex: 0,
            start: 0.0,
            end: 2.0,
            text: 'Hello',
          ),
          TranscriptChunk(
            position: 1,
            speakerIndex: 1,
            start: 2.0,
            end: 4.0,
            text: 'Hi',
          ),
        ];
        await setupTranscriptTest(
          tester,
          chunks: chunks,
          speakerTurns: [
            SpeakerTurn(0, [chunks[0]]),
            SpeakerTurn(1, [chunks[1]]),
          ],
          speakers: {0: 'Alice', 1: 'Bob'},
        );

        expect(find.byType(StyledText), findsWidgets);
        expect(find.byType(RichText), findsWidgets);
        expect(find.byType(Row), findsWidgets);
      });

      testWidgets('should use default speaker names when not provided',
          (WidgetTester tester) async {
        final chunks = [
          TranscriptChunk(
            position: 0,
            speakerIndex: 0,
            start: 0.0,
            end: 2.0,
            text: 'Text',
          ),
        ];
        await setupTranscriptTest(
          tester,
          chunks: chunks,
          speakerTurns: [SpeakerTurn(0, chunks)],
        );

        expect(find.text('Speaker 0', skipOffstage: false), findsOneWidget);
      });

      testWidgets('should display multiple alternating speaker turns',
          (WidgetTester tester) async {
        final chunks = [
          TranscriptChunk(
            position: 0,
            speakerIndex: 0,
            start: 0.0,
            end: 2.0,
            text: 'A1',
          ),
          TranscriptChunk(
            position: 1,
            speakerIndex: 1,
            start: 2.0,
            end: 4.0,
            text: 'B1',
          ),
          TranscriptChunk(
            position: 2,
            speakerIndex: 0,
            start: 4.0,
            end: 6.0,
            text: 'A2',
          ),
        ];
        await setupTranscriptTest(
          tester,
          chunks: chunks,
          speakerTurns: [
            SpeakerTurn(0, [chunks[0]]),
            SpeakerTurn(1, [chunks[1]]),
            SpeakerTurn(0, [chunks[2]]),
          ],
          speakers: {0: 'Alice', 1: 'Bob'},
        );

        expect(find.byType(StyledText), findsWidgets);
        expect(find.byType(RichText), findsWidgets);
      });
    });

    group('auto-scroll control', () {
      testWidgets('should show scroll button when auto-scroll disabled',
          (WidgetTester tester) async {
        // Arrange
        final mockEpisode = createMockEpisode();
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.episode).thenReturn(mockEpisode);
        when(mockViewModel.duration).thenReturn('1h 5m');
        when(mockViewModel.datePublished).thenReturn('2 days ago');
        when(mockViewModel.remainingTime).thenReturn('-1h 5m');
        when(mockViewModel.elapsedTime).thenReturn('0m 0s');
        when(mockViewModel.autoScrollEnabled).thenReturn(false);
        when(mockViewModel.isPlaying).thenReturn(true);
        when(mockViewModel.isCompleted).thenReturn(false);

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));
        await tester.pump(const Duration(milliseconds: 350));

        // Assert
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byIcon(Icons.read_more), findsOneWidget);
      });

      testWidgets('should hide scroll button when auto-scroll enabled',
          (WidgetTester tester) async {
        // Arrange
        final mockEpisode = createMockEpisode();
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.episode).thenReturn(mockEpisode);
        when(mockViewModel.duration).thenReturn('1h 5m');
        when(mockViewModel.datePublished).thenReturn('2 days ago');
        when(mockViewModel.remainingTime).thenReturn('-1h 5m');
        when(mockViewModel.elapsedTime).thenReturn('0m 0s');
        when(mockViewModel.autoScrollEnabled).thenReturn(true);

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));
        await tester.pump();

        // Assert
        expect(find.byType(FloatingActionButton), findsNothing);
      });

      testWidgets('should re-enable auto-scroll when scroll button is tapped',
          (WidgetTester tester) async {
        // Arrange
        final mockEpisode = createMockEpisode();
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.episode).thenReturn(mockEpisode);
        when(mockViewModel.duration).thenReturn('1h 5m');
        when(mockViewModel.datePublished).thenReturn('2 days ago');
        when(mockViewModel.remainingTime).thenReturn('-1h 5m');
        when(mockViewModel.elapsedTime).thenReturn('0m 0s');
        when(mockViewModel.isPlaying).thenReturn(true);
        when(mockViewModel.autoScrollEnabled).thenReturn(false);

        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));
        await tester.pump(const Duration(milliseconds: 350));

        // Act - Tap the scroll button
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        // Assert
        verify(mockViewModel.setAutoScrollEnabled(true)).called(1);
      });
    });
  });
}
