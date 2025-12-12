import 'package:cribe/data/models/podcasts/podcast_with_episodes.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PodcastWithEpisodes', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    test('should create PodcastWithEpisodes from constructor', () {
      final episodes = [
        Episode(
          id: 1,
          externalId: 'ep_1',
          podcastId: 42,
          name: 'Episode 1',
          description: 'First episode',
          audioUrl: 'https://example.com/audio1.mp3',
          imageUrl: 'https://example.com/image1.jpg',
          datePublished: '2024-01-15',
          duration: 1800,
          createdAt: testDate,
          updatedAt: testDate,
        ),
      ];

      final podcast = PodcastWithEpisodes(
        id: 42,
        authorName: 'John Doe',
        name: 'Test Podcast',
        imageUrl: 'https://example.com/image.jpg',
        description: 'A test podcast',
        externalId: 'ext_123',
        createdAt: testDate,
        updatedAt: testDate,
        episodes: episodes,
      );

      expect(podcast.id, 42);
      expect(podcast.authorName, 'John Doe');
      expect(podcast.name, 'Test Podcast');
      expect(podcast.imageUrl, 'https://example.com/image.jpg');
      expect(podcast.description, 'A test podcast');
      expect(podcast.externalId, 'ext_123');
      expect(podcast.episodes.length, 1);
      expect(podcast.episodes.first.name, 'Episode 1');
    });

    test('should create PodcastWithEpisodes from JSON', () {
      final json = {
        'id': 42,
        'authorName': 'John Doe',
        'name': 'Test Podcast',
        'imageUrl': 'https://example.com/image.jpg',
        'description': 'A test podcast',
        'externalId': 'ext_123',
        'createdAt': '2024-01-15T10:30:00.000Z',
        'updatedAt': '2024-01-15T10:30:00.000Z',
        'episodes': [
          {
            'id': 1,
            'external_id': 'ep_1',
            'podcast_id': 42,
            'name': 'Episode 1',
            'description': 'First episode',
            'audio_url': 'https://example.com/audio1.mp3',
            'image_url': 'https://example.com/image1.jpg',
            'date_published': '2024-01-15',
            'duration': 1800,
            'created_at': '2024-01-15T10:30:00.000Z',
            'updated_at': '2024-01-15T10:30:00.000Z',
          },
        ],
      };

      final podcast = PodcastWithEpisodes.fromJson(json);

      expect(podcast.id, 42);
      expect(podcast.authorName, 'John Doe');
      expect(podcast.name, 'Test Podcast');
      expect(podcast.episodes.length, 1);
      expect(podcast.episodes.first.name, 'Episode 1');
    });

    test('should handle missing episodes in JSON', () {
      final json = {
        'id': 42,
        'authorName': 'John Doe',
        'name': 'Test Podcast',
        'imageUrl': 'https://example.com/image.jpg',
        'description': 'A test podcast',
        'externalId': 'ext_123',
        'createdAt': '2024-01-15T10:30:00.000Z',
        'updatedAt': '2024-01-15T10:30:00.000Z',
      };

      final podcast = PodcastWithEpisodes.fromJson(json);

      expect(podcast.episodes, isEmpty);
    });

    test('should handle empty episodes array in JSON', () {
      final json = {
        'id': 42,
        'authorName': 'John Doe',
        'name': 'Test Podcast',
        'imageUrl': 'https://example.com/image.jpg',
        'description': 'A test podcast',
        'externalId': 'ext_123',
        'createdAt': '2024-01-15T10:30:00.000Z',
        'updatedAt': '2024-01-15T10:30:00.000Z',
        'episodes': [],
      };

      final podcast = PodcastWithEpisodes.fromJson(json);

      expect(podcast.episodes, isEmpty);
    });
  });
}
