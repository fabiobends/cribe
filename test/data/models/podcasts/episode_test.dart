import 'package:cribe/data/models/podcasts/episode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Episode', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    test('should create Episode from constructor', () {
      final episode = Episode(
        id: 1,
        externalId: 'ext_123',
        podcastId: 42,
        name: 'Test Episode',
        description: 'A test episode description',
        audioUrl: 'https://example.com/audio.mp3',
        imageUrl: 'https://example.com/image.jpg',
        datePublished: '2024-01-15',
        duration: 3600,
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(episode.id, 1);
      expect(episode.externalId, 'ext_123');
      expect(episode.podcastId, 42);
      expect(episode.name, 'Test Episode');
      expect(episode.description, 'A test episode description');
      expect(episode.audioUrl, 'https://example.com/audio.mp3');
      expect(episode.imageUrl, 'https://example.com/image.jpg');
      expect(episode.datePublished, '2024-01-15');
      expect(episode.duration, 3600);
      expect(episode.createdAt, testDate);
      expect(episode.updatedAt, testDate);
    });

    test('should create Episode from JSON', () {
      final json = {
        'id': 1,
        'externalId': 'ext_123',
        'podcastId': 42,
        'name': 'Test Episode',
        'description': 'A test episode description',
        'audioUrl': 'https://example.com/audio.mp3',
        'imageUrl': 'https://example.com/image.jpg',
        'datePublished': '2024-01-15',
        'duration': 3600,
        'createdAt': '2024-01-15T10:30:00.000Z',
        'updatedAt': '2024-01-15T10:30:00.000Z',
      };

      final episode = Episode.fromJson(json);

      expect(episode.id, 1);
      expect(episode.externalId, 'ext_123');
      expect(episode.podcastId, 42);
      expect(episode.name, 'Test Episode');
      expect(episode.description, 'A test episode description');
      expect(episode.audioUrl, 'https://example.com/audio.mp3');
      expect(episode.imageUrl, 'https://example.com/image.jpg');
      expect(episode.datePublished, '2024-01-15');
      expect(episode.duration, 3600);
    });

    test('should handle missing fields in JSON', () {
      final json = <String, dynamic>{
        'createdAt': '2024-01-15T10:30:00.000Z',
        'updatedAt': '2024-01-15T10:30:00.000Z',
      };

      final episode = Episode.fromJson(json);

      expect(episode.id, 0);
      expect(episode.externalId, '');
      expect(episode.podcastId, 0);
      expect(episode.name, '');
      expect(episode.description, '');
      expect(episode.audioUrl, '');
      expect(episode.imageUrl, '');
      expect(episode.datePublished, '');
      expect(episode.duration, 0);
    });
  });
}
