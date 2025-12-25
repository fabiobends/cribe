import 'package:cribe/data/services/quiz_service.dart';
import 'package:cribe/domain/models/quiz.dart';
import 'package:cribe/ui/quiz/view_models/quiz_sessions_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'quiz_sessions_view_model_test.mocks.dart';

@GenerateMocks([QuizService])
void main() {
  late QuizSessionsViewModel viewModel;
  late MockQuizService mockService;

  setUp(() {
    mockService = MockQuizService();
  });

  List<QuizData> createMockQuizSessions({
    int count = 2,
    bool completed = false,
  }) {
    return List.generate(
      count,
      (index) => QuizData(
        session: QuizSession(
          id: index + 1,
          userId: 1,
          episodeId: index + 1,
          episodeName: 'Episode ${index + 1}',
          podcastName: 'Podcast ${index + 1}',
          status:
              completed ? SessionStatus.completed : SessionStatus.inProgress,
          totalQuestions: 5,
          answeredQuestions: completed ? 5 : index + 1,
          correctAnswers: completed ? 4 : index,
          startedAt: DateTime.now().subtract(Duration(days: index + 1)),
        ),
        questions: [],
      ),
    );
  }

  group('QuizSessionsViewModel', () {
    group('initialization', () {
      test('should load quiz sessions on initialization', () async {
        // Arrange
        final mockSessions = createMockQuizSessions();
        when(mockService.getUserQuizSessions())
            .thenAnswer((_) async => mockSessions);

        // Act
        viewModel = QuizSessionsViewModel(service: mockService);
        await Future.delayed(Duration.zero); // Allow async init to complete

        // Assert
        verify(mockService.getUserQuizSessions()).called(1);
      });
    });

    group('loadQuizSessions', () {
      test('should load quiz sessions successfully', () async {
        // Arrange
        final mockSessions = createMockQuizSessions(count: 3);
        when(mockService.getUserQuizSessions())
            .thenAnswer((_) async => mockSessions);
        viewModel = QuizSessionsViewModel(service: mockService);

        // Act
        await viewModel.loadQuizSessions();

        // Assert
        expect(viewModel.quizSessions.length, equals(3));
        expect(viewModel.sessionCount, equals(3));
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.error, isNull);
      });

      test('should set loading state during load', () async {
        // Arrange
        when(mockService.getUserQuizSessions()).thenAnswer(
          (_) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return [];
          },
        );
        viewModel = QuizSessionsViewModel(service: mockService);

        // Act
        final future = viewModel.loadQuizSessions();
        await Future.delayed(Duration.zero);

        // Assert - loading should be true during execution
        expect(viewModel.isLoading, isTrue);

        await future;
        expect(viewModel.isLoading, isFalse);
      });

      test('should set error when load fails', () async {
        // Arrange
        when(mockService.getUserQuizSessions())
            .thenThrow(Exception('Network error'));
        viewModel = QuizSessionsViewModel(service: mockService);

        // Act
        await viewModel.loadQuizSessions();

        // Assert
        expect(viewModel.error, equals('Failed to load quiz sessions'));
        expect(viewModel.quizSessions, isEmpty);
        expect(viewModel.isLoading, isFalse);
      });

      test('should clear previous sessions on error', () async {
        // Arrange
        final mockSessions = createMockQuizSessions();
        when(mockService.getUserQuizSessions())
            .thenAnswer((_) async => mockSessions);
        viewModel = QuizSessionsViewModel(service: mockService);
        await viewModel.loadQuizSessions();

        // Act - now make it fail
        when(mockService.getUserQuizSessions()).thenThrow(Exception('Error'));
        await viewModel.loadQuizSessions();

        // Assert
        expect(viewModel.quizSessions, isEmpty);
      });
    });

    group('refresh', () {
      test('should reload quiz sessions', () async {
        // Arrange
        when(mockService.getUserQuizSessions())
            .thenAnswer((_) async => createMockQuizSessions());
        viewModel = QuizSessionsViewModel(service: mockService);
        reset(mockService);
        when(mockService.getUserQuizSessions())
            .thenAnswer((_) async => createMockQuizSessions(count: 3));

        // Act
        await viewModel.refresh();

        // Assert
        verify(mockService.getUserQuizSessions()).called(1);
        expect(viewModel.quizSessions.length, equals(3));
      });
    });

    group('session data', () {
      test('should return all loaded sessions', () async {
        // Arrange
        final mockSessions = [
          ...createMockQuizSessions(),
          ...createMockQuizSessions(completed: true),
        ];
        when(mockService.getUserQuizSessions())
            .thenAnswer((_) async => mockSessions);
        viewModel = QuizSessionsViewModel(service: mockService);
        await viewModel.loadQuizSessions();

        // Assert
        expect(viewModel.quizSessions.length, equals(4));
      });

      test('should include both completed and in-progress sessions', () async {
        // Arrange
        final mockSessions = [
          ...createMockQuizSessions(),
          ...createMockQuizSessions(count: 3, completed: true),
        ];
        when(mockService.getUserQuizSessions())
            .thenAnswer((_) async => mockSessions);
        viewModel = QuizSessionsViewModel(service: mockService);
        await viewModel.loadQuizSessions();

        // Assert
        expect(viewModel.quizSessions.length, equals(5));
        expect(
          viewModel.quizSessions.where((s) => s.session.isCompleted).length,
          equals(3),
        );
        expect(
          viewModel.quizSessions
              .where((s) => s.session.status == SessionStatus.inProgress)
              .length,
          equals(2),
        );
      });
    });

    group('getters', () {
      test('sessionCount should return correct count', () async {
        // Arrange
        final mockSessions = createMockQuizSessions(count: 5);
        when(mockService.getUserQuizSessions())
            .thenAnswer((_) async => mockSessions);
        viewModel = QuizSessionsViewModel(service: mockService);

        // Act
        await viewModel.loadQuizSessions();

        // Assert
        expect(viewModel.sessionCount, equals(5));
      });

      test('sessionCount should return zero when empty', () async {
        // Arrange
        when(mockService.getUserQuizSessions()).thenAnswer((_) async => []);
        viewModel = QuizSessionsViewModel(service: mockService);

        // Act
        await viewModel.loadQuizSessions();

        // Assert
        expect(viewModel.sessionCount, equals(0));
      });
    });
  });
}
