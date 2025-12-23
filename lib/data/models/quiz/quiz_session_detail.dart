import 'package:cribe/data/models/quiz/question.dart';
import 'package:cribe/data/models/quiz/quiz_session.dart';
import 'package:cribe/data/models/quiz/user_answer.dart';
import 'package:cribe/domain/models/quiz.dart';

/// Full quiz session details
class QuizSessionDetailDto {
  final QuizSessionDto session;
  final List<QuestionDto> questions;
  final List<UserAnswerDto> answers;

  QuizSessionDetailDto({
    required this.session,
    required this.questions,
    required this.answers,
  });

  factory QuizSessionDetailDto.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return QuizSessionDetailDto(
      session: QuizSessionDto.fromJson(map['session']),
      questions: (map['questions'] as List<dynamic>? ?? [])
          .map((q) => QuestionDto.fromJson(q))
          .toList(),
      answers: (map['answers'] as List<dynamic>? ?? [])
          .map((a) => UserAnswerDto.fromJson(a))
          .toList(),
    );
  }

  QuizData toDomain() {
    return QuizData(
      session: session.toDomain(),
      questions: questions.map((q) => q.toDomain()).toList(),
      userAnswers: answers.map((a) => a.toDomain()).toList(),
    );
  }
}
