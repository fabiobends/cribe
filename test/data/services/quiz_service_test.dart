import 'package:cribe/data/models/quiz/quiz_session.dart';
import 'package:cribe/data/models/quiz/quiz_session_detail.dart';
import 'package:cribe/data/models/quiz/user_answer.dart';
import 'package:cribe/data/repositories/quizzes/quiz_repository.dart';
import 'package:cribe/data/services/quiz_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'quiz_service_test.mocks.dart';

@GenerateMocks([QuizRepository])
void main() {
  late QuizService service;
  late MockQuizRepository mockRepository;

  setUp(() {
    mockRepository = MockQuizRepository();
    service = QuizService(repository: mockRepository);
  });

  group('QuizService', () {
    test('should start quiz and return domain model', () async {
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

      when(mockRepository.getOrCreateSession(42))
          .thenAnswer((_) async => mockDetail);

      final result = await service.startQuiz(42);

      expect(result.session.id, 1);
      expect(result.questions, isEmpty);
      verify(mockRepository.getOrCreateSession(42)).called(1);
    });

    test('should get session detail by id', () async {
      final mockSession = QuizSessionDto(
        id: 5,
        userId: 10,
        episodeId: 42,
        episodeName: 'Test Episode',
        podcastName: 'Test Podcast',
        status: 'completed',
        totalQuestions: 5,
        answeredQuestions: 5,
        correctAnswers: 4,
        startedAt: DateTime.parse('2024-01-15T10:30:00.000Z'),
        completedAt: DateTime.parse('2024-01-15T11:00:00.000Z'),
        updatedAt: DateTime.parse('2024-01-15T11:00:00.000Z'),
      );

      final mockDetail = QuizSessionDetailDto.fromJson({
        'session': mockSession.toJson(),
        'questions': [],
        'answers': [],
      });

      when(mockRepository.getSessionDetail(5))
          .thenAnswer((_) async => mockDetail);

      final result = await service.getSessionDetail(5);

      expect(result.session.id, 5);
      expect(result.session.status.name, 'completed');
      verify(mockRepository.getSessionDetail(5)).called(1);
    });

    test('should submit answer and return domain model', () async {
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
        mockRepository.submitAnswer(
          sessionId: 1,
          request: anyNamed('request'),
        ),
      ).thenAnswer((_) async => mockAnswer);

      final result = await service.submitAnswer(
        sessionId: 1,
        questionId: 5,
        selectedOptionId: 3,
      );

      expect(result.isCorrect, true);
      expect(result.feedback, 'Correct!');
      verify(
        mockRepository.submitAnswer(
          sessionId: 1,
          request: anyNamed('request'),
        ),
      ).called(1);
    });

    test('should complete quiz and return domain model', () async {
      final mockSession = QuizSessionDto(
        id: 1,
        userId: 10,
        episodeId: 42,
        episodeName: 'Test Episode',
        podcastName: 'Test Podcast',
        status: 'completed',
        totalQuestions: 5,
        answeredQuestions: 5,
        correctAnswers: 4,
        startedAt: DateTime.parse('2024-01-15T10:30:00.000Z'),
        completedAt: DateTime.parse('2024-01-15T11:00:00.000Z'),
        updatedAt: DateTime.parse('2024-01-15T11:00:00.000Z'),
      );

      when(mockRepository.completeQuiz(1)).thenAnswer((_) async => mockSession);

      final result = await service.completeQuiz(1);

      expect(result.status.name, 'completed');
      expect(result.correctAnswers, 4);
      verify(mockRepository.completeQuiz(1)).called(1);
    });

    test('should get user sessions', () async {
      when(mockRepository.getUserSessions()).thenAnswer((_) async => []);

      final result = await service.getUserSessions();

      expect(result, isEmpty);
      verify(mockRepository.getUserSessions()).called(1);
    });
  });
}
