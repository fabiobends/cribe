import 'package:cribe/data/services/quiz_service.dart';
import 'package:cribe/domain/models/quiz.dart';
import 'package:cribe/ui/shared/view_models/base_view_model.dart';

class QuizViewModel extends BaseViewModel {
  final QuizService _quizService;
  final int _episodeId;

  QuizViewModel({
    required QuizService quizService,
    required int episodeId,
    QuizData? quizData,
  })  : _quizService = quizService,
        _episodeId = episodeId,
        _quizData = quizData {
    _initialize();
  }
  int get episodeId => _episodeId;

  String get episodeName => _quizData?.session.episodeName ?? '';

  QuizData? _quizData;
  QuizData? get quizData => _quizData;

  int _currentQuestionIndex = 0;
  int get currentQuestionIndex => _currentQuestionIndex;

  Question? get currentQuestion {
    if (_quizData == null || _quizData!.questions.isEmpty) return null;
    if (_currentQuestionIndex >= _quizData!.questions.length) return null;
    return _quizData!.questions[_currentQuestionIndex];
  }

  int? _selectedOptionId;
  int? get selectedOptionId => _selectedOptionId;

  String? _textAnswer;
  String? get textAnswer => _textAnswer;

  bool _showingFeedback = false;
  bool get showingFeedback => _showingFeedback;

  UserAnswer? _currentFeedback;
  UserAnswer? get currentFeedback => _currentFeedback;

  bool _showingCompletionScreen = false;
  bool get showingCompletionScreen => _showingCompletionScreen;

  double get progress {
    if (_quizData == null) return 0.0;
    return _quizData!.session.progress;
  }

  bool get isQuizCompleted {
    return _quizData?.session.isCompleted ?? false;
  }

  bool get canGoBack {
    if (_quizData == null) return false;
    // In review mode (completed quiz), always allow going back
    if (_quizData!.session.isCompleted) {
      return _currentQuestionIndex > 0;
    }
    // During quiz, only go back to answered questions
    return _currentQuestionIndex > 0 &&
        _quizData!.isQuestionAnswered(
          _quizData!.questions[_currentQuestionIndex - 1].id,
        );
  }

  bool get canConfirmAnswer {
    if (_showingFeedback) return false;

    final question = currentQuestion;
    if (question == null) return false;

    switch (question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.trueFalse:
        return _selectedOptionId != null;
      case QuestionType.openEnded:
        return _textAnswer != null && _textAnswer!.trim().isNotEmpty;
    }
  }

  int get accuracyPercentage {
    if (_quizData == null) return 0;
    return (_quizData!.session.accuracy * 100).toInt();
  }

  String get completionMessage {
    if (accuracyPercentage >= 80) {
      return 'Excellent work! You really know this topic.';
    } else if (accuracyPercentage >= 60) {
      return 'Good job! Keep learning and improving.';
    } else {
      return 'Keep practicing! Every quiz helps you learn more.';
    }
  }

  Future<void> _initialize() async {
    if (_quizData != null) {
      // Quiz data already provided, no need to load
      logger.info('QuizViewModel initialized with existing quiz data');

      // If quiz is already completed, start from first question for review
      if (_quizData!.session.isCompleted) {
        logger.info('Quiz already completed - showing review mode');
        _currentQuestionIndex = 0;
        _loadCurrentQuestionAnswer();
        notifyListeners();
        return;
      }

      // Find first unanswered question
      _currentQuestionIndex = _quizData!.questions.indexWhere(
        (q) => !_quizData!.isQuestionAnswered(q.id),
      );

      if (_currentQuestionIndex == -1) {
        _currentQuestionIndex = 0;
      }

      _loadCurrentQuestionAnswer();
      notifyListeners();
      return;
    }

    logger.info('Initializing quiz for episode $_episodeId');
    setLoading(true);
    setError(null);

    try {
      // Backend returns existing session if found, or creates new one
      _quizData = await _quizService.startQuiz(_episodeId);
      logger.info('Quiz session ${_quizData!.session.id} loaded');

      // If quiz is already completed, start from first question for review
      if (_quizData!.session.isCompleted) {
        logger.info('Quiz already completed - showing review mode');
        _currentQuestionIndex = 0;
        _loadCurrentQuestionAnswer();
        notifyListeners();
        return;
      }

      // Find first unanswered question
      _currentQuestionIndex = _quizData!.questions.indexWhere(
        (q) => !_quizData!.isQuestionAnswered(q.id),
      );

      if (_currentQuestionIndex == -1) {
        _currentQuestionIndex = 0;
      }

      _loadCurrentQuestionAnswer();
    } catch (e) {
      logger.error('Failed to initialize quiz: $e');
      setError('Failed to load quiz. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  void _loadCurrentQuestionAnswer() {
    final question = currentQuestion;
    if (question == null) return;

    final answer = _quizData?.getAnswerForQuestion(question.id);
    if (answer != null) {
      _selectedOptionId = answer.selectedOptionId;
      _textAnswer = answer.textAnswer;
      _currentFeedback = answer;
      _showingFeedback = true;
    } else {
      _selectedOptionId = null;
      _textAnswer = null;
      _currentFeedback = null;
      _showingFeedback = false;
    }
    notifyListeners();
  }

  void selectOption(int optionId) {
    if (_showingFeedback) return;

    _selectedOptionId = optionId;
    notifyListeners();
  }

  void updateTextAnswer(String text) {
    if (_showingFeedback) return;

    _textAnswer = text;
    notifyListeners();
  }

  Future<void> confirmAnswer() async {
    if (!canConfirmAnswer || _quizData == null || currentQuestion == null) {
      return;
    }

    setLoading(true);
    setError(null);

    try {
      final answer = await _quizService.submitAnswer(
        sessionId: _quizData!.session.id,
        questionId: currentQuestion!.id,
        selectedOptionId: _selectedOptionId,
        textAnswer: _textAnswer,
      );

      logger.info(
        'Answer submitted for question ${currentQuestion!.id}: ${answer.isCorrect ? "correct" : "incorrect"}',
      );

      // Update quiz data with new answer
      _quizData = QuizData(
        session: QuizSession(
          id: _quizData!.session.id,
          userId: _quizData!.session.userId,
          episodeId: _quizData!.session.episodeId,
          episodeName: _quizData!.session.episodeName,
          podcastName: _quizData!.session.podcastName,
          status: _quizData!.session.status,
          totalQuestions: _quizData!.session.totalQuestions,
          answeredQuestions: _quizData!.session.answeredQuestions + 1,
          correctAnswers:
              _quizData!.session.correctAnswers + (answer.isCorrect ? 1 : 0),
          startedAt: _quizData!.session.startedAt,
          completedAt: _quizData!.session.completedAt,
        ),
        questions: _quizData!.questions,
        userAnswers: [..._quizData!.userAnswers, answer],
      );

      _currentFeedback = answer;
      _showingFeedback = true;
      notifyListeners();
    } catch (e) {
      logger.error('Failed to submit answer: $e');
      setError('Failed to submit answer. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  Future<void> goToNext() async {
    if (_quizData == null) return;

    // If this is the last question, complete the quiz
    if (_currentQuestionIndex >= _quizData!.questions.length - 1) {
      await _completeQuiz();
      return;
    }

    _currentQuestionIndex++;
    _loadCurrentQuestionAnswer();
    notifyListeners();
  }

  void goToPrevious() {
    if (!canGoBack) return;

    _currentQuestionIndex--;
    _loadCurrentQuestionAnswer();
    _showingCompletionScreen = false; // Hide completion screen when going back
    notifyListeners();
  }

  void goToNextForReview() {
    if (_quizData == null) return;
    if (_currentQuestionIndex >= _quizData!.questions.length - 1) {
      // Reached the end in review mode, show completion screen
      _showingCompletionScreen = true;
      notifyListeners();
      return;
    }

    _currentQuestionIndex++;
    _loadCurrentQuestionAnswer();
    notifyListeners();
  }

  Future<void> _completeQuiz() async {
    if (_quizData == null) return;

    setLoading(true);
    setError(null);

    try {
      final completedSession = await _quizService.completeQuiz(
        _quizData!.session.id,
      );

      logger.info(
        'Quiz completed: ${completedSession.correctAnswers}/${completedSession.totalQuestions}',
      );

      _quizData = QuizData(
        session: completedSession,
        questions: _quizData!.questions,
        userAnswers: _quizData!.userAnswers,
      );

      _showingCompletionScreen = true;
      notifyListeners();
    } catch (e) {
      logger.error('Failed to complete quiz: $e');
      setError('Failed to complete quiz. Please try again.');
    } finally {
      setLoading(false);
    }
  }
}
