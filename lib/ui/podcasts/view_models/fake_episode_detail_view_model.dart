import 'package:cribe/data/repositories/transcripts/fake_transcript_repository.dart';
import 'package:cribe/data/services/player_service.dart';
import 'package:cribe/data/services/transcription_service.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/ui/podcasts/view_models/episode_detail_view_model.dart';

class FakeEpisodeDetailViewModel extends EpisodeDetailViewModel {
  FakeEpisodeDetailViewModel()
      : super(
          episode: Episode(
            id: 1,
            externalId: 'fake-episode-1',
            podcastId: 1,
            name: 'Fake Episode for Development',
            description:
                'This is a fake episode used for development and testing',
            audioUrl: 'https://example.com/audio/fake-episode.mp3',
            imageUrl: 'https://picsum.photos/400/400?random=1',
            datePublished: DateTime.now()
                .subtract(const Duration(days: 7))
                .toIso8601String(),
            duration: 3600,
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
            updatedAt: DateTime.now(),
          ),
          playerService: PlayerService(),
          transcriptionService: TranscriptionService(
            repository: FakeTranscriptRepository(),
          ),
        ) {
    logger.info('FakeEpisodeDetailViewModel initialized');
  }
}
