import 'package:cribe/domain/models/podcast.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Podcast', () {
    group('constructor', () {
      test('should create a Podcast instance with required fields', () {
        // Arrange & Act
        final podcast = Podcast(
          id: 1,
          authorName: 'Author Name',
          name: 'Podcast Name',
          description: 'Podcast description',
          externalId: 'ext-123',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024, 1, 2),
        );

        // Assert
        expect(podcast.id, equals(1));
        expect(podcast.authorName, equals('Author Name'));
        expect(podcast.name, equals('Podcast Name'));
        expect(podcast.description, equals('Podcast description'));
        expect(podcast.externalId, equals('ext-123'));
        expect(podcast.createdAt, equals(DateTime(2024)));
        expect(podcast.updatedAt, equals(DateTime(2024, 1, 2)));
        expect(podcast.imageUrl, isNull);
        expect(podcast.episodes, isNull);
      });

      test('should create a Podcast instance with all fields', () {
        // Arrange
        final episodes = [
          Episode(
            id: 1,
            externalId: 'ep-1',
            podcastId: 1,
            name: 'Episode 1',
            description: 'Episode 1 description',
            audioUrl: 'https://example.com/audio.mp3',
            datePublished: '2024-01-01',
            duration: 3600,
            createdAt: DateTime(2024),
            updatedAt: DateTime(2024, 1, 2),
          ),
        ];

        // Act
        final podcast = Podcast(
          id: 1,
          authorName: 'Author Name',
          name: 'Podcast Name',
          imageUrl: 'https://example.com/image.jpg',
          description: 'Podcast description',
          externalId: 'ext-123',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024, 1, 2),
          episodes: episodes,
        );

        // Assert
        expect(podcast.imageUrl, equals('https://example.com/image.jpg'));
        expect(podcast.episodes, isNotNull);
        expect(podcast.episodes!.length, equals(1));
        expect(podcast.episodes!.first.name, equals('Episode 1'));
      });
    });

    group('fromJson', () {
      test('should create a Podcast from JSON with required fields', () {
        // Arrange
        final json = {
          'id': 1,
          'author_name': 'Author Name',
          'name': 'Podcast Name',
          'description': 'Podcast description',
          'external_id': 'ext-123',
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-02T00:00:00.000Z',
        };

        // Act
        final podcast = Podcast.fromJson(json);

        // Assert
        expect(podcast.id, equals(1));
        expect(podcast.authorName, equals('Author Name'));
        expect(podcast.name, equals('Podcast Name'));
        expect(podcast.description, equals('Podcast description'));
        expect(podcast.externalId, equals('ext-123'));
        expect(
          podcast.createdAt,
          equals(DateTime.parse('2024-01-01T00:00:00.000Z')),
        );
        expect(
          podcast.updatedAt,
          equals(DateTime.parse('2024-01-02T00:00:00.000Z')),
        );
        expect(podcast.imageUrl, isNull);
        expect(podcast.episodes, isNull);
      });

      test('should create a Podcast from JSON with all fields', () {
        // Arrange
        final json = {
          'id': 1,
          'author_name': 'Author Name',
          'name': 'Podcast Name',
          'image_url': 'https://example.com/image.jpg',
          'description': 'Podcast description',
          'external_id': 'ext-123',
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-02T00:00:00.000Z',
          'episodes': [
            {
              'id': 1,
              'external_id': 'ep-1',
              'podcast_id': 1,
              'name': 'Episode 1',
              'description': 'Episode 1 description',
              'audio_url': 'https://example.com/audio.mp3',
              'date_published': '2024-01-01',
              'duration': 3600,
              'created_at': '2024-01-01T00:00:00.000Z',
              'updated_at': '2024-01-02T00:00:00.000Z',
            },
          ],
        };

        // Act
        final podcast = Podcast.fromJson(json);

        // Assert
        expect(podcast.imageUrl, equals('https://example.com/image.jpg'));
        expect(podcast.episodes, isNotNull);
        expect(podcast.episodes!.length, equals(1));
        expect(podcast.episodes!.first.name, equals('Episode 1'));
      });

      test('should handle null episodes in JSON', () {
        // Arrange
        final json = {
          'id': 1,
          'author_name': 'Author Name',
          'name': 'Podcast Name',
          'description': 'Podcast description',
          'external_id': 'ext-123',
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-02T00:00:00.000Z',
          'episodes': null,
        };

        // Act
        final podcast = Podcast.fromJson(json);

        // Assert
        expect(podcast.episodes, isNull);
      });
    });

    group('toJson', () {
      test('should convert Podcast to JSON with required fields', () {
        // Arrange
        final podcast = Podcast(
          id: 1,
          authorName: 'Author Name',
          name: 'Podcast Name',
          description: 'Podcast description',
          externalId: 'ext-123',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024, 1, 2),
        );

        // Act
        final json = podcast.toJson();

        // Assert
        expect(json['id'], equals(1));
        expect(json['author_name'], equals('Author Name'));
        expect(json['name'], equals('Podcast Name'));
        expect(json['description'], equals('Podcast description'));
        expect(json['external_id'], equals('ext-123'));
        expect(json['created_at'], equals('2024-01-01T00:00:00.000'));
        expect(json['updated_at'], equals('2024-01-02T00:00:00.000'));
        expect(json['image_url'], isNull);
        expect(json['episodes'], isNull);
      });

      test('should convert Podcast to JSON with all fields', () {
        // Arrange
        final episodes = [
          Episode(
            id: 1,
            externalId: 'ep-1',
            podcastId: 1,
            name: 'Episode 1',
            description: 'Episode 1 description',
            audioUrl: 'https://example.com/audio.mp3',
            datePublished: '2024-01-01',
            duration: 3600,
            createdAt: DateTime(2024),
            updatedAt: DateTime(2024, 1, 2),
          ),
        ];

        final podcast = Podcast(
          id: 1,
          authorName: 'Author Name',
          name: 'Podcast Name',
          imageUrl: 'https://example.com/image.jpg',
          description: 'Podcast description',
          externalId: 'ext-123',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024, 1, 2),
          episodes: episodes,
        );

        // Act
        final json = podcast.toJson();

        // Assert
        expect(json['image_url'], equals('https://example.com/image.jpg'));
        expect(json['episodes'], isNotNull);
        expect(json['episodes'], isA<List>());
        expect((json['episodes'] as List).length, equals(1));
      });
    });

    group('JSON serialization round trip', () {
      test('should maintain data integrity through serialization', () {
        // Arrange
        final original = Podcast(
          id: 1,
          authorName: 'Author Name',
          name: 'Podcast Name',
          imageUrl: 'https://example.com/image.jpg',
          description: 'Podcast description',
          externalId: 'ext-123',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024, 1, 2),
        );

        // Act
        final json = original.toJson();
        final deserialized = Podcast.fromJson(json);

        // Assert
        expect(deserialized.id, equals(original.id));
        expect(deserialized.authorName, equals(original.authorName));
        expect(deserialized.name, equals(original.name));
        expect(deserialized.imageUrl, equals(original.imageUrl));
        expect(deserialized.description, equals(original.description));
        expect(deserialized.externalId, equals(original.externalId));
        expect(deserialized.createdAt, equals(original.createdAt));
        expect(deserialized.updatedAt, equals(original.updatedAt));
      });
    });
  });

  group('Episode', () {
    group('constructor', () {
      test('should create an Episode instance with required fields', () {
        // Arrange & Act
        final episode = Episode(
          id: 1,
          externalId: 'ep-1',
          podcastId: 1,
          name: 'Episode Name',
          description: 'Episode description',
          audioUrl: 'https://example.com/audio.mp3',
          datePublished: '2024-01-01',
          duration: 3600,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024, 1, 2),
        );

        // Assert
        expect(episode.id, equals(1));
        expect(episode.externalId, equals('ep-1'));
        expect(episode.podcastId, equals(1));
        expect(episode.name, equals('Episode Name'));
        expect(episode.description, equals('Episode description'));
        expect(episode.audioUrl, equals('https://example.com/audio.mp3'));
        expect(episode.datePublished, equals('2024-01-01'));
        expect(episode.duration, equals(3600));
        expect(episode.createdAt, equals(DateTime(2024)));
        expect(episode.updatedAt, equals(DateTime(2024, 1, 2)));
        expect(episode.imageUrl, isNull);
      });

      test('should create an Episode instance with imageUrl', () {
        // Arrange & Act
        final episode = Episode(
          id: 1,
          externalId: 'ep-1',
          podcastId: 1,
          name: 'Episode Name',
          description: 'Episode description',
          audioUrl: 'https://example.com/audio.mp3',
          imageUrl: 'https://example.com/episode-image.jpg',
          datePublished: '2024-01-01',
          duration: 3600,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024, 1, 2),
        );

        // Assert
        expect(
          episode.imageUrl,
          equals('https://example.com/episode-image.jpg'),
        );
      });
    });

    group('fromJson', () {
      test('should create an Episode from JSON with required fields', () {
        // Arrange
        final json = {
          'id': 1,
          'external_id': 'ep-1',
          'podcast_id': 1,
          'name': 'Episode Name',
          'description': 'Episode description',
          'audio_url': 'https://example.com/audio.mp3',
          'date_published': '2024-01-01',
          'duration': 3600,
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-02T00:00:00.000Z',
        };

        // Act
        final episode = Episode.fromJson(json);

        // Assert
        expect(episode.id, equals(1));
        expect(episode.externalId, equals('ep-1'));
        expect(episode.podcastId, equals(1));
        expect(episode.name, equals('Episode Name'));
        expect(episode.description, equals('Episode description'));
        expect(episode.audioUrl, equals('https://example.com/audio.mp3'));
        expect(episode.datePublished, equals('2024-01-01'));
        expect(episode.duration, equals(3600));
        expect(
          episode.createdAt,
          equals(DateTime.parse('2024-01-01T00:00:00.000Z')),
        );
        expect(
          episode.updatedAt,
          equals(DateTime.parse('2024-01-02T00:00:00.000Z')),
        );
        expect(episode.imageUrl, isNull);
      });

      test('should create an Episode from JSON with imageUrl', () {
        // Arrange
        final json = {
          'id': 1,
          'external_id': 'ep-1',
          'podcast_id': 1,
          'name': 'Episode Name',
          'description': 'Episode description',
          'audio_url': 'https://example.com/audio.mp3',
          'image_url': 'https://example.com/episode-image.jpg',
          'date_published': '2024-01-01',
          'duration': 3600,
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-02T00:00:00.000Z',
        };

        // Act
        final episode = Episode.fromJson(json);

        // Assert
        expect(
          episode.imageUrl,
          equals('https://example.com/episode-image.jpg'),
        );
      });
    });

    group('toJson', () {
      test('should convert Episode to JSON with required fields', () {
        // Arrange
        final episode = Episode(
          id: 1,
          externalId: 'ep-1',
          podcastId: 1,
          name: 'Episode Name',
          description: 'Episode description',
          audioUrl: 'https://example.com/audio.mp3',
          datePublished: '2024-01-01',
          duration: 3600,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024, 1, 2),
        );

        // Act
        final json = episode.toJson();

        // Assert
        expect(json['id'], equals(1));
        expect(json['external_id'], equals('ep-1'));
        expect(json['podcast_id'], equals(1));
        expect(json['name'], equals('Episode Name'));
        expect(json['description'], equals('Episode description'));
        expect(json['audio_url'], equals('https://example.com/audio.mp3'));
        expect(json['date_published'], equals('2024-01-01'));
        expect(json['duration'], equals(3600));
        expect(json['created_at'], equals('2024-01-01T00:00:00.000'));
        expect(json['updated_at'], equals('2024-01-02T00:00:00.000'));
        expect(json['image_url'], isNull);
      });

      test('should convert Episode to JSON with imageUrl', () {
        // Arrange
        final episode = Episode(
          id: 1,
          externalId: 'ep-1',
          podcastId: 1,
          name: 'Episode Name',
          description: 'Episode description',
          audioUrl: 'https://example.com/audio.mp3',
          imageUrl: 'https://example.com/episode-image.jpg',
          datePublished: '2024-01-01',
          duration: 3600,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024, 1, 2),
        );

        // Act
        final json = episode.toJson();

        // Assert
        expect(
          json['image_url'],
          equals('https://example.com/episode-image.jpg'),
        );
      });
    });

    group('JSON serialization round trip', () {
      test('should maintain data integrity through serialization', () {
        // Arrange
        final original = Episode(
          id: 1,
          externalId: 'ep-1',
          podcastId: 1,
          name: 'Episode Name',
          description: 'Episode description',
          audioUrl: 'https://example.com/audio.mp3',
          imageUrl: 'https://example.com/episode-image.jpg',
          datePublished: '2024-01-01',
          duration: 3600,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024, 1, 2),
        );

        // Act
        final json = original.toJson();
        final deserialized = Episode.fromJson(json);

        // Assert
        expect(deserialized.id, equals(original.id));
        expect(deserialized.externalId, equals(original.externalId));
        expect(deserialized.podcastId, equals(original.podcastId));
        expect(deserialized.name, equals(original.name));
        expect(deserialized.description, equals(original.description));
        expect(deserialized.audioUrl, equals(original.audioUrl));
        expect(deserialized.imageUrl, equals(original.imageUrl));
        expect(deserialized.datePublished, equals(original.datePublished));
        expect(deserialized.duration, equals(original.duration));
        expect(deserialized.createdAt, equals(original.createdAt));
        expect(deserialized.updatedAt, equals(original.updatedAt));
      });
    });
  });
}
