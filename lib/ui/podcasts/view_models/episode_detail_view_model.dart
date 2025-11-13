import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/ui/shared/view_models/base_view_model.dart';

class EpisodeDetailViewModel extends BaseViewModel {
  EpisodeDetailViewModel({required int episodeId}) : _episodeId = episodeId {
    logger.info('EpisodeDetailViewModel initialized for episode: $episodeId');
    _loadEpisode();
  }

  final int _episodeId;
  Episode? _episode;
  double _playbackProgress = 0.0;
  bool _isPlaying = false;

  Episode? get episode => _episode;
  double get playbackProgress => _playbackProgress;
  bool get isPlaying => _isPlaying;

  void _loadEpisode() {
    logger.info('Loading episode for episode ID: $_episodeId');
    setLoading(true);

    try {
      // Mock episode data
      _episode = Episode(
        id: _episodeId,
        externalId: 'ep-$_episodeId',
        podcastId: 1,
        name: 'Episode $_episodeId: ${_getEpisodeTitle()}',
        description: _getEpisodeDescription(),
        audioUrl: 'https://example.com/audio/$_episodeId.mp3',
        imageUrl: 'https://picsum.photos/400/400?random=$_episodeId',
        datePublished: DateTime.now()
            .subtract(Duration(days: _episodeId * 7))
            .toIso8601String(),
        duration: 3600 + (_episodeId * 300),
        createdAt: DateTime.now().subtract(Duration(days: _episodeId * 7)),
        updatedAt: DateTime.now(),
      );

      // Simulate some initial playback progress
      _playbackProgress = 0.25;

      setLoading(false);
      logger.info('Episode loaded successfully');
    } catch (e) {
      logger.error('Failed to load episode: $e');
      setError('Failed to load episode');
      setLoading(false);
    }
  }

  String _getEpisodeTitle() {
    final titles = [
      'The Future of AI and Technology',
      'Building Better Products',
      'The Science of Happiness',
      'Understanding Climate Change',
      'The Art of Storytelling',
    ];
    return titles[_episodeId % titles.length];
  }

  String _getEpisodeDescription() {
    return '''
In this episode, we dive deep into fascinating topics that matter. Our guest shares incredible insights and experiences that will leave you inspired and informed.

We explore various perspectives and discuss the implications of current trends. This conversation covers everything from practical advice to thought-provoking ideas.

Join us for an engaging discussion that challenges conventional thinking and offers fresh perspectives on important subjects.
''';
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

  String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m ${secs}s';
    }
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        final weeks = difference.inDays ~/ 7;
        return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
      } else if (difference.inDays < 365) {
        final months = difference.inDays ~/ 30;
        return '$months ${months == 1 ? 'month' : 'months'} ago';
      } else {
        final years = difference.inDays ~/ 365;
        return '$years ${years == 1 ? 'year' : 'years'} ago';
      }
    } catch (e) {
      logger.warn('Failed to parse date: $e');
      return dateString;
    }
  }

  String getCurrentTime() {
    if (_episode == null) return '0:00';
    final currentSeconds = (_episode!.duration * _playbackProgress).toInt();
    return formatDuration(currentSeconds);
  }

  String getTotalTime() {
    if (_episode == null) return '0:00';
    return formatDuration(_episode!.duration);
  }
}
