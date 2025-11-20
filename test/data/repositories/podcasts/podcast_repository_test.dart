import 'package:cribe/core/constants/api_path.dart';
import 'package:cribe/data/repositories/podcasts/podcast_repository.dart';
import 'package:cribe/data/services/api_service.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'podcast_repository_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late PodcastRepository podcastRepository;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    podcastRepository = PodcastRepository(apiService: mockApiService);
  });

  group('PodcastRepository', () {
    group('getPodcasts', () {
      test('should call ApiService.get and update podcasts list', () async {
        // Arrange
        final mockPodcasts = [
          Podcast(
            id: 1,
            authorName: 'Author 1',
            name: 'Podcast 1',
            imageUrl: 'image1.jpg',
            description: 'Description 1',
            externalId: 'ext1',
            createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
            updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
          ),
          Podcast(
            id: 2,
            authorName: 'Author 2',
            name: 'Podcast 2',
            imageUrl: 'image2.jpg',
            description: 'Description 2',
            externalId: 'ext2',
            createdAt: DateTime.parse('2024-01-03T00:00:00.000Z'),
            updatedAt: DateTime.parse('2024-01-04T00:00:00.000Z'),
          ),
        ];

        final mockApiResponse = ApiResponse<List<Podcast>>(
          data: mockPodcasts,
          statusCode: 200,
          message: 'Success',
        );

        when(
          mockApiService.get<List<Podcast>>(
            ApiPath.podcasts,
            any,
          ),
        ).thenAnswer((_) async => mockApiResponse);

        // Act
        await podcastRepository.getPodcasts();

        // Assert
        verify(mockApiService.get<List<Podcast>>(ApiPath.podcasts, any));
        expect(podcastRepository.podcasts, equals(mockPodcasts));
        expect(podcastRepository.podcasts, hasLength(2));
      });

      test('should handle empty podcasts list', () async {
        // Arrange
        final mockApiResponse = ApiResponse<List<Podcast>>(
          data: [],
          statusCode: 200,
          message: 'Success',
        );

        when(
          mockApiService.get<List<Podcast>>(
            ApiPath.podcasts,
            any,
          ),
        ).thenAnswer((_) async => mockApiResponse);

        // Act
        await podcastRepository.getPodcasts();

        // Assert
        expect(podcastRepository.podcasts, isEmpty);
      });

      test('should rethrow exception when ApiService.get fails', () async {
        // Arrange
        when(
          mockApiService.get<List<Podcast>>(
            ApiPath.podcasts,
            any,
          ),
        ).thenThrow(ApiException('Failed to fetch podcasts', statusCode: 500));

        // Act & Assert
        expect(
          () => podcastRepository.getPodcasts(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getPodcastById', () {
      test('should call ApiService.get with correct id', () async {
        // Arrange
        const podcastId = 1;
        final mockPodcast = Podcast(
          id: podcastId,
          authorName: 'Author',
          name: 'Podcast',
          imageUrl: 'image.jpg',
          description: 'Description',
          externalId: 'ext',
          createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
          updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
        );

        final mockApiResponse = ApiResponse<Podcast>(
          data: mockPodcast,
          statusCode: 200,
          message: 'Success',
        );

        when(
          mockApiService.get<Podcast>(
            ApiPath.podcastById(podcastId),
            any,
          ),
        ).thenAnswer((_) async => mockApiResponse);

        // Act
        final result = await podcastRepository.getPodcastById(podcastId);

        // Assert
        verify(
          mockApiService.get<Podcast>(ApiPath.podcastById(podcastId), any),
        );
        expect(result, equals(mockPodcast));
      });

      test('should rethrow exception when ApiService.get fails', () async {
        // Arrange
        const podcastId = 1;

        when(
          mockApiService.get<Podcast>(
            ApiPath.podcastById(podcastId),
            any,
          ),
        ).thenThrow(ApiException('Podcast not found', statusCode: 404));

        // Act & Assert
        expect(
          () => podcastRepository.getPodcastById(podcastId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getEpisodesByPodcastId', () {
      test('should return episodes from podcast', () async {
        // Arrange
        const podcastId = 1;
        final mockEpisodes = [
          Episode(
            id: 1,
            externalId: 'ep1',
            podcastId: podcastId,
            name: 'Episode 1',
            description: 'Description 1',
            audioUrl: 'audio1.mp3',
            imageUrl: 'image1.jpg',
            datePublished: '2024-01-01',
            duration: 3600,
            createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
            updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
          ),
        ];

        final mockPodcast = Podcast(
          id: podcastId,
          authorName: 'Author',
          name: 'Podcast',
          imageUrl: 'image.jpg',
          description: 'Description',
          externalId: 'ext',
          createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
          updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
          episodes: mockEpisodes,
        );

        final mockApiResponse = ApiResponse<Podcast>(
          data: mockPodcast,
          statusCode: 200,
          message: 'Success',
        );

        when(
          mockApiService.get<Podcast>(
            ApiPath.podcastById(podcastId),
            any,
          ),
        ).thenAnswer((_) async => mockApiResponse);

        // Act
        final result =
            await podcastRepository.getEpisodesByPodcastId(podcastId);

        // Assert
        expect(result, equals(mockEpisodes));
        expect(result, hasLength(1));
      });

      test('should return empty list when podcast has no episodes', () async {
        // Arrange
        const podcastId = 1;
        final mockPodcast = Podcast(
          id: podcastId,
          authorName: 'Author',
          name: 'Podcast',
          imageUrl: 'image.jpg',
          description: 'Description',
          externalId: 'ext',
          createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
          updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
        );

        final mockApiResponse = ApiResponse<Podcast>(
          data: mockPodcast,
          statusCode: 200,
          message: 'Success',
        );

        when(
          mockApiService.get<Podcast>(
            ApiPath.podcastById(podcastId),
            any,
          ),
        ).thenAnswer((_) async => mockApiResponse);

        // Act
        final result =
            await podcastRepository.getEpisodesByPodcastId(podcastId);

        // Assert
        expect(result, isEmpty);
      });

      test('should rethrow exception when getPodcastById fails', () async {
        // Arrange
        const podcastId = 1;

        when(
          mockApiService.get<Podcast>(
            ApiPath.podcastById(podcastId),
            any,
          ),
        ).thenThrow(ApiException('Podcast not found', statusCode: 404));

        // Act & Assert
        expect(
          () => podcastRepository.getEpisodesByPodcastId(podcastId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('setPodcasts', () {
      test('should update podcasts list', () {
        // Arrange
        final mockPodcasts = [
          Podcast(
            id: 1,
            authorName: 'Author',
            name: 'Podcast',
            imageUrl: 'image.jpg',
            description: 'Description',
            externalId: 'ext',
            createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
            updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
          ),
        ];

        // Act
        podcastRepository.setPodcasts(mockPodcasts);

        // Assert
        expect(podcastRepository.podcasts, equals(mockPodcasts));
      });
    });

    group('lifecycle methods', () {
      test('should call init method', () async {
        // Act
        await podcastRepository.init();

        // Assert - No specific assertion needed, just testing code path
      });

      test('should call dispose method', () async {
        // Act
        await podcastRepository.dispose();

        // Assert - No specific assertion needed, just testing code path
      });
    });
  });
}
