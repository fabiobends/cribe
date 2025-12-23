enum QuestionType {
  multipleChoice('multiple_choice'),
  trueFalse('true_false'),
  openEnded('open_ended');

  const QuestionType(this.value);
  final String value;

  static QuestionType fromString(String value) {
    return QuestionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => QuestionType.multipleChoice,
    );
  }
}

enum SessionStatus {
  inProgress('in_progress'),
  completed('completed'),
  abandoned('abandoned');

  const SessionStatus(this.value);
  final String value;

  static SessionStatus fromString(String value) {
    return SessionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => SessionStatus.inProgress,
    );
  }
}

class QuestionOption {
  final int id;
  final int questionId;
  final String optionText;
  final int position;
  final bool isCorrect;

  QuestionOption({
    required this.id,
    required this.questionId,
    required this.optionText,
    required this.position,
    required this.isCorrect,
  });
}

class Question {
  final int id;
  final int episodeId;
  final String questionText;
  final QuestionType type;
  final int position;
  final List<QuestionOption> options;

  Question({
    required this.id,
    required this.episodeId,
    required this.questionText,
    required this.type,
    required this.position,
    this.options = const [],
  });
}

class UserAnswer {
  final int id;
  final int sessionId;
  final int questionId;
  final int? selectedOptionId;
  final String? textAnswer;
  final bool isCorrect;
  final String feedback;
  final DateTime answeredAt;

  UserAnswer({
    required this.id,
    required this.sessionId,
    required this.questionId,
    this.selectedOptionId,
    this.textAnswer,
    required this.isCorrect,
    required this.feedback,
    required this.answeredAt,
  });
}

class QuizSession {
  final int id;
  final int userId;
  final int episodeId;
  final String episodeName;
  final String podcastName;
  final SessionStatus status;
  final int totalQuestions;
  final int answeredQuestions;
  final int correctAnswers;
  final DateTime startedAt;
  final DateTime? completedAt;

  QuizSession({
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
  });

  double get progress =>
      totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;

  double get accuracy =>
      answeredQuestions > 0 ? correctAnswers / answeredQuestions : 0.0;

  bool get isCompleted => status == SessionStatus.completed;
}

class QuizData {
  final QuizSession session;
  final List<Question> questions;
  final List<UserAnswer> userAnswers;

  QuizData({
    required this.session,
    required this.questions,
    this.userAnswers = const [],
  });

  UserAnswer? getAnswerForQuestion(int questionId) {
    for (final answer in userAnswers) {
      if (answer.questionId == questionId) {
        return answer;
      }
    }
    return null;
  }

  bool isQuestionAnswered(int questionId) {
    return getAnswerForQuestion(questionId) != null;
  }
}
