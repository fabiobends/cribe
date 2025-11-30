import 'package:cribe/core/constants/spacing.dart';
import 'package:cribe/core/logger/logger_mixins.dart';
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
      'EpisodeDetailScreen initialized for episode ${_viewModel.episode.id}',
    );
  }

  void _goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          _buildEpisodeContent(context),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
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
          text: _viewModel.episode.name,
          variant: TextVariant.subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (_viewModel.episode.imageUrl != null)
              Image.network(
                _viewModel.episode.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.headphones,
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
                  Icons.headphones,
                  size: Spacing.huge,
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

  Widget _buildEpisodeContent(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<EpisodeDetailViewModel>(
      builder: (context, viewModel, child) {
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
                      size: Spacing.medium,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: Spacing.small),
                    StyledText(
                      text: viewModel.datePublished,
                      variant: TextVariant.caption,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: Spacing.medium),
                    Icon(
                      Icons.access_time,
                      size: Spacing.medium,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: Spacing.small),
                    StyledText(
                      text: viewModel.duration,
                      variant: TextVariant.caption,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.large),
                // Play button and progress
                _buildPlaybackControls(context),
                const SizedBox(height: Spacing.large),
                // Transcript section
                const SizedBox(height: Spacing.small),
                _buildTranscriptView(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTranscriptView(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<EpisodeDetailViewModel>(
      builder: (context, vm, child) {
        // show snackbar on error
        if (vm.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: StyledText(
                  text: vm.error!,
                  variant: TextVariant.body,
                  color: theme.colorScheme.onError,
                ),
                backgroundColor: theme.colorScheme.error,
              ),
            );
            vm.setError(null);
          });
        }

        final chunks = vm.chunks;
        final speakers = vm.speakers;

        // Show loading state if no chunks yet
        if (chunks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.large),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: Spacing.medium),
                  StyledText(
                    text: 'Transcribing this episode...',
                    variant: TextVariant.body,
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          );
        }

        // Get speaker turns from view model
        final turns = vm.speakerTurns;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: turns.map((turn) {
            final name =
                speakers[turn.speakerIndex] ?? 'Speaker ${turn.speakerIndex}';

            // Determine alignment: even -> left, odd -> right
            final alignLeft = turn.speakerIndex % 2 == 0;

            // Current audio position in seconds
            final audioPos = vm.currentAudioPosition;

            // Build text spans with proper highlighting based on audio time
            final textSpans = turn.chunks.map((chunk) {
              // Word should be highlighted only if audio has passed its start time
              // Use a small threshold to avoid highlighting words at position 0
              final isSpokenOrCurrent = audioPos > 0 &&
                  audioPos >= (chunk.start - vm.transcriptSyncOffset);
              return TextSpan(
                text: '${chunk.text} ',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isSpokenOrCurrent
                      ? theme.colorScheme
                          .onPrimary // Already spoken or current: full brightness
                      : theme.colorScheme.onPrimary
                          .withValues(alpha: 0.4), // Otherwise dimmed
                ),
              );
            }).toList();

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.small),
              child: Row(
                mainAxisAlignment:
                    alignLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Column(
                      crossAxisAlignment: alignLeft
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                      children: [
                        // Speaker name underlined
                        StyledText(
                          text: name,
                          variant: TextVariant.label,
                          color: theme.colorScheme.onPrimary
                              .withValues(alpha: 0.7),
                        ),
                        Container(
                          height: Spacing.tiny,
                          width: Spacing.large,
                          color: alignLeft
                              ? theme.colorScheme.primary
                              : theme.colorScheme.secondary,
                        ),
                        const SizedBox(height: Spacing.extraSmall),
                        // Words with proper highlighting per chunk
                        RichText(
                          textAlign:
                              alignLeft ? TextAlign.left : TextAlign.right,
                          text: TextSpan(children: textSpans),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPlaybackControls(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<EpisodeDetailViewModel>(
      builder: (context, viewModel, child) {
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
                        viewModel.isCompleted
                            ? Icons.replay_circle_filled
                            : (viewModel.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled),
                        size: Spacing.extraLarge,
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
                      onChanged: viewModel.seekTo,
                      activeColor: theme.colorScheme.primary,
                      inactiveColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.medium,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          viewModel.isBuffering
                              ? const SizedBox(
                                  width: Spacing.medium,
                                  height: Spacing.medium,
                                  child: CircularProgressIndicator(
                                    strokeWidth: Spacing.tiny,
                                  ),
                                )
                              : StyledText(
                                  text: viewModel.elapsedTime,
                                  variant: TextVariant.caption,
                                  color: theme.colorScheme.onSurface,
                                ),
                          StyledText(
                            text: viewModel.remainingTime,
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
      },
    );
  }
}
