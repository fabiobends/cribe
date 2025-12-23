import 'package:cribe/data/repositories/transcripts/transcript_repository.dart';
import 'package:cribe/data/services/base_service.dart';
import 'package:cribe/domain/models/transcript_event.dart';

/// Service for streaming transcript events via SSE
class TranscriptionService extends BaseService {
  final TranscriptRepository _repository;

  TranscriptionService({required TranscriptRepository repository})
      : _repository = repository {
    logger.info('TranscriptionService initialized');
  }

  @override
  Future<void> init() async {
    logger.debug('TranscriptionService init called');
  }

  @override
  Future<void> dispose() async {
    logger.debug('TranscriptionService dispose called');
  }

  /// Connects to the SSE endpoint for the given episode id and returns a
  /// stream of strongly-typed transcript events
  Stream<TranscriptEvent> streamTranscript(int episodeId) {
    return _repository.streamTranscript(episodeId);
  }
}
