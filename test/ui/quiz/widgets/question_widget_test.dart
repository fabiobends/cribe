import 'package:cribe/domain/models/quiz.dart';
import 'package:cribe/ui/quiz/widgets/question_widget.dart';
import 'package:cribe/ui/shared/widgets/styled_text.dart';
import 'package:cribe/ui/shared/widgets/styled_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuestionWidget', () {
    testWidgets('should display question text', (tester) async {
      final question = Question(
        id: 1,
        episodeId: 1,
        questionText: 'What is the capital of France?',
        type: QuestionType.multipleChoice,
        position: 1,
        options: [
          QuestionOption(
            id: 1,
            questionId: 1,
            optionText: 'Paris',
            position: 1,
            isCorrect: true,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestionWidget(
              question: question,
              showingFeedback: false,
              onOptionSelected: (_) {},
              onTextChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('What is the capital of France?'), findsOneWidget);
      expect(find.byType(StyledText), findsWidgets);
    });

    testWidgets('should display multiple choice options', (tester) async {
      final question = Question(
        id: 1,
        episodeId: 1,
        questionText: 'Test question?',
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
          QuestionOption(
            id: 2,
            questionId: 1,
            optionText: 'Option B',
            position: 2,
            isCorrect: false,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestionWidget(
              question: question,
              showingFeedback: false,
              onOptionSelected: (_) {},
              onTextChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Option A'), findsOneWidget);
      expect(find.text('Option B'), findsOneWidget);
    });

    testWidgets('should call onOptionSelected when option tapped',
        (tester) async {
      int? selectedId;
      final question = Question(
        id: 1,
        episodeId: 1,
        questionText: 'Test question?',
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
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestionWidget(
              question: question,
              showingFeedback: false,
              onOptionSelected: (id) => selectedId = id,
              onTextChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Option A'));
      await tester.pump();

      expect(selectedId, 1);
    });

    testWidgets('should display text field for open ended questions',
        (tester) async {
      final question = Question(
        id: 1,
        episodeId: 1,
        questionText: 'Explain your answer',
        type: QuestionType.openEnded,
        position: 1,
        options: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestionWidget(
              question: question,
              showingFeedback: false,
              onOptionSelected: (_) {},
              onTextChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(StyledTextField), findsOneWidget);
    });

    testWidgets('should display feedback when showing feedback',
        (tester) async {
      final question = Question(
        id: 1,
        episodeId: 1,
        questionText: 'Test question?',
        type: QuestionType.multipleChoice,
        position: 1,
        options: [],
      );

      final feedback = UserAnswer(
        id: 1,
        sessionId: 1,
        questionId: 1,
        selectedOptionId: 1,
        isCorrect: true,
        feedback: 'Great job!',
        answeredAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestionWidget(
              question: question,
              showingFeedback: true,
              feedback: feedback,
              onOptionSelected: (_) {},
              onTextChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Correct!'), findsOneWidget);
      expect(find.text('Great job!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should display incorrect feedback', (tester) async {
      final question = Question(
        id: 1,
        episodeId: 1,
        questionText: 'Test question?',
        type: QuestionType.multipleChoice,
        position: 1,
        options: [],
      );

      final feedback = UserAnswer(
        id: 1,
        sessionId: 1,
        questionId: 1,
        selectedOptionId: 1,
        isCorrect: false,
        feedback: 'Try again!',
        answeredAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestionWidget(
              question: question,
              showingFeedback: true,
              feedback: feedback,
              onOptionSelected: (_) {},
              onTextChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Incorrect'), findsOneWidget);
      expect(find.text('Try again!'), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('should display true/false options', (tester) async {
      final question = Question(
        id: 1,
        episodeId: 1,
        questionText: 'True or false?',
        type: QuestionType.trueFalse,
        position: 1,
        options: [
          QuestionOption(
            id: 1,
            questionId: 1,
            optionText: 'True',
            position: 1,
            isCorrect: true,
          ),
          QuestionOption(
            id: 2,
            questionId: 1,
            optionText: 'False',
            position: 2,
            isCorrect: false,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestionWidget(
              question: question,
              showingFeedback: false,
              onOptionSelected: (_) {},
              onTextChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
