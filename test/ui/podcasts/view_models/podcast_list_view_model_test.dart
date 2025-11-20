import 'package:cribe/data/repositories/podcasts/podcast_repository.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/ui/podcasts/view_models/podcast_list_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'podcast_list_view_model_test.mocks.dart';

@GenerateMocks([PodcastRepository])
void main() {
  late PodcastListViewModel viewModel;
  late MockPodcastRepository mockRepository;

  setUp(() {
    mockRepository = MockPodcastRepository();
    when(mockRepository.podcasts).thenReturn([]);
    viewModel = PodcastListViewModel(repository: mockRepository);
  });

  group('PodcastListViewModel', () {
    group('initial state', () {
      test('should initialize with empty podcasts', () {
        expect(viewModel.podcasts, isEmpty);
      });

      test('should have correct podcast data from repository', () {
        final mockPodcasts = [
          Podcast(
            id: 1,
            externalId: 'test-1',
            authorName: 'Test Author',
            name: 'Test Podcast',
            description: 'Test Description',
            imageUrl: 'test.jpg',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        when(mockRepository.podcasts).thenReturn(mockPodcasts);

        expect(viewModel.podcasts.length, equals(1));
        expect(viewModel.podcasts.first.name, equals('Test Podcast'));
      });
    });

    group('loadPodcasts', () {
      test('should call getPodcasts on repository', () async {
        reset(mockRepository);
        when(mockRepository.getPodcasts()).thenAnswer((_) async {});
        when(mockRepository.podcasts).thenReturn([]);

        await viewModel.loadPodcasts();

        verify(mockRepository.getPodcasts()).called(1);
      });

      test('should set loading state during load', () async {
        when(mockRepository.getPodcasts()).thenAnswer((_) async {});

        expect(viewModel.isLoading, isFalse);
        final future = viewModel.loadPodcasts();
        expect(viewModel.isLoading, isTrue);
        await future;
        expect(viewModel.isLoading, isFalse);
      });

      test('should set error when load fails', () async {
        when(mockRepository.getPodcasts())
            .thenThrow(Exception('Network error'));

        await viewModel.loadPodcasts();

        expect(viewModel.error, equals('Failed to load podcasts'));
        expect(viewModel.isLoading, isFalse);
      });
    });

    group('refresh', () {
      test('should call getPodcasts on repository', () async {
        reset(mockRepository);
        when(mockRepository.getPodcasts()).thenAnswer((_) async {});
        when(mockRepository.podcasts).thenReturn([]);

        await viewModel.refresh();

        verify(mockRepository.getPodcasts()).called(1);
      });

      test('should not set loading state during refresh', () async {
        when(mockRepository.getPodcasts()).thenAnswer((_) async {});

        final initialLoadingState = viewModel.isLoading;
        await viewModel.refresh();

        expect(viewModel.isLoading, equals(initialLoadingState));
      });

      test('should set error when refresh fails', () async {
        when(mockRepository.getPodcasts())
            .thenThrow(Exception('Network error'));

        await viewModel.refresh();

        expect(viewModel.error, equals('Failed to refresh podcasts'));
      });
    });
  });
}
