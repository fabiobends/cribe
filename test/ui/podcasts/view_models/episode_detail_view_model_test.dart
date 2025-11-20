import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/ui/podcasts/view_models/episode_detail_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late EpisodeDetailViewModel viewModel;
  late Episode testEpisode;

  setUp(() {
    testEpisode = Episode(
      id: 1,
      externalId: 'test-episode-1',
      podcastId: 1,
      name: 'Test Episode 1',
      description: 'Test Description',
      audioUrl: 'test.mp3',
      imageUrl: 'test.jpg',
      datePublished: DateTime.now().toIso8601String(),
      duration: 3600,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    viewModel = EpisodeDetailViewModel(episode: testEpisode);
  });

  group('EpisodeDetailViewModel', () {
    group('initialization', () {
      test('should initialize with correct episode', () {
        expect(viewModel.episode, isNotNull);
        expect(viewModel.episode.id, equals(1));
      });

      test('should load episode data on initialization', () {
        expect(viewModel.episode, isNotNull);
        expect(viewModel.episode.name, equals('Test Episode 1'));
      });

      test('should initialize playback progress to 0.0', () {
        expect(viewModel.playbackProgress, equals(0.0));
      });

      test('should initialize as not playing', () {
        expect(viewModel.isPlaying, isFalse);
      });
    });

    group('playback controls', () {
      test('togglePlayPause should toggle isPlaying state', () {
        expect(viewModel.isPlaying, isFalse);

        viewModel.togglePlayPause();
        expect(viewModel.isPlaying, isTrue);

        viewModel.togglePlayPause();
        expect(viewModel.isPlaying, isFalse);
      });

      test('seekTo should update playback progress', () {
        viewModel.seekTo(0.5);
        expect(viewModel.playbackProgress, equals(0.5));

        viewModel.seekTo(0.75);
        expect(viewModel.playbackProgress, equals(0.75));
      });

      test('seekTo should not accept progress less than 0', () {
        viewModel.seekTo(0.5);
        viewModel.seekTo(-0.1);
        expect(viewModel.playbackProgress, equals(0.5));
      });

      test('seekTo should not accept progress greater than 1', () {
        viewModel.seekTo(0.5);
        viewModel.seekTo(1.5);
        expect(viewModel.playbackProgress, equals(0.5));
      });
    });

    group('computed properties', () {
      test('duration should return formatted duration', () {
        expect(viewModel.duration, equals('1h 0m'));
      });

      test('datePublished should return formatted date', () {
        expect(viewModel.datePublished, isNotEmpty);
      });

      test('elapsedTime should return formatted elapsed time', () {
        viewModel.seekTo(0.5);
        expect(viewModel.elapsedTime, isNotEmpty);
        expect(viewModel.elapsedTime, equals('30m'));
      });
    });
  });
}
