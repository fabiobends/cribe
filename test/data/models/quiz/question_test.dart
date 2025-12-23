import 'package:cribe/data/models/quiz/question.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuestionDto', () {
    test('should serialize from/to JSON', () {
      final json = {
        'id': 1,
        'episode_id': 42,
        'question_text': 'Test question',
        'type': 'multiple_choice',
        'position': 1,
        'created_at': '2024-01-15T10:30:00.000Z',
        'updated_at': '2024-01-15T10:30:00.000Z',
        'options': [],
      };

      final question = QuestionDto.fromJson(json);
      expect(question.id, 1);
      expect(question.toJson()['question_text'], 'Test question');
    });

    test('should convert to domain', () {
      final dto = QuestionDto(
        id: 1,
        episodeId: 42,
        questionText: 'Test question',
        type: 'multiple_choice',
        position: 1,
        options: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final domain = dto.toDomain();
      expect(domain.id, dto.id);
      expect(domain.questionText, dto.questionText);
      expect(domain.type.toString(), contains('multipleChoice'));
    });
  });
}
