import 'package:cribe/data/repositories/podcasts/podcast_repository.dart';
import 'package:cribe/domain/models/podcast.dart';

class FakePodcastRepository extends PodcastRepository {
  @override
  Future<void> getPodcasts() async {
    logger.info('Loading mock podcasts in FakePodcastRepository');
    final data = [
      Podcast(
        id: 1,
        authorName: 'Joe Rogan',
        name: 'The Joe Rogan Experience',
        imageUrl: 'https://picsum.photos/200/200?random=1',
        description:
            'The official podcast of comedian Joe Rogan. Long form conversations with the best minds in the world.',
        externalId: 'ext-1',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      Podcast(
        id: 2,
        authorName: 'Lex Fridman',
        name: 'Lex Fridman Podcast',
        imageUrl: 'https://picsum.photos/200/200?random=2',
        description:
            'Conversations about science, technology, history, philosophy and the nature of intelligence.',
        externalId: 'ext-2',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now(),
      ),
      Podcast(
        id: 3,
        authorName: 'Tim Ferriss',
        name: 'The Tim Ferriss Show',
        imageUrl: 'https://picsum.photos/200/200?random=3',
        description:
            'Tim Ferriss deconstructs world-class performers from eclectic areas.',
        externalId: 'ext-3',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now(),
      ),
      Podcast(
        id: 4,
        authorName: 'Tim Ferriss',
        name: 'The Tim Ferriss Show',
        imageUrl: 'https://picsum.photos/200/200?random=4',
        description:
            'Tim Ferriss deconstructs world-class performers from eclectic areas.',
        externalId: 'ext-4',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now(),
      ),
      Podcast(
        id: 5,
        authorName: 'Tim Ferriss',
        name: 'The Tim Ferriss Show',
        imageUrl: 'https://picsum.photos/200/200?random=5',
        description:
            'Tim Ferriss deconstructs world-class performers from eclectic areas.',
        externalId: 'ext-5',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now(),
      ),
    ];
    setPodcasts(data);
  }

  @override
  Future<Podcast> getPodcastById(int id) async {
    logger.info(
      'Loading mock podcast by ID in FakePodcastRepository',
      extra: {'id': id},
    );

    // Return mock podcast with episodes
    return Podcast(
      id: id,
      authorName: 'Joe Rogan',
      name: 'The Joe Rogan Experience',
      imageUrl: 'https://picsum.photos/400/400?random=$id',
      description:
          'The official podcast of comedian Joe Rogan. Long form conversations with the best minds in the world.',
      externalId: 'ext-$id',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      episodes: List.generate(
        12,
        (index) => Episode(
          id: index + 1,
          externalId: 'ep-$id-${index + 1}',
          podcastId: id,
          name: 'Episode ${index + 1}: Mock Episode Title',
          description:
              'This is a mock episode description for testing purposes.',
          audioUrl: 'https://example.com/audio/$id/${index + 1}.mp3',
          imageUrl: 'https://picsum.photos/200/200?random=${id * 100 + index}',
          datePublished: DateTime.now()
              .subtract(Duration(days: index * 7))
              .toIso8601String(),
          duration: 3600 + (index * 300),
          createdAt: DateTime.now().subtract(Duration(days: index * 7)),
          updatedAt: DateTime.now(),
        ),
      ),
    );
  }
}
