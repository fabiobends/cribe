import 'dart:async';

import 'package:cribe/core/utils/time_utils.dart';
import 'package:cribe/data/services/player_service.dart';
import 'package:cribe/data/services/transcription_service.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/domain/models/transcript.dart';
import 'package:cribe/domain/models/transcript_event.dart';
import 'package:cribe/ui/shared/view_models/base_view_model.dart';

class EpisodeDetailViewModel extends BaseViewModel {
  static const double _minProgress = 0.0;
  static const double _maxProgress = 1.0;
  static const double _completedThreshold = 0.999;
  static const double _transcriptSyncOffset =
      0.4; // seconds to adjust transcript timing

  // Auto-scroll configuration
  static const double scrollTopThreshold = 0.20; // Threshold from top
  static const double scrollBottomThreshold = 0.80; // Threshold from bottom
  static const double scrollTargetPosition = 0.40; // Position from top

  final Episode episode;
  final PlayerService _playerService;
  final TranscriptionService _transcriptionService;

  StreamSubscription<Duration?>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;

  EpisodeDetailViewModel({
    required this.episode,
    required PlayerService playerService,
    required TranscriptionService transcriptionService,
  })  : _playerService = playerService,
        _transcriptionService = transcriptionService {
    logger
        .info('EpisodeDetailViewModel initialized for episode: ${episode.id}');
    _initializePlayer();
    _initializeTranscript();
  }

  double _playbackProgress = 0.0;
  bool _isPlaying = false;
  int _audioDuration = 0;
  double _currentAudioPosition = 0.0; // in seconds

  // Transcript streaming state
  final List<TranscriptChunk> _chunks = [];
  final Map<int, String> _speakers = {}; // speaker_index -> name
  int _currentTranscriptChunkPosition = -1;
  int? _currentHighlightedChunkPosition;
  bool _transcriptCompleted = false;
  bool _isStreaming = false;
  StreamSubscription? _sseSubscription;
  bool _autoScrollEnabled = true;

  List<TranscriptChunk> get chunks => List.unmodifiable(_chunks);
  Map<int, String> get speakers => Map.unmodifiable(_speakers);
  int get currentTranscriptChunkPosition => _currentTranscriptChunkPosition;
  int? get currentHighlightedChunkPosition => _currentHighlightedChunkPosition;
  double get currentAudioPosition => _currentAudioPosition;
  double get transcriptSyncOffset => _transcriptSyncOffset;
  bool get transcriptCompleted => _transcriptCompleted;
  bool get isStreaming => _isStreaming;
  bool get autoScrollEnabled => _autoScrollEnabled;

  void setAutoScrollEnabled(bool enabled) {
    _autoScrollEnabled = enabled;
    notifyListeners();
  }

  /// Group consecutive chunks by speaker into "turns" for display
  List<SpeakerTurn> get speakerTurns {
    final turns = <SpeakerTurn>[];
    int? currentSpeaker;
    List<TranscriptChunk> currentChunks = [];

    for (var chunk in _chunks) {
      if (currentSpeaker == null || currentSpeaker != chunk.speakerIndex) {
        // New speaker turn
        if (currentChunks.isNotEmpty) {
          turns.add(SpeakerTurn(currentSpeaker!, List.from(currentChunks)));
        }
        currentSpeaker = chunk.speakerIndex;
        currentChunks = [chunk];
      } else {
        // Same speaker, continue turn
        currentChunks.add(chunk);
      }
    }
    // Add last turn
    if (currentChunks.isNotEmpty && currentSpeaker != null) {
      turns.add(SpeakerTurn(currentSpeaker, List.from(currentChunks)));
    }

    return turns;
  }

  /// Start streaming using the provided [TranscriptionService]. This keeps
  /// the view model free of repository creation details.
  Future<void> startTranscriptStreamWith(TranscriptionService service) async {
    if (_isStreaming) {
      await stopTranscriptStream();
    }
    _isStreaming = true;
    _transcriptCompleted = false;
    _chunks.clear();
    _speakers.clear();
    _currentTranscriptChunkPosition = -1;
    setLoading(true);
    notifyListeners();

    try {
      final stream = service.streamTranscript(episode.id);
      _sseSubscription = stream.listen(
        (event) {
          _handleTranscriptEvent(event);
        },
        onDone: () {
          _isStreaming = false;
          setLoading(false);
          notifyListeners();
        },
        onError: (e) {
          logger.error('Transcript SSE error', error: e);
          setError('Transcript streaming error');
          _isStreaming = false;
          setLoading(false);
          notifyListeners();
        },
        cancelOnError: true,
      );
    } catch (e, st) {
      logger.error(
        'Failed to start transcript stream with service',
        error: e,
        stackTrace: st,
      );
      setError('Failed to start transcript stream');
      _isStreaming = false;
      setLoading(false);
      notifyListeners();
    }
  }

  void _handleTranscriptEvent(TranscriptEvent event) {
    switch (event) {
      case TranscriptChunkEvent():
        final chunk = TranscriptChunk(
          position: event.position,
          speakerIndex: event.speakerIndex,
          start: event.start,
          end: event.end,
          text: event.text,
        );
        _chunks.add(chunk);
        _currentTranscriptChunkPosition = chunk.position;
        notifyListeners();
        break;

      case TranscriptSpeakerEvent():
        _speakers[event.index] = event.name;
        notifyListeners();
        break;

      case TranscriptCompleteEvent():
        _transcriptCompleted = true;
        setLoading(false);
        setSuccess(true);
        notifyListeners();
        break;

      case TranscriptErrorEvent():
        setError(event.error);
        notifyListeners();
        break;
    }
  }

  /// Stop streaming and cleanup
  Future<void> stopTranscriptStream() async {
    try {
      await _sseSubscription?.cancel();
      _sseSubscription = null;
    } catch (e) {
      logger.error('Error canceling transcript stream', error: e);
    }
    _isStreaming = false;
    notifyListeners();
  }

  double get playbackProgress => _playbackProgress;
  bool get isPlaying => _isPlaying;
  bool get isCompleted => _playbackProgress >= _completedThreshold;
  bool get isBuffering => _isPlaying && _playbackProgress == _minProgress;

  // Computed properties for formatted data
  String get duration => TimeUtils.formatDuration(
        _audioDuration > 0 ? _audioDuration : episode.duration,
      );
  String get datePublished =>
      TimeUtils.formatRelativeDate(episode.datePublished);
  String get elapsedTime {
    final totalDuration =
        _audioDuration > 0 ? _audioDuration : episode.duration;
    final currentSeconds = (totalDuration * _playbackProgress).toInt();
    return TimeUtils.formatTime(currentSeconds);
  }

  String get remainingTime {
    final totalDuration =
        _audioDuration > 0 ? _audioDuration : episode.duration;
    final currentSeconds = (totalDuration * _playbackProgress).toInt();
    final remaining = totalDuration - currentSeconds;
    return '-${TimeUtils.formatTime(remaining)}';
  }

  Future<void> _initializePlayer() async {
    try {
      logger.info('Initializing player with URL: ${episode.audioUrl}');
      await _playerService.setAudioUrl(episode.audioUrl);

      _positionSubscription = _playerService.positionStream.listen((position) {
        if (position != null && _audioDuration > 0) {
          _currentAudioPosition = position.inSeconds.toDouble();
          _playbackProgress = position.inSeconds / _audioDuration;
          _updateCurrentHighlightedChunk();
          notifyListeners();
        }
      });

      _durationSubscription = _playerService.durationStream.listen((duration) {
        if (duration != null) {
          _audioDuration = duration.inSeconds;
          notifyListeners();
        }
      });
    } catch (e) {
      logger.error('Failed to initialize player', error: e);
      setError('Failed to load audio');
    }
  }

  Future<void> _initializeTranscript() async {
    logger.info('Initializing transcript stream for episode: ${episode.id}');
    await startTranscriptStreamWith(_transcriptionService);
  }

  void _updateCurrentHighlightedChunk() {
    if (_chunks.isEmpty || _currentAudioPosition <= 0) {
      _currentHighlightedChunkPosition = null;
      return;
    }

    // Find the current chunk based on audio position
    for (var chunk in _chunks) {
      if (_currentAudioPosition >= (chunk.start - _transcriptSyncOffset) &&
          _currentAudioPosition <= chunk.end) {
        if (_currentHighlightedChunkPosition != chunk.position) {
          _currentHighlightedChunkPosition = chunk.position;
        }
        return;
      }
    }
  }

  void togglePlayPause() {
    logger.info('Toggle play/pause');

    if (isCompleted) {
      logger.info('Restarting episode from beginning');
      seekTo(_minProgress);
      _playerService.play();
      _isPlaying = true;
    } else if (_isPlaying) {
      _playerService.pause();
      _isPlaying = false;
    } else {
      _playerService.play();
      _isPlaying = true;
    }
    notifyListeners();
  }

  void seekTo(double progress) {
    logger.info('Seeking to progress: $progress');
    if (progress >= _minProgress && progress <= _maxProgress) {
      final totalDuration =
          _audioDuration > 0 ? _audioDuration : episode.duration;
      final position = Duration(seconds: (totalDuration * progress).toInt());
      _playerService.seek(position);
      _playbackProgress = progress;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    logger.info('Disposing EpisodeDetailViewModel');
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _sseSubscription?.cancel();
    _playerService.stop();
    _playerService.dispose();
    super.dispose();
  }
}
