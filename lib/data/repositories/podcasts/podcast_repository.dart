import 'package:cribe/core/constants/api_path.dart';
import 'package:cribe/data/repositories/base_repository.dart';
import 'package:cribe/domain/models/podcast.dart';

class PodcastRepository extends BaseRepository {
  PodcastRepository({super.apiService}) {
    logger.info('PodcastRepository initialized');
  }
  List<Podcast> _podcasts = [];
  List<Podcast> get podcasts => _podcasts;

  @override
  init() async {
    logger.info('PodcastRepository initialized with init');
  }

  @override
  dispose() async {
    logger.info('PodcastRepository disposed');
  }

  Future<void> getPodcasts() async {
    logger.info('Starting getPodcasts request');

    try {
      final response = await apiService?.get(
        ApiPath.podcasts,
        (json) => (json as List).map((e) => Podcast.fromJson(e)).toList(),
      );

      logger.info('getPodcasts request successful');
      setPodcasts(response?.data ?? []);
    } catch (e) {
      logger.error('getPodcasts request failed', error: e);
      rethrow;
    }
  }

  Future<Podcast> getPodcastById(int id) async {
    logger.info('Starting getPodcastById request', extra: {'id': id});

    try {
      final response = await apiService!.get(
        ApiPath.podcastById(id),
        (json) => Podcast.fromJson(json),
      );

      logger.info('getPodcastById request successful');
      return response.data;
    } catch (e) {
      logger
          .error('getPodcastById request failed', error: e, extra: {'id': id});
      rethrow;
    }
  }

  Future<List<Episode>> getEpisodesByPodcastId(int podcastId) async {
    logger.info(
      'Starting getEpisodesByPodcastId request',
      extra: {'podcastId': podcastId},
    );

    try {
      // Get podcast with episodes included
      final podcast = await getPodcastById(podcastId);

      logger.info(
        'getEpisodesByPodcastId request successful',
        extra: {'episodeCount': podcast.episodes?.length ?? 0},
      );
      return podcast.episodes ?? [];
    } catch (e) {
      logger.error(
        'getEpisodesByPodcastId request failed',
        error: e,
        extra: {'podcastId': podcastId},
      );
      rethrow;
    }
  }

  setPodcasts(List<Podcast> podcasts) {
    _podcasts = podcasts;
    logger.info('Podcasts list updated with ${podcasts.length} items');
  }
}
