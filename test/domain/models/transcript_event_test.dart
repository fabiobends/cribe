import 'package:cribe/domain/models/transcript_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TranscriptEventType', () {
    test('fromString should return correct enum value', () {
      expect(
        TranscriptEventType.fromString('chunk'),
        TranscriptEventType.chunk,
      );
      expect(
        TranscriptEventType.fromString('speaker'),
        TranscriptEventType.speaker,
      );
      expect(
        TranscriptEventType.fromString('complete'),
        TranscriptEventType.complete,
      );
      expect(
        TranscriptEventType.fromString('error'),
        TranscriptEventType.error,
      );
    });

    test('fromString should throw ArgumentError for unknown type', () {
      expect(
        () => TranscriptEventType.fromString('unknown'),
        throwsArgumentError,
      );
    });
  });

  group('TranscriptChunkEvent', () {
    test('should create from valid JSON', () {
      final json = {
        'position': 0,
        'speaker_index': 1,
        'start': 1.5,
        'end': 2.5,
        'text': 'Hello',
      };

      final event = TranscriptChunkEvent.fromJson(json);

      expect(event.position, 0);
      expect(event.speakerIndex, 1);
      expect(event.start, 1.5);
      expect(event.end, 2.5);
      expect(event.text, 'Hello');
      expect(event.type, TranscriptEventType.chunk);
    });

    test('should handle integer values for start and end', () {
      final json = {
        'position': 0,
        'speaker_index': 1,
        'start': 1,
        'end': 2,
        'text': 'Hello',
      };

      final event = TranscriptChunkEvent.fromJson(json);

      expect(event.start, 1.0);
      expect(event.end, 2.0);
    });
  });

  group('TranscriptSpeakerEvent', () {
    test('should create from valid JSON', () {
      final json = {
        'index': 0,
        'name': 'Speaker 1',
      };

      final event = TranscriptSpeakerEvent.fromJson(json);

      expect(event.index, 0);
      expect(event.name, 'Speaker 1');
      expect(event.type, TranscriptEventType.speaker);
    });
  });

  group('TranscriptCompleteEvent', () {
    test('should create from valid JSON', () {
      final json = <String, dynamic>{};

      final event = TranscriptCompleteEvent.fromJson(json);

      expect(event.type, TranscriptEventType.complete);
    });

    test('should be const constructible', () {
      const event = TranscriptCompleteEvent();
      expect(event.type, TranscriptEventType.complete);
    });
  });

  group('TranscriptErrorEvent', () {
    test('should create from valid JSON with error message', () {
      final json = {
        'error': 'Something went wrong',
      };

      final event = TranscriptErrorEvent.fromJson(json);

      expect(event.error, 'Something went wrong');
      expect(event.type, TranscriptEventType.error);
    });

    test('should default to "Unknown error" when error field is missing', () {
      final json = <String, dynamic>{};

      final event = TranscriptErrorEvent.fromJson(json);

      expect(event.error, 'Unknown error');
    });

    test('should default to "Unknown error" when error field is null', () {
      final json = {'error': null};

      final event = TranscriptErrorEvent.fromJson(json);

      expect(event.error, 'Unknown error');
    });
  });

  group('TranscriptEvent sealed class', () {
    test('should allow pattern matching on event types', () {
      const TranscriptEvent event = TranscriptChunkEvent(
        position: 0,
        speakerIndex: 0,
        start: 0.0,
        end: 1.0,
        text: 'test',
      );

      final result = switch (event) {
        TranscriptChunkEvent() => 'chunk',
        TranscriptSpeakerEvent() => 'speaker',
        TranscriptCompleteEvent() => 'complete',
        TranscriptErrorEvent() => 'error',
      };

      expect(result, 'chunk');
    });
  });
}
