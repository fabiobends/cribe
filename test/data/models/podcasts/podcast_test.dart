import 'package:cribe/data/models/podcasts/podcast.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Podcast', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    test('should create Podcast from constructor', () {
      final podcast = Podcast(
        id: 1,
        authorName: 'John Doe',
        name: 'Test Podcast',
        imageUrl: 'https://example.com/image.jpg',
        description: 'A test podcast description',
        externalId: 'ext_123',
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(podcast.id, 1);
      expect(podcast.authorName, 'John Doe');
      expect(podcast.name, 'Test Podcast');
      expect(podcast.imageUrl, 'https://example.com/image.jpg');
      expect(podcast.description, 'A test podcast description');
      expect(podcast.externalId, 'ext_123');
      expect(podcast.createdAt, testDate);
      expect(podcast.updatedAt, testDate);
    });

    test('should create Podcast from JSON', () {
      final json = {
        'id': 1,
        'authorName': 'John Doe',
        'name': 'Test Podcast',
        'imageUrl': 'https://example.com/image.jpg',
        'description': 'A test podcast description',
        'externalId': 'ext_123',
        'createdAt': '2024-01-15T10:30:00.000Z',
        'updatedAt': '2024-01-15T10:30:00.000Z',
      };

      final podcast = Podcast.fromJson(json);

      expect(podcast.id, 1);
      expect(podcast.authorName, 'John Doe');
      expect(podcast.name, 'Test Podcast');
      expect(podcast.imageUrl, 'https://example.com/image.jpg');
      expect(podcast.description, 'A test podcast description');
      expect(podcast.externalId, 'ext_123');
    });

    test('should handle missing fields in JSON', () {
      final json = <String, dynamic>{
        'createdAt': '2024-01-15T10:30:00.000Z',
        'updatedAt': '2024-01-15T10:30:00.000Z',
      };

      final podcast = Podcast.fromJson(json);

      expect(podcast.id, 0);
      expect(podcast.authorName, '');
      expect(podcast.name, '');
      expect(podcast.imageUrl, '');
      expect(podcast.description, '');
      expect(podcast.externalId, '');
    });
  });
}
