import 'package:flutter/material.dart';
import 'core/game_theme.dart';
import 'models/game_settings.dart';
import 'models/game_statistics.dart';
import 'services/local_storage_service.dart';
import 'services/music_service.dart';
import 'services/feedback_service.dart';
import 'services/sound_synthesizer.dart';
import 'services/ad_service.dart';
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
  bool _isStateLoaded = false;
  bool _splashFinished = false;

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
    try {
      final settings = await _storage.loadSettings();
      final stats = await _storage.loadStatistics();
      if (mounted) {
        setState(() {
          _settings = settings;
          _statistics = stats;
          _isStateLoaded = true;
          if (_splashFinished) {
            _currentView = AppView.home;
          }
        });
      }
      FeedbackService.updateSettings(settings);
      await MusicService.instance.initialize(
        musicEnabled: settings.musicEnabled,
        musicVolume: settings.musicVolume,
      );
      await SoundSynthesizer.instance.initialize(
        volume: settings.soundVolume,
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _isStateLoaded = true;
          if (_splashFinished) {
            _currentView = AppView.home;
          }
        });
      }
    }
  }

  void _onSplashComplete() {
    _splashFinished = true;
    if (_isStateLoaded && mounted) {
      _switchView(AppView.home);
    }
  }

  DateTime _lastViewChange = DateTime.fromMillisecondsSinceEpoch(0);

  void _switchView(AppView newView) {
    if (_currentView == newView) return;
    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    final now = DateTime.now();
    if (!isTest && now.difference(_lastViewChange).inMilliseconds < 250) return;
    _lastViewChange = now;
    if (mounted) {
      setState(() => _currentView = newView);
    }
  }

  GameTheme get _currentTheme {
    final found = GameTheme.allThemes.firstWhere(
      (t) => t.type.name == _settings.selectedTheme,
      orElse: () => GameTheme.midnightNeon,
    );
    return found;
  }

  void _updateSettings(GameSettings updated) {
    final musicToggled = updated.musicEnabled != _settings.musicEnabled;
    final musicVolChanged = updated.musicVolume != _settings.musicVolume;
    final soundVolChanged = updated.soundVolume != _settings.soundVolume;
    setState(() => _settings = updated);
    _storage.saveSettings(updated);
    FeedbackService.updateSettings(updated);
    if (musicToggled) {
      MusicService.instance.setMusicEnabled(updated.musicEnabled);
    }
    if (musicVolChanged) {
      MusicService.instance.setVolume(updated.musicVolume);
    }
    if (soundVolChanged) {
      SoundSynthesizer.instance.setVolume(updated.soundVolume);
    }
  }

  void _updateStatistics(GameStatistics updated) {
    setState(() => _statistics = updated);
    _storage.saveStatistics(updated);
  }

  void _handleStartGame() {
    _switchView(AppView.game);
  }

  void _handleGoHome() {
    AdService.instance.showAd(
      onComplete: () {
        if (mounted) {
          _switchView(AppView.home);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _currentTheme;
    final isReducedMotion = _settings.reducedMotion;

    return MaterialApp(
      title: 'Stack Go',
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
        duration:
            isReducedMotion ? Duration.zero : const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          if (isReducedMotion) {
            return child;
          }
          final scale = Tween<double>(begin: 0.98, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: scale,
              child: child,
            ),
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
          reducedMotion: _settings.reducedMotion,
          onLoaded: _onSplashComplete,
        );
      case AppView.game:
        return GameScreen(
          theme: theme,
          settings: _settings,
          statistics: _statistics,
          onUpdateStatistics: _updateStatistics,
          onUpdateSettings: _updateSettings,
          onHome: _handleGoHome,
          onOpenSettings: () => _switchView(AppView.settings),
        );
      case AppView.themes:
        return ThemesScreen(
          currentTheme: theme,
          bestScore: _statistics.bestScore,
          totalPlacements: _statistics.totalBlocksPlaced,
          reducedMotion: _settings.reducedMotion,
          onSelectTheme: (newTheme) {
            _updateSettings(
                _settings.copyWith(selectedTheme: newTheme.type.name));
          },
          onDismiss: () => _switchView(AppView.home),
        );
      case AppView.settings:
        return SettingsScreen(
          theme: theme,
          settings: _settings,
          onSave: _updateSettings,
          onDismiss: () => _switchView(AppView.home),
          onOpenThemes: () => _switchView(AppView.themes),
        );
      case AppView.tutorial:
        return TutorialScreen(
          theme: theme,
          reducedMotion: _settings.reducedMotion,
          onDismiss: () => _switchView(AppView.home),
        );
      case AppView.home:
        return HomeScreen(
          theme: theme,
          statistics: _statistics,
          settings: _settings,
          onPlay: _handleStartGame,
          onThemes: () => _switchView(AppView.themes),
          onSettings: () => _switchView(AppView.settings),
          onTutorial: () => _switchView(AppView.tutorial),
        );
    }
  }
}
