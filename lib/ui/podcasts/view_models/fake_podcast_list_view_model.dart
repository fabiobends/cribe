import 'package:cribe/data/repositories/podcasts/fake_podcast_repository.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/ui/shared/view_models/base_view_model.dart';

class FakePodcastListViewModel extends BaseViewModel {
  final FakePodcastRepository _repository;

  FakePodcastListViewModel({required FakePodcastRepository repository})
      : _repository = repository,
        super(repo: repository);

  List<Podcast> get podcasts => _repository.podcasts;

  void getPodcasts() {
    logger.info('Loading mock podcasts');
    setLoading(true);
    _repository.getPodcasts();
    notifyListeners();
    setLoading(false);
  }
}
