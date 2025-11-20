import 'package:cribe/data/repositories/podcasts/podcast_repository.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/ui/shared/view_models/base_view_model.dart';

class PodcastListViewModel extends BaseViewModel {
  final PodcastRepository _repository;

  PodcastListViewModel({required PodcastRepository repository})
      : _repository = repository,
        super(repo: repository) {
    logger.info('PodcastListViewModel initialized');
    loadPodcasts();
  }

  List<Podcast> get podcasts => _repository.podcasts;

  Future<void> loadPodcasts() async {
    logger.info('Loading podcasts');
    setLoading(true);
    try {
      await _repository.getPodcasts();
      notifyListeners();
    } catch (e) {
      final errorMessage = 'Failed to load podcasts';
      logger.error(errorMessage, error: e);
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  Future<void> refresh() async {
    logger.info('Refreshing podcasts');
    try {
      await _repository.getPodcasts();
      notifyListeners();
    } catch (e) {
      final errorMessage = 'Failed to refresh podcasts';
      logger.error(errorMessage, error: e);
      setError(errorMessage);
    }
  }
}
