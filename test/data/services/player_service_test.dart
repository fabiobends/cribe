import 'dart:async';

import 'package:cribe/data/services/player_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'player_service_test.mocks.dart';

@GenerateMocks([AudioPlayer])
void main() {
  late PlayerService playerService;
  late MockAudioPlayer mockAudioPlayer;

  setUp(() {
    mockAudioPlayer = MockAudioPlayer();

    // Setup default mock behaviors
    when(mockAudioPlayer.positionStream)
        .thenAnswer((_) => Stream.value(Duration.zero));
    when(mockAudioPlayer.durationStream).thenAnswer((_) => Stream.value(null));
    when(mockAudioPlayer.playerStateStream).thenAnswer(
      (_) => Stream.value(PlayerState(false, ProcessingState.idle)),
    );
    when(mockAudioPlayer.position).thenReturn(Duration.zero);
    when(mockAudioPlayer.playing).thenReturn(false);
    when(mockAudioPlayer.duration).thenReturn(null);
    when(mockAudioPlayer.dispose()).thenAnswer((_) async {});

    playerService = PlayerService(audioPlayer: mockAudioPlayer);
  });

  group('PlayerService', () {
    group('initialization', () {
      test('should initialize successfully', () async {
        await playerService.init();
        expect(playerService, isNotNull);
      });

      test('should expose audio player', () {
        expect(playerService.audioPlayer, isA<AudioPlayer>());
      });
    });

    group('stream getters', () {
      test('should provide position stream', () {
        expect(playerService.positionStream, isA<Stream<Duration?>>());
      });

      test('should provide duration stream', () {
        expect(playerService.durationStream, isA<Stream<Duration?>>());
      });

      test('should provide player state stream', () {
        expect(playerService.playerStateStream, isA<Stream<PlayerState>>());
      });
    });

    group('property getters', () {
      test('should return position', () {
        expect(playerService.position, isA<Duration>());
      });

      test('should return playing state', () {
        expect(playerService.playing, isA<bool>());
        expect(playerService.playing, isFalse);
      });

      test('should return null duration initially', () {
        expect(playerService.duration, isNull);
      });
    });

    group('playback controls', () {
      test('should call play on audio player', () async {
        when(mockAudioPlayer.play()).thenAnswer((_) async {});

        await playerService.play();

        verify(mockAudioPlayer.play()).called(1);
      });

      test('should call pause on audio player', () async {
        when(mockAudioPlayer.pause()).thenAnswer((_) async {});

        await playerService.pause();

        verify(mockAudioPlayer.pause()).called(1);
      });

      test('should call seek on audio player', () async {
        final position = const Duration(seconds: 30);
        when(mockAudioPlayer.seek(any)).thenAnswer((_) async {});

        await playerService.seek(position);

        verify(mockAudioPlayer.seek(position)).called(1);
      });

      test('should call stop on audio player', () async {
        when(mockAudioPlayer.stop()).thenAnswer((_) async {});

        await playerService.stop();

        verify(mockAudioPlayer.stop()).called(1);
      });
    });

    group('error handling', () {
      test('should rethrow error when setAudioUrl fails', () async {
        when(mockAudioPlayer.setUrl(any)).thenThrow(Exception('Invalid URL'));

        expectLater(
          playerService.setAudioUrl('invalid-url'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('disposal', () {
      test('should dispose successfully', () async {
        await playerService.dispose();
        // Just verify it doesn't throw
      });
    });
  });
}
