class TranscriptChunk {
  final int position;
  final int speakerIndex;
  final double start;
  final double end;
  final String text;

  TranscriptChunk({
    required this.position,
    required this.speakerIndex,
    required this.start,
    required this.end,
    required this.text,
  });

  factory TranscriptChunk.fromJson(Map<String, dynamic> json) {
    return TranscriptChunk(
      position: json['position'] as int,
      speakerIndex: json['speaker_index'] as int,
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'speaker_index': speakerIndex,
      'start': start,
      'end': end,
      'text': text,
    };
  }
}

/// Represents a speaker's turn (consecutive chunks by the same speaker)
class SpeakerTurn {
  final int speakerIndex;
  final List<TranscriptChunk> chunks;

  SpeakerTurn(this.speakerIndex, this.chunks);
}
