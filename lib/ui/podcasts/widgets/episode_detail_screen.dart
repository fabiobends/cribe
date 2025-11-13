import 'package:cribe/core/constants/spacing.dart';
import 'package:cribe/core/logger/logger_mixins.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/ui/podcasts/view_models/episode_detail_view_model.dart';
import 'package:cribe/ui/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EpisodeDetailScreen extends StatefulWidget {
  const EpisodeDetailScreen({
    super.key,
  });

  @override
  State<EpisodeDetailScreen> createState() => _EpisodeDetailScreenState();
}

class _EpisodeDetailScreenState extends State<EpisodeDetailScreen>
    with ScreenLogger {
  late EpisodeDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<EpisodeDetailViewModel>();
    logger.info(
      'EpisodeDetailScreen initialized for episode ${_viewModel.episode?.id}',
    );
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    logger.info('Disposing EpisodeDetailScreen');
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    logger.debug('EpisodeDetailScreen view model changed');
    if (_viewModel.error != null) {
      logger.warn(
        'EpisodeDetailScreen encountered an error: ${_viewModel.error}',
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
      body: Consumer<EpisodeDetailViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.episode == null) {
            return Center(
              child: StyledText(
                text: 'Episode not found',
                variant: TextVariant.body,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, viewModel.episode!),
              _buildEpisodeContent(context, viewModel),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, Episode episode) {
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
          text: episode.name,
          variant: TextVariant.subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (episode.imageUrl != null)
              Image.network(
                episode.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.headphones,
                      size: 100,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              )
            else
              Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.headphones,
                  size: 100,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    theme.colorScheme.surface.withValues(alpha: 0.8),
                    theme.colorScheme.surface,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEpisodeContent(
    BuildContext context,
    EpisodeDetailViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final episode = viewModel.episode!;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Episode metadata
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: Spacing.small),
                StyledText(
                  text: viewModel.formatDate(episode.datePublished),
                  variant: TextVariant.caption,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: Spacing.medium),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: Spacing.small),
                StyledText(
                  text: viewModel.formatDuration(episode.duration),
                  variant: TextVariant.caption,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: Spacing.large),

            // Play button and progress
            _buildPlaybackControls(context, viewModel),
            const SizedBox(height: Spacing.large),

            // Description section
            StyledText(
              text: 'Description',
              variant: TextVariant.subtitle,
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(height: Spacing.small),
            StyledText(
              text: episode.description,
              variant: TextVariant.body,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaybackControls(
    BuildContext context,
    EpisodeDetailViewModel viewModel,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.medium),
        child: Column(
          children: [
            // Play/Pause button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    viewModel.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: viewModel.togglePlayPause,
                ),
              ],
            ),
            const SizedBox(height: Spacing.small),

            // Progress bar
            Column(
              children: [
                Slider(
                  value: viewModel.playbackProgress,
                  onChanged: (value) => viewModel.seekTo(value),
                  activeColor: theme.colorScheme.primary,
                  inactiveColor: theme.colorScheme.surfaceContainerHighest,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: Spacing.medium),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StyledText(
                        text: viewModel.getCurrentTime(),
                        variant: TextVariant.caption,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      StyledText(
                        text: viewModel.getTotalTime(),
                        variant: TextVariant.caption,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
