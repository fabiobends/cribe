import 'package:cribe/core/utils/time_utils.dart';
import 'package:cribe/data/repositories/podcasts/podcast_repository.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/ui/shared/view_models/base_view_model.dart';

class FormattedEpisode {
  final Episode episode;

  FormattedEpisode(this.episode);

  String get duration => TimeUtils.formatDuration(episode.duration);
  String get datePublished =>
      TimeUtils.formatRelativeDate(episode.datePublished);
}

class PodcastDetailViewModel extends BaseViewModel {
  final PodcastRepository _repository;

  PodcastDetailViewModel({
    required int podcastId,
    required PodcastRepository repository,
  })  : _podcastId = podcastId,
        _repository = repository {
    logger.info('PodcastDetailViewModel initialized for podcast: $podcastId');
    _loadPodcastWithEpisodes();
  }

  final int _podcastId;
  Podcast? _podcast;
  List<Episode> _episodes = [];

  Podcast? get podcast => _podcast;
  List<FormattedEpisode> get episodes =>
      _episodes.map((e) => FormattedEpisode(e)).toList();

  Future<void> _loadPodcastWithEpisodes() async {
    logger.info('Loading podcast and episodes for podcast ID: $_podcastId');
    setLoading(true);

    try {
      // Fetch podcast details with episodes from API
      _podcast = await _repository.getPodcastById(_podcastId);
      _episodes = _podcast?.episodes ?? [];

      logger.info(
        'Podcast and episodes loaded successfully',
        extra: {'episodeCount': _episodes.length},
      );
      setLoading(false);
    } catch (e) {
      logger.error('Failed to load podcast and episodes', error: e);
      final errorMessage = 'Failed to load podcast details';
      setError(errorMessage);
    }
  }
}
