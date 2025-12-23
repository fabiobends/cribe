import 'package:cribe/domain/models/quiz.dart';

class QuestionOptionDto {
  final int id;
  final int questionId;
  final String optionText;
  final int position;
  final bool isCorrect;
  final DateTime createdAt;

  QuestionOptionDto({
    required this.id,
    required this.questionId,
    required this.optionText,
    required this.position,
    required this.isCorrect,
    required this.createdAt,
  });

  factory QuestionOptionDto.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return QuestionOptionDto(
      id: map['id'] as int? ?? 0,
      questionId: map['question_id'] as int? ?? 0,
      optionText: map['option_text'] as String? ?? '',
      position: map['position'] as int? ?? 0,
      isCorrect: map['is_correct'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'option_text': optionText,
      'position': position,
      'is_correct': isCorrect,
      'created_at': createdAt.toIso8601String(),
    };
  }

  QuestionOption toDomain() {
    return QuestionOption(
      id: id,
      questionId: questionId,
      optionText: optionText,
      position: position,
      isCorrect: isCorrect,
    );
  }
}
