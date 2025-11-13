import 'package:cribe/ui/podcasts/view_models/podcast_detail_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PodcastDetailViewModel viewModel;
  const testPodcastId = 1;

  setUp(() {
    viewModel = PodcastDetailViewModel(podcastId: testPodcastId);
  });

  group('PodcastDetailViewModel', () {
    group('initial state', () {
      test('should initialize with success state and mock data', () {
        // Assert
        expect(viewModel.error, isNull);
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.podcast, isNotNull);
        expect(viewModel.episodes, isNotEmpty);
      });

      test('should load podcast with correct ID', () {
        // Assert
        expect(viewModel.podcast?.id, equals(testPodcastId));
      });

      test('should load 12 mock episodes', () {
        // Assert
        expect(viewModel.episodes.length, equals(12));
      });

      test('should have correct podcast data structure', () {
        // Assert
        final podcast = viewModel.podcast!;
        expect(podcast.id, equals(testPodcastId));
        expect(podcast.authorName, equals('Joe Rogan'));
        expect(podcast.name, equals('The Joe Rogan Experience'));
        expect(podcast.imageUrl, isNotNull);
        expect(podcast.description, isNotEmpty);
        expect(podcast.externalId, equals('ext-$testPodcastId'));
        expect(podcast.createdAt, isNotNull);
        expect(podcast.updatedAt, isNotNull);
      });

      test('should have all required episode fields', () {
        // Assert
        for (final episode in viewModel.episodes) {
          expect(episode.id, isNotNull);
          expect(episode.externalId, isNotEmpty);
          expect(episode.podcastId, equals(testPodcastId));
          expect(episode.name, isNotEmpty);
          expect(episode.description, isNotEmpty);
          expect(episode.audioUrl, isNotEmpty);
          expect(episode.imageUrl, isNotNull);
          expect(episode.datePublished, isNotEmpty);
          expect(episode.duration, greaterThan(0));
          expect(episode.createdAt, isNotNull);
          expect(episode.updatedAt, isNotNull);
        }
      });

      test('episodes should be ordered by date (newest first)', () {
        // Assert
        for (int i = 0; i < viewModel.episodes.length - 1; i++) {
          final currentDate =
              DateTime.parse(viewModel.episodes[i].datePublished);
          final nextDate =
              DateTime.parse(viewModel.episodes[i + 1].datePublished);
          expect(
            currentDate.isAfter(nextDate) ||
                currentDate.isAtSameMomentAs(nextDate),
            isTrue,
          );
        }
      });
    });

    group('formatDuration', () {
      test('should format duration with hours and minutes', () {
        // Arrange
        const durationInSeconds = 3665; // 1 hour and 1 minute

        // Act
        final result = viewModel.formatDuration(durationInSeconds);

        // Assert
        expect(result, equals('1h 1m'));
      });

      test('should format duration with only hours', () {
        // Arrange
        const durationInSeconds = 3600; // 1 hour exactly

        // Act
        final result = viewModel.formatDuration(durationInSeconds);

        // Assert
        expect(result, equals('1h 0m'));
      });

      test('should format duration with only minutes', () {
        // Arrange
        const durationInSeconds = 300; // 5 minutes

        // Act
        final result = viewModel.formatDuration(durationInSeconds);

        // Assert
        expect(result, equals('5m'));
      });

      test('should format zero duration', () {
        // Arrange
        const durationInSeconds = 0;

        // Act
        final result = viewModel.formatDuration(durationInSeconds);

        // Assert
        expect(result, equals('0m'));
      });

      test('should format multiple hours', () {
        // Arrange
        const durationInSeconds = 7265; // 2 hours and 1 minute

        // Act
        final result = viewModel.formatDuration(durationInSeconds);

        // Assert
        expect(result, equals('2h 1m'));
      });
    });

    group('formatDate', () {
      test('should format today\'s date', () {
        // Arrange
        final today = DateTime.now();
        final dateString = today.toIso8601String();

        // Act
        final result = viewModel.formatDate(dateString);

        // Assert
        expect(result, equals('Today'));
      });

      test('should format yesterday\'s date', () {
        // Arrange
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final dateString = yesterday.toIso8601String();

        // Act
        final result = viewModel.formatDate(dateString);

        // Assert
        expect(result, equals('Yesterday'));
      });

      test('should format date within a week', () {
        // Arrange
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        final dateString = threeDaysAgo.toIso8601String();

        // Act
        final result = viewModel.formatDate(dateString);

        // Assert
        expect(result, equals('3 days ago'));
      });

      test('should format date within a month (weeks)', () {
        // Arrange
        final twoWeeksAgo = DateTime.now().subtract(const Duration(days: 14));
        final dateString = twoWeeksAgo.toIso8601String();

        // Act
        final result = viewModel.formatDate(dateString);

        // Assert
        expect(result, equals('2 weeks ago'));
      });

      test('should format date within a year (months)', () {
        // Arrange
        final twoMonthsAgo = DateTime.now().subtract(const Duration(days: 60));
        final dateString = twoMonthsAgo.toIso8601String();

        // Act
        final result = viewModel.formatDate(dateString);

        // Assert
        expect(result, equals('2 months ago'));
      });

      test('should format date over a year (years)', () {
        // Arrange
        final twoYearsAgo = DateTime.now().subtract(const Duration(days: 730));
        final dateString = twoYearsAgo.toIso8601String();

        // Act
        final result = viewModel.formatDate(dateString);

        // Assert
        expect(result, equals('2 years ago'));
      });

      test('should return original string for invalid date', () {
        // Arrange
        const invalidDateString = 'invalid-date';

        // Act
        final result = viewModel.formatDate(invalidDateString);

        // Assert
        expect(result, equals(invalidDateString));
      });
    });

    group('different podcast IDs', () {
      test('should load podcast with different ID', () {
        // Arrange & Act
        final viewModel2 = PodcastDetailViewModel(podcastId: 2);

        // Assert
        expect(viewModel2.podcast?.id, equals(2));
        expect(viewModel2.podcast?.externalId, equals('ext-2'));
        expect(viewModel2.episodes.length, equals(12));
      });
    });
  });
}
