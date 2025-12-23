import 'package:cribe/data/models/quiz/question.dart';
import 'package:cribe/data/models/quiz/question_option.dart';
import 'package:cribe/data/models/quiz/quiz_session.dart';
import 'package:cribe/data/models/quiz/quiz_session_detail.dart';
import 'package:cribe/data/models/quiz/submit_answer_request.dart';
import 'package:cribe/data/models/quiz/user_answer.dart';
import 'package:cribe/data/repositories/quizzes/quiz_repository.dart';

class FakeQuizRepository extends QuizRepository {
  // Mock data using actual model classes
  late final List<QuestionDto> _mockQuestions;
  late final Map<int, List<UserAnswerDto>> _mockAnswers;

  FakeQuizRepository() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    _mockQuestions = [
      QuestionDto(
        id: 1,
        episodeId: 1,
        questionText: 'What is the main topic discussed in this episode?',
        type: 'multiple_choice',
        position: 1,
        createdAt: yesterday,
        updatedAt: yesterday,
        options: [
          QuestionOptionDto(
            id: 1,
            questionId: 1,
            optionText: 'Technology and AI',
            position: 1,
            isCorrect: true,
            createdAt: yesterday,
          ),
          QuestionOptionDto(
            id: 2,
            questionId: 1,
            optionText: 'Politics',
            position: 2,
            isCorrect: false,
            createdAt: yesterday,
          ),
          QuestionOptionDto(
            id: 3,
            questionId: 1,
            optionText: 'Sports',
            position: 3,
            isCorrect: false,
            createdAt: yesterday,
          ),
        ],
      ),
      QuestionDto(
        id: 2,
        episodeId: 1,
        questionText: 'Who was the main guest in this episode?',
        type: 'multiple_choice',
        position: 2,
        createdAt: yesterday,
        updatedAt: yesterday,
        options: [
          QuestionOptionDto(
            id: 4,
            questionId: 2,
            optionText: 'Elon Musk',
            position: 1,
            isCorrect: false,
            createdAt: yesterday,
          ),
          QuestionOptionDto(
            id: 5,
            questionId: 2,
            optionText: 'Sam Altman',
            position: 2,
            isCorrect: true,
            createdAt: yesterday,
          ),
        ],
      ),
      QuestionDto(
        id: 3,
        episodeId: 1,
        questionText: 'What year was this technology first introduced?',
        type: 'multiple_choice',
        position: 3,
        createdAt: yesterday,
        updatedAt: yesterday,
        options: [
          QuestionOptionDto(
            id: 6,
            questionId: 3,
            optionText: '2020',
            position: 1,
            isCorrect: false,
            createdAt: yesterday,
          ),
          QuestionOptionDto(
            id: 7,
            questionId: 3,
            optionText: '2022',
            position: 2,
            isCorrect: true,
            createdAt: yesterday,
          ),
          QuestionOptionDto(
            id: 8,
            questionId: 3,
            optionText: '2023',
            position: 3,
            isCorrect: false,
            createdAt: yesterday,
          ),
        ],
      ),
      QuestionDto(
        id: 4,
        episodeId: 1,
        questionText:
            'True or False: The guest mentioned ethical concerns about AI.',
        type: 'true_false',
        position: 4,
        createdAt: yesterday,
        updatedAt: yesterday,
        options: [
          QuestionOptionDto(
            id: 9,
            questionId: 4,
            optionText: 'True',
            position: 1,
            isCorrect: true,
            createdAt: yesterday,
          ),
          QuestionOptionDto(
            id: 10,
            questionId: 4,
            optionText: 'False',
            position: 2,
            isCorrect: false,
            createdAt: yesterday,
          ),
        ],
      ),
      QuestionDto(
        id: 5,
        episodeId: 1,
        questionText: 'What was the key takeaway from this episode?',
        type: 'open_ended',
        position: 5,
        createdAt: yesterday,
        updatedAt: yesterday,
        options: [],
      ),
    ];

    _mockAnswers = {
      1: [
        UserAnswerDto(
          id: 1,
          sessionId: 1,
          questionId: 1,
          userId: 1,
          selectedOptionId: 1,
          isCorrect: true,
          feedback: 'Correct! The main topic was about Technology and AI.',
          answeredAt: now.subtract(const Duration(minutes: 3)),
        ),
        UserAnswerDto(
          id: 2,
          sessionId: 1,
          questionId: 2,
          userId: 1,
          selectedOptionId: 4,
          isCorrect: false,
          feedback: 'Incorrect. The guest was Sam Altman, not Elon Musk.',
          answeredAt: now.subtract(const Duration(minutes: 2)),
        ),
      ],
    };
  }

  @override
  Future<QuizSessionDetailDto> getOrCreateSession(int episodeId) async {
    logger.info('Loading mock quiz session in FakeQuizRepository');

    final now = DateTime.now();
    final session = QuizSessionDto(
      id: 1,
      userId: 1,
      episodeId: episodeId,
      episodeName: 'The Future of AI',
      podcastName: 'Tech Talks',
      status: 'in_progress',
      totalQuestions: 5,
      answeredQuestions: 2,
      correctAnswers: 1,
      startedAt: now.subtract(const Duration(minutes: 5)),
      updatedAt: now,
    );

    return QuizSessionDetailDto(
      session: session,
      questions: _mockQuestions,
      answers: _mockAnswers[1]!,
    );
  }

  @override
  Future<QuizSessionDetailDto> getSessionDetail(int sessionId) async {
    logger.info('Loading mock session detail in FakeQuizRepository');
    return getOrCreateSession(1);
  }

  @override
  Future<List<QuizSessionDetailDto>> getUserSessions() async {
    logger.info('Loading mock user sessions in FakeQuizRepository');

    final now = DateTime.now();
    return [
      QuizSessionDetailDto(
        session: QuizSessionDto(
          id: 1,
          userId: 1,
          episodeId: 1,
          episodeName: 'The Future of AI',
          podcastName: 'Tech Talks',
          status: 'in_progress',
          totalQuestions: 5,
          answeredQuestions: 2,
          correctAnswers: 1,
          startedAt: now.subtract(const Duration(minutes: 5)),
          updatedAt: now,
        ),
        answers: _mockAnswers[1]!,
        questions: _mockQuestions,
      ),
      QuizSessionDetailDto(
        session: QuizSessionDto(
          id: 2,
          episodeId: 2,
          episodeName: 'Understanding Quantum Computing',
          podcastName: 'Science Weekly',
          userId: 1,
          status: 'completed',
          totalQuestions: 10,
          answeredQuestions: 10,
          correctAnswers: 8,
          startedAt: now.subtract(const Duration(days: 1)),
          completedAt: now.subtract(const Duration(hours: 23)),
          updatedAt: now.subtract(const Duration(hours: 23)),
        ),
        answers: [],
        questions: [],
      ),
    ];
  }

  @override
  Future<UserAnswerDto> submitAnswer({
    required int sessionId,
    required SubmitAnswerRequest request,
  }) async {
    logger.info('Submitting mock answer in FakeQuizRepository');

    // Simulate correct answer for demonstration
    return UserAnswerDto(
      id: 3,
      sessionId: sessionId,
      questionId: request.questionId,
      userId: 1,
      selectedOptionId: request.selectedOptionId,
      textAnswer: request.textAnswer,
      isCorrect: true,
      feedback: 'Great job! That\'s the correct answer.',
      answeredAt: DateTime.now(),
    );
  }

  @override
  Future<QuizSessionDto> completeQuiz(int sessionId) async {
    logger.info('Completing mock quiz in FakeQuizRepository');

    return QuizSessionDto(
      id: sessionId,
      userId: 1,
      episodeId: 1,
      episodeName: 'The Future of AI',
      podcastName: 'Tech Talks',
      status: 'completed',
      totalQuestions: 5,
      answeredQuestions: 5,
      correctAnswers: 4,
      startedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
