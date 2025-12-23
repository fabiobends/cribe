import 'package:cribe/data/services/quiz_service.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/domain/models/quiz.dart';
import 'package:cribe/ui/quiz/view_models/quiz_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'quiz_view_model_test.mocks.dart';

@GenerateMocks([QuizService])
void main() {
  late QuizViewModel viewModel;
  late MockQuizService mockQuizService;
  late Episode episode;

  Episode createEpisode() => Episode(
        id: 1,
        externalId: 'test-episode',
        podcastId: 1,
        name: 'Test Episode',
        description: 'Test Description',
        audioUrl: 'https://example.com/audio.mp3',
        imageUrl: 'https://example.com/image.jpg',
        datePublished: DateTime.now().toIso8601String(),
        duration: 3600,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  QuizData createQuizData({
    int totalQuestions = 1,
    int answeredQuestions = 0,
    int correctAnswers = 0,
    SessionStatus status = SessionStatus.inProgress,
    List<Question>? questions,
    List<UserAnswer> userAnswers = const [],
  }) =>
      QuizData(
        session: QuizSession(
          id: 1,
          userId: 10,
          episodeId: 1,
          episodeName: 'Test Episode',
          podcastName: 'Test Podcast',
          status: status,
          totalQuestions: totalQuestions,
          answeredQuestions: answeredQuestions,
          correctAnswers: correctAnswers,
          startedAt: DateTime.now(),
          completedAt:
              status == SessionStatus.completed ? DateTime.now() : null,
        ),
        questions: questions ??
            List.generate(
              totalQuestions,
              (i) => Question(
                id: i + 1,
                episodeId: 1,
                questionText: 'Question ${i + 1}?',
                type: QuestionType.multipleChoice,
                position: i + 1,
                options: [],
              ),
            ),
        userAnswers: userAnswers,
      );

  Future<void> initViewModel(QuizData quizData) async {
    when(mockQuizService.startQuiz(1)).thenAnswer((_) async => quizData);
    viewModel =
        QuizViewModel(quizService: mockQuizService, episodeId: episode.id);
    await Future.delayed(Duration.zero);
  }

  setUp(() {
    mockQuizService = MockQuizService();
    episode = createEpisode();
  });

  group('QuizViewModel', () {
    test('should initialize with quiz data', () async {
      final quizData = createQuizData(totalQuestions: 5);
      await initViewModel(quizData);

      expect(viewModel.quizData, isNotNull);
      expect(viewModel.quizData!.questions.length, 5);
      verify(mockQuizService.startQuiz(1)).called(1);
    });

    test('should calculate progress correctly', () async {
      await initViewModel(
        createQuizData(
          totalQuestions: 5,
          answeredQuestions: 2,
        ),
      );
      expect(viewModel.progress, 0.4);
    });

    test('should return correct accuracy percentage', () async {
      await initViewModel(
        createQuizData(
          totalQuestions: 5,
          answeredQuestions: 5,
          correctAnswers: 4,
          status: SessionStatus.completed,
        ),
      );
      expect(viewModel.accuracyPercentage, 80);
    });

    test('should return excellent message for 80%+ accuracy', () async {
      await initViewModel(
        createQuizData(
          totalQuestions: 5,
          answeredQuestions: 5,
          correctAnswers: 4,
          status: SessionStatus.completed,
        ),
      );
      expect(
        viewModel.completionMessage,
        'Excellent work! You really know this topic.',
      );
    });

    test('should select option', () async {
      await initViewModel(createQuizData());
      viewModel.selectOption(1);

      expect(viewModel.selectedOptionId, 1);
      expect(viewModel.canConfirmAnswer, true);
    });

    test('should update text answer', () async {
      await initViewModel(
        createQuizData(
          questions: [
            Question(
              id: 1,
              episodeId: 1,
              questionText: 'Test?',
              type: QuestionType.openEnded,
              position: 1,
              options: [],
            ),
          ],
        ),
      );
      viewModel.updateTextAnswer('My answer');

      expect(viewModel.textAnswer, 'My answer');
      expect(viewModel.canConfirmAnswer, true);
    });

    test('should confirm answer', () async {
      await initViewModel(createQuizData());
      final mockAnswer = UserAnswer(
        id: 1,
        sessionId: 1,
        questionId: 1,
        selectedOptionId: 1,
        isCorrect: true,
        feedback: 'Correct!',
        answeredAt: DateTime.now(),
      );

      when(
        mockQuizService.submitAnswer(
          sessionId: 1,
          questionId: 1,
          selectedOptionId: 1,
        ),
      ).thenAnswer((_) async => mockAnswer);

      viewModel.selectOption(1);
      await viewModel.confirmAnswer();

      expect(viewModel.showingFeedback, true);
      expect(viewModel.currentFeedback?.isCorrect, true);
    });

    group('error handling', () {
      test('should handle initialization error', () async {
        when(mockQuizService.startQuiz(1))
            .thenThrow(Exception('Network error'));
        viewModel =
            QuizViewModel(quizService: mockQuizService, episodeId: episode.id);
        await Future.delayed(Duration.zero);

        expect(viewModel.error, isNotNull);
        expect(viewModel.quizData, isNull);
      });

      test('should handle submit answer error', () async {
        await initViewModel(createQuizData());
        when(
          mockQuizService.submitAnswer(
            sessionId: 1,
            questionId: 1,
            selectedOptionId: 1,
          ),
        ).thenThrow(Exception('Network error'));

        viewModel.selectOption(1);
        await viewModel.confirmAnswer();

        expect(viewModel.error, isNotNull);
        expect(viewModel.showingFeedback, false);
      });

      test('should handle complete quiz error', () async {
        await initViewModel(
          createQuizData(
            answeredQuestions: 1,
            correctAnswers: 1,
            userAnswers: [
              UserAnswer(
                id: 1,
                sessionId: 1,
                questionId: 1,
                selectedOptionId: 1,
                isCorrect: true,
                feedback: 'Correct!',
                answeredAt: DateTime.now(),
              ),
            ],
          ),
        );
        when(mockQuizService.completeQuiz(1))
            .thenThrow(Exception('Network error'));

        await viewModel.goToNext();

        expect(viewModel.error, isNotNull);
        expect(viewModel.showingCompletionScreen, false);
      });
    });

    group('navigation', () {
      test('should go to next question', () async {
        await initViewModel(createQuizData(totalQuestions: 2));

        expect(viewModel.currentQuestionIndex, 0);
        await viewModel.goToNext();
        expect(viewModel.currentQuestionIndex, 1);
      });

      test('should go to previous question', () async {
        await initViewModel(
          createQuizData(
            totalQuestions: 2,
            answeredQuestions: 1,
            correctAnswers: 1,
            userAnswers: [
              UserAnswer(
                id: 1,
                sessionId: 1,
                questionId: 1,
                selectedOptionId: 1,
                isCorrect: true,
                feedback: 'Correct!',
                answeredAt: DateTime.now(),
              ),
            ],
          ),
        );

        await viewModel.goToNext();
        expect(viewModel.currentQuestionIndex, 1);

        viewModel.goToPrevious();
        expect(viewModel.currentQuestionIndex, 0);
      });
    });

    group('review mode', () {
      test('should handle review mode for completed quiz', () async {
        await initViewModel(
          createQuizData(
            totalQuestions: 2,
            answeredQuestions: 2,
            correctAnswers: 2,
            status: SessionStatus.completed,
            userAnswers: List.generate(
              2,
              (i) => UserAnswer(
                id: i + 1,
                sessionId: 1,
                questionId: i + 1,
                selectedOptionId: i + 1,
                isCorrect: true,
                feedback: 'Correct!',
                answeredAt: DateTime.now(),
              ),
            ),
          ),
        );

        expect(viewModel.isQuizCompleted, true);
        expect(viewModel.currentQuestionIndex, 0);
        expect(viewModel.showingFeedback, true);
      });

      test('should navigate in review mode', () async {
        await initViewModel(
          createQuizData(
            totalQuestions: 2,
            answeredQuestions: 2,
            correctAnswers: 2,
            status: SessionStatus.completed,
            userAnswers: List.generate(
              2,
              (i) => UserAnswer(
                id: i + 1,
                sessionId: 1,
                questionId: i + 1,
                selectedOptionId: i + 1,
                isCorrect: true,
                feedback: 'Correct!',
                answeredAt: DateTime.now(),
              ),
            ),
          ),
        );

        viewModel.goToNextForReview();
        expect(viewModel.currentQuestionIndex, 1);

        viewModel.goToNextForReview();
        expect(viewModel.showingCompletionScreen, true);
      });
    });
  });
}
