import 'package:cribe/data/models/podcasts/episode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Episode', () {
    group('constructor', () {
      test('should create Episode with required fields', () {
        // Arrange
        final createdAt = DateTime(2024);
        final updatedAt = DateTime(2024, 1, 2);

        // Act
        final episode = Episode(
          id: 1,
          externalId: 'ep123',
          podcastId: 10,
          name: 'Episode 1: Introduction',
          description: 'The first episode',
          audioUrl: 'https://example.com/audio.mp3',
          imageUrl: 'https://example.com/episode.jpg',
          datePublished: '2024-01-01',
          duration: 3600,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        // Assert
        expect(episode.id, equals(1));
        expect(episode.externalId, equals('ep123'));
        expect(episode.podcastId, equals(10));
        expect(episode.name, equals('Episode 1: Introduction'));
        expect(episode.description, equals('The first episode'));
        expect(episode.audioUrl, equals('https://example.com/audio.mp3'));
        expect(episode.imageUrl, equals('https://example.com/episode.jpg'));
        expect(episode.datePublished, equals('2024-01-01'));
        expect(episode.duration, equals(3600));
        expect(episode.createdAt, equals(createdAt));
        expect(episode.updatedAt, equals(updatedAt));
      });
    });

    group('fromJson', () {
      test('should create Episode from valid JSON map', () {
        // Arrange
        final json = {
          'id': 2,
          'externalId': 'ep456',
          'podcastId': 20,
          'name': 'Episode 2: Deep Dive',
          'description': 'Going deeper',
          'audioUrl': 'https://example.com/audio2.mp3',
          'imageUrl': 'https://example.com/episode2.jpg',
          'datePublished': '2024-02-01',
          'duration': 4500,
          'createdAt': '2024-02-01T10:00:00.000Z',
          'updatedAt': '2024-02-02T10:00:00.000Z',
        };

        // Act
        final episode = Episode.fromJson(json);

        // Assert
        expect(episode.id, equals(2));
        expect(episode.externalId, equals('ep456'));
        expect(episode.podcastId, equals(20));
        expect(episode.name, equals('Episode 2: Deep Dive'));
        expect(episode.description, equals('Going deeper'));
        expect(episode.audioUrl, equals('https://example.com/audio2.mp3'));
        expect(episode.imageUrl, equals('https://example.com/episode2.jpg'));
        expect(episode.datePublished, equals('2024-02-01'));
        expect(episode.duration, equals(4500));
        expect(
          episode.createdAt,
          equals(DateTime.parse('2024-02-01T10:00:00.000Z')),
        );
        expect(
          episode.updatedAt,
          equals(DateTime.parse('2024-02-02T10:00:00.000Z')),
        );
      });

      test('should handle null fields with default values', () {
        // Arrange
        final json = {
          'id': null,
          'externalId': null,
          'podcastId': null,
          'name': null,
          'description': null,
          'audioUrl': null,
          'imageUrl': null,
          'datePublished': null,
          'duration': null,
          'createdAt': '1970-01-01T00:00:00.000Z',
          'updatedAt': '1970-01-01T00:00:00.000Z',
        };

        // Act
        final episode = Episode.fromJson(json);

        // Assert
        expect(episode.id, equals(0));
        expect(episode.externalId, equals(''));
        expect(episode.podcastId, equals(0));
        expect(episode.name, equals(''));
        expect(episode.description, equals(''));
        expect(episode.audioUrl, equals(''));
        expect(episode.imageUrl, equals(''));
        expect(episode.datePublished, equals(''));
        expect(episode.duration, equals(0));
      });

      test('should handle missing fields with default values', () {
        // Arrange
        final json = <String, dynamic>{
          'createdAt': '1970-01-01T00:00:00.000Z',
          'updatedAt': '1970-01-01T00:00:00.000Z',
        };

        // Act
        final episode = Episode.fromJson(json);

        // Assert
        expect(episode.id, equals(0));
        expect(episode.externalId, equals(''));
        expect(episode.podcastId, equals(0));
        expect(episode.name, equals(''));
        expect(episode.description, equals(''));
        expect(episode.audioUrl, equals(''));
        expect(episode.imageUrl, equals(''));
        expect(episode.datePublished, equals(''));
        expect(episode.duration, equals(0));
      });

      test('should handle JSON with extra fields', () {
        // Arrange
        final json = {
          'id': 3,
          'externalId': 'ep789',
          'podcastId': 30,
          'name': 'Episode 3: Finale',
          'description': 'The end',
          'audioUrl': 'https://example.com/audio3.mp3',
          'imageUrl': 'https://example.com/episode3.jpg',
          'datePublished': '2024-03-01',
          'duration': 5400,
          'createdAt': '2024-03-01T10:00:00.000Z',
          'updatedAt': '2024-03-02T10:00:00.000Z',
          'extraField': 'should be ignored',
          'rating': 5,
        };

        // Act
        final episode = Episode.fromJson(json);

        // Assert
        expect(episode.id, equals(3));
        expect(episode.name, equals('Episode 3: Finale'));
        expect(episode.duration, equals(5400));
      });
    });
  });
}
