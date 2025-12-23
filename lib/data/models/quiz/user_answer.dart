import 'package:cribe/domain/models/quiz.dart';

class UserAnswerDto {
  final int id;
  final int sessionId;
  final int questionId;
  final int userId;
  final int? selectedOptionId;
  final String? textAnswer;
  final bool isCorrect;
  final String feedback;
  final DateTime answeredAt;

  UserAnswerDto({
    required this.id,
    required this.sessionId,
    required this.questionId,
    required this.userId,
    this.selectedOptionId,
    this.textAnswer,
    required this.isCorrect,
    required this.feedback,
    required this.answeredAt,
  });

  factory UserAnswerDto.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return UserAnswerDto(
      id: map['id'] as int? ?? 0,
      sessionId: map['session_id'] as int? ?? 0,
      questionId: map['question_id'] as int? ?? 0,
      userId: map['user_id'] as int? ?? 0,
      selectedOptionId: map['selected_option_id'] as int?,
      textAnswer: map['text_answer'] as String?,
      isCorrect: map['is_correct'] as bool? ?? false,
      feedback: map['feedback'] as String? ?? '',
      answeredAt: DateTime.parse(map['answered_at'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'question_id': questionId,
      'user_id': userId,
      'selected_option_id': selectedOptionId,
      'text_answer': textAnswer,
      'is_correct': isCorrect,
      'feedback': feedback,
      'answered_at': answeredAt.toIso8601String(),
    };
  }

  UserAnswer toDomain() {
    return UserAnswer(
      id: id,
      sessionId: sessionId,
      questionId: questionId,
      selectedOptionId: selectedOptionId,
      textAnswer: textAnswer,
      isCorrect: isCorrect,
      feedback: feedback,
      answeredAt: answeredAt,
    );
  }
}
