import 'package:cribe/data/models/podcasts/podcast.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Podcast', () {
    group('constructor', () {
      test('should create Podcast with required fields', () {
        // Arrange
        final createdAt = DateTime(2024);
        final updatedAt = DateTime(2024, 1, 2);

        // Act
        final podcast = Podcast(
          id: 1,
          authorName: 'John Doe',
          name: 'Tech Talk',
          imageUrl: 'https://example.com/image.jpg',
          description: 'A podcast about technology',
          externalId: 'ext123',
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        // Assert
        expect(podcast.id, equals(1));
        expect(podcast.authorName, equals('John Doe'));
        expect(podcast.name, equals('Tech Talk'));
        expect(podcast.imageUrl, equals('https://example.com/image.jpg'));
        expect(podcast.description, equals('A podcast about technology'));
        expect(podcast.externalId, equals('ext123'));
        expect(podcast.createdAt, equals(createdAt));
        expect(podcast.updatedAt, equals(updatedAt));
      });
    });

    group('fromJson', () {
      test('should create Podcast from valid JSON map', () {
        // Arrange
        final json = {
          'id': 1,
          'authorName': 'Jane Smith',
          'name': 'Science Hour',
          'imageUrl': 'https://example.com/science.jpg',
          'description': 'All about science',
          'externalId': 'ext456',
          'createdAt': '2024-02-01T10:00:00.000Z',
          'updatedAt': '2024-02-02T10:00:00.000Z',
        };

        // Act
        final podcast = Podcast.fromJson(json);

        // Assert
        expect(podcast.id, equals(1));
        expect(podcast.authorName, equals('Jane Smith'));
        expect(podcast.name, equals('Science Hour'));
        expect(podcast.imageUrl, equals('https://example.com/science.jpg'));
        expect(podcast.description, equals('All about science'));
        expect(podcast.externalId, equals('ext456'));
        expect(
          podcast.createdAt,
          equals(DateTime.parse('2024-02-01T10:00:00.000Z')),
        );
        expect(
          podcast.updatedAt,
          equals(DateTime.parse('2024-02-02T10:00:00.000Z')),
        );
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
        };

        // Act
        final podcast = Podcast.fromJson(json);

        // Assert
        expect(podcast.id, equals(0));
        expect(podcast.authorName, equals(''));
        expect(podcast.name, equals(''));
        expect(podcast.imageUrl, equals(''));
        expect(podcast.description, equals(''));
        expect(podcast.externalId, equals(''));
      });

      test('should handle missing fields with default values', () {
        // Arrange
        final json = <String, dynamic>{
          'createdAt': '1970-01-01T00:00:00.000Z',
          'updatedAt': '1970-01-01T00:00:00.000Z',
        };

        // Act
        final podcast = Podcast.fromJson(json);

        // Assert
        expect(podcast.id, equals(0));
        expect(podcast.authorName, equals(''));
        expect(podcast.name, equals(''));
        expect(podcast.imageUrl, equals(''));
        expect(podcast.description, equals(''));
        expect(podcast.externalId, equals(''));
      });

      test('should handle JSON with extra fields', () {
        // Arrange
        final json = {
          'id': 2,
          'authorName': 'Bob Johnson',
          'name': 'History Tales',
          'imageUrl': 'https://example.com/history.jpg',
          'description': 'Stories from history',
          'externalId': 'ext789',
          'createdAt': '2024-03-01T10:00:00.000Z',
          'updatedAt': '2024-03-02T10:00:00.000Z',
          'extraField': 'should be ignored',
          'anotherField': 12345,
        };

        // Act
        final podcast = Podcast.fromJson(json);

        // Assert
        expect(podcast.id, equals(2));
        expect(podcast.authorName, equals('Bob Johnson'));
        expect(podcast.name, equals('History Tales'));
      });
    });
  });
}
