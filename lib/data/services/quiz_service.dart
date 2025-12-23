import 'package:cribe/data/models/quiz/quiz_session_detail.dart';
import 'package:cribe/data/models/quiz/submit_answer_request.dart';
import 'package:cribe/data/repositories/quizzes/quiz_repository.dart';
import 'package:cribe/data/services/base_service.dart';
import 'package:cribe/domain/models/quiz.dart';

/// Service for managing quiz operations and data transformation
class QuizService extends BaseService {
  final QuizRepository _repository;

  QuizService({required QuizRepository repository}) : _repository = repository {
    logger.info('QuizService initialized');
  }

  @override
  Future<void> init() async {
    logger.debug('QuizService init called');
  }

  @override
  Future<void> dispose() async {
    logger.debug('QuizService dispose called');
  }

  /// Get or create quiz session with complete details
  Future<QuizData> startQuiz(int episodeId) async {
    logger.info('Starting quiz for episode $episodeId');

    final sessionDetail = await _repository.getOrCreateSession(episodeId);

    logger.info(
      'Quiz session loaded',
      extra: {
        'sessionId': sessionDetail.session.id,
        'questions': sessionDetail.questions.length,
        'answers': sessionDetail.answers.length,
      },
    );

    return sessionDetail.toDomain();
  }

  /// Get session details by ID
  Future<QuizData> getSessionDetail(int sessionId) async {
    logger.info('Getting session detail for session $sessionId');

    final sessionDetail = await _repository.getSessionDetail(sessionId);
    return sessionDetail.toDomain();
  }

  /// Get all user's quiz sessions
  Future<List<QuizSessionDetailDto>> getUserSessions() async {
    logger.info('Getting user sessions');

    final summaries = await _repository.getUserSessions();
    return summaries;
  }

  /// Get all user's quiz sessions as domain models
  Future<List<QuizData>> getUserQuizSessions() async {
    logger.info('Getting user quiz sessions');

    final dtos = await _repository.getUserSessions();
    final sessions = dtos.map((dto) => dto.toDomain()).toList();

    logger.info(
      'User quiz sessions loaded',
      extra: {'count': sessions.length},
    );

    return sessions;
  }

  Future<UserAnswer> submitAnswer({
    required int sessionId,
    required int questionId,
    int? selectedOptionId,
    String? textAnswer,
  }) async {
    final request = SubmitAnswerRequest(
      questionId: questionId,
      selectedOptionId: selectedOptionId,
      textAnswer: textAnswer,
    );

    final dto = await _repository.submitAnswer(
      sessionId: sessionId,
      request: request,
    );

    return dto.toDomain();
  }

  Future<QuizSession> completeQuiz(int sessionId) async {
    final dto = await _repository.completeQuiz(sessionId);
    return dto.toDomain();
  }
}
