import 'package:cribe/domain/models/quiz.dart';

class QuizSessionDto {
  final int id;
  final int userId;
  final int episodeId;
  final String episodeName;
  final String podcastName;
  final String status;
  final int totalQuestions;
  final int answeredQuestions;
  final int correctAnswers;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime updatedAt;

  QuizSessionDto({
    required this.id,
    required this.userId,
    required this.episodeId,
    required this.episodeName,
    required this.podcastName,
    required this.status,
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.correctAnswers,
    required this.startedAt,
    this.completedAt,
    required this.updatedAt,
  });

  factory QuizSessionDto.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return QuizSessionDto(
      id: map['id'] as int? ?? 0,
      userId: map['user_id'] as int? ?? 0,
      episodeId: map['episode_id'] as int? ?? 0,
      episodeName: map['episode_name'] as String? ?? '',
      podcastName: map['podcast_name'] as String? ?? '',
      status: map['status'] as String? ?? 'in_progress',
      totalQuestions: map['total_questions'] as int? ?? 0,
      answeredQuestions: map['answered_questions'] as int? ?? 0,
      correctAnswers: map['correct_answers'] as int? ?? 0,
      startedAt: DateTime.parse(map['started_at'] as String? ?? ''),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      updatedAt: DateTime.parse(map['updated_at'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'episode_id': episodeId,
      'episode_name': episodeName,
      'podcast_name': podcastName,
      'status': status,
      'total_questions': totalQuestions,
      'answered_questions': answeredQuestions,
      'correct_answers': correctAnswers,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  QuizSession toDomain() {
    return QuizSession(
      id: id,
      userId: userId,
      episodeId: episodeId,
      episodeName: episodeName,
      podcastName: podcastName,
      status: SessionStatus.fromString(status),
      totalQuestions: totalQuestions,
      answeredQuestions: answeredQuestions,
      correctAnswers: correctAnswers,
      startedAt: startedAt,
      completedAt: completedAt,
    );
  }
}
