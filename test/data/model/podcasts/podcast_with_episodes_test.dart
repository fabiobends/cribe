import 'package:cribe/data/model/podcasts/podcast_with_episodes.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PodcastWithEpisodes', () {
    group('constructor', () {
      test('should create PodcastWithEpisodes with required fields', () {
        // Arrange
        final createdAt = DateTime(2024);
        final updatedAt = DateTime(2024, 1, 2);
        final episode = Episode(
          id: 1,
          externalId: 'ep1',
          podcastId: 1,
          name: 'Episode 1',
          description: 'First episode',
          audioUrl: 'https://example.com/audio.mp3',
          imageUrl: 'https://example.com/image.jpg',
          datePublished: '2024-01-01',
          duration: 3600,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        // Act
        final podcast = PodcastWithEpisodes(
          id: 1,
          authorName: 'John Doe',
          name: 'Tech Talk',
          imageUrl: 'https://example.com/podcast.jpg',
          description: 'A podcast about technology',
          externalId: 'ext123',
          createdAt: createdAt,
          updatedAt: updatedAt,
          episodes: [episode],
        );

        // Assert
        expect(podcast.id, equals(1));
        expect(podcast.authorName, equals('John Doe'));
        expect(podcast.name, equals('Tech Talk'));
        expect(podcast.imageUrl, equals('https://example.com/podcast.jpg'));
        expect(podcast.description, equals('A podcast about technology'));
        expect(podcast.externalId, equals('ext123'));
        expect(podcast.createdAt, equals(createdAt));
        expect(podcast.updatedAt, equals(updatedAt));
        expect(podcast.episodes, hasLength(1));
        expect(podcast.episodes.first, equals(episode));
      });

      test('should create PodcastWithEpisodes with empty episodes list', () {
        // Arrange
        final createdAt = DateTime(2024);
        final updatedAt = DateTime(2024, 1, 2);

        // Act
        final podcast = PodcastWithEpisodes(
          id: 2,
          authorName: 'Jane Smith',
          name: 'New Podcast',
          imageUrl: 'https://example.com/new.jpg',
          description: 'Brand new',
          externalId: 'ext456',
          createdAt: createdAt,
          updatedAt: updatedAt,
          episodes: [],
        );

        // Assert
        expect(podcast.episodes, isEmpty);
      });
    });

    group('fromJson', () {
      test('should create PodcastWithEpisodes from valid JSON with episodes',
          () {
        // Arrange
        final json = {
          'id': 1,
          'authorName': 'Jane Smith',
          'name': 'Science Hour',
          'imageUrl': 'https://example.com/science.jpg',
          'description': 'All about science',
          'externalId': 'ext789',
          'createdAt': '2024-02-01T10:00:00.000Z',
          'updatedAt': '2024-02-02T10:00:00.000Z',
          'episodes': [
            {
              'id': 1,
              'external_id': 'ep1',
              'podcast_id': 1,
              'name': 'Episode 1',
              'description': 'First episode',
              'audio_url': 'https://example.com/audio1.mp3',
              'image_url': 'https://example.com/ep1.jpg',
              'date_published': '2024-02-01T10:00:00.000Z',
              'duration': 3600,
              'created_at': '2024-02-01T10:00:00.000Z',
              'updated_at': '2024-02-02T10:00:00.000Z',
            },
            {
              'id': 2,
              'external_id': 'ep2',
              'podcast_id': 1,
              'name': 'Episode 2',
              'description': 'Second episode',
              'audio_url': 'https://example.com/audio2.mp3',
              'image_url': 'https://example.com/ep2.jpg',
              'date_published': '2024-02-08T10:00:00.000Z',
              'duration': 4500,
              'created_at': '2024-02-08T10:00:00.000Z',
              'updated_at': '2024-02-09T10:00:00.000Z',
            },
          ],
        };

        // Act
        final podcast = PodcastWithEpisodes.fromJson(json);

        // Assert
        expect(podcast.id, equals(1));
        expect(podcast.authorName, equals('Jane Smith'));
        expect(podcast.name, equals('Science Hour'));
        expect(podcast.episodes, hasLength(2));
        expect(podcast.episodes[0].name, equals('Episode 1'));
        expect(podcast.episodes[1].name, equals('Episode 2'));
      });

      test('should handle null episodes field with empty list', () {
        // Arrange
        final json = {
          'id': 2,
          'authorName': 'Bob',
          'name': 'Test Podcast',
          'imageUrl': 'https://example.com/test.jpg',
          'description': 'Test',
          'externalId': 'ext999',
          'createdAt': '2024-03-01T10:00:00.000Z',
          'updatedAt': '2024-03-02T10:00:00.000Z',
          'episodes': null,
        };

        // Act
        final podcast = PodcastWithEpisodes.fromJson(json);

        // Assert
        expect(podcast.episodes, isEmpty);
      });

      test('should handle missing episodes field with empty list', () {
        // Arrange
        final json = {
          'id': 3,
          'authorName': 'Alice',
          'name': 'Another Podcast',
          'imageUrl': 'https://example.com/another.jpg',
          'description': 'Another one',
          'externalId': 'ext888',
          'createdAt': '2024-04-01T10:00:00.000Z',
          'updatedAt': '2024-04-02T10:00:00.000Z',
        };

        // Act
        final podcast = PodcastWithEpisodes.fromJson(json);

        // Assert
        expect(podcast.episodes, isEmpty);
      });

      test('should handle null fields with default values', () {
        // Arrange
        final json = {
          'id': null,
          'authorName': null,
          'name': null,
          'imageUrl': null,
          'description': null,
          'externalId': null,
          'createdAt': '1970-01-01T00:00:00.000Z',
          'updatedAt': '1970-01-01T00:00:00.000Z',
          'episodes': null,
        };

        // Act
        final podcast = PodcastWithEpisodes.fromJson(json);

        // Assert
        expect(podcast.id, equals(0));
        expect(podcast.authorName, equals(''));
        expect(podcast.name, equals(''));
        expect(podcast.imageUrl, equals(''));
        expect(podcast.description, equals(''));
        expect(podcast.externalId, equals(''));
        expect(podcast.episodes, isEmpty);
      });

      test('should handle JSON with extra fields', () {
        // Arrange
        final json = {
          'id': 4,
          'authorName': 'Charlie',
          'name': 'Extra Fields Podcast',
          'imageUrl': 'https://example.com/extra.jpg',
          'description': 'With extras',
          'externalId': 'ext777',
          'createdAt': '2024-05-01T10:00:00.000Z',
          'updatedAt': '2024-05-02T10:00:00.000Z',
          'episodes': [],
          'extraField': 'should be ignored',
          'rating': 5,
          'subscribers': 1000,
        };

        // Act
        final podcast = PodcastWithEpisodes.fromJson(json);

        // Assert
        expect(podcast.id, equals(4));
        expect(podcast.name, equals('Extra Fields Podcast'));
        expect(podcast.episodes, isEmpty);
      });
    });
  });
}
