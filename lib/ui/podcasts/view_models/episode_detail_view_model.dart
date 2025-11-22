import 'dart:async';

import 'package:cribe/core/utils/time_utils.dart';
import 'package:cribe/data/services/player_service.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/ui/shared/view_models/base_view_model.dart';

class EpisodeDetailViewModel extends BaseViewModel {
  final Episode episode;
  final PlayerService _playerService;

  StreamSubscription<Duration?>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;

  EpisodeDetailViewModel({
    required this.episode,
    required PlayerService playerService,
  }) : _playerService = playerService {
    logger
        .info('EpisodeDetailViewModel initialized for episode: ${episode.id}');
    _initializePlayer();
  }

  double _playbackProgress = 0.0;
  bool _isPlaying = false;
  int _audioDuration = 0;

  double get playbackProgress => _playbackProgress;
  bool get isPlaying => _isPlaying;

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
          _playbackProgress = position.inSeconds / _audioDuration;
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

  void togglePlayPause() {
    logger.info('Toggle play/pause');
    if (_isPlaying) {
      _playerService.pause();
    } else {
      _playerService.play();
    }
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void seekTo(double progress) {
    logger.info('Seeking to progress: $progress');
    if (progress >= 0.0 && progress <= 1.0) {
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
    _playerService.stop();
    _playerService.dispose();
    super.dispose();
  }
}
