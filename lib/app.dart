import 'package:flutter/material.dart';
import 'core/game_theme.dart';
import 'models/game_settings.dart';
import 'models/game_statistics.dart';
import 'services/local_storage_service.dart';
import 'services/music_service.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/game_screen.dart';
import 'ui/screens/themes_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/tutorial_screen.dart';

enum AppView {
  splash,
  home,
  game,
  themes,
  settings,
  tutorial,
}

class StackPulseApp extends StatefulWidget {
  const StackPulseApp({super.key});

  @override
  State<StackPulseApp> createState() => _StackPulseAppState();
}

class _StackPulseAppState extends State<StackPulseApp>
    with WidgetsBindingObserver {
  final LocalStorageService _storage = LocalStorageService();
  GameSettings _settings = const GameSettings();
  GameStatistics _statistics = const GameStatistics();
  AppView _currentView = AppView.splash;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    MusicService.instance.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    MusicService.instance.onAppLifecycleStateChanged(state);
  }

  Future<void> _loadState() async {
    final settings = await _storage.loadSettings();
    final stats = await _storage.loadStatistics();
    setState(() {
      _settings = settings;
      _statistics = stats;
      _isLoading = false;
    });
    await MusicService.instance.initialize(musicEnabled: settings.musicEnabled);
  }

  GameTheme get _currentTheme {
    final found = GameTheme.allThemes.firstWhere(
      (t) => t.type.name == _settings.selectedTheme,
      orElse: () => GameTheme.midnightNeon,
    );
    return found;
  }

  void _updateSettings(GameSettings updated) {
    setState(() => _settings = updated);
    _storage.saveSettings(updated);
    MusicService.instance.setMusicEnabled(updated.musicEnabled);
  }

  void _updateStatistics(GameStatistics updated) {
    setState(() => _statistics = updated);
    _storage.saveStatistics(updated);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFF061225),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF13D9FF)),
          ),
        ),
      );
    }

    final theme = _currentTheme;

    return MaterialApp(
      title: 'Stack Pulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Plus Jakarta Sans',
        scaffoldBackgroundColor: theme.background,
        colorScheme: ColorScheme.dark(
          primary: theme.primaryAccent,
          surface: theme.surface,
        ),
      ),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_currentView),
          child: _buildCurrentView(theme),
        ),
      ),
    );
  }

  Widget _buildCurrentView(GameTheme theme) {
    switch (_currentView) {
      case AppView.splash:
        return SplashScreen(
          theme: theme,
          onLoaded: () => setState(() => _currentView = AppView.home),
        );
      case AppView.game:
        return GameScreen(
          theme: theme,
          settings: _settings,
          statistics: _statistics,
          onUpdateStatistics: _updateStatistics,
          onHome: () => setState(() => _currentView = AppView.home),
          onOpenSettings: () => setState(() => _currentView = AppView.settings),
        );
      case AppView.themes:
        return ThemesScreen(
          currentTheme: theme,
          bestScore: _statistics.bestScore,
          onSelectTheme: (newTheme) {
            _updateSettings(
                _settings.copyWith(selectedTheme: newTheme.type.name));
          },
          onDismiss: () => setState(() => _currentView = AppView.home),
        );
      case AppView.settings:
        return SettingsScreen(
          theme: theme,
          settings: _settings,
          onSave: _updateSettings,
          onDismiss: () => setState(() => _currentView = AppView.home),
          onOpenThemes: () => setState(() => _currentView = AppView.themes),
        );
      case AppView.tutorial:
        return TutorialScreen(
          theme: theme,
          onDismiss: () => setState(() => _currentView = AppView.home),
        );
      case AppView.home:
        return HomeScreen(
          theme: theme,
          statistics: _statistics,
          onPlay: () => setState(() => _currentView = AppView.game),
          onThemes: () => setState(() => _currentView = AppView.themes),
          onSettings: () => setState(() => _currentView = AppView.settings),
          onTutorial: () => setState(() => _currentView = AppView.tutorial),
        );
    }
  }
}
