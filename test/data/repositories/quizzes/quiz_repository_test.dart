import 'package:cribe/core/constants/api_path.dart';
import 'package:cribe/data/models/quiz/quiz_session.dart';
import 'package:cribe/data/models/quiz/quiz_session_detail.dart';
import 'package:cribe/data/models/quiz/submit_answer_request.dart';
import 'package:cribe/data/models/quiz/user_answer.dart';
import 'package:cribe/data/repositories/quizzes/quiz_repository.dart';
import 'package:cribe/data/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'quiz_repository_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late QuizRepository quizRepository;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    quizRepository = QuizRepository(apiService: mockApiService);
  });

  group('QuizRepository', () {
    test('should call init', () async {
      await quizRepository.init();
      // No assertion needed
    });

    test('should call dispose', () async {
      await quizRepository.dispose();
      // No assertion needed
    });

    test('should get or create session', () async {
      final mockSession = QuizSessionDto(
        id: 1,
        userId: 10,
        episodeId: 42,
        episodeName: 'Test Episode',
        podcastName: 'Test Podcast',
        status: 'in_progress',
        totalQuestions: 5,
        answeredQuestions: 0,
        correctAnswers: 0,
        startedAt: DateTime.parse('2024-01-15T10:30:00.000Z'),
        updatedAt: DateTime.parse('2024-01-15T10:30:00.000Z'),
      );

      final mockDetail = QuizSessionDetailDto.fromJson({
        'session': mockSession.toJson(),
        'questions': [],
        'answers': [],
      });

      when(
        mockApiService.post<QuizSessionDetailDto>(
          ApiPath.quizzes,
          any,
          body: anyNamed('body'),
        ),
      ).thenAnswer(
        (_) async => ApiResponse(
          data: mockDetail,
          statusCode: 200,
          message: 'Success',
        ),
      );

      final result = await quizRepository.getOrCreateSession(42);
      expect(result.session.id, 1);
    });

    test('should submit answer', () async {
      final mockAnswer = UserAnswerDto(
        id: 1,
        sessionId: 1,
        questionId: 5,
        userId: 10,
        selectedOptionId: 3,
        isCorrect: true,
        feedback: 'Correct!',
        answeredAt: DateTime.parse('2024-01-15T10:30:00.000Z'),
      );

      when(
        mockApiService.post<UserAnswerDto>(
          ApiPath.quizAnswersById(1),
          any,
          body: anyNamed('body'),
        ),
      ).thenAnswer(
        (_) async => ApiResponse(
          data: mockAnswer,
          statusCode: 200,
          message: 'Success',
        ),
      );

      final result = await quizRepository.submitAnswer(
        sessionId: 1,
        request: SubmitAnswerRequest(questionId: 5, selectedOptionId: 3),
      );

      expect(result.isCorrect, true);
    });

    test('should rethrow error when getOrCreateSession fails', () async {
      when(
        mockApiService.post<QuizSessionDetailDto>(
          ApiPath.quizzes,
          any,
          body: anyNamed('body'),
        ),
      ).thenThrow(Exception('Network error'));

      expect(
        () => quizRepository.getOrCreateSession(42),
        throwsException,
      );
    });

    test('should rethrow error when submitAnswer fails', () async {
      when(
        mockApiService.post<UserAnswerDto>(
          ApiPath.quizAnswersById(1),
          any,
          body: anyNamed('body'),
        ),
      ).thenThrow(Exception('Network error'));

      expect(
        () => quizRepository.submitAnswer(
          sessionId: 1,
          request: SubmitAnswerRequest(questionId: 5, selectedOptionId: 3),
        ),
        throwsException,
      );
    });

    test('should rethrow error when getSessionDetail fails', () async {
      when(
        mockApiService.get<QuizSessionDetailDto>(
          ApiPath.quizById(1),
          any,
        ),
      ).thenThrow(Exception('Network error'));

      expect(
        () => quizRepository.getSessionDetail(1),
        throwsException,
      );
    });

    test('should rethrow error when getUserSessions fails', () async {
      when(
        mockApiService.get(
          ApiPath.quizzes,
          any,
        ),
      ).thenThrow(Exception('Network error'));

      expect(
        () => quizRepository.getUserSessions(),
        throwsException,
      );
    });

    test('should rethrow error when completeQuiz fails', () async {
      when(
        mockApiService.patch<QuizSessionDto>(
          ApiPath.quizStatusById(1),
          any,
          body: anyNamed('body'),
        ),
      ).thenThrow(Exception('Network error'));

      expect(
        () => quizRepository.completeQuiz(1),
        throwsException,
      );
    });
  });
}
