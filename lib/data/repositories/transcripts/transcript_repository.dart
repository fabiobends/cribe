import 'dart:async';

import 'package:cribe/core/constants/api_path.dart';
import 'package:cribe/data/repositories/base_repository.dart';
import 'package:cribe/domain/models/transcript_event.dart';

class TranscriptRepository extends BaseRepository {
  TranscriptRepository({
    super.apiService,
  }) {
    logger.info('TranscriptRepository initialized');
  }

  @override
  init() async {
    logger.info('TranscriptRepository initialized with init');
  }

  @override
  dispose() async {
    logger.info('TranscriptRepository disposed');
  }

  /// Connects to the SSE endpoint for the given episode id and returns a
  /// stream of strongly-typed transcript events
  Stream<TranscriptEvent> streamTranscript(int episodeId) async* {
    logger.info(
      'Starting transcript stream',
      extra: {'episodeId': episodeId},
    );

    try {
      if (apiService == null) {
        throw StateError('ApiService not initialized');
      }
      await for (final event in apiService!.getStream(
        ApiPath.transcriptsStreamSse(episodeId),
        _parseEvent,
      )) {
        yield event;
      }

      logger.info(
        'Transcript stream completed',
        extra: {'episodeId': episodeId},
      );
    } catch (e) {
      logger.error(
        'Transcript stream failed',
        error: e,
        extra: {'episodeId': episodeId},
      );
      rethrow;
    }
  }

  /// Parse raw SSE event string and data into strongly-typed event
  TranscriptEvent? _parseEvent(String eventType, Map<String, dynamic> data) {
    try {
      final type = TranscriptEventType.fromString(eventType);

      switch (type) {
        case TranscriptEventType.chunk:
          return TranscriptChunkEvent.fromJson(data);
        case TranscriptEventType.speaker:
          return TranscriptSpeakerEvent.fromJson(data);
        case TranscriptEventType.complete:
          return TranscriptCompleteEvent.fromJson(data);
        case TranscriptEventType.error:
          return TranscriptErrorEvent.fromJson(data);
      }
    } catch (e) {
      logger.debug(
        'Failed to parse transcript event',
        extra: {'eventType': eventType, 'data': data},
      );
      return null;
    }
  }
}
