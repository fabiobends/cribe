import 'package:cribe/core/constants/api_path.dart';
import 'package:cribe/data/models/quiz/quiz_session.dart';
import 'package:cribe/data/models/quiz/quiz_session_detail.dart';
import 'package:cribe/data/models/quiz/start_session_request.dart';
import 'package:cribe/data/models/quiz/submit_answer_request.dart';
import 'package:cribe/data/models/quiz/update_session_status_request.dart';
import 'package:cribe/data/models/quiz/user_answer.dart';
import 'package:cribe/data/repositories/base_repository.dart';

class QuizRepository extends BaseRepository {
  QuizRepository({super.apiService}) {
    logger.info('QuizRepository initialized');
  }

  @override
  Future<void> init() async {
    logger.debug('QuizRepository initialized');
  }

  @override
  Future<void> dispose() async {
    logger.debug('QuizRepository disposed');
  }

  /// Get or create a quiz session for an episode
  Future<QuizSessionDetailDto> getOrCreateSession(int episodeId) async {
    logger.info(
      'Starting getOrCreateSession request',
      extra: {'episodeId': episodeId},
    );

    try {
      final request = StartSessionRequest(episodeId: episodeId);
      final response = await apiService!.post<QuizSessionDetailDto>(
        ApiPath.quizzes,
        QuizSessionDetailDto.fromJson,
        body: request.toJson(),
      );

      logger.info(
        'getOrCreateSession request successful',
        extra: {
          'sessionId': response.data.session.id,
          'questionsCount': response.data.questions.length,
          'answersCount': response.data.answers.length,
        },
      );
      return response.data;
    } catch (e) {
      logger.error(
        'getOrCreateSession request failed',
        error: e,
        extra: {'episodeId': episodeId},
      );
      rethrow;
    }
  }

  /// Get session details by ID with all questions and answers
  Future<QuizSessionDetailDto> getSessionDetail(int sessionId) async {
    logger.info(
      'Starting getSessionDetail request',
      extra: {'sessionId': sessionId},
    );

    try {
      final response = await apiService!.get<QuizSessionDetailDto>(
        ApiPath.quizById(sessionId),
        QuizSessionDetailDto.fromJson,
      );

      logger.info('getSessionDetail request successful');
      return response.data;
    } catch (e) {
      logger.error(
        'getSessionDetail request failed',
        error: e,
        extra: {'sessionId': sessionId},
      );
      rethrow;
    }
  }

  /// Get all quiz sessions for the user
  Future<List<QuizSessionDetailDto>> getUserSessions() async {
    logger.info('Starting getUserSessions request');

    try {
      final response = await apiService!.get(
        ApiPath.quizzes,
        (json) => (json as List)
            .map((e) => QuizSessionDetailDto.fromJson(e))
            .toList(),
      );

      logger.info(
        'getUserSessions request successful',
        extra: {
          'count': response.data.length,
        },
      );
      return response.data;
    } catch (e) {
      logger.error('getUserSessions request failed', error: e);
      rethrow;
    }
  }

  /// Submit an answer to a question
  Future<UserAnswerDto> submitAnswer({
    required int sessionId,
    required SubmitAnswerRequest request,
  }) async {
    logger.info(
      'Starting submitAnswer request',
      extra: {'sessionId': sessionId},
    );

    try {
      final response = await apiService!.post<UserAnswerDto>(
        ApiPath.quizAnswersById(sessionId),
        UserAnswerDto.fromJson,
        body: request.toJson(),
      );

      logger.info('submitAnswer request successful');
      return response.data;
    } catch (e) {
      logger.error(
        'submitAnswer request failed',
        error: e,
        extra: {'sessionId': sessionId},
      );
      rethrow;
    }
  }

  /// Complete the quiz session
  Future<QuizSessionDto> completeQuiz(int sessionId) async {
    logger.info(
      'Starting completeQuiz request',
      extra: {'sessionId': sessionId},
    );

    try {
      final request = UpdateSessionStatusRequest(status: 'completed');
      final response = await apiService!.patch<QuizSessionDto>(
        ApiPath.quizStatusById(sessionId),
        QuizSessionDto.fromJson,
        body: request.toJson(),
      );

      logger.info('completeQuiz request successful');
      return response.data;
    } catch (e) {
      logger.error(
        'completeQuiz request failed',
        error: e,
        extra: {'sessionId': sessionId},
      );
      rethrow;
    }
  }
}
