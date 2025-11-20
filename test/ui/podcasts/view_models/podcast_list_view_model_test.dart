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

    group('BaseViewModel integration', () {
      test('should extend BaseViewModel', () {
        expect(viewModel.isLoading, isNotNull);
        expect(viewModel.error, isNull);
      });

      test('setLoading should update loading state', () {
        viewModel.setLoading(true);
        expect(viewModel.isLoading, isTrue);

        viewModel.setLoading(false);
        expect(viewModel.isLoading, isFalse);
      });

      test('setError should update error state', () {
        viewModel.setError('Test error');
        expect(viewModel.error, equals('Test error'));

        viewModel.setError(null);
        expect(viewModel.error, isNull);
      });
    });
  });
}
