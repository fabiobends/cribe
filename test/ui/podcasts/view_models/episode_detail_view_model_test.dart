import 'dart:async';

import 'package:cribe/data/services/player_service.dart';
import 'package:cribe/data/services/transcription_service.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/domain/models/transcript_event.dart';
import 'package:cribe/ui/podcasts/view_models/episode_detail_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'episode_detail_view_model_test.mocks.dart';

@GenerateMocks([PlayerService, TranscriptionService])
void main() {
  late EpisodeDetailViewModel viewModel;
  late Episode testEpisode;
  late MockPlayerService mockPlayerService;
  late MockTranscriptionService mockTranscriptService;

  setUp(() {
    mockPlayerService = MockPlayerService();
    mockTranscriptService = MockTranscriptionService();

    when(mockPlayerService.setAudioUrl(any)).thenAnswer((_) async {});
    when(mockPlayerService.positionStream)
        .thenAnswer((_) => const Stream.empty());
    when(mockPlayerService.durationStream)
        .thenAnswer((_) => const Stream.empty());

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
    viewModel = EpisodeDetailViewModel(
      episode: testEpisode,
      playerService: mockPlayerService,
      transcriptionService: mockTranscriptService,
    );
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
      test('togglePlayPause should call play/pause on service', () {
        when(mockPlayerService.play()).thenAnswer((_) async {});
        when(mockPlayerService.pause()).thenAnswer((_) async {});

        expect(viewModel.isPlaying, isFalse);

        viewModel.togglePlayPause();
        verify(mockPlayerService.play()).called(1);

        expect(viewModel.isPlaying, isTrue);

        viewModel.togglePlayPause();
        verify(mockPlayerService.pause()).called(1);
        expect(viewModel.isPlaying, isFalse);
      });

      test('seekTo should update playback progress', () {
        when(mockPlayerService.seek(any)).thenAnswer((_) async {});

        viewModel.seekTo(0.5);
        expect(viewModel.playbackProgress, equals(0.5));
        verify(mockPlayerService.seek(any)).called(1);

        viewModel.seekTo(0.75);
        expect(viewModel.playbackProgress, equals(0.75));
      });

      test('seekTo should not accept progress less than 0', () {
        when(mockPlayerService.seek(any)).thenAnswer((_) async {});
        viewModel.seekTo(0.5);
        viewModel.seekTo(-0.1);
        expect(viewModel.playbackProgress, equals(0.5));
      });

      test('seekTo should not accept progress greater than 1', () {
        when(mockPlayerService.seek(any)).thenAnswer((_) async {});
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
        expect(viewModel.elapsedTime, equals('30:00'));
      });

      test('remainingTime should return formatted remaining time', () {
        viewModel.seekTo(0.5);
        expect(viewModel.remainingTime, isNotEmpty);
        expect(viewModel.remainingTime, equals('-30:00'));
      });
    });

    group('player stream handling', () {
      test('should update progress when position stream emits', () async {
        final positionController = StreamController<Duration?>();
        final durationController = StreamController<Duration?>();

        when(mockPlayerService.setAudioUrl(any)).thenAnswer((_) async {});
        when(mockPlayerService.positionStream)
            .thenAnswer((_) => positionController.stream);
        when(mockPlayerService.durationStream)
            .thenAnswer((_) => durationController.stream);

        final newViewModel = EpisodeDetailViewModel(
          episode: testEpisode,
          playerService: mockPlayerService,
          transcriptionService: mockTranscriptService,
        );
        durationController.add(const Duration(seconds: 100));
        await Future.delayed(const Duration(milliseconds: 10));

        // Then emit position
        positionController.add(const Duration(seconds: 50));
        await Future.delayed(const Duration(milliseconds: 10));

        expect(newViewModel.playbackProgress, equals(0.5));

        positionController.close();
        durationController.close();
      });

      test('should update audio duration when duration stream emits', () async {
        final positionController = StreamController<Duration?>();
        final durationController = StreamController<Duration?>();

        when(mockPlayerService.setAudioUrl(any)).thenAnswer((_) async {});
        when(mockPlayerService.positionStream)
            .thenAnswer((_) => positionController.stream);
        when(mockPlayerService.durationStream)
            .thenAnswer((_) => durationController.stream);

        final newViewModel = EpisodeDetailViewModel(
          episode: testEpisode,
          playerService: mockPlayerService,
          transcriptionService: mockTranscriptService,
        );

        // Emit duration to update the view model
        durationController.add(const Duration(seconds: 180)); // 3 minutes
        await Future.delayed(const Duration(milliseconds: 10));

        expect(newViewModel.duration, equals('3m'));

        positionController.close();
        durationController.close();
      });

      test('should set error when player initialization fails', () async {
        when(mockPlayerService.setAudioUrl(any))
            .thenThrow(Exception('Network error'));
        when(mockPlayerService.positionStream)
            .thenAnswer((_) => const Stream.empty());
        when(mockPlayerService.durationStream)
            .thenAnswer((_) => const Stream.empty());

        final newViewModel = EpisodeDetailViewModel(
          episode: testEpisode,
          playerService: mockPlayerService,
          transcriptionService: mockTranscriptService,
        );

        await Future.delayed(const Duration(milliseconds: 10));

        // Should have an error set (either from player or transcript init failure)
        expect(newViewModel.error, isNotNull);
      });
    });

    group('Transcript streaming', () {
      test('should handle all transcript event types', () async {
        final controller = StreamController<TranscriptEvent>();
        when(mockTranscriptService.streamTranscript(any))
            .thenAnswer((_) => controller.stream);

        final newViewModel = EpisodeDetailViewModel(
          episode: testEpisode,
          playerService: mockPlayerService,
          transcriptionService: mockTranscriptService,
        );
        await Future.delayed(const Duration(milliseconds: 10));

        // Test chunk event
        controller.add(
          const TranscriptChunkEvent(
            position: 0,
            speakerIndex: 0,
            start: 0.0,
            end: 2.0,
            text: 'Hello',
          ),
        );
        await Future.delayed(const Duration(milliseconds: 10));
        expect(newViewModel.chunks.length, equals(1));
        expect(newViewModel.chunks[0].text, equals('Hello'));

        // Test speaker event
        controller.add(const TranscriptSpeakerEvent(index: 0, name: 'Alice'));
        await Future.delayed(const Duration(milliseconds: 10));
        expect(newViewModel.speakers[0], equals('Alice'));

        // Test complete event
        controller.add(const TranscriptCompleteEvent());
        await Future.delayed(const Duration(milliseconds: 10));
        expect(newViewModel.transcriptCompleted, isTrue);

        // Test error event
        controller.add(const TranscriptErrorEvent(error: 'Test error'));
        await Future.delayed(const Duration(milliseconds: 10));
        expect(newViewModel.error, equals('Test error'));

        controller.close();
      });

      test('should handle stream errors and cleanup', () async {
        final controller = StreamController<TranscriptEvent>();
        when(mockTranscriptService.streamTranscript(any))
            .thenAnswer((_) => controller.stream);

        final newViewModel = EpisodeDetailViewModel(
          episode: testEpisode,
          playerService: mockPlayerService,
          transcriptionService: mockTranscriptService,
        );
        await Future.delayed(const Duration(milliseconds: 10));

        // Test onError
        controller.addError(Exception('SSE error'));
        await Future.delayed(const Duration(milliseconds: 10));
        expect(newViewModel.error, equals('Transcript streaming error'));
        expect(newViewModel.isStreaming, isFalse);

        controller.close();
      });

      test('should handle initialization failure', () async {
        when(mockTranscriptService.streamTranscript(any))
            .thenThrow(Exception('Connection failed'));

        final newViewModel = EpisodeDetailViewModel(
          episode: testEpisode,
          playerService: mockPlayerService,
          transcriptionService: mockTranscriptService,
        );
        await Future.delayed(const Duration(milliseconds: 10));

        expect(newViewModel.error, equals('Failed to start transcript stream'));
        expect(newViewModel.isStreaming, isFalse);
      });
    });

    group('Speaker turns grouping', () {
      test('should group consecutive chunks by speaker', () async {
        final controller = StreamController<TranscriptEvent>();
        when(mockTranscriptService.streamTranscript(any))
            .thenAnswer((_) => controller.stream);

        final newViewModel = EpisodeDetailViewModel(
          episode: testEpisode,
          playerService: mockPlayerService,
          transcriptionService: mockTranscriptService,
        );
        await Future.delayed(const Duration(milliseconds: 10));

        // Speaker 0 (2 chunks), Speaker 1 (1 chunk), Speaker 0 (1 chunk)
        controller.add(
          const TranscriptChunkEvent(
            position: 0,
            speakerIndex: 0,
            start: 0.0,
            end: 2.0,
            text: 'A',
          ),
        );
        controller.add(
          const TranscriptChunkEvent(
            position: 1,
            speakerIndex: 0,
            start: 2.0,
            end: 4.0,
            text: 'B',
          ),
        );
        controller.add(
          const TranscriptChunkEvent(
            position: 2,
            speakerIndex: 1,
            start: 4.0,
            end: 6.0,
            text: 'C',
          ),
        );
        controller.add(
          const TranscriptChunkEvent(
            position: 3,
            speakerIndex: 0,
            start: 6.0,
            end: 8.0,
            text: 'D',
          ),
        );
        await Future.delayed(const Duration(milliseconds: 10));

        final turns = newViewModel.speakerTurns;
        expect(turns.length, equals(3));
        expect(turns[0].chunks.length, equals(2)); // Speaker 0, 2 chunks
        expect(turns[1].chunks.length, equals(1)); // Speaker 1, 1 chunk
        expect(turns[2].chunks.length, equals(1)); // Speaker 0, 1 chunk

        controller.close();
      });
    });

    group('Getters', () {
      test('should return immutable collections and default values', () {
        expect(viewModel.chunks, isEmpty);
        expect(viewModel.speakers, isEmpty);
        expect(viewModel.speakerTurns, isEmpty);
        expect(viewModel.currentTranscriptChunkPosition, equals(-1));
        expect(viewModel.transcriptCompleted, isFalse);
        expect(() => viewModel.chunks.clear(), throwsUnsupportedError);
      });
    });
  });
}
