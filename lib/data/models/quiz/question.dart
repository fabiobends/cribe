import 'package:cribe/data/models/quiz/question_option.dart';
import 'package:cribe/domain/models/quiz.dart';

class QuestionDto {
  final int id;
  final int episodeId;
  final String questionText;
  final String type;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<QuestionOptionDto> options;

  QuestionDto({
    required this.id,
    required this.episodeId,
    required this.questionText,
    required this.type,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    this.options = const [],
  });

  factory QuestionDto.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return QuestionDto(
      id: map['id'] as int? ?? 0,
      episodeId: map['episode_id'] as int? ?? 0,
      questionText: map['question_text'] as String? ?? '',
      type: map['type'] as String? ?? 'multiple_choice',
      position: map['position'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String? ?? ''),
      updatedAt: DateTime.parse(map['updated_at'] as String? ?? ''),
      options: (map['options'] as List<dynamic>? ?? [])
          .map((o) => QuestionOptionDto.fromJson(o))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'episode_id': episodeId,
      'question_text': questionText,
      'type': type,
      'position': position,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'options': options.map((o) => o.toJson()).toList(),
    };
  }

  Question toDomain() {
    return Question(
      id: id,
      episodeId: episodeId,
      questionText: questionText,
      type: QuestionType.fromString(type),
      position: position,
      options: options.map((o) => o.toDomain()).toList(),
    );
  }
}
