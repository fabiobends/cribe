/// Transcript SSE event types from the backend
enum TranscriptEventType {
  chunk,
  speaker,
  complete,
  error;

  static TranscriptEventType fromString(String value) {
    switch (value) {
      case 'chunk':
        return TranscriptEventType.chunk;
      case 'speaker':
        return TranscriptEventType.speaker;
      case 'complete':
        return TranscriptEventType.complete;
      case 'error':
        return TranscriptEventType.error;
      default:
        throw ArgumentError('Unknown event type: $value');
    }
  }
}

/// Base class for all transcript events
sealed class TranscriptEvent {
  final TranscriptEventType type;
  const TranscriptEvent(this.type);
}

/// Chunk event: word segment with speaker and timing
class TranscriptChunkEvent extends TranscriptEvent {
  final int position;
  final int speakerIndex;
  final double start;
  final double end;
  final String text;

  const TranscriptChunkEvent({
    required this.position,
    required this.speakerIndex,
    required this.start,
    required this.end,
    required this.text,
  }) : super(TranscriptEventType.chunk);

  factory TranscriptChunkEvent.fromJson(Map<String, dynamic> json) {
    return TranscriptChunkEvent(
      position: json['position'] as int,
      speakerIndex: json['speaker_index'] as int,
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
      text: json['text'] as String,
    );
  }
}

/// Speaker event: speaker identification update
class TranscriptSpeakerEvent extends TranscriptEvent {
  final int index;
  final String name;

  const TranscriptSpeakerEvent({
    required this.index,
    required this.name,
  }) : super(TranscriptEventType.speaker);

  factory TranscriptSpeakerEvent.fromJson(Map<String, dynamic> json) {
    return TranscriptSpeakerEvent(
      index: json['index'] as int,
      name: json['name'] as String,
    );
  }
}

/// Complete event: transcription finished
class TranscriptCompleteEvent extends TranscriptEvent {
  const TranscriptCompleteEvent() : super(TranscriptEventType.complete);

  factory TranscriptCompleteEvent.fromJson(Map<String, dynamic> json) {
    return const TranscriptCompleteEvent();
  }
}

/// Error event: transcription error occurred
class TranscriptErrorEvent extends TranscriptEvent {
  final String error;

  const TranscriptErrorEvent({
    required this.error,
  }) : super(TranscriptEventType.error);

  factory TranscriptErrorEvent.fromJson(Map<String, dynamic> json) {
    return TranscriptErrorEvent(
      error: json['error'] as String? ?? 'Unknown error',
    );
  }
}
