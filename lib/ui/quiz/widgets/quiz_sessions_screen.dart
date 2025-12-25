import 'package:cribe/core/constants/spacing.dart';
import 'package:cribe/core/logger/logger_mixins.dart';
import 'package:cribe/data/repositories/quizzes/quiz_repository.dart';
import 'package:cribe/data/services/api_service.dart';
import 'package:cribe/data/services/quiz_service.dart';
import 'package:cribe/domain/models/quiz.dart';
import 'package:cribe/ui/quiz/view_models/quiz_sessions_view_model.dart';
import 'package:cribe/ui/quiz/view_models/quiz_view_model.dart';
import 'package:cribe/ui/quiz/widgets/quiz_screen.dart';
import 'package:cribe/ui/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuizSessionsScreen extends StatefulWidget {
  const QuizSessionsScreen({super.key});

  @override
  State<QuizSessionsScreen> createState() => _QuizSessionsScreenState();
}

class _QuizSessionsScreenState extends State<QuizSessionsScreen>
    with ScreenLogger {
  late QuizSessionsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    logger.info('QuizSessionsScreen initialized');
    _viewModel = context.read<QuizSessionsViewModel>();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    logger.info('Disposing QuizSessionsScreen');
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    logger.debug('QuizSessionsScreen view model changed');
    if (_viewModel.error != null) {
      logger.warn(
        'QuizSessionsScreen encountered an error: ${_viewModel.error}',
      );
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
    }
  }

  void _navigateToQuizDetail(BuildContext context, QuizData data) {
    logger.info(
      'Navigating to quiz detail',
      extra: {
        'sessionId': data.session.id,
        'episodeId': data.session.episodeId,
      },
    );

    final quizRepository =
        QuizRepository(apiService: context.read<ApiService>());
    final quizService = QuizService(repository: quizRepository);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (newContext) => ChangeNotifierProvider(
          create: (_) => QuizViewModel(
            episodeId: data.session.episodeId,
            quizService: quizService,
            quizData: data,
          ),
          child: const QuizScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Consumer<QuizSessionsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (viewModel.quizSessions.isEmpty) {
              return RefreshIndicator(
                onRefresh: viewModel.refresh,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: StyledText(
                            text: 'No sessions available',
                            variant: TextVariant.body,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: viewModel.refresh,
              child: ListView.builder(
                padding: const EdgeInsets.all(Spacing.medium),
                itemCount: viewModel.quizSessions.length,
                itemBuilder: (context, index) {
                  final data = viewModel.quizSessions[index];
                  return _QuizSessionCard(
                    data: data,
                    onTap: () => _navigateToQuizDetail(context, data),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _QuizSessionCard extends StatelessWidget {
  final QuizData data;
  final VoidCallback? onTap;

  const _QuizSessionCard({
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = data.session.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.medium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.small),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.medium),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StyledText(
                      text: data.session.episodeName,
                      variant: TextVariant.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.extraSmall),
                    StyledText(
                      text: data.session.podcastName,
                      variant: TextVariant.caption,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: Spacing.extraSmall),
                    StyledText(
                      text:
                          '${data.session.answeredQuestions} / ${data.session.totalQuestions} answered',
                      variant: TextVariant.caption,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.all(Spacing.extraSmall),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: theme.colorScheme.onPrimary,
                    size: Spacing.medium,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
