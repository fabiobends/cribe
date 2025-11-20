import 'package:cribe/core/constants/spacing.dart';
import 'package:cribe/core/logger/logger_mixins.dart';
import 'package:cribe/data/repositories/podcasts/podcast_repository.dart';
import 'package:cribe/data/services/api_service.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/ui/podcasts/view_models/podcast_detail_view_model.dart';
import 'package:cribe/ui/podcasts/view_models/podcast_list_view_model.dart';
import 'package:cribe/ui/podcasts/widgets/podcast_detail_screen.dart';
import 'package:cribe/ui/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PodcastListScreen extends StatefulWidget {
  const PodcastListScreen({super.key});

  @override
  State<PodcastListScreen> createState() => _PodcastListScreenState();
}

class _PodcastListScreenState extends State<PodcastListScreen>
    with ScreenLogger {
  late PodcastListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    logger.info('PodcastListScreen initialized');
    _viewModel = context.read<PodcastListViewModel>();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    logger.info('Disposing PodcastListScreen');
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    logger.debug('PodcastListScreen view model changed');
    if (_viewModel.error != null) {
      logger.warn(
        'PodcastListScreen encountered an error: ${_viewModel.error}',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Consumer<PodcastListViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (viewModel.podcasts.isEmpty) {
              return Center(
                child: StyledText(
                  text: 'No podcasts available',
                  variant: TextVariant.body,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(Spacing.medium),
              itemCount: viewModel.podcasts.length,
              itemBuilder: (context, index) {
                final podcast = viewModel.podcasts[index];
                return _PodcastCard(podcast: podcast);
              },
            );
          },
        ),
      ),
    );
  }
}

class _PodcastCard extends StatelessWidget {
  final Podcast podcast;

  const _PodcastCard({required this.podcast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.medium),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (newContext) => ChangeNotifierProvider(
                create: (_) => PodcastDetailViewModel(
                  podcastId: podcast.id,
                  repository: PodcastRepository(
                    apiService: context.read<ApiService>(),
                  ),
                ),
                child: const PodcastDetailScreen(),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(Spacing.small),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.medium),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Spacing.small),
                child: podcast.imageUrl != null
                    ? Image.network(
                        podcast.imageUrl!,
                        width: Spacing.extraLarge,
                        height: Spacing.extraLarge,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: Spacing.extraLarge,
                            height: Spacing.extraLarge,
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.mic,
                              size: Spacing.large,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: Spacing.extraLarge,
                        height: Spacing.extraLarge,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.mic,
                          size: Spacing.large,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
              const SizedBox(width: Spacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StyledText(
                      text: podcast.name,
                      variant: TextVariant.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.extraSmall),
                    StyledText(
                      text: podcast.authorName,
                      variant: TextVariant.caption,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: Spacing.small),
                    StyledText(
                      text: podcast.description,
                      variant: TextVariant.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
