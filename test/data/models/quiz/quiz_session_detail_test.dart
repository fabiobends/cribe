import 'package:cribe/data/models/quiz/quiz_session_detail.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuizSessionDetailDto', () {
    test('should serialize from JSON', () {
      final json = {
        'session': {
          'id': 1,
          'user_id': 10,
          'episode_id': 42,
          'episode_name': 'Sample Episode',
          'podcast_name': 'Sample Podcast',
          'status': 'in_progress',
          'total_questions': 2,
          'answered_questions': 1,
          'correct_answers': 1,
          'started_at': '2024-01-15T10:30:00.000Z',
          'updated_at': '2024-01-15T10:30:00.000Z',
        },
        'questions': [],
        'answers': [],
      };

      final detail = QuizSessionDetailDto.fromJson(json);
      expect(detail.session.id, 1);
    });
  });
}
