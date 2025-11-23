import 'package:cribe/data/repositories/podcasts/fake_podcast_repository.dart';
import 'package:cribe/data/services/player_service.dart';
import 'package:cribe/domain/models/podcast.dart';
import 'package:cribe/ui/auth/view_models/fake_login_view_model.dart';
import 'package:cribe/ui/auth/view_models/fake_register_view_model.dart';
import 'package:cribe/ui/auth/view_models/login_view_model.dart';
import 'package:cribe/ui/auth/view_models/register_view_model.dart';
import 'package:cribe/ui/auth/widgets/login_screen.dart';
import 'package:cribe/ui/auth/widgets/register_screen.dart';
import 'package:cribe/ui/dev_helper/widgets/component_showcase.dart';
import 'package:cribe/ui/navigation/widgets/main_navigation_screen.dart';
import 'package:cribe/ui/podcasts/view_models/episode_detail_view_model.dart';
import 'package:cribe/ui/podcasts/view_models/fake_podcast_detail_view_model.dart';
import 'package:cribe/ui/podcasts/view_models/podcast_detail_view_model.dart';
import 'package:cribe/ui/podcasts/view_models/podcast_list_view_model.dart';
import 'package:cribe/ui/podcasts/widgets/episode_detail_screen.dart';
import 'package:cribe/ui/podcasts/widgets/podcast_detail_screen.dart';
import 'package:cribe/ui/podcasts/widgets/podcasts_list_screen.dart';
import 'package:cribe/ui/settings/view_models/fake_settings_view_model.dart';
import 'package:cribe/ui/settings/view_models/settings_view_model.dart';
import 'package:cribe/ui/settings/widgets/settings_screen.dart';
import 'package:cribe/ui/shared/widgets/styled_button.dart';
import 'package:cribe/ui/shared/widgets/styled_dropdown.dart';
import 'package:cribe/ui/shared/widgets/styled_switch.dart';
import 'package:cribe/ui/shared/widgets/styled_text.dart';
import 'package:cribe/ui/shared/widgets/styled_text_button.dart';
import 'package:cribe/ui/shared/widgets/styled_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StorybookView extends StatelessWidget {
  const StorybookView({super.key});
  static const _tabs = [
    'Widgets',
    'Screens',
  ];
  static const _components = [
    'StyledButton',
    'StyledText',
    'StyledTextField',
    'StyledTextButton',
    'StyledSwitch',
    'StyledDropdown',
  ];
  static const _screens = [
    'LoginScreen',
    'RegisterScreen',
    'MainNavigationScreen',
    'PodcastListScreen',
    'PodcastDetailScreen',
    'EpisodeDetailScreen',
    'SettingsScreen',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: colorScheme.surfaceBright,
        appBar: TabBar(
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
        body: TabBarView(
          children: [
            _buildList(context, _components),
            _buildList(context, _screens),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<String> items) {
    return ListView(
      children: items.map((name) {
        return ListTile(
          title: StyledText(text: name, variant: TextVariant.body),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => _buildStoryBookItem(name),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildStoryBookItem(String name) {
    // Handle components
    switch (name) {
      case 'StyledButton':
        return ComponentShowcase(
          name: name,
          variants: [
            StyledButton(
              text: 'Primary Button',
              variant: ButtonVariant.primary,
              onPressed: () {},
            ),
            StyledButton(
              text: 'Secondary Button',
              variant: ButtonVariant.secondary,
              onPressed: () {},
            ),
            StyledButton(
              text: 'Danger Button',
              variant: ButtonVariant.danger,
              onPressed: () {},
            ),
            StyledButton(
              text: 'Loading Button',
              variant: ButtonVariant.primary,
              onPressed: () {},
              isLoading: true,
            ),
            StyledButton(
              text: 'Disabled Button',
              variant: ButtonVariant.primary,
              onPressed: () {},
              isEnabled: false,
            ),
          ],
        );

      case 'StyledText':
        return ComponentShowcase(
          name: name,
          variants: const [
            StyledText(
              text: 'Headline Text',
              variant: TextVariant.headline,
            ),
            StyledText(
              text: 'Title Text',
              variant: TextVariant.title,
            ),
            StyledText(
              text: 'Subtitle Text',
              variant: TextVariant.subtitle,
            ),
            StyledText(
              text: 'Body Text',
              variant: TextVariant.body,
            ),
            StyledText(
              text: 'Label Text',
              variant: TextVariant.label,
            ),
            StyledText(
              text: 'Caption Text',
              variant: TextVariant.caption,
            ),
            StyledText(
              text: 'Custom Color Text',
              variant: TextVariant.body,
              color: Colors.blue,
            ),
            StyledText(
              text:
                  'This is a very long text that will be truncated with ellipsis when it exceeds the maximum lines limit, more text to show truncation',
              variant: TextVariant.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );

      case 'StyledTextField':
        return ComponentShowcase(
          name: name,
          variants: [
            StyledTextField(
              label: 'Email',
              hint: 'Enter your email',
              controller: TextEditingController(),
            ),
            StyledTextField(
              label: 'Password',
              hint: 'Enter your password',
              controller: TextEditingController(),
              obscureText: true,
            ),
            StyledTextField(
              label: 'Search',
              hint: 'Search for items',
              controller: TextEditingController(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: const Icon(Icons.clear),
              onPressedSuffixIcon: () {
                // Clear action
              },
            ),
            StyledTextField(
              label: 'API Endpoint',
              hint: 'Enter URL',
              controller: TextEditingController(),
              suffixIcon: const Icon(Icons.link),
              keyboardType: TextInputType.url,
              helperText: 'Override the default API endpoint for testing',
            ),
          ],
        );

      case 'StyledTextButton':
        return ComponentShowcase(
          name: name,
          variants: [
            StyledTextButton(
              text: 'Text Button',
              onPressed: () {},
            ),
            StyledTextButton(
              text: 'Disabled Button',
              onPressed: () {},
              isEnabled: false,
            ),
          ],
        );

      case 'StyledSwitch':
        return ComponentShowcase(
          name: name,
          variants: [
            StyledSwitch(
              value: true,
              onChanged: (value) {},
              title: 'Enable Feature',
              subtitle: 'Toggle this feature on/off',
            ),
            StyledSwitch(
              value: false,
              onChanged: (value) {},
              title: 'Disabled Switch',
              subtitle: 'This switch is disabled',
              enabled: false,
            ),
            StyledSwitch(
              value: true,
              onChanged: (value) {},
            ),
          ],
        );

      case 'StyledDropdown':
        return ComponentShowcase(
          name: name,
          variants: [
            StyledDropdown<String>(
              label: 'Select Option',
              value: 'Option 1',
              options: const [
                (value: 'Option 1', label: 'Option 1'),
                (value: 'Option 2', label: 'Option 2'),
                (value: 'Option 3', label: 'Option 3'),
              ],
              onChanged: (value) {},
              subtitle: 'Choose one of the available options',
            ),
            StyledDropdown<String>(
              label: 'A/B Test Variant',
              hint: 'Select variant',
              options: const [
                (value: 'A', label: 'Variant A'),
                (value: 'B', label: 'Variant B'),
              ],
              onChanged: (value) {},
              subtitle: 'Controls which version of the feature is shown',
            ),
          ],
        );

      // Handle screens with fake view models
      case 'LoginScreen':
        return Scaffold(
          appBar:
              AppBar(title: StyledText(text: name, variant: TextVariant.title)),
          body: ChangeNotifierProvider<LoginViewModel>(
            create: (_) => FakeLoginViewModel(),
            child: const LoginScreen(),
          ),
        );

      case 'RegisterScreen':
        return Scaffold(
          appBar:
              AppBar(title: StyledText(text: name, variant: TextVariant.title)),
          body: ChangeNotifierProvider<RegisterViewModel>(
            create: (_) => FakeRegisterViewModel(),
            child: const RegisterScreen(),
          ),
        );

      case 'MainNavigationScreen':
        return Scaffold(
          appBar:
              AppBar(title: StyledText(text: name, variant: TextVariant.title)),
          body: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) =>
                    PodcastListViewModel(repository: FakePodcastRepository()),
              ),
              ChangeNotifierProvider(
                create: (_) => FakeSettingsViewModel(),
              ),
            ],
            child: const MainNavigationScreen(),
          ),
        );

      case 'PodcastListScreen':
        return Scaffold(
          appBar:
              AppBar(title: StyledText(text: name, variant: TextVariant.title)),
          body: ChangeNotifierProvider(
            create: (_) =>
                PodcastListViewModel(repository: FakePodcastRepository()),
            child: const PodcastListScreen(),
          ),
        );

      case 'PodcastDetailScreen':
        return Scaffold(
          appBar:
              AppBar(title: StyledText(text: name, variant: TextVariant.title)),
          body: ChangeNotifierProvider<PodcastDetailViewModel>(
            create: (_) => FakePodcastDetailViewModel(),
            child: const PodcastDetailScreen(),
          ),
        );

      case 'EpisodeDetailScreen':
        return Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: StyledText(text: name, variant: TextVariant.title),
              ),
              body: ChangeNotifierProvider(
                create: (_) => EpisodeDetailViewModel(
                  episode: Episode(
                    id: 1,
                    externalId: 'fake-episode-1',
                    podcastId: 1,
                    name: 'An Update from Ira',
                    description:
                        '<p>Ira Glass shares some news about This American Life</p>\n\n<p>To sign up as a Life Partner, visit <a href="https://thisamericanlife.supercast.com?utm_campaign=lifepartners&amp;utm_source=rss&amp;utm_medium=shownotes">thisamericanlife.org/lifepartners</a></p>',
                    audioUrl:
                        'https://www.thisamericanlife.org/sites/default/files/audio/upload/extra/life_partners_standalone_promo_10_15_2025_v2.mp3',
                    imageUrl: 'https://picsum.photos/400/400?random=1',
                    datePublished: DateTime.now()
                        .subtract(const Duration(days: 7))
                        .toIso8601String(),
                    duration: 3600,
                    createdAt: DateTime.now().subtract(const Duration(days: 7)),
                    updatedAt: DateTime.now(),
                  ),
                  playerService: PlayerService(),
                ),
                child: const EpisodeDetailScreen(),
              ),
            );
          },
        );

      case 'SettingsScreen':
        return Scaffold(
          appBar:
              AppBar(title: StyledText(text: name, variant: TextVariant.title)),
          body: ChangeNotifierProvider<SettingsViewModel>(
            create: (_) => FakeSettingsViewModel(),
            child: const SettingsScreen(),
          ),
        );

      default:
        return Scaffold(
          appBar:
              AppBar(title: StyledText(text: name, variant: TextVariant.title)),
          body: Center(
            child: StyledText(
              text: '$name not implemented yet',
              variant: TextVariant.body,
            ),
          ),
        );
    }
  }
}
