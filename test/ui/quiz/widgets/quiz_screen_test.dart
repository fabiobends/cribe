import 'package:cribe/data/services/quiz_service.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/domain/models/quiz.dart';
import 'package:cribe/ui/quiz/view_models/quiz_view_model.dart';
import 'package:cribe/ui/quiz/widgets/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'quiz_screen_test.mocks.dart';

@GenerateMocks([QuizService])
void main() {
  late MockQuizService mockQuizService;
  late Episode episode;

  setUp(() {
    mockQuizService = MockQuizService();
    episode = Episode(
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
  });

  Widget createTestWidget(QuizViewModel viewModel) {
    return MaterialApp(
      home: ChangeNotifierProvider<QuizViewModel>.value(
        value: viewModel,
        child: const QuizScreen(),
      ),
    );
  }

  QuizData createMockQuizData({
    SessionStatus status = SessionStatus.inProgress,
    int answeredQuestions = 0,
    int correctAnswers = 0,
    List<UserAnswer>? userAnswers,
  }) {
    return QuizData(
      session: QuizSession(
        id: 1,
        userId: 10,
        episodeId: 1,
        episodeName: 'Test Episode',
        podcastName: 'Test Podcast',
        status: status,
        totalQuestions: 2,
        answeredQuestions: answeredQuestions,
        correctAnswers: correctAnswers,
        startedAt: DateTime.now(),
        completedAt: status == SessionStatus.completed ? DateTime.now() : null,
      ),
      questions: [
        Question(
          id: 1,
          episodeId: 1,
          questionText: 'Question 1?',
          type: QuestionType.multipleChoice,
          position: 1,
          options: [
            QuestionOption(
              id: 1,
              questionId: 1,
              optionText: 'Option A',
              position: 1,
              isCorrect: true,
            ),
          ],
        ),
        Question(
          id: 2,
          episodeId: 1,
          questionText: 'Question 2?',
          type: QuestionType.multipleChoice,
          position: 2,
          options: [],
        ),
      ],
      userAnswers: userAnswers ?? [],
    );
  }

  group('QuizScreen', () {
    testWidgets('should display loading when initializing', (tester) async {
      when(mockQuizService.startQuiz(1)).thenAnswer(
        (_) async => Future.delayed(const Duration(seconds: 10)),
      );

      final viewModel = QuizViewModel(
        quizService: mockQuizService,
        episodeId: episode.id,
      );

      await tester.pumpWidget(createTestWidget(viewModel));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display question and UI elements', (tester) async {
      when(mockQuizService.startQuiz(1))
          .thenAnswer((_) async => createMockQuizData());

      final viewModel = QuizViewModel(
        quizService: mockQuizService,
        episodeId: episode.id,
      );

      await tester.pumpWidget(createTestWidget(viewModel));
      await tester.pumpAndSettle();

      expect(find.text('Question 1?'), findsOneWidget);
      expect(find.text('Option A'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Confirm Answer'), findsOneWidget);
      expect(find.text('Test Episode'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should display completion screen', (tester) async {
      when(mockQuizService.startQuiz(1)).thenAnswer(
        (_) async => createMockQuizData(
          status: SessionStatus.completed,
          answeredQuestions: 2,
          correctAnswers: 2,
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

      final viewModel = QuizViewModel(
        quizService: mockQuizService,
        episodeId: episode.id,
      );

      await tester.pumpWidget(createTestWidget(viewModel));
      await tester.pumpAndSettle();

      viewModel.goToNextForReview();
      viewModel.goToNextForReview();
      await tester.pump();

      expect(find.text('Quiz Complete!'), findsOneWidget);
      expect(find.text('100% Accuracy'), findsOneWidget);
      expect(find.text('Back to Episode'), findsOneWidget);
    });

    testWidgets('should handle error state', (tester) async {
      when(mockQuizService.startQuiz(1)).thenThrow(Exception('Network error'));

      final viewModel = QuizViewModel(
        quizService: mockQuizService,
        episodeId: episode.id,
      );

      await tester.pumpWidget(createTestWidget(viewModel));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(viewModel.isLoading, false);
      expect(viewModel.error, isNotNull);
    });

    testWidgets('should handle navigation', (tester) async {
      when(mockQuizService.startQuiz(1))
          .thenAnswer((_) async => createMockQuizData());

      final viewModel = QuizViewModel(
        quizService: mockQuizService,
        episodeId: episode.id,
      );

      await tester.pumpWidget(createTestWidget(viewModel));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(QuizScreen), findsNothing);
    });

    testWidgets('should call confirmAnswer when Confirm Answer tapped',
        (tester) async {
      when(mockQuizService.startQuiz(1))
          .thenAnswer((_) async => createMockQuizData());
      when(
        mockQuizService.submitAnswer(
          sessionId: 1,
          questionId: 1,
          selectedOptionId: 1,
        ),
      ).thenAnswer(
        (_) async => UserAnswer(
          id: 1,
          sessionId: 1,
          questionId: 1,
          selectedOptionId: 1,
          isCorrect: true,
          feedback: 'Correct!',
          answeredAt: DateTime.now(),
        ),
      );

      final viewModel = QuizViewModel(
        quizService: mockQuizService,
        episodeId: episode.id,
      );
      await tester.pumpWidget(createTestWidget(viewModel));
      await tester.pumpAndSettle();
      viewModel.selectOption(1);
      await tester.pump();
      await tester.tap(find.text('Confirm Answer'));
      await tester.pumpAndSettle();
      expect(viewModel.showingFeedback, true);
    });

    testWidgets('should call next when Next Question tapped', (tester) async {
      when(mockQuizService.startQuiz(1))
          .thenAnswer((_) async => createMockQuizData());
      final viewModel = QuizViewModel(
        quizService: mockQuizService,
        episodeId: episode.id,
      );
      await tester.pumpWidget(createTestWidget(viewModel));
      await tester.pumpAndSettle();
      final initialIndex = viewModel.currentQuestionIndex;
      // Simulate feedback to show Next Question button
      viewModel.selectOption(1);
      when(
        mockQuizService.submitAnswer(
          sessionId: 1,
          questionId: 1,
          selectedOptionId: 1,
        ),
      ).thenAnswer(
        (_) async => UserAnswer(
          id: 1,
          sessionId: 1,
          questionId: 1,
          selectedOptionId: 1,
          isCorrect: true,
          feedback: 'Correct!',
          answeredAt: DateTime.now(),
        ),
      );
      await viewModel.confirmAnswer();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next Question'));
      await tester.pumpAndSettle();
      expect(viewModel.currentQuestionIndex, initialIndex + 1);
    });
  });
}
