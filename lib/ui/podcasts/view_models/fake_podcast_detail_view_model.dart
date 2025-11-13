import 'package:cribe/ui/podcasts/view_models/podcast_detail_view_model.dart';

class FakePodcastDetailViewModel extends PodcastDetailViewModel {
  FakePodcastDetailViewModel() : super(podcastId: 1) {
    logger.info('FakePodcastDetailViewModel initialized');
  }
}
