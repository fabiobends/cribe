import 'package:cribe/data/models/quiz/question_option.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuestionOptionDto', () {
    test('should serialize from/to JSON', () {
      final json = {
        'id': 1,
        'question_id': 42,
        'option_text': 'Paris',
        'position': 1,
        'is_correct': true,
        'created_at': '2024-01-15T10:30:00.000Z',
      };

      final option = QuestionOptionDto.fromJson(json);
      expect(option.optionText, 'Paris');
      expect(option.toJson()['is_correct'], true);
    });
    test('should convert to domain', () {
      final dto = QuestionOptionDto(
        id: 1,
        questionId: 42,
        optionText: 'Paris',
        position: 1,
        isCorrect: true,
        createdAt: DateTime.now(),
      );
      final domain = dto.toDomain();
      expect(domain.id, dto.id);
      expect(domain.optionText, dto.optionText);
      expect(domain.isCorrect, true);
    });
  });
}
