import 'package:cribe/core/constants/spacing.dart';
import 'package:cribe/core/logger/logger_mixins.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/ui/podcasts/view_models/episode_detail_view_model.dart';
import 'package:cribe/ui/podcasts/view_models/podcast_detail_view_model.dart';
import 'package:cribe/ui/podcasts/widgets/episode_detail_screen.dart';
import 'package:cribe/ui/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PodcastDetailScreen extends StatefulWidget {
  const PodcastDetailScreen({
    super.key,
  });

  @override
  State<PodcastDetailScreen> createState() => _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends State<PodcastDetailScreen>
    with ScreenLogger {
  late PodcastDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<PodcastDetailViewModel>();
    logger.info(
      'PodcastDetailScreen initialized for podcast ${_viewModel.podcast?.id}',
    );
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    logger.info('Disposing PodcastDetailScreen');
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    logger.debug('PodcastDetailScreen view model changed');
    if (_viewModel.error != null) {
      logger.warn(
        'PodcastDetailScreen encountered an error: ${_viewModel.error}',
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

  void _goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Consumer<PodcastDetailViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.podcast == null) {
            return Center(
              child: StyledText(
                text: 'Podcast not found',
                variant: TextVariant.body,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, viewModel.podcast!),
              _buildEpisodesList(context, viewModel),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, Podcast podcast) {
    final theme = Theme.of(context);
    final expandedHeight = MediaQuery.of(context).size.height * 0.25;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: theme.colorScheme.onSurface,
        ),
        onPressed: () => _goBack(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: StyledText(
          text: podcast.name,
          variant: TextVariant.subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (podcast.imageUrl != null)
              Image.network(
                podcast.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.mic,
                      size: Spacing.huge,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              )
            else
              Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.mic,
                  size: Spacing.huge * 2,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEpisodesList(
    BuildContext context,
    PodcastDetailViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final podcast = viewModel.podcast!;

    return SliverList(
      delegate: SliverChildListDelegate([
        // Podcast info section
        Padding(
          padding: const EdgeInsets.all(Spacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StyledText(
                text: 'By ${podcast.authorName}',
                variant: TextVariant.subtitle,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: Spacing.medium),
              StyledText(
                text: podcast.description,
                variant: TextVariant.body,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: Spacing.large),
              StyledText(
                text: 'Episodes (${viewModel.episodes.length})',
                variant: TextVariant.title,
              ),
              const SizedBox(height: Spacing.medium),
            ],
          ),
        ),
        ...viewModel.episodes.map((formattedEpisode) {
          return _EpisodeCard(
            formattedEpisode: formattedEpisode,
          );
        }),
        const SizedBox(height: Spacing.large),
      ]),
    );
  }
}

class _EpisodeCard extends StatelessWidget {
  final FormattedEpisode formattedEpisode;

  const _EpisodeCard({
    required this.formattedEpisode,
  });

  void _navigateToEpisodeDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) =>
              EpisodeDetailViewModel(episode: formattedEpisode.episode),
          child: const EpisodeDetailScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final episode = formattedEpisode.episode;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.medium,
        vertical: Spacing.small,
      ),
      child: InkWell(
        onTap: () => _navigateToEpisodeDetail(context),
        borderRadius: BorderRadius.circular(Spacing.small),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.medium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Spacing.small),
                child: episode.imageUrl != null
                    ? Image.network(
                        episode.imageUrl!,
                        width: Spacing.extraLarge,
                        height: Spacing.extraLarge,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Container(
                            width: Spacing.extraLarge,
                            height: Spacing.extraLarge,
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: SizedBox(
                                width: Spacing.medium,
                                height: Spacing.medium,
                                child: CircularProgressIndicator(
                                  strokeWidth: Spacing.tiny,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder(theme);
                        },
                      )
                    : _buildPlaceholder(theme),
              ),
              const SizedBox(width: Spacing.medium),
              // Episode info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StyledText(
                      text: episode.name,
                      variant: TextVariant.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.extraSmall),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: Spacing.extraSmall),
                        StyledText(
                          text: formattedEpisode.duration,
                          variant: TextVariant.caption,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: Spacing.small),
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: Spacing.extraSmall),
                        StyledText(
                          text: formattedEpisode.datePublished,
                          variant: TextVariant.caption,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.small),
                    StyledText(
                      text: episode.description,
                      variant: TextVariant.caption,
                      maxLines: 3,
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

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      width: Spacing.extraLarge,
      height: Spacing.extraLarge,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.play_circle_outline,
        size: Spacing.large,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
