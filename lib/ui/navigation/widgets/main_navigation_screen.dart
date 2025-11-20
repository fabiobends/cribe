import 'package:cribe/core/logger/logger_mixins.dart';
import 'package:cribe/data/repositories/podcasts/podcast_repository.dart';
import 'package:cribe/data/services/api_service.dart';
import 'package:cribe/data/services/storage_service.dart';
import 'package:cribe/ui/podcasts/view_models/podcast_list_view_model.dart';
import 'package:cribe/ui/podcasts/widgets/podcasts_list_screen.dart';
import 'package:cribe/ui/settings/view_models/settings_view_model.dart';
import 'package:cribe/ui/settings/widgets/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with ScreenLogger {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    logger.info('MainNavigationScreen initialized');
  }

  @override
  void dispose() {
    logger.info('Disposing MainNavigationScreen');
    super.dispose();
  }

  void _onTabTapped(int index) {
    logger.info('Tab changed to index: $index');
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          Builder(
            builder: (context) => ChangeNotifierProvider<PodcastListViewModel>(
              create: (_) => PodcastListViewModel(
                repository:
                    PodcastRepository(apiService: context.read<ApiService>()),
              ),
              child: const PodcastListScreen(),
            ),
          ),
          Builder(
            builder: (context) => ChangeNotifierProvider<SettingsViewModel>(
              create: (_) => SettingsViewModel(
                storageService: context.read<StorageService>(),
              ),
              child: const SettingsScreen(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: theme.colorScheme.surfaceDim,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
