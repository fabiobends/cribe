import 'package:cribe/core/constants/spacing.dart';
import 'package:cribe/core/logger/logger_mixins.dart';
import 'package:cribe/ui/quiz/view_models/quiz_view_model.dart';
import 'package:cribe/ui/quiz/widgets/question_widget.dart';
import 'package:cribe/ui/shared/widgets/styled_button.dart';
import 'package:cribe/ui/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with ScreenLogger {
  late QuizViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<QuizViewModel>();
    _viewModel.addListener(_onViewModelChanged);
    logger.info('QuizScreen initialized for episode ${_viewModel.episodeId}');
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (_viewModel.error != null) {
      logger.warn('Quiz error: ${_viewModel.error}');
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: StyledText(
            text: _viewModel.error!,
            variant: TextVariant.body,
            color: theme.colorScheme.onError,
          ),
          backgroundColor: theme.colorScheme.error,
        ),
      );
      _viewModel.setError(null);
      Navigator.of(context).pop();
    }
  }

  void _goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> _handleConfirmAnswer() async {
    await _viewModel.confirmAnswer();
  }

  Future<void> _handleNext() async {
    // If quiz is already completed (review mode), navigate through questions
    if (_viewModel.isQuizCompleted) {
      _viewModel.goToNextForReview();
      return;
    }

    await _viewModel.goToNext();
  }

  void _handlePrevious() {
    _viewModel.goToPrevious();
  }

  Widget _buildMainActionButton(QuizViewModel vm) {
    final isLastQuestion =
        vm.currentQuestionIndex >= (vm.quizData!.questions.length - 1);

    if (vm.quizData!.session.isCompleted) {
      return StyledButton(
        text: isLastQuestion ? 'View Results' : 'Next Question',
        onPressed: _handleNext,
        variant: ButtonVariant.primary,
      );
    }

    if (vm.showingFeedback) {
      return StyledButton(
        text: isLastQuestion ? 'Finish Quiz' : 'Next Question',
        onPressed: _handleNext,
        variant: ButtonVariant.primary,
        isLoading: vm.isLoading,
      );
    }

    return StyledButton(
      text: 'Confirm Answer',
      onPressed: vm.canConfirmAnswer ? _handleConfirmAnswer : null,
      variant: ButtonVariant.primary,
      isLoading: vm.isLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<QuizViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.surface,
            leading: IconButton(
              icon: Icon(
                Icons.close,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: () => _goBack(context),
            ),
            title: StyledText(
              text: viewModel.episodeName,
              variant: TextVariant.title,
              color: theme.colorScheme.onSurface,
            ),
          ),
          body: Builder(
            builder: (context) {
              if (viewModel.isLoading && viewModel.quizData == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (viewModel.showingCompletionScreen) {
                return _buildCompletionScreen(context, viewModel);
              }

              if (viewModel.currentQuestion == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return _buildQuizContent(context, viewModel);
            },
          ),
        );
      },
    );
  }

  Widget _buildQuizContent(BuildContext context, QuizViewModel vm) {
    return Column(
      children: [
        // Progress bar
        _buildProgressBar(context, vm),

        // Question content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.large),
            child: QuestionWidget(
              question: vm.currentQuestion!,
              selectedOptionId: vm.selectedOptionId,
              textAnswer: vm.textAnswer,
              showingFeedback: vm.showingFeedback,
              feedback: vm.currentFeedback,
              onOptionSelected: vm.selectOption,
              onTextChanged: vm.updateTextAnswer,
            ),
          ),
        ),

        // Action buttons
        _buildActionButtons(context, vm),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, QuizViewModel vm) {
    final theme = Theme.of(context);
    final progress = vm.progress;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.medium,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Spacing.small),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(
            theme.colorScheme.primary,
          ),
          minHeight: Spacing.small,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, QuizViewModel vm) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.large,
          vertical: Spacing.medium,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous button
            if (vm.canGoBack)
              Padding(
                padding: const EdgeInsets.only(right: Spacing.small),
                child: IconButton(
                  onPressed: _handlePrevious,
                  icon: Icon(
                    Icons.arrow_back,
                    color: theme.colorScheme.onSurface,
                    size: Spacing.large,
                  ),
                ),
              ),

            // Main action button
            Expanded(
              child: _buildMainActionButton(vm),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionScreen(BuildContext context, QuizViewModel vm) {
    final theme = Theme.of(context);
    final session = vm.quizData!.session;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.large),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.large,
        children: [
          // Title
          StyledText(
            text: 'Quiz Complete!',
            variant: TextVariant.headline,
            color: theme.colorScheme.onSurface,
            textAlign: TextAlign.center,
          ),

          // Score
          StyledText(
            text:
                'You got ${session.correctAnswers} out of ${session.totalQuestions} questions correct',
            variant: TextVariant.body,
            color: theme.colorScheme.onSurfaceVariant,
            textAlign: TextAlign.center,
          ),

          // Accuracy percentage
          StyledText(
            text: '${vm.accuracyPercentage}% Accuracy',
            variant: TextVariant.title,
            color: theme.colorScheme.primary,
            textAlign: TextAlign.center,
          ),

          // Encouragement message
          StyledText(
            text: vm.completionMessage,
            variant: TextVariant.body,
            color: theme.colorScheme.onSurface,
            textAlign: TextAlign.center,
          ),

          // Back button
          StyledButton(
            text: 'Back to Episode',
            onPressed: () => _goBack(context),
            variant: ButtonVariant.primary,
          ),

          const SizedBox(height: Spacing.large),
        ],
      ),
    );
  }
}
