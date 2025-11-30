import 'package:cribe/data/repositories/transcripts/transcript_repository.dart';
import 'package:cribe/domain/models/transcript_event.dart';

/// Service for streaming transcript events via SSE
class TranscriptionService {
  final TranscriptRepository _repository;

  TranscriptionService({required TranscriptRepository repository})
      : _repository = repository;

  /// Connects to the SSE endpoint for the given episode id and returns a
  /// stream of strongly-typed transcript events
  Stream<TranscriptEvent> streamTranscript(int episodeId) {
    return _repository.streamTranscript(episodeId);
  }
}
