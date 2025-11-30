import 'dart:async';

import 'package:cribe/core/constants/api_path.dart';
import 'package:cribe/data/repositories/transcripts/transcript_repository.dart';
import 'package:cribe/data/services/api_service.dart';
import 'package:cribe/domain/models/transcript_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'transcript_repository_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late TranscriptRepository transcriptRepository;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    transcriptRepository = TranscriptRepository(apiService: mockApiService);
  });

  group('TranscriptEventType', () {
    group('fromString', () {
      test('should convert "chunk" to TranscriptEventType.chunk', () {
        expect(
          TranscriptEventType.fromString('chunk'),
          equals(TranscriptEventType.chunk),
        );
      });

      test('should convert "speaker" to TranscriptEventType.speaker', () {
        expect(
          TranscriptEventType.fromString('speaker'),
          equals(TranscriptEventType.speaker),
        );
      });

      test('should convert "complete" to TranscriptEventType.complete', () {
        expect(
          TranscriptEventType.fromString('complete'),
          equals(TranscriptEventType.complete),
        );
      });

      test('should convert "error" to TranscriptEventType.error', () {
        expect(
          TranscriptEventType.fromString('error'),
          equals(TranscriptEventType.error),
        );
      });

      test('should throw ArgumentError for unknown event type', () {
        expect(
          () => TranscriptEventType.fromString('unknown'),
          throwsArgumentError,
        );
      });
    });
  });

  group('TranscriptChunkEvent', () {
    test('should create from JSON', () {
      // Arrange
      final json = {
        'position': 0,
        'speaker_index': 1,
        'start': 0.5,
        'end': 1.2,
        'text': 'Hello',
      };

      // Act
      final event = TranscriptChunkEvent.fromJson(json);

      // Assert
      expect(event.position, equals(0));
      expect(event.speakerIndex, equals(1));
      expect(event.start, equals(0.5));
      expect(event.end, equals(1.2));
      expect(event.text, equals('Hello'));
      expect(event.type, equals(TranscriptEventType.chunk));
    });
  });

  group('TranscriptSpeakerEvent', () {
    test('should create from JSON', () {
      // Arrange
      final json = {
        'index': 0,
        'name': 'John Doe',
      };

      // Act
      final event = TranscriptSpeakerEvent.fromJson(json);

      // Assert
      expect(event.index, equals(0));
      expect(event.name, equals('John Doe'));
      expect(event.type, equals(TranscriptEventType.speaker));
    });
  });

  group('TranscriptCompleteEvent', () {
    test('should create from JSON', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final event = TranscriptCompleteEvent.fromJson(json);

      // Assert
      expect(event.type, equals(TranscriptEventType.complete));
    });
  });

  group('TranscriptErrorEvent', () {
    test('should create from JSON with error message', () {
      // Arrange
      final json = {
        'error': 'Transcription failed',
      };

      // Act
      final event = TranscriptErrorEvent.fromJson(json);

      // Assert
      expect(event.error, equals('Transcription failed'));
      expect(event.type, equals(TranscriptEventType.error));
    });

    test('should use default error message when error field is missing', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final event = TranscriptErrorEvent.fromJson(json);

      // Assert
      expect(event.error, equals('Unknown error'));
    });
  });

  group('TranscriptRepository', () {
    group('streamTranscript', () {
      test('should stream and parse multiple SSE events correctly', () async {
        // Arrange
        const episodeId = 1;
        final mockEvents = [
          const TranscriptSpeakerEvent(index: 0, name: 'Alice'),
          const TranscriptChunkEvent(
            position: 0,
            speakerIndex: 0,
            start: 0.0,
            end: 2.0,
            text: 'Hello',
          ),
          const TranscriptCompleteEvent(),
        ];

        when(
          mockApiService.getStream<TranscriptEvent>(
            ApiPath.transcriptsStreamSse(episodeId),
            any,
          ),
        ).thenAnswer((_) => Stream.fromIterable(mockEvents));

        // Act
        final events =
            await transcriptRepository.streamTranscript(episodeId).toList();

        // Assert
        verify(
          mockApiService.getStream<TranscriptEvent>(
            ApiPath.transcriptsStreamSse(episodeId),
            any,
          ),
        );
        expect(events.length, equals(3));
        expect(events[0], isA<TranscriptSpeakerEvent>());
        expect(events[1], isA<TranscriptChunkEvent>());
        expect(events[2], isA<TranscriptCompleteEvent>());
      });

      test('should handle error events in stream', () async {
        // Arrange
        const episodeId = 1;
        final mockEvents = [
          const TranscriptErrorEvent(error: 'Failed to transcribe'),
        ];

        when(
          mockApiService.getStream<TranscriptEvent>(
            ApiPath.transcriptsStreamSse(episodeId),
            any,
          ),
        ).thenAnswer((_) => Stream.fromIterable(mockEvents));

        // Act
        final events =
            await transcriptRepository.streamTranscript(episodeId).toList();

        // Assert
        expect(events.length, equals(1));
        expect(events[0], isA<TranscriptErrorEvent>());
        expect(
          (events[0] as TranscriptErrorEvent).error,
          equals('Failed to transcribe'),
        );
      });

      test('should handle empty stream', () async {
        // Arrange
        const episodeId = 1;

        when(
          mockApiService.getStream<TranscriptEvent>(
            ApiPath.transcriptsStreamSse(episodeId),
            any,
          ),
        ).thenAnswer((_) => Stream.fromIterable([]));

        // Act
        final events =
            await transcriptRepository.streamTranscript(episodeId).toList();

        // Assert
        expect(events, isEmpty);
      });

      test('should rethrow exception when ApiService.getStream fails',
          () async {
        // Arrange
        const episodeId = 1;

        when(
          mockApiService.getStream<TranscriptEvent>(
            ApiPath.transcriptsStreamSse(episodeId),
            any,
          ),
        ).thenThrow(ApiException('Stream failed', statusCode: 500));

        // Act & Assert
        expect(
          () => transcriptRepository.streamTranscript(episodeId).toList(),
          throwsA(isA<ApiException>()),
        );
      });

      test('should filter out null events from invalid/malformed data',
          () async {
        // Arrange
        const episodeId = 1;

        // Create a custom stream controller to simulate the parsing behavior
        final controller = StreamController<TranscriptEvent?>();

        when(
          mockApiService.getStream<TranscriptEvent>(
            ApiPath.transcriptsStreamSse(episodeId),
            any,
          ),
        ).thenAnswer((invocation) {
          // Get the fromJson function that was passed
          final fromJson = invocation.positionalArguments[1] as TranscriptEvent?
              Function(String, Map<String, dynamic>);

          // Simulate valid and invalid events
          Future.microtask(() {
            // Valid chunk event
            final validChunk = fromJson('chunk', {
              'position': 0,
              'speaker_index': 0,
              'start': 0.0,
              'end': 1.0,
              'text': 'Valid',
            });
            if (validChunk != null) controller.add(validChunk);

            // Invalid event type (should return null and be filtered)
            final invalidType = fromJson('invalid_type', {});
            if (invalidType != null) controller.add(invalidType);

            // Valid speaker event
            final validSpeaker = fromJson('speaker', {
              'index': 0,
              'name': 'Alice',
            });
            if (validSpeaker != null) controller.add(validSpeaker);

            controller.close();
          });

          return controller.stream
              .where((event) => event != null)
              .cast<TranscriptEvent>();
        });

        // Act
        final events =
            await transcriptRepository.streamTranscript(episodeId).toList();

        // Assert - Only valid events should be present (invalid_type filtered out)
        expect(events.length, equals(2));
        expect(events[0], isA<TranscriptChunkEvent>());
        expect(events[1], isA<TranscriptSpeakerEvent>());
      });
    });

    group('lifecycle methods', () {
      test('should call init method', () async {
        // Act
        await transcriptRepository.init();

        // Assert - No specific assertion needed, just testing code path
      });

      test('should call dispose method', () async {
        // Act
        await transcriptRepository.dispose();

        // Assert - No specific assertion needed, just testing code path
      });
    });
  });
}
