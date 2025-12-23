import 'package:cribe/data/models/quiz/user_answer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserAnswerDto', () {
    test('should serialize from/to JSON', () {
      final json = {
        'id': 1,
        'session_id': 10,
        'question_id': 5,
        'user_id': 20,
        'selected_option_id': 3,
        'text_answer': null,
        'is_correct': true,
        'feedback': 'Correct!',
        'answered_at': '2024-01-15T10:30:00.000Z',
      };

      final answer = UserAnswerDto.fromJson(json);
      expect(answer.isCorrect, true);
      expect(answer.toJson()['feedback'], 'Correct!');
    });
  });
}
