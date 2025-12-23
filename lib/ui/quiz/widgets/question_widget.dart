import 'package:cribe/core/constants/spacing.dart';
import 'package:cribe/core/ui/themes/color_scheme_extension.dart';
import 'package:cribe/domain/models/quiz.dart';
import 'package:cribe/ui/shared/widgets/styled_text.dart';
import 'package:cribe/ui/shared/widgets/styled_text_field.dart';
import 'package:flutter/material.dart';

class QuestionWidget extends StatelessWidget {
  final Question question;
  final int? selectedOptionId;
  final String? textAnswer;
  final bool showingFeedback;
  final UserAnswer? feedback;
  final Function(int) onOptionSelected;
  final Function(String) onTextChanged;

  const QuestionWidget({
    super.key,
    required this.question,
    this.selectedOptionId,
    this.textAnswer,
    required this.showingFeedback,
    this.feedback,
    required this.onOptionSelected,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question text
        StyledText(
          text: question.questionText,
          variant: TextVariant.headline,
          color: theme.colorScheme.onSurface,
        ),
        const SizedBox(height: Spacing.large),

        // Feedback section
        if (showingFeedback && feedback != null) ...[
          _buildFeedback(context, feedback!),
          const SizedBox(height: Spacing.large),
        ],

        // Adaptive content based on question type
        _buildQuestionContent(context),
      ],
    );
  }

  Widget _buildQuestionContent(BuildContext context) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return _MultipleChoiceOptions(
          options: question.options,
          selectedOptionId: selectedOptionId,
          showingFeedback: showingFeedback,
          feedback: feedback,
          onOptionSelected: onOptionSelected,
        );
      case QuestionType.trueFalse:
        return _TrueFalseOptions(
          options: question.options,
          selectedOptionId: selectedOptionId,
          showingFeedback: showingFeedback,
          feedback: feedback,
          onOptionSelected: onOptionSelected,
        );
      case QuestionType.openEnded:
        return _OpenEndedInput(
          textAnswer: textAnswer,
          showingFeedback: showingFeedback,
          onTextChanged: onTextChanged,
        );
    }
  }

  Widget _buildFeedback(BuildContext context, UserAnswer feedback) {
    final theme = Theme.of(context);
    final isCorrect = feedback.isCorrect;

    return Container(
      padding: const EdgeInsets.all(Spacing.medium),
      decoration: BoxDecoration(
        color: isCorrect
            ? theme.colorScheme.successContainer.withValues(alpha: 0.3)
            : theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(Spacing.small),
        border: Border.all(
          color:
              isCorrect ? theme.colorScheme.success : theme.colorScheme.error,
          width: Spacing.tiny,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect
                    ? theme.colorScheme.success
                    : theme.colorScheme.error,
                size: Spacing.large,
              ),
              const SizedBox(width: Spacing.small),
              StyledText(
                text: isCorrect ? 'Correct!' : 'Incorrect',
                variant: TextVariant.title,
                color: isCorrect
                    ? theme.colorScheme.success
                    : theme.colorScheme.error,
              ),
            ],
          ),
          const SizedBox(height: Spacing.small),
          StyledText(
            text: feedback.feedback,
            variant: TextVariant.body,
            color: theme.colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}

class _MultipleChoiceOptions extends StatelessWidget {
  final List<QuestionOption> options;
  final int? selectedOptionId;
  final bool showingFeedback;
  final UserAnswer? feedback;
  final Function(int) onOptionSelected;

  const _MultipleChoiceOptions({
    required this.options,
    required this.selectedOptionId,
    required this.showingFeedback,
    required this.feedback,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: options.map((option) {
        final isSelected = selectedOptionId == option.id;
        final isCorrect = option.isCorrect;
        final showCorrect = showingFeedback && isCorrect;
        final showIncorrect = showingFeedback && isSelected && !isCorrect;

        Color? borderColor;
        Color? backgroundColor;

        if (showCorrect) {
          borderColor = theme.colorScheme.success;
          backgroundColor =
              theme.colorScheme.successContainer.withValues(alpha: 0.2);
        } else if (showIncorrect) {
          borderColor = theme.colorScheme.error;
          backgroundColor =
              theme.colorScheme.errorContainer.withValues(alpha: 0.2);
        } else if (isSelected) {
          borderColor = theme.colorScheme.primary;
          backgroundColor =
              theme.colorScheme.primaryContainer.withValues(alpha: 0.1);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.small),
          child: InkWell(
            onTap: showingFeedback ? null : () => onOptionSelected(option.id),
            borderRadius: BorderRadius.circular(Spacing.small),
            child: Container(
              padding: const EdgeInsets.all(Spacing.medium),
              decoration: BoxDecoration(
                color: backgroundColor ??
                    theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(Spacing.small),
                border: Border.all(
                  color: borderColor ?? theme.colorScheme.outline,
                  width: Spacing.tiny,
                ),
              ),
              child: Row(
                children: [
                  if (showCorrect)
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.success,
                      size: Spacing.large,
                    )
                  else if (showIncorrect)
                    Icon(
                      Icons.cancel,
                      color: theme.colorScheme.error,
                      size: Spacing.large,
                    )
                  else
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onPrimary,
                      size: Spacing.large,
                    ),
                  const SizedBox(width: Spacing.medium),
                  Expanded(
                    child: StyledText(
                      text: option.optionText,
                      variant: TextVariant.body,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TrueFalseOptions extends StatelessWidget {
  final List<QuestionOption> options;
  final int? selectedOptionId;
  final bool showingFeedback;
  final UserAnswer? feedback;
  final Function(int) onOptionSelected;

  const _TrueFalseOptions({
    required this.options,
    required this.selectedOptionId,
    required this.showingFeedback,
    required this.feedback,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((option) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.extraSmall),
            child: _TrueFalseButton(
              option: option,
              isSelected: selectedOptionId == option.id,
              showingFeedback: showingFeedback,
              onTap: () => onOptionSelected(option.id),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TrueFalseButton extends StatelessWidget {
  final QuestionOption option;
  final bool isSelected;
  final bool showingFeedback;
  final VoidCallback onTap;

  const _TrueFalseButton({
    required this.option,
    required this.isSelected,
    required this.showingFeedback,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showCorrect = showingFeedback && option.isCorrect;
    final showIncorrect = showingFeedback && isSelected && !option.isCorrect;
    final isTrue = option.optionText.toLowerCase().contains('true');

    final IconData iconData;
    final Color iconColor;

    // Determine icon based on state
    if (showCorrect || showIncorrect) {
      // Feedback mode: use filled icons
      iconData = isTrue ? Icons.check_circle : Icons.cancel;
    } else {
      // Selection mode: use outline icons
      iconData = isTrue ? Icons.check : Icons.close;
    }

    // Determine color
    if (showCorrect) {
      iconColor = isTrue ? theme.colorScheme.success : theme.colorScheme.error;
    } else if (showIncorrect) {
      iconColor = theme.colorScheme.error;
    } else if (isSelected) {
      iconColor = theme.colorScheme.onPrimary;
    } else {
      iconColor = isTrue ? theme.colorScheme.success : theme.colorScheme.error;
    }

    final icon = Icon(
      iconData,
      color: iconColor,
      size: Spacing.extraLarge,
    );

    return GestureDetector(
      onTap: showingFeedback ? null : onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.25 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: icon,
      ),
    );
  }
}

class _OpenEndedInput extends StatefulWidget {
  final String? textAnswer;
  final bool showingFeedback;
  final Function(String) onTextChanged;

  const _OpenEndedInput({
    required this.textAnswer,
    required this.showingFeedback,
    required this.onTextChanged,
  });

  @override
  State<_OpenEndedInput> createState() => _OpenEndedInputState();
}

class _OpenEndedInputState extends State<_OpenEndedInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.textAnswer);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onTextChanged(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Spacing.small),
        color: widget.showingFeedback
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : null,
      ),
      child: StyledTextField(
        hint: 'Type your answer here...',
        controller: _controller,
        enabled: !widget.showingFeedback,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        maxLines: 5,
      ),
    );
  }
}
