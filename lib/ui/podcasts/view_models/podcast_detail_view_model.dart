import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/ui/shared/view_models/base_view_model.dart';

class PodcastDetailViewModel extends BaseViewModel {
  PodcastDetailViewModel({required int podcastId}) : _podcastId = podcastId {
    logger.info('PodcastDetailViewModel initialized for podcast: $podcastId');
    _loadPodcastWithEpisodes();
  }

  final int _podcastId;
  Podcast? _podcast;
  List<Episode> _episodes = [];

  Podcast? get podcast => _podcast;
  List<Episode> get episodes => _episodes;

  void _loadPodcastWithEpisodes() {
    logger.info('Loading podcast and episodes for podcast ID: $_podcastId');
    setLoading(true);

    try {
      // Mock podcast data
      _podcast = Podcast(
        id: _podcastId,
        authorName: 'Joe Rogan',
        name: 'The Joe Rogan Experience',
        imageUrl: 'https://picsum.photos/400/400?random=$_podcastId',
        description:
            'The official podcast of comedian Joe Rogan. Long form conversations with the best minds in the world. Join Joe as he explores a wide range of topics with guests from various fields.',
        externalId: 'ext-$_podcastId',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );

      // Mock episodes data
      _episodes = List.generate(
        12,
        (index) => Episode(
          id: index + 1,
          externalId: 'ep-$_podcastId-${index + 1}',
          podcastId: _podcastId,
          name: 'Episode ${index + 1}: ${_getEpisodeTitle(index)}',
          description: _getEpisodeDescription(index),
          audioUrl: 'https://example.com/audio/$_podcastId/${index + 1}.mp3',
          imageUrl:
              'https://picsum.photos/200/200?random=${_podcastId * 100 + index}',
          datePublished: DateTime.now()
              .subtract(Duration(days: index * 7))
              .toIso8601String(),
          duration: 3600 + (index * 300), // 1 hour + varying minutes
          createdAt: DateTime.now().subtract(Duration(days: index * 7)),
          updatedAt: DateTime.now(),
        ),
      );

      logger.info(
          'Podcast and episodes loaded successfully: ${_episodes.length} episodes',);
      setLoading(false);
    } catch (e) {
      logger.error('Failed to load podcast and episodes', error: e);
      final errorMessage = 'Failed to load podcast details';
      setError(errorMessage);
    }
  }

  String _getEpisodeTitle(int index) {
    final titles = [
      'Life, the Universe and Everything',
      'The Future of AI and Technology',
      'Fitness, Health and Longevity',
      'Comedy and the Creative Process',
      'Science, Space and Exploration',
      'Politics and Free Speech',
      'Mixed Martial Arts and Combat Sports',
      'Philosophy and Consciousness',
      'Music and Entertainment Industry',
      'Business and Entrepreneurship',
      'Nature, Wildlife and Conservation',
      'History and Ancient Civilizations',
    ];
    return titles[index % titles.length];
  }

  String _getEpisodeDescription(int index) {
    final descriptions = [
      'Join us for an incredible conversation exploring deep philosophical questions and modern scientific discoveries.',
      'A fascinating discussion about artificial intelligence, machine learning, and what the future holds for humanity.',
      'Everything you need to know about staying healthy, building muscle, and living a longer life.',
      'Behind the scenes look at what it takes to be creative and make people laugh for a living.',
      'An amazing journey through space exploration and the latest discoveries in astrophysics.',
      'Important conversations about free speech, democracy, and the state of modern politics.',
      'Breaking down the latest fights, techniques, and stories from the world of MMA.',
      'Deep dive into consciousness, the nature of reality, and ancient philosophical wisdom.',
      'Inside look at the music industry, creative process, and life as a touring musician.',
      'Learn from successful entrepreneurs about building companies and creating value.',
      'Exploring the natural world, wildlife conservation, and our relationship with nature.',
      'Fascinating stories from ancient history and archaeological discoveries.',
    ];
    return descriptions[index % descriptions.length];
  }

  String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
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
      logger.warn('Failed to parse date: $dateString');
      return dateString;
    }
  }
}
