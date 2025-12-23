class SubmitAnswerRequest {
  final int questionId;
  final int? selectedOptionId;
  final String? textAnswer;

  SubmitAnswerRequest({
    required this.questionId,
    this.selectedOptionId,
    this.textAnswer,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'selected_option_id': selectedOptionId,
      'text_answer': textAnswer,
    };
  }
}
