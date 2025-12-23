import 'package:cribe/data/repositories/transcripts/transcript_repository.dart';
import 'package:cribe/data/services/transcription_service.dart';
import 'package:cribe/domain/models/transcript_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'transcription_service_test.mocks.dart';

@GenerateMocks([TranscriptRepository])
void main() {
  late TranscriptionService service;
  late MockTranscriptRepository mockRepository;

  setUp(() {
    mockRepository = MockTranscriptRepository();
    service = TranscriptionService(repository: mockRepository);
  });

  group('TranscriptionService', () {
    test('should delegate streamTranscript to repository', () async {
      // Arrange
      final episodeId = 123;
      final mockEvents = [
        const TranscriptSpeakerEvent(index: 0, name: 'Speaker 1'),
        const TranscriptChunkEvent(
          position: 0,
          speakerIndex: 0,
          start: 0.0,
          end: 1.5,
          text: 'Hello',
        ),
        const TranscriptCompleteEvent(),
      ];

      when(mockRepository.streamTranscript(episodeId))
          .thenAnswer((_) => Stream.fromIterable(mockEvents));

      // Act
      final stream = service.streamTranscript(episodeId);
      final events = await stream.toList();

      // Assert
      expect(events, equals(mockEvents));
      verify(mockRepository.streamTranscript(episodeId)).called(1);
    });

    test('should propagate errors from repository', () async {
      // Arrange
      final episodeId = 456;
      final error = Exception('Network error');

      when(mockRepository.streamTranscript(episodeId))
          .thenAnswer((_) => Stream.error(error));

      // Act
      final stream = service.streamTranscript(episodeId);

      // Assert
      expect(
        stream.toList(),
        throwsA(equals(error)),
      );
      verify(mockRepository.streamTranscript(episodeId)).called(1);
    });

    test('should handle empty stream from repository', () async {
      // Arrange
      final episodeId = 789;

      when(mockRepository.streamTranscript(episodeId))
          .thenAnswer((_) => const Stream.empty());

      // Act
      final stream = service.streamTranscript(episodeId);
      final events = await stream.toList();

      // Assert
      expect(events, isEmpty);
      verify(mockRepository.streamTranscript(episodeId)).called(1);
    });

    test('should call init', () async {
      await service.init();
      // No assertion needed
    });

    test('should call dispose', () async {
      await service.dispose();
      // No assertion needed
    });
  });
}
