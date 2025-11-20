import 'package:cribe/core/utils/time_utils.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/ui/shared/view_models/base_view_model.dart';

class EpisodeDetailViewModel extends BaseViewModel {
  final Episode episode;

  EpisodeDetailViewModel({required this.episode}) {
    logger
        .info('EpisodeDetailViewModel initialized for episode: ${episode.id}');
  }

  double _playbackProgress = 0.0;
  bool _isPlaying = false;

  double get playbackProgress => _playbackProgress;
  bool get isPlaying => _isPlaying;

  // Computed properties for formatted data
  String get duration => TimeUtils.formatDuration(episode.duration);
  String get datePublished =>
      TimeUtils.formatRelativeDate(episode.datePublished);
  String get elapsedTime {
    final currentSeconds = (episode.duration * _playbackProgress).toInt();
    return TimeUtils.formatDuration(currentSeconds);
  }

  void togglePlayPause() {
    logger.info('Toggle play/pause');
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void seekTo(double progress) {
    logger.info('Seeking to progress: $progress');
    if (progress >= 0.0 && progress <= 1.0) {
      _playbackProgress = progress;
      notifyListeners();
    }
  }
}
