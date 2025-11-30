import 'package:cribe/domain/models/transcript.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TranscriptChunk', () {
    group('fromJson', () {
      test('should create TranscriptChunk from valid JSON', () {
        // Arrange
        final json = {
          'position': 0,
          'speaker_index': 1,
          'start': 0.5,
          'end': 1.2,
          'text': 'Hello',
        };

        // Act
        final chunk = TranscriptChunk.fromJson(json);

        // Assert
        expect(chunk.position, equals(0));
        expect(chunk.speakerIndex, equals(1));
        expect(chunk.start, equals(0.5));
        expect(chunk.end, equals(1.2));
        expect(chunk.text, equals('Hello'));
      });

      test('should handle integer values for start and end times', () {
        // Arrange
        final json = {
          'position': 5,
          'speaker_index': 0,
          'start': 10,
          'end': 12,
          'text': 'World',
        };

        // Act
        final chunk = TranscriptChunk.fromJson(json);

        // Assert
        expect(chunk.start, equals(10.0));
        expect(chunk.end, equals(12.0));
      });
    });

    group('toJson', () {
      test('should convert TranscriptChunk to JSON', () {
        // Arrange
        final chunk = TranscriptChunk(
          position: 2,
          speakerIndex: 1,
          start: 3.5,
          end: 4.8,
          text: 'Test',
        );

        // Act
        final json = chunk.toJson();

        // Assert
        expect(json['position'], equals(2));
        expect(json['speaker_index'], equals(1));
        expect(json['start'], equals(3.5));
        expect(json['end'], equals(4.8));
        expect(json['text'], equals('Test'));
      });
    });
  });

  group('SpeakerTurn', () {
    test('should create SpeakerTurn with speaker index and chunks', () {
      // Arrange
      final chunks = [
        TranscriptChunk(
          position: 0,
          speakerIndex: 0,
          start: 0.0,
          end: 1.0,
          text: 'Hello',
        ),
        TranscriptChunk(
          position: 1,
          speakerIndex: 0,
          start: 1.0,
          end: 2.0,
          text: 'there',
        ),
      ];

      // Act
      final turn = SpeakerTurn(0, chunks);

      // Assert
      expect(turn.speakerIndex, equals(0));
      expect(turn.chunks, equals(chunks));
      expect(turn.chunks.length, equals(2));
    });
  });
}
