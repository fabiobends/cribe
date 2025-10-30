import 'package:cribe/core/constants/ui_state.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/ui/shared/view_models/base_view_model.dart';

class PodcastsListViewModel extends BaseViewModel {
  PodcastsListViewModel() {
    logger.info('PodcastsListViewModel initialized');
    _loadMockPodcasts();
  }

  UiState _state = UiState.initial;
  String _errorMessage = '';
  List<Podcast> _podcasts = [];

  UiState get state => _state;
  String get errorMessage => _errorMessage;
  bool get hasError => _state == UiState.error;
  List<Podcast> get podcasts => _podcasts;

  void _loadMockPodcasts() {
    logger.info('Loading mock podcasts');
    _setState(UiState.loading);

    try {
      // Mock podcasts data
      _podcasts = [
        Podcast(
          id: 1,
          authorName: 'Joe Rogan',
          name: 'The Joe Rogan Experience',
          imageUrl: 'https://picsum.photos/200/200?random=1',
          description:
              'The official podcast of comedian Joe Rogan. Long form conversations with the best minds in the world.',
          externalId: 'ext-1',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
        ),
        Podcast(
          id: 2,
          authorName: 'Lex Fridman',
          name: 'Lex Fridman Podcast',
          imageUrl: 'https://picsum.photos/200/200?random=2',
          description:
              'Conversations about science, technology, history, philosophy and the nature of intelligence.',
          externalId: 'ext-2',
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          updatedAt: DateTime.now(),
        ),
        Podcast(
          id: 3,
          authorName: 'Tim Ferriss',
          name: 'The Tim Ferriss Show',
          imageUrl: 'https://picsum.photos/200/200?random=3',
          description:
              'Tim Ferriss deconstructs world-class performers from eclectic areas.',
          externalId: 'ext-3',
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
          updatedAt: DateTime.now(),
        ),
        Podcast(
          id: 4,
          authorName: 'NPR',
          name: 'How I Built This',
          imageUrl: 'https://picsum.photos/200/200?random=4',
          description:
              'A podcast about innovators, entrepreneurs, and idealists, and the stories behind the movements they built.',
          externalId: 'ext-4',
          createdAt: DateTime.now().subtract(const Duration(days: 120)),
          updatedAt: DateTime.now(),
        ),
        Podcast(
          id: 5,
          authorName: 'Naval Ravikant',
          name: 'Naval',
          imageUrl: 'https://picsum.photos/200/200?random=5',
          description:
              'Naval on startups, angel investing, crypto, and life philosophy.',
          externalId: 'ext-5',
          createdAt: DateTime.now().subtract(const Duration(days: 150)),
          updatedAt: DateTime.now(),
        ),
      ];

      logger.info(
          'Mock podcasts loaded successfully: ${_podcasts.length} podcasts',);
      _setState(UiState.success);
    } catch (e) {
      logger.error('Failed to load mock podcasts', error: e);
      _errorMessage = 'Failed to load podcasts';
      _setState(UiState.error);
    }
  }

  void clearError() {
    if (_state == UiState.error) {
      logger.debug('Clearing error state');
      _setState(UiState.initial);
    }
  }

  void _setState(UiState newState) {
    logger.debug('State changed: $_state -> $newState');
    _state = newState;
    setLoading(newState == UiState.loading);
    if (newState == UiState.error) {
      setError(_errorMessage);
    } else {
      setError(null);
    }
    notifyListeners();
  }
}
