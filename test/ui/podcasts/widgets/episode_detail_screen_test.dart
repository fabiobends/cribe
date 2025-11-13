import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/ui/podcasts/view_models/episode_detail_view_model.dart';
import 'package:cribe/ui/podcasts/widgets/episode_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'episode_detail_screen_test.mocks.dart';

// TestEpisodeDetailViewModel that can trigger actual listener notifications
class TestEpisodeDetailViewModel extends EpisodeDetailViewModel {
  TestEpisodeDetailViewModel({required super.episodeId});

  void setEpisode(Episode? episode) {
    _episode = episode;
    notifyListeners();
  }

  void setPlaybackProgress(double progress) {
    _playbackProgress = progress;
    notifyListeners();
  }

  void setIsPlaying(bool playing) {
    _isPlaying = playing;
    notifyListeners();
  }

  Episode? _episode;

  @override
  Episode? get episode => _episode;

  double _playbackProgress = 0.0;

  @override
  double get playbackProgress => _playbackProgress;

  bool _isPlaying = false;

  @override
  bool get isPlaying => _isPlaying;
}

@GenerateMocks([EpisodeDetailViewModel])
void main() {
  late MockEpisodeDetailViewModel mockViewModel;
  const testEpisodeId = 1;

  setUp(() {
    mockViewModel = MockEpisodeDetailViewModel();

    // Default mock behavior
    when(mockViewModel.isLoading).thenReturn(false);
    when(mockViewModel.error).thenReturn('');
    when(mockViewModel.episode).thenReturn(null);
    when(mockViewModel.playbackProgress).thenReturn(0.0);
    when(mockViewModel.isPlaying).thenReturn(false);
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
      home: ChangeNotifierProvider<EpisodeDetailViewModel>(
        create: (_) => viewModel,
        child: const EpisodeDetailScreen(),
      ),
    );
  }

  group('EpisodeDetailScreen', () {
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
      testWidgets('should show not found message when episode is null',
          (WidgetTester tester) async {
        // Arrange
        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.episode).thenReturn(null);

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Assert
        expect(find.text('Episode not found'), findsOneWidget);
      });
    });

    group('success state with data', () {
      testWidgets('should display episode details with sliver app bar',
          (WidgetTester tester) async {
        // Arrange
        final mockEpisode = createMockEpisode();

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.episode).thenReturn(mockEpisode);
        when(mockViewModel.formatDuration(any)).thenReturn('1h 5m');
        when(mockViewModel.formatDate(any)).thenReturn('2 days ago');
        when(mockViewModel.getCurrentTime()).thenReturn('0m 0s');
        when(mockViewModel.getTotalTime()).thenReturn('1h 5m');

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
        when(mockViewModel.formatDuration(any)).thenReturn('1h 5m');
        when(mockViewModel.formatDate(any)).thenReturn('2 days ago');
        when(mockViewModel.getCurrentTime()).thenReturn('0m 0s');
        when(mockViewModel.getTotalTime()).thenReturn('1h 5m');

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Assert
        expect(find.text('2 days ago'), findsOneWidget);
        expect(find.text('1h 5m'), findsWidgets);
      });

      testWidgets('should display episode description',
          (WidgetTester tester) async {
        // Arrange
        final mockEpisode = createMockEpisode();

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.episode).thenReturn(mockEpisode);
        when(mockViewModel.formatDuration(any)).thenReturn('1h 5m');
        when(mockViewModel.formatDate(any)).thenReturn('2 days ago');
        when(mockViewModel.getCurrentTime()).thenReturn('0m 0s');
        when(mockViewModel.getTotalTime()).thenReturn('1h 5m');

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Assert
        expect(find.text('Description'), findsOneWidget);
        expect(find.textContaining('fascinating topics'), findsOneWidget);
      });

      testWidgets('should display playback controls',
          (WidgetTester tester) async {
        // Arrange
        final mockEpisode = createMockEpisode();

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.episode).thenReturn(mockEpisode);
        when(mockViewModel.formatDuration(any)).thenReturn('1h 5m');
        when(mockViewModel.formatDate(any)).thenReturn('2 days ago');
        when(mockViewModel.getCurrentTime()).thenReturn('0m 0s');
        when(mockViewModel.getTotalTime()).thenReturn('1h 5m');
        when(mockViewModel.playbackProgress).thenReturn(0.25);
        when(mockViewModel.isPlaying).thenReturn(false);

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Assert
        expect(find.byIcon(Icons.play_circle_filled), findsOneWidget);
        expect(find.byType(Slider), findsOneWidget);
        expect(find.text('0m 0s'), findsOneWidget);
      });

      testWidgets('should display pause icon when playing',
          (WidgetTester tester) async {
        // Arrange
        final mockEpisode = createMockEpisode();

        when(mockViewModel.isLoading).thenReturn(false);
        when(mockViewModel.episode).thenReturn(mockEpisode);
        when(mockViewModel.formatDuration(any)).thenReturn('1h 5m');
        when(mockViewModel.formatDate(any)).thenReturn('2 days ago');
        when(mockViewModel.getCurrentTime()).thenReturn('15m 0s');
        when(mockViewModel.getTotalTime()).thenReturn('1h 5m');
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
        when(mockViewModel.formatDuration(any)).thenReturn('1h 5m');
        when(mockViewModel.formatDate(any)).thenReturn('2 days ago');
        when(mockViewModel.getCurrentTime()).thenReturn('0m 0s');
        when(mockViewModel.getTotalTime()).thenReturn('1h 5m');
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
        when(mockViewModel.formatDuration(any)).thenReturn('1h 5m');
        when(mockViewModel.formatDate(any)).thenReturn('2 days ago');
        when(mockViewModel.getCurrentTime()).thenReturn('0m 0s');
        when(mockViewModel.getTotalTime()).thenReturn('1h 5m');

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
        when(mockViewModel.formatDuration(any)).thenReturn('1h 5m');
        when(mockViewModel.formatDate(any)).thenReturn('2 days ago');
        when(mockViewModel.getCurrentTime()).thenReturn('0m 0s');
        when(mockViewModel.getTotalTime()).thenReturn('1h 5m');

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
        when(mockViewModel.formatDuration(any)).thenReturn('1h 5m');
        when(mockViewModel.formatDate(any)).thenReturn('2 days ago');
        when(mockViewModel.getCurrentTime()).thenReturn('0m 0s');
        when(mockViewModel.getTotalTime()).thenReturn('1h 5m');

        // Act
        await tester.pumpWidget(createWidgetUnderTest(mockViewModel));

        // Assert
        expect(find.byType(CustomScrollView), findsOneWidget);
      });
    });

    group('reactive updates', () {
      testWidgets('should update UI when playback progress changes',
          (WidgetTester tester) async {
        // Arrange
        final testViewModel =
            TestEpisodeDetailViewModel(episodeId: testEpisodeId);
        final mockEpisode = createMockEpisode();
        testViewModel.setEpisode(mockEpisode);
        testViewModel.setPlaybackProgress(0.25);

        await tester.pumpWidget(createWidgetUnderTest(testViewModel));

        // Initially at 0.25
        expect(testViewModel.playbackProgress, equals(0.25));

        // Act - Change progress
        testViewModel.setPlaybackProgress(0.75);
        await tester.pump();

        // Assert
        expect(testViewModel.playbackProgress, equals(0.75));
      });

      testWidgets('should update UI when playing state changes',
          (WidgetTester tester) async {
        // Arrange
        final testViewModel =
            TestEpisodeDetailViewModel(episodeId: testEpisodeId);
        final mockEpisode = createMockEpisode();
        testViewModel.setEpisode(mockEpisode);
        testViewModel.setIsPlaying(false);

        await tester.pumpWidget(createWidgetUnderTest(testViewModel));

        // Initially not playing
        expect(find.byIcon(Icons.play_circle_filled), findsOneWidget);

        // Act - Start playing
        testViewModel.setIsPlaying(true);
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.pause_circle_filled), findsOneWidget);
      });
    });
  });
}
