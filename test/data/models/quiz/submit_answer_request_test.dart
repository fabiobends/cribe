import 'package:cribe/data/models/quiz/submit_answer_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubmitAnswerRequest', () {
    test('should create SubmitAnswerRequest with selected option', () {
      final request = SubmitAnswerRequest(
        questionId: 1,
        selectedOptionId: 42,
      );

      expect(request.questionId, 1);
      expect(request.selectedOptionId, 42);
      expect(request.textAnswer, null);
    });

    test('should create SubmitAnswerRequest with text answer', () {
      final request = SubmitAnswerRequest(
        questionId: 1,
        textAnswer: 'My answer',
      );

      expect(request.questionId, 1);
      expect(request.selectedOptionId, null);
      expect(request.textAnswer, 'My answer');
    });

    test('should convert to JSON with selected option', () {
      final request = SubmitAnswerRequest(
        questionId: 1,
        selectedOptionId: 42,
      );

      final json = request.toJson();

      expect(json['question_id'], 1);
      expect(json['selected_option_id'], 42);
      expect(json['text_answer'], null);
    });

    test('should convert to JSON with text answer', () {
      final request = SubmitAnswerRequest(
        questionId: 1,
        textAnswer: 'My answer',
      );

      final json = request.toJson();

      expect(json['question_id'], 1);
      expect(json['selected_option_id'], null);
      expect(json['text_answer'], 'My answer');
    });
  });
}
