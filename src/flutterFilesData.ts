export interface FlutterCodeFile {
  path: string;
  category: 'core' | 'game' | 'models' | 'services' | 'ui' | 'test' | 'config';
  description: string;
  content: string;
}

export const FLUTTER_PROJECT_FILES: FlutterCodeFile[] = [
  {
    path: 'pubspec.yaml',
    category: 'config',
    description: 'Flutter project dependencies: Flame ^1.20.0, shared_preferences, flutter_test',
    content: `name: stack_pulse
description: "Stack Pulse - Premium Minimalist 2D Precision Stacking Game in Flutter & Flame"
publish_to: "none"
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  flame: ^1.20.0
  shared_preferences: ^2.2.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true`,
  },
  {
    path: 'lib/main.dart',
    category: 'core',
    description: 'App entry point: locks orientation to portrait and sets system bar styling',
    content: `import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0B1020),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const StackPulseApp());
}`,
  },
  {
    path: 'lib/app.dart',
    category: 'core',
    description: 'Main app widget, state router (Home, Game, Themes, Settings, Tutorial)',
    content: `import 'package:flutter/material.dart';
import 'core/game_theme.dart';
import 'models/game_settings.dart';
import 'models/game_statistics.dart';
import 'services/local_storage_service.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/game_screen.dart';
import 'ui/screens/themes_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/tutorial_screen.dart';

enum AppView { home, game, themes, settings, tutorial }

class StackPulseApp extends StatefulWidget {
  const StackPulseApp({super.key});

  @override
  State<StackPulseApp> createState() => _StackPulseAppState();
}

class _StackPulseAppState extends State<StackPulseApp> {
  final LocalStorageService _storage = LocalStorageService();
  GameSettings _settings = const GameSettings();
  GameStatistics _statistics = const GameStatistics();
  AppView _currentView = AppView.home;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final settings = await _storage.loadSettings();
    final stats = await _storage.loadStatistics();
    setState(() {
      _settings = settings;
      _statistics = stats;
      _isLoading = false;
    });
  }

  GameTheme get _currentTheme {
    return GameTheme.allThemes.firstWhere(
      (t) => t.type.name == _settings.selectedTheme,
      orElse: () => GameTheme.midnightNeon,
    );
  }

  void _updateSettings(GameSettings updated) {
    setState(() => _settings = updated);
    _storage.saveSettings(updated);
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
          backgroundColor: Color(0xFF0B1020),
          body: Center(child: CircularProgressIndicator(color: Color(0xFF55DDFB))),
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
          background: theme.background,
        ),
      ),
      home: _buildCurrentView(theme),
    );
  }

  Widget _buildCurrentView(GameTheme theme) {
    switch (_currentView) {
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
            _updateSettings(_settings.copyWith(selectedTheme: newTheme.type.name));
          },
          onDismiss: () => setState(() => _currentView = AppView.home),
        );
      case AppView.settings:
        return SettingsScreen(
          theme: theme,
          settings: _settings,
          onSave: _updateSettings,
          onDismiss: () => setState(() => _currentView = AppView.home),
        );
      case AppView.tutorial:
        return TutorialScreen(
          theme: theme,
          onDismiss: () => setState(() => _currentView = AppView.home),
        );
      case AppView.home:
      default:
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
}`,
  },
  {
    path: 'lib/core/game_config.dart',
    category: 'core',
    description: 'Centralized gameplay constants, speeds, dimensions, tolerances',
    content: `class GameConfig {
  static const double logicalWidth = 360.0;
  static const double logicalHeight = 640.0;
  static const double baseBlockWidth = 210.0;
  static const double blockHeight = 26.0;
  static const double basePositionY = 120.0;
  static const double initialSpeed = 160.0;
  static const double maxSpeed = 340.0;
  static const double speedIncrementPerPoint = 5.0;
  static const double toleranceRatio = 0.025;
  static const double minTolerance = 2.0;
  static const double maxTolerance = 5.0;
  static const double boundaryPadding = 12.0;
  static const double cameraFollowThresholdY = 320.0;
  static const double cameraEasingSpeed = 5.0;
}`,
  },
  {
    path: 'lib/core/game_theme.dart',
    category: 'core',
    description: 'The 4 themes: Midnight Neon, Aurora, Sunset Pulse, Arctic Glow',
    content: `import 'package:flutter/material.dart';

enum ThemeType { midnightNeon, aurora, sunsetPulse, arcticGlow }

class GameTheme {
  final ThemeType type;
  final String name;
  final String description;
  final int unlockScore;
  final Color background;
  final Color secondaryBackground;
  final Color surface;
  final Color primaryAccent;
  final Color secondaryAccent;
  final Color successAccent;
  final Color warningAccent;
  final Color text;
  final Color secondaryText;
  final List<Color> blockPalette;

  const GameTheme({
    required this.type,
    required this.name,
    required this.description,
    required this.unlockScore,
    required this.background,
    required this.secondaryBackground,
    required this.surface,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.successAccent,
    required this.warningAccent,
    required this.text,
    required this.secondaryText,
    required this.blockPalette,
  });

  static const GameTheme midnightNeon = GameTheme(
    type: ThemeType.midnightNeon,
    name: 'Midnight Neon',
    description: 'Electric cyan and violet pulses against deep midnight navy.',
    unlockScore: 0,
    background: Color(0xFF0B1020),
    secondaryBackground: Color(0xFF141C30),
    surface: Color(0xFF1D2940),
    primaryAccent: Color(0xFF55DDFB),
    secondaryAccent: Color(0xFF8B5CF6),
    successAccent: Color(0xFF57E5B3),
    warningAccent: Color(0xFFF7C76D),
    text: Color(0xFFF7FAFF),
    secondaryText: Color(0xFF9CAEC8),
    blockPalette: [
      Color(0xFF55DDFB),
      Color(0xFF60A5FA),
      Color(0xFF8B5CF6),
      Color(0xFFA78BFA),
      Color(0xFF57E5B3),
      Color(0xFF2DD4BF),
    ],
  );

  static const GameTheme aurora = GameTheme(
    type: ThemeType.aurora,
    name: 'Aurora',
    description: 'Ethereal emerald and turquoise shimmering in arctic polar skies.',
    unlockScore: 10,
    background: Color(0xFF071B19),
    secondaryBackground: Color(0xFF0D2C28),
    surface: Color(0xFF143D38),
    primaryAccent: Color(0xFF34D399),
    secondaryAccent: Color(0xFF2DD4BF),
    successAccent: Color(0xFF6EE7B7),
    warningAccent: Color(0xFFFCD34D),
    text: Color(0xFFF0FDF4),
    secondaryText: Color(0xFF86EFAC),
    blockPalette: [
      Color(0xFF10B981),
      Color(0xFF34D399),
      Color(0xFF2DD4BF),
      Color(0xFF06B6D4),
      Color(0xFF14B8A6),
      Color(0xFF059669),
    ],
  );

  static const GameTheme sunsetPulse = GameTheme(
    type: ThemeType.sunsetPulse,
    name: 'Sunset Pulse',
    description: 'Warm orange, coral and velvet violet horizons.',
    unlockScore: 25,
    background: Color(0xFF1C0D1E),
    secondaryBackground: Color(0xFF2C132F),
    surface: Color(0xFF3D1B42),
    primaryAccent: Color(0xFFF97316),
    secondaryAccent: Color(0xFFEC4899),
    successAccent: Color(0xFFF43F5E),
    warningAccent: Color(0xFFFBBF24),
    text: Color(0xFFFFF1F2),
    secondaryText: Color(0xFFFDA4AF),
    blockPalette: [
      Color(0xFFF97316),
      Color(0xFFFB923C),
      Color(0xFFF43F5E),
      Color(0xFFE11D48),
      Color(0xFFC026D3),
      Color(0xFF9333EA),
    ],
  );

  static const GameTheme arcticGlow = GameTheme(
    type: ThemeType.arcticGlow,
    name: 'Arctic Glow',
    description: 'Pristine glacial ice, deep oceanic sapphire and frost crystal white.',
    unlockScore: 50,
    background: Color(0xFF061325),
    secondaryBackground: Color(0xFF0C203B),
    surface: Color(0xFF142F54),
    primaryAccent: Color(0xFF38BDF8),
    secondaryAccent: Color(0xFFE0F2FE),
    successAccent: Color(0xFF7DD3FC),
    warningAccent: Color(0xFFFDE68A),
    text: Color(0xFFF8FAFC),
    secondaryText: Color(0xFFBAE6FD),
    blockPalette: [
      Color(0xFF38BDF8),
      Color(0xFF0284C7),
      Color(0xFF7DD3FC),
      Color(0xFFBAE6FD),
      Color(0xFFE0F2FE),
      Color(0xFF60A5FA),
    ],
  );

  static const List<GameTheme> allThemes = [
    midnightNeon,
    aurora,
    sunsetPulse,
    arcticGlow,
  ];

  Color getBlockColor(int index) => blockPalette[index % blockPalette.length];
}`,
  },
  {
    path: 'lib/services/feedback_service.dart',
    category: 'services',
    description: 'Haptic and Sound feedback service with consecutive streak pitch and intensity scaling',
    content: `import 'package:flutter/services.dart';

class FeedbackService {
  static void triggerNormalPlacement({required bool haptics, required bool sound}) {
    if (haptics) {
      HapticFeedback.lightImpact();
    }
    if (sound) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Plays unique feedback for consecutive perfect placements, escalating response per streak
  static void triggerPerfectPlacement({
    required bool haptics,
    required bool sound,
    int streak = 1,
  }) {
    if (haptics) {
      if (streak >= 5) {
        HapticFeedback.heavyImpact();
      } else if (streak >= 3) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    }
    if (sound) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  static void triggerGameOver({required bool haptics, required bool sound}) {
    if (haptics) {
      HapticFeedback.heavyImpact();
    }
    if (sound) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  static void triggerButtonTap({required bool haptics, required bool sound}) {
    if (haptics) {
      HapticFeedback.selectionClick();
    }
    if (sound) {
      SystemSound.play(SystemSoundType.click);
    }
  }
}`,
  },
  {
    path: 'lib/game/systems/placement_engine.dart',
    category: 'game',
    description: 'Pure interval intersection mathematics with tolerance snapping and trimming',
    content: `import 'dart:math';
import '../../core/game_config.dart';
import '../../core/game_state.dart';

class PlacementEngine {
  static PlacementResult calculatePlacement({
    required double previousLeft,
    required double previousWidth,
    required double movingLeft,
    required double movingWidth,
    double? customTolerance,
  }) {
    final previousRight = previousLeft + previousWidth;
    final movingRight = movingLeft + movingWidth;

    // Tolerance: clamp(previousBlockWidth * 0.025, 2, 5)
    final tolerance = customTolerance ??
        (previousWidth * GameConfig.toleranceRatio)
            .clamp(GameConfig.minTolerance, GameConfig.maxTolerance);

    final offset = (movingLeft - previousLeft).abs();

    if (offset <= tolerance) {
      return PlacementResult(
        type: PlacementResultType.perfect,
        retainedLeft: previousLeft,
        retainedRight: previousRight,
        retainedWidth: previousWidth,
      );
    }

    final overlapLeft = max(previousLeft, movingLeft);
    final overlapRight = min(previousRight, movingRight);
    final overlapWidth = max(0.0, overlapRight - overlapLeft);

    if (overlapWidth <= 0.001) {
      return PlacementResult(
        type: PlacementResultType.miss,
        retainedLeft: movingLeft,
        retainedRight: movingRight,
        retainedWidth: 0.0,
        excessLeft: movingLeft,
        excessRight: movingRight,
        excessWidth: movingWidth,
        isExcessOnRight: movingLeft > previousLeft,
      );
    }

    double? excessLeft;
    double? excessRight;
    double? excessWidth;
    bool isExcessOnRight = true;

    if (movingLeft > previousLeft) {
      isExcessOnRight = true;
      excessLeft = overlapRight;
      excessRight = movingRight;
      excessWidth = movingRight - overlapRight;
    } else {
      isExcessOnRight = false;
      excessLeft = movingLeft;
      excessRight = overlapLeft;
      excessWidth = overlapLeft - movingLeft;
    }

    return PlacementResult(
      type: PlacementResultType.partial,
      retainedLeft: overlapLeft,
      retainedRight: overlapRight,
      retainedWidth: overlapWidth,
      excessLeft: excessLeft,
      excessRight: excessRight,
      excessWidth: excessWidth,
      isExcessOnRight: isExcessOnRight,
    );
  }
}`,
  },
  {
    path: 'lib/game/stack_pulse_game.dart',
    category: 'game',
    description: 'FlameGame controller with camera tracking, input handling, and particle bursts',
    content: `import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../core/game_config.dart';
import '../core/game_state.dart';
import '../core/game_theme.dart';
import '../models/game_settings.dart';
import 'components/stack_block.dart';
import 'components/moving_block.dart';
import 'components/falling_piece.dart';
import 'components/particle_effect.dart';
import 'systems/placement_engine.dart';
import 'systems/difficulty_controller.dart';
import 'systems/score_controller.dart';
import 'systems/camera_controller.dart';
import 'services/feedback_service.dart';

class StackPulseGame extends FlameGame with TapDetector {
  GameTheme theme;
  GameSettings settings;
  final Function(int score, int streak, String? badge) onScoreUpdate;
  final Function(int finalScore, int bestStreak) onGameOver;

  GamePlayState state = GamePlayState.home;
  final ScoreController scoreController = ScoreController();
  final CameraController cameraController = CameraController();

  late final World gameWorld;
  late final CameraComponent gameCamera;

  double lastPlacedLeft = (GameConfig.logicalWidth - GameConfig.baseBlockWidth) / 2;
  double lastPlacedWidth = GameConfig.baseBlockWidth;
  double topStackY = GameConfig.basePositionY;
  int blockCount = 0;
  int nextDirection = 1;

  MovingBlockComponent? currentMovingBlock;

  StackPulseGame({
    required this.theme,
    required this.settings,
    required this.onScoreUpdate,
    required this.onGameOver,
  });

  @override
  Color backgroundColor() => theme.background;

  @override
  Future<void> onLoad() async {
    gameWorld = World();
    gameCamera = CameraComponent.withFixedResolution(
      width: GameConfig.logicalWidth,
      height: GameConfig.logicalHeight,
      world: gameWorld,
    );
    gameCamera.viewfinder.anchor = Anchor.bottomLeft;
    gameCamera.viewfinder.position = Vector2(0, GameConfig.logicalHeight);

    addAll([gameWorld, gameCamera]);
    initializeGame();
  }

  void initializeGame() {
    gameWorld.removeAll(gameWorld.children);
    scoreController.reset();
    cameraController.reset();
    state = GamePlayState.initializing;
    blockCount = 0;
    nextDirection = 1;

    lastPlacedLeft = (GameConfig.logicalWidth - GameConfig.baseBlockWidth) / 2;
    lastPlacedWidth = GameConfig.baseBlockWidth;
    topStackY = GameConfig.basePositionY;

    final baseBlock = StackBlockComponent(
      position: Vector2(lastPlacedLeft, topStackY),
      size: Vector2(lastPlacedWidth, GameConfig.blockHeight),
      blockColor: theme.getBlockColor(0),
      isBase: true,
    );
    gameWorld.add(baseBlock);

    spawnMovingBlock();
    state = GamePlayState.moving;
  }

  void spawnMovingBlock() {
    blockCount++;
    final spawnY = topStackY + GameConfig.blockHeight;
    final speed = DifficultyController.calculateSpeed(scoreController.currentScore);
    final direction = nextDirection;
    nextDirection = -nextDirection;

    final initialX = direction == 1
        ? GameConfig.boundaryPadding
        : GameConfig.logicalWidth - lastPlacedWidth - GameConfig.boundaryPadding;

    currentMovingBlock = MovingBlockComponent(
      position: Vector2(initialX, spawnY),
      size: Vector2(lastPlacedWidth, GameConfig.blockHeight),
      blockColor: theme.getBlockColor(blockCount),
      speed: speed,
      direction: direction,
      minX: GameConfig.boundaryPadding,
      maxX: GameConfig.logicalWidth - GameConfig.boundaryPadding,
    );

    gameWorld.add(currentMovingBlock!);
    state = GamePlayState.moving;
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (state != GamePlayState.moving || currentMovingBlock == null) return;

    state = GamePlayState.placing;
    final moving = currentMovingBlock!;
    final movingX = moving.position.x;
    final movingW = moving.size.x;
    final movingY = moving.position.y;
    final blockColor = moving.blockColor;

    moving.removeFromParent();
    currentMovingBlock = null;

    final result = PlacementEngine.calculatePlacement(
      previousLeft: lastPlacedLeft,
      previousWidth: lastPlacedWidth,
      movingLeft: movingX,
      movingWidth: movingW,
    );

    if (result.type == PlacementResultType.miss) {
      handleMiss(movingX, movingY, movingW, blockColor);
    } else {
      handleSuccess(result, movingY, blockColor);
    }
  }

  void handleSuccess(PlacementResult result, double y, Color color) {
    final isPerfect = result.type == PlacementResultType.perfect;
    scoreController.recordPlacement(isPerfect: isPerfect);

    lastPlacedLeft = result.retainedLeft;
    lastPlacedWidth = result.retainedWidth;
    topStackY = y;

    final placedBlock = StackBlockComponent(
      position: Vector2(lastPlacedLeft, topStackY),
      size: Vector2(lastPlacedWidth, GameConfig.blockHeight),
      blockColor: color,
    );
    gameWorld.add(placedBlock);

    if (!isPerfect && result.excessLeft != null && result.excessWidth != null && result.excessWidth! > 0) {
      final excessPiece = FallingPieceComponent(
        position: Vector2(result.excessLeft! + result.excessWidth! / 2, y + GameConfig.blockHeight / 2),
        size: Vector2(result.excessWidth!, GameConfig.blockHeight),
        pieceColor: color.withOpacity(0.85),
        maxY: GameConfig.logicalHeight + 300,
        rotationSpeed: result.isExcessOnRight ? 2.5 : -2.5,
      );
      gameWorld.add(excessPiece);
    }

    String? streakBadge;
    if (isPerfect) {
      if (!settings.reducedMotion) {
        final particleCount = (20 + scoreController.currentStreak * 4).clamp(20, 48);
        final particleBurst = ParticleEffectComponent(
          position: Vector2(lastPlacedLeft + lastPlacedWidth / 2, y + GameConfig.blockHeight / 2),
          particleColor: theme.primaryAccent,
          count: particleCount,
        );
        gameWorld.add(particleBurst);
      }
      FeedbackService.triggerPerfectPlacement(
        haptics: settings.hapticsEnabled,
        sound: settings.soundEnabled,
        streak: scoreController.currentStreak,
      );
      streakBadge = DifficultyController.getStreakBadge(scoreController.currentStreak);
    } else {
      FeedbackService.triggerNormalPlacement(haptics: settings.hapticsEnabled, sound: settings.soundEnabled);
    }

    cameraController.updateTarget(topStackY);
    onScoreUpdate(scoreController.currentScore, scoreController.currentStreak, streakBadge);
    spawnMovingBlock();
  }

  void handleMiss(double x, double y, double w, Color color) {
    state = GamePlayState.gameOver;
    FeedbackService.triggerGameOver(haptics: settings.hapticsEnabled, sound: settings.soundEnabled);

    final fallingMiss = FallingPieceComponent(
      position: Vector2(x + w / 2, y + GameConfig.blockHeight / 2),
      size: Vector2(w, GameConfig.blockHeight),
      pieceColor: color,
      maxY: GameConfig.logicalHeight + 400,
      rotationSpeed: 3.5,
    );
    gameWorld.add(fallingMiss);

    onGameOver(scoreController.currentScore, scoreController.bestStreakInRun);
  }

  void pauseGame() {
    if (state == GamePlayState.moving) state = GamePlayState.paused;
  }

  void resumeGame() {
    if (state == GamePlayState.paused) state = GamePlayState.moving;
  }

  @override
  void update(double dt) {
    final safeDt = dt.clamp(0.0, 0.05);
    if (state == GamePlayState.paused) return;

    super.update(safeDt);
    cameraController.update(safeDt);
    gameCamera.viewfinder.position = Vector2(0, GameConfig.logicalHeight + cameraController.currentOffsetY);
  }
}`,
  },
  {
    path: 'test/unit/placement_engine_test.dart',
    category: 'test',
    description: 'Automated Flutter unit tests for interval calculations and snapping',
    content: `import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/game_state.dart';
import '../../lib/game/systems/placement_engine.dart';

void main() {
  group('PlacementEngine Tests', () {
    test('Perfect alignment within tolerance snaps to previous block', () {
      final result = PlacementEngine.calculatePlacement(
        previousLeft: 75.0,
        previousWidth: 210.0,
        movingLeft: 76.5,
        movingWidth: 210.0,
      );

      expect(result.type, equals(PlacementResultType.perfect));
      expect(result.retainedLeft, equals(75.0));
      expect(result.retainedWidth, equals(210.0));
      expect(result.isSuccessful, isTrue);
    });

    test('Partial overlap on the right trims excess piece', () {
      final result = PlacementEngine.calculatePlacement(
        previousLeft: 75.0,
        previousWidth: 200.0,
        movingLeft: 95.0,
        movingWidth: 200.0,
      );

      expect(result.type, equals(PlacementResultType.partial));
      expect(result.retainedLeft, equals(95.0));
      expect(result.retainedRight, equals(275.0));
      expect(result.retainedWidth, equals(180.0));
      expect(result.excessWidth, equals(20.0));
      expect(result.isExcessOnRight, isTrue);
    });

    test('Zero overlap returns miss and ends run', () {
      final result = PlacementEngine.calculatePlacement(
        previousLeft: 75.0,
        previousWidth: 100.0,
        movingLeft: 200.0,
        movingWidth: 100.0,
      );

      expect(result.type, equals(PlacementResultType.miss));
      expect(result.retainedWidth, equals(0.0));
      expect(result.isSuccessful, isFalse);
    });
  });
}`,
  },
];
