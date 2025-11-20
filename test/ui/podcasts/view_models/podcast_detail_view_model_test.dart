import 'package:cribe/data/repositories/podcasts/podcast_repository.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/ui/podcasts/view_models/podcast_detail_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'podcast_detail_view_model_test.mocks.dart';

@GenerateMocks([PodcastRepository])
void main() {
  late PodcastDetailViewModel viewModel;
  late MockPodcastRepository mockRepository;
  const testPodcastId = 1;

  final mockPodcast = Podcast(
    id: testPodcastId,
    externalId: 'test-podcast-1',
    authorName: 'Test Author',
    name: 'Test Podcast',
    description: 'Test Description',
    imageUrl: 'test.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    episodes: [
      Episode(
        id: 1,
        externalId: 'test-episode-1',
        podcastId: testPodcastId,
        name: 'Test Episode',
        description: 'Test Episode Description',
        audioUrl: 'test.mp3',
        imageUrl: 'test-ep.jpg',
        datePublished: DateTime.now().toIso8601String(),
        duration: 3600,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ],
  );

  setUp(() {
    mockRepository = MockPodcastRepository();
    when(mockRepository.getPodcastById(testPodcastId))
        .thenAnswer((_) async => mockPodcast);
    viewModel = PodcastDetailViewModel(
      podcastId: testPodcastId,
      repository: mockRepository,
    );
  });

  group('PodcastDetailViewModel', () {
    group('initial state', () {
      test('should initialize and start loading', () async {
        await Future.delayed(const Duration(milliseconds: 10));
        expect(viewModel.isLoading, isFalse);
      });

      test('should load podcast with repository', () async {
        verify(mockRepository.getPodcastById(testPodcastId)).called(1);
      });

      test('should have all required episode fields', () {
        // Assert
        for (final formattedEpisode in viewModel.episodes) {
          final episode = formattedEpisode.episode;
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

      test('FormattedEpisode should have formatted properties', () {
        // Assert
        for (final formattedEpisode in viewModel.episodes) {
          expect(formattedEpisode.duration, isNotEmpty);
          expect(formattedEpisode.datePublished, isNotEmpty);
        }
      });

      test('episodes should be ordered by date (newest first)', () {
        // Assert
        for (int i = 0; i < viewModel.episodes.length - 1; i++) {
          final currentDate =
              DateTime.parse(viewModel.episodes[i].episode.datePublished);
          final nextDate =
              DateTime.parse(viewModel.episodes[i + 1].episode.datePublished);
          expect(
            currentDate.isAfter(nextDate) ||
                currentDate.isAtSameMomentAs(nextDate),
            isTrue,
          );
        }
      });
    });

    group('FormattedEpisode', () {
      test('should format duration correctly', () {
        final formattedEpisode = viewModel.episodes.first;
        expect(formattedEpisode.duration, equals('1h 0m'));
      });

      test('should format date correctly', () {
        final formattedEpisode = viewModel.episodes.first;
        expect(formattedEpisode.datePublished, isNotEmpty);
      });
    });

    group('removed formatting methods', () {
      test('should load podcast with different ID', () async {
        final mockRepository2 = MockPodcastRepository();
        final mockPodcast2 = Podcast(
          id: 2,
          externalId: 'test-podcast-2',
          authorName: 'Test Author 2',
          name: 'Test Podcast 2',
          description: 'Test Description 2',
          imageUrl: 'test2.jpg',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(mockRepository2.getPodcastById(2))
            .thenAnswer((_) async => mockPodcast2);
        final viewModel2 = PodcastDetailViewModel(
          podcastId: 2,
          repository: mockRepository2,
        );

        await Future.delayed(const Duration(milliseconds: 50));

        expect(viewModel2.podcast?.id, equals(2));
      });
    });
  });
}
