import 'package:cribe/data/services/quiz_service.dart';
import 'package:cribe/domain/models/quiz.dart';
import 'package:cribe/ui/shared/view_models/base_view_model.dart';

class QuizSessionsViewModel extends BaseViewModel {
  final QuizService _service;

  QuizSessionsViewModel({required QuizService service})
      : _service = service,
        super() {
    logger.info('QuizSessionsViewModel initialized');
    loadQuizSessions();
  }

  List<QuizData> _quizSessions = [];

  /// Getter for quiz sessions (domain models)
  List<QuizData> get quizSessions => _quizSessions;

  /// Get count of quiz sessions
  int get sessionCount => _quizSessions.length;

  /// Load all quiz sessions for the current user
  Future<void> loadQuizSessions() async {
    logger.info('Loading quiz sessions');
    setLoading(true);
    setError(null);

    try {
      _quizSessions = await _service.getUserQuizSessions();
      logger.info(
        'Quiz sessions loaded successfully',
        extra: {
          'count': _quizSessions.length,
        },
      );
      notifyListeners();
    } catch (e) {
      final errorMessage = 'Failed to load quiz sessions';
      logger.error(errorMessage, error: e);
      setError(errorMessage);
      _quizSessions = [];
    } finally {
      setLoading(false);
    }
  }

  /// Refresh quiz sessions
  Future<void> refresh() async {
    logger.info('Refreshing quiz sessions');
    await loadQuizSessions();
  }
}
