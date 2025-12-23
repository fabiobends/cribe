import 'package:cribe/domain/models/quiz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuestionType', () {
    test('should convert from string', () {
      expect(
        QuestionType.fromString('multiple_choice'),
        QuestionType.multipleChoice,
      );
      expect(QuestionType.fromString('invalid'), QuestionType.multipleChoice);
    });
  });

  group('SessionStatus', () {
    test('should convert from string', () {
      expect(SessionStatus.fromString('completed'), SessionStatus.completed);
      expect(SessionStatus.fromString('invalid'), SessionStatus.inProgress);
    });
  });

  group('QuizSession', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    test('should calculate progress and accuracy', () {
      final session = QuizSession(
        id: 1,
        userId: 10,
        episodeId: 42,
        episodeName: 'Test Episode',
        podcastName: 'Test Podcast',
        status: SessionStatus.inProgress,
        totalQuestions: 10,
        answeredQuestions: 5,
        correctAnswers: 4,
        startedAt: testDate,
      );

      expect(session.progress, 0.5);
      expect(session.accuracy, 0.8);
      expect(session.isCompleted, false);
    });
  });

  group('QuizData', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    test('should get answer for question', () {
      final session = QuizSession(
        id: 1,
        userId: 10,
        episodeId: 42,
        episodeName: 'Test Episode',
        podcastName: 'Test Podcast',
        status: SessionStatus.inProgress,
        totalQuestions: 1,
        answeredQuestions: 1,
        correctAnswers: 1,
        startedAt: testDate,
      );

      final answers = [
        UserAnswer(
          id: 1,
          sessionId: 1,
          questionId: 1,
          selectedOptionId: 1,
          isCorrect: true,
          feedback: 'Correct!',
          answeredAt: testDate,
        ),
      ];

      final quizData = QuizData(
        session: session,
        questions: [],
        userAnswers: answers,
      );

      expect(quizData.getAnswerForQuestion(1)?.questionId, 1);
      expect(quizData.isQuestionAnswered(1), true);
      expect(quizData.isQuestionAnswered(2), false);
    });
  });
}
