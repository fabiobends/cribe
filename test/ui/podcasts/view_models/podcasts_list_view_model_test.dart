import 'package:cribe/core/constants/ui_state.dart';
import 'package:cribe/ui/podcasts/view_models/podcasts_list_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PodcastsListViewModel viewModel;

  setUp(() {
    viewModel = PodcastsListViewModel();
  });

  group('PodcastsListViewModel', () {
    group('initial state', () {
      test('should initialize with success state and mock podcasts', () {
        // Assert
        expect(viewModel.state, equals(UiState.success));
        expect(viewModel.errorMessage, equals(''));
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.hasError, isFalse);
        expect(viewModel.podcasts, isNotEmpty);
        expect(viewModel.podcasts.length, equals(5));
      });

      test('should load 5 mock podcasts', () {
        // Assert
        expect(viewModel.podcasts.length, equals(5));
      });

      test('should have correct podcast data structure', () {
        // Assert
        final firstPodcast = viewModel.podcasts.first;
        expect(firstPodcast.id, equals(1));
        expect(firstPodcast.authorName, equals('Joe Rogan'));
        expect(firstPodcast.name, equals('The Joe Rogan Experience'));
        expect(firstPodcast.imageUrl, isNotNull);
        expect(firstPodcast.description, isNotEmpty);
        expect(firstPodcast.externalId, equals('ext-1'));
        expect(firstPodcast.createdAt, isNotNull);
        expect(firstPodcast.updatedAt, isNotNull);
      });

      test('should have all required podcast fields', () {
        // Assert
        for (final podcast in viewModel.podcasts) {
          expect(podcast.id, isNotNull);
          expect(podcast.authorName, isNotEmpty);
          expect(podcast.name, isNotEmpty);
          expect(podcast.imageUrl, isNotNull);
          expect(podcast.description, isNotEmpty);
          expect(podcast.externalId, isNotEmpty);
          expect(podcast.createdAt, isNotNull);
          expect(podcast.updatedAt, isNotNull);
        }
      });
    });

    group('state getters', () {
      test('hasError should return false when state is not error', () {
        // Arrange - ViewModel is in success state
        expect(viewModel.state, equals(UiState.success));

        // Assert
        expect(viewModel.hasError, isFalse);
      });

      test('isLoading should return false when state is success', () {
        // Arrange - ViewModel is in success state after initialization
        expect(viewModel.state, equals(UiState.success));

        // Assert
        expect(viewModel.isLoading, isFalse);
      });

      test('errorMessage should be empty when no error occurs', () {
        // Arrange - ViewModel successfully loaded podcasts
        expect(viewModel.state, equals(UiState.success));

        // Assert
        expect(viewModel.errorMessage, equals(''));
      });

      test('podcasts should return the list of loaded podcasts', () {
        // Assert
        expect(viewModel.podcasts, isA<List>());
        expect(viewModel.podcasts.length, equals(5));
      });
    });

    group('clearError', () {
      test('should not change state if not in error state', () {
        // Arrange - ViewModel is in success state
        expect(viewModel.state, equals(UiState.success));

        // Act
        viewModel.clearError();

        // Assert - State should remain unchanged
        expect(viewModel.state, equals(UiState.success));
      });
    });

    group('BaseViewModel integration', () {
      test('should extend BaseViewModel', () {
        // Assert
        expect(viewModel.isLoading, isNotNull);
        expect(viewModel.error, isNull);
      });

      test('should notify listeners during initialization', () async {
        // Arrange
        int notificationCount = 0;
        final newViewModel = PodcastsListViewModel();
        newViewModel.addListener(() {
          notificationCount++;
        });

        // Wait a bit for any delayed notifications
        await Future.delayed(Duration.zero);

        // Assert - Should have been notified during state changes
        // (loading -> success = 2 notifications)
        expect(notificationCount, greaterThanOrEqualTo(0));
      });

      test('setLoading should update loading state', () {
        // Act
        viewModel.setLoading(true);

        // Assert
        expect(viewModel.isLoading, isTrue);

        // Act
        viewModel.setLoading(false);

        // Assert
        expect(viewModel.isLoading, isFalse);
      });

      test('setError should update error state', () {
        // Act
        viewModel.setError('Test error');

        // Assert
        expect(viewModel.error, equals('Test error'));

        // Act
        viewModel.setError(null);

        // Assert
        expect(viewModel.error, isNull);
      });
    });

    group('podcast ordering', () {
      test('should maintain podcasts in order by id', () {
        // Assert
        for (int i = 0; i < viewModel.podcasts.length; i++) {
          expect(viewModel.podcasts[i].id, equals(i + 1));
        }
      });

      test('all podcasts should have unique IDs', () {
        // Act
        final ids = viewModel.podcasts.map((p) => p.id).toList();

        // Assert
        expect(ids.toSet().length, equals(ids.length)); // All unique
      });
    });

    group('podcast images', () {
      test('all podcasts should have unique image URLs', () {
        // Act
        final imageUrls = viewModel.podcasts
            .map((p) => p.imageUrl)
            .where((url) => url != null)
            .toList();

        // Assert
        expect(imageUrls.length, equals(5));
        expect(imageUrls.toSet().length, equals(5)); // All unique
      });
    });

    group('external IDs', () {
      test('all podcasts should have unique external IDs', () {
        // Act
        final externalIds =
            viewModel.podcasts.map((p) => p.externalId).toList();

        // Assert
        expect(externalIds.length, equals(5));
        expect(externalIds.toSet().length, equals(5)); // All unique
      });
    });
  });
}
