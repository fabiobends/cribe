import 'package:cribe/data/services/quiz_service.dart';
import 'package:cribe/domain/models/quiz.dart';
import 'package:cribe/ui/quiz/view_models/quiz_sessions_view_model.dart';
import 'package:cribe/ui/quiz/widgets/quiz_sessions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'quiz_sessions_screen_test.mocks.dart';

@GenerateMocks([QuizService])
void main() {
  group('QuizSessionsScreen', () {
    late MockQuizService mockService;

    setUp(() {
      mockService = MockQuizService();
    });

    Widget createTestWidget(QuizSessionsViewModel viewModel) {
      return MaterialApp(
        home: ChangeNotifierProvider<QuizSessionsViewModel>.value(
          value: viewModel,
          child: const QuizSessionsScreen(),
        ),
      );
    }

    group('UI elements', () {
      testWidgets('should display Scaffold', (tester) async {
        // Arrange
        when(mockService.getUserQuizSessions()).thenAnswer((_) async => []);
        final viewModel = QuizSessionsViewModel(service: mockService);

        // Act
        await tester.pumpWidget(createTestWidget(viewModel));
        await tester.pump();

        // Assert
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should display SafeArea', (tester) async {
        // Arrange
        when(mockService.getUserQuizSessions()).thenAnswer((_) async => []);
        final viewModel = QuizSessionsViewModel(service: mockService);

        // Act
        await tester.pumpWidget(createTestWidget(viewModel));
        await tester.pump();

        // Assert
        expect(find.byType(SafeArea), findsOneWidget);
      });
    });

    group('loading state', () {
      testWidgets('should show CircularProgressIndicator when loading',
          (tester) async {
        // Arrange
        when(mockService.getUserQuizSessions()).thenAnswer(
          (_) => Future.delayed(const Duration(milliseconds: 100), () => []),
        );
        final viewModel = QuizSessionsViewModel(service: mockService);

        // Act
        await tester.pumpWidget(createTestWidget(viewModel));
        viewModel.loadQuizSessions();
        await tester.pump();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Clean up - wait for the delayed future to complete
        await tester.pumpAndSettle();
      });

      testWidgets('should hide loading indicator after data loads',
          (tester) async {
        // Arrange
        when(mockService.getUserQuizSessions()).thenAnswer((_) async => []);
        final viewModel = QuizSessionsViewModel(service: mockService);

        // Act
        await tester.pumpWidget(createTestWidget(viewModel));
        await viewModel.loadQuizSessions();
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    group('empty state', () {
      testWidgets('should display empty message when no sessions',
          (tester) async {
        // Arrange
        when(mockService.getUserQuizSessions()).thenAnswer((_) async => []);
        final viewModel = QuizSessionsViewModel(service: mockService);

        // Act
        await tester.pumpWidget(createTestWidget(viewModel));
        await viewModel.loadQuizSessions();
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('No sessions available'), findsOneWidget);
      });

      testWidgets('should display RefreshIndicator in empty state',
          (tester) async {
        // Arrange
        when(mockService.getUserQuizSessions()).thenAnswer((_) async => []);
        final viewModel = QuizSessionsViewModel(service: mockService);

        // Act
        await tester.pumpWidget(createTestWidget(viewModel));
        await viewModel.loadQuizSessions();
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(RefreshIndicator), findsOneWidget);
      });
    });

    group('sessions list', () {
      testWidgets('should display list of sessions when available',
          (tester) async {
        // Arrange
        final mockSessions = [
          QuizData(
            session: QuizSession(
              id: 1,
              episodeId: 1,
              episodeName: 'Episode 1',
              podcastName: 'Podcast 1',
              userId: 1,
              totalQuestions: 5,
              answeredQuestions: 2,
              correctAnswers: 1,
              startedAt: DateTime.parse('2024-01-01'),
              status: SessionStatus.inProgress,
            ),
            questions: const [],
          ),
          QuizData(
            session: QuizSession(
              id: 2,
              episodeId: 2,
              episodeName: 'Episode 2',
              podcastName: 'Podcast 2',
              userId: 1,
              totalQuestions: 10,
              answeredQuestions: 10,
              correctAnswers: 8,
              startedAt: DateTime.parse('2024-01-01'),
              completedAt: DateTime.parse('2024-01-02'),
              status: SessionStatus.completed,
            ),
            questions: const [],
          ),
        ];
        when(mockService.getUserQuizSessions())
            .thenAnswer((_) async => mockSessions);
        final viewModel = QuizSessionsViewModel(service: mockService);

        // Act
        await tester.pumpWidget(createTestWidget(viewModel));
        await viewModel.loadQuizSessions();
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(ListView), findsOneWidget);
        expect(find.text('Episode 1'), findsOneWidget);
        expect(find.text('Episode 2'), findsOneWidget);
        expect(find.text('Podcast 1'), findsOneWidget);
        expect(find.text('Podcast 2'), findsOneWidget);
      });

      testWidgets('should display progress text for each session',
          (tester) async {
        // Arrange
        final mockSessions = [
          QuizData(
            session: QuizSession(
              id: 1,
              episodeId: 1,
              episodeName: 'Episode 1',
              podcastName: 'Podcast 1',
              userId: 1,
              totalQuestions: 5,
              answeredQuestions: 2,
              correctAnswers: 1,
              startedAt: DateTime.parse('2024-01-01'),
              status: SessionStatus.inProgress,
            ),
            questions: const [],
          ),
        ];
        when(mockService.getUserQuizSessions())
            .thenAnswer((_) async => mockSessions);
        final viewModel = QuizSessionsViewModel(service: mockService);

        // Act
        await tester.pumpWidget(createTestWidget(viewModel));
        await viewModel.loadQuizSessions();
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('2 / 5 answered'), findsOneWidget);
      });

      testWidgets('should display checkmark for completed sessions',
          (tester) async {
        // Arrange
        final mockSessions = [
          QuizData(
            session: QuizSession(
              id: 1,
              episodeId: 1,
              episodeName: 'Episode 1',
              podcastName: 'Podcast 1',
              userId: 1,
              totalQuestions: 10,
              answeredQuestions: 10,
              correctAnswers: 8,
              startedAt: DateTime.parse('2024-01-01'),
              completedAt: DateTime.parse('2024-01-02'),
              status: SessionStatus.completed,
            ),
            questions: const [],
          ),
        ];
        when(mockService.getUserQuizSessions())
            .thenAnswer((_) async => mockSessions);
        final viewModel = QuizSessionsViewModel(service: mockService);

        // Act
        await tester.pumpWidget(createTestWidget(viewModel));
        await viewModel.loadQuizSessions();
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('should not display checkmark for in-progress sessions',
          (tester) async {
        // Arrange
        final mockSessions = [
          QuizData(
            session: QuizSession(
              id: 1,
              episodeId: 1,
              episodeName: 'Episode 1',
              podcastName: 'Podcast 1',
              userId: 1,
              totalQuestions: 5,
              answeredQuestions: 2,
              correctAnswers: 1,
              startedAt: DateTime.parse('2024-01-01'),
              status: SessionStatus.inProgress,
            ),
            questions: const [],
          ),
        ];
        when(mockService.getUserQuizSessions())
            .thenAnswer((_) async => mockSessions);
        final viewModel = QuizSessionsViewModel(service: mockService);

        // Act
        await tester.pumpWidget(createTestWidget(viewModel));
        await viewModel.loadQuizSessions();
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.check), findsNothing);
      });

      testWidgets('should display RefreshIndicator with sessions list',
          (tester) async {
        // Arrange
        final mockSessions = [
          QuizData(
            session: QuizSession(
              id: 1,
              episodeId: 1,
              episodeName: 'Episode 1',
              podcastName: 'Podcast 1',
              userId: 1,
              totalQuestions: 5,
              answeredQuestions: 2,
              correctAnswers: 1,
              startedAt: DateTime.parse('2024-01-01'),
              status: SessionStatus.inProgress,
            ),
            questions: const [],
          ),
        ];
        when(mockService.getUserQuizSessions())
            .thenAnswer((_) async => mockSessions);
        final viewModel = QuizSessionsViewModel(service: mockService);

        // Act
        await tester.pumpWidget(createTestWidget(viewModel));
        await viewModel.loadQuizSessions();
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(RefreshIndicator), findsOneWidget);
      });
    });

    group('interactions', () {
      testWidgets('card should be tappable', (tester) async {
        // Arrange
        final mockSessions = [
          QuizData(
            session: QuizSession(
              id: 1,
              episodeId: 1,
              episodeName: 'Episode 1',
              podcastName: 'Podcast 1',
              userId: 1,
              totalQuestions: 5,
              answeredQuestions: 2,
              correctAnswers: 1,
              startedAt: DateTime.parse('2024-01-01'),
              status: SessionStatus.inProgress,
            ),
            questions: const [],
          ),
        ];
        when(mockService.getUserQuizSessions())
            .thenAnswer((_) async => mockSessions);
        final viewModel = QuizSessionsViewModel(service: mockService);

        // Act
        await tester.pumpWidget(createTestWidget(viewModel));
        await viewModel.loadQuizSessions();
        await tester.pumpAndSettle();

        // Assert - verify the card has an InkWell making it tappable
        expect(find.byType(InkWell), findsWidgets);
        expect(find.byType(Card), findsWidgets);
      });
    });
  });
}
