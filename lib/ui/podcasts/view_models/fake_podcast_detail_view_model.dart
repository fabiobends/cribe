import 'package:cribe/data/repositories/podcasts/fake_podcast_repository.dart';
import 'package:cribe/ui/podcasts/view_models/podcast_detail_view_model.dart';

class FakePodcastDetailViewModel extends PodcastDetailViewModel {
  FakePodcastDetailViewModel()
      : super(
          podcastId: 1,
          repository: FakePodcastRepository(),
        ) {
    logger.info('FakePodcastDetailViewModel initialized');
  }
}
