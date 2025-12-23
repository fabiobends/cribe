import 'package:cribe/data/models/quiz/quiz_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuizSessionDto', () {
    test('should serialize from/to JSON', () {
      final json = {
        'id': 1,
        'user_id': 10,
        'episode_id': 42,
        'status': 'in_progress',
        'total_questions': 10,
        'answered_questions': 5,
        'correct_answers': 4,
        'started_at': '2024-01-15T10:30:00.000Z',
        'completed_at': null,
        'updated_at': '2024-01-15T10:30:00.000Z',
      };

      final session = QuizSessionDto.fromJson(json);
      expect(session.status, 'in_progress');
      expect(session.toJson()['id'], 1);
    });
  });
}
