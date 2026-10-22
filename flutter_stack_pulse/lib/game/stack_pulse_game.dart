import 'package:flame/events.dart';
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

  // Track tower geometry
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
    // Align camera viewport origin
    gameCamera.viewfinder.anchor = Anchor.bottomLeft;
    gameCamera.viewfinder.position = Vector2(0, GameConfig.logicalHeight);

    addAll([gameWorld, gameCamera]);
    initializeGame();
  }

  void updateTheme(GameTheme newTheme) {
    theme = newTheme;
  }

  void updateSettings(GameSettings newSettings) {
    settings = newSettings;
  }

  void initializeGame() {
    // Clear components
    gameWorld.removeAll(gameWorld.children);
    scoreController.reset();
    cameraController.reset();
    state = GamePlayState.initializing;
    blockCount = 0;
    nextDirection = 1;

    lastPlacedLeft = (GameConfig.logicalWidth - GameConfig.baseBlockWidth) / 2;
    lastPlacedWidth = GameConfig.baseBlockWidth;
    topStackY = GameConfig.basePositionY;

    // Base stationary block
    final baseBlock = StackBlockComponent(
      position: Vector2(lastPlacedLeft, topStackY),
      size: Vector2(lastPlacedWidth, GameConfig.blockHeight),
      blockColor: theme.getBlockColor(0),
      isBase: true,
    );
    gameWorld.add(baseBlock);

    // Spawn first moving block
    spawnMovingBlock();
    state = GamePlayState.moving;
  }

  void spawnMovingBlock() {
    blockCount++;
    final spawnY = topStackY + GameConfig.blockHeight;
    final speed = DifficultyController.calculateSpeed(scoreController.currentScore);
    final direction = nextDirection;
    nextDirection = -nextDirection; // alternate starting direction

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
    // Only accept taps when MOVING
    if (state != GamePlayState.moving || currentMovingBlock == null) {
      return;
    }

    state = GamePlayState.placing;
    final moving = currentMovingBlock!;
    final movingX = moving.position.x;
    final movingW = moving.size.x;
    final movingY = moving.position.y;
    final blockColor = moving.blockColor;

    // Remove moving component immediately to lock input
    moving.removeFromParent();
    currentMovingBlock = null;

    // Calculate overlap mathematically
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

    // Update geometry
    lastPlacedLeft = result.retainedLeft;
    lastPlacedWidth = result.retainedWidth;
    topStackY = y;

    // Add stationary placed block
    final placedBlock = StackBlockComponent(
      position: Vector2(lastPlacedLeft, topStackY),
      size: Vector2(lastPlacedWidth, GameConfig.blockHeight),
      blockColor: color,
    );
    gameWorld.add(placedBlock);

    // Excess falling piece if partial
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

    // Perfect placement particles and feedback
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

    // Camera target update
    cameraController.updateTarget(topStackY);

    onScoreUpdate(scoreController.currentScore, scoreController.currentStreak, streakBadge);

    // Spawn next block
    spawnMovingBlock();
  }

  void handleMiss(double x, double y, double w, Color color) {
    state = GamePlayState.gameOver;
    FeedbackService.triggerGameOver(haptics: settings.hapticsEnabled, sound: settings.soundEnabled);

    // Animate missed block falling away
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
    if (state == GamePlayState.moving) {
      state = GamePlayState.paused;
    }
  }

  void resumeGame() {
    if (state == GamePlayState.paused) {
      state = GamePlayState.moving;
    }
  }

  @override
  void update(double dt) {
    // Large delta time clamp when resuming from background
    final safeDt = dt.clamp(0.0, 0.05);

    if (state == GamePlayState.paused) {
      return;
    }

    super.update(safeDt);
    cameraController.update(safeDt);

    // Sync Flame camera position with eased camera offset
    gameCamera.viewfinder.position = Vector2(0, GameConfig.logicalHeight + cameraController.currentOffsetY);
  }
}
