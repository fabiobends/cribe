import 'package:cribe/core/constants/spacing.dart';
import 'package:cribe/core/logger/logger_mixins.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/ui/podcasts/view_models/podcast_detail_view_model.dart';
import 'package:cribe/ui/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PodcastDetailScreen extends StatefulWidget {
  final int podcastId;

  const PodcastDetailScreen({
    super.key,
    required this.podcastId,
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
    logger.info(
      'PodcastDetailScreen initialized for podcast ${widget.podcastId}',
    );
    _viewModel = context.read<PodcastDetailViewModel>();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: StyledText(
            text: _viewModel.error!,
            variant: TextVariant.body,
            color: Colors.white,
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
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
        onPressed: () => Navigator.of(context).pop(),
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
      BuildContext context, PodcastDetailViewModel viewModel,) {
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
        ...viewModel.episodes.map((episode) {
          return _EpisodeCard(
            episode: episode,
            viewModel: viewModel,
          );
        }),
        const SizedBox(height: Spacing.large),
      ]),
    );
  }
}

class _EpisodeCard extends StatelessWidget {
  final Episode episode;
  final PodcastDetailViewModel viewModel;

  const _EpisodeCard({
    required this.episode,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.medium,
        vertical: Spacing.small,
      ),
      child: InkWell(
        onTap: () {
          // TODO: Play episode or navigate to episode player
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.medium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
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
                                  strokeWidth: 2,
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
                          text: viewModel.formatDuration(episode.duration),
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
                          text: viewModel.formatDate(episode.datePublished),
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
