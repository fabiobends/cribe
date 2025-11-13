import 'package:cribe/ui/podcasts/view_models/episode_detail_view_model.dart';

class FakeEpisodeDetailViewModel extends EpisodeDetailViewModel {
  FakeEpisodeDetailViewModel() : super(episodeId: 1) {
    logger.info('FakeEpisodeDetailViewModel initialized');
  }
}
