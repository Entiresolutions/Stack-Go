import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/game_config.dart';
import '../core/game_state.dart';
import '../core/game_theme.dart';
import '../models/game_settings.dart';
import '../services/feedback_service.dart';
import 'components/falling_piece.dart';
import 'components/moving_block.dart';
import 'components/particle_effect.dart';
import 'components/stack_block.dart';
import 'stack_world.dart';
import 'systems/camera_controller.dart';
import 'systems/difficulty_controller.dart';
import 'systems/placement_engine.dart';
import 'systems/score_controller.dart';

class StackPulseGame extends FlameGame<StackWorld>
    with TapCallbacks, KeyboardEvents {
  GameTheme theme;
  GameSettings settings;
  final Function(int score, int streak, String? badge) onScoreUpdate;
  final Function(int finalScore, int bestStreak) onGameOver;

  GamePlayState state = GamePlayState.home;
  final ScoreController scoreController = ScoreController();
  final CameraController cameraController = CameraController();

  double lastPlacedLeft =
      (GameConfig.logicalWidth - GameConfig.baseBlockWidth) / 2;
  double lastPlacedWidth = GameConfig.baseBlockWidth;
  double topStackY = GameConfig.basePositionY;
  int blockCount = 0;
  int nextDirection = 1;

  MovingBlockComponent? currentMovingBlock;
  final Random _random = Random();

  StackPulseGame({
    required this.theme,
    required this.settings,
    required this.onScoreUpdate,
    required this.onGameOver,
  }) : super(
          world: StackWorld(theme: theme),
          camera: CameraComponent.withFixedResolution(
            width: GameConfig.logicalWidth,
            height: GameConfig.logicalHeight,
          ),
        );

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2(0, 0);
    initializeGame();
  }

  void updateTheme(GameTheme newTheme) {
    theme = newTheme;
    world.updateTheme(newTheme);
  }

  void updateSettings(GameSettings newSettings) {
    settings = newSettings;
  }

  void initializeGame() {
    world.removeAll(world.children);
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
    world.add(baseBlock);

    // Spawn first moving block
    spawnMovingBlock();
    state = GamePlayState.moving;
  }

  void spawnMovingBlock() {
    blockCount++;
    final spawnY = topStackY - GameConfig.blockHeight;
    final speed =
        DifficultyController.calculateSpeed(scoreController.currentScore);
    final direction = nextDirection;
    nextDirection = -nextDirection; // alternate left/right spawning

    final initialX = direction == 1
        ? GameConfig.boundaryPadding
        : GameConfig.logicalWidth -
            lastPlacedWidth -
            GameConfig.boundaryPadding;

    currentMovingBlock = MovingBlockComponent(
      position: Vector2(initialX, spawnY),
      size: Vector2(lastPlacedWidth, GameConfig.blockHeight),
      blockColor: theme.getBlockColor(blockCount),
      speed: speed,
      direction: direction,
      minX: GameConfig.boundaryPadding,
      maxX: GameConfig.logicalWidth - GameConfig.boundaryPadding,
    );

    world.add(currentMovingBlock!);
    state = GamePlayState.moving;
  }

  @override
  void onTapDown(TapDownEvent event) {
    handlePlacementTap();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isDown = event is KeyDownEvent;
    if (isDown &&
        (event.logicalKey == LogicalKeyboardKey.space ||
            event.logicalKey == LogicalKeyboardKey.enter)) {
      final handled = handlePlacementTap();
      if (handled) return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  bool handlePlacementTap() {
    if (state != GamePlayState.moving || currentMovingBlock == null) {
      return false;
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

    return true;
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
    world.add(placedBlock);

    // Excess falling piece if partial
    if (!isPerfect &&
        result.excessLeft != null &&
        result.excessWidth != null &&
        result.excessWidth! > 0) {
      final excessPiece = FallingPieceComponent(
        position: Vector2(
          result.excessLeft! + result.excessWidth! / 2,
          y + GameConfig.blockHeight / 2,
        ),
        size: Vector2(result.excessWidth!, GameConfig.blockHeight),
        pieceColor: color.withValues(alpha: 0.85),
        maxY: topStackY + GameConfig.logicalHeight + 200,
        rotationSpeed: result.isExcessOnRight ? 2.5 : -2.5,
      );
      world.add(excessPiece);
    }

    // Perfect placement visual flash, particles, and audio-tactile feedback
    String? streakBadge;
    if (isPerfect) {
      world.triggerFlash(min(1.0, 0.7 + scoreController.currentStreak * 0.05));

      if (!settings.reducedMotion) {
        final particleCount =
            (20 + scoreController.currentStreak * 4).clamp(20, 48);
        final particleBurst = ParticleEffectComponent(
          position: Vector2(
            lastPlacedLeft + lastPlacedWidth / 2,
            y + GameConfig.blockHeight / 2,
          ),
          particleColor: theme.primaryAccent,
          count: particleCount,
        );
        world.add(particleBurst);
      }

      FeedbackService.triggerPerfectPlacement(
        haptics: settings.hapticsEnabled,
        sound: settings.soundEnabled,
        streak: scoreController.currentStreak,
      );
      streakBadge =
          DifficultyController.getStreakBadge(scoreController.currentStreak);
    } else {
      FeedbackService.triggerNormalPlacement(
        haptics: settings.hapticsEnabled,
        sound: settings.soundEnabled,
        score: scoreController.currentScore,
      );
    }

    // Camera target update
    cameraController.updateTarget(topStackY);

    onScoreUpdate(
      scoreController.currentScore,
      scoreController.currentStreak,
      streakBadge,
    );

    // Spawn next block
    spawnMovingBlock();
  }

  void handleMiss(double x, double y, double w, Color color) {
    state = GamePlayState.gameOver;
    FeedbackService.triggerGameOver(
      haptics: settings.hapticsEnabled,
      sound: settings.soundEnabled,
    );

    if (!settings.reducedMotion) {
      cameraController.triggerShake(12.0);
    }

    // Animate missed block falling away
    final fallingMiss = FallingPieceComponent(
      position: Vector2(x + w / 2, y + GameConfig.blockHeight / 2),
      size: Vector2(w, GameConfig.blockHeight),
      pieceColor: color,
      maxY: topStackY + GameConfig.logicalHeight + 300,
      rotationSpeed: 3.5,
    );
    world.add(fallingMiss);

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
    final safeDt = dt.clamp(0.0, 0.05);

    if (state == GamePlayState.paused) {
      return;
    }

    super.update(safeDt);
    cameraController.update(safeDt);

    double shakeX = 0.0;
    double shakeY = 0.0;
    if (cameraController.shakeIntensity > 0.0) {
      shakeX = (_random.nextDouble() - 0.5) * cameraController.shakeIntensity;
      shakeY = (_random.nextDouble() - 0.5) * cameraController.shakeIntensity;
    }

    camera.viewfinder.position = Vector2(
      shakeX,
      cameraController.currentOffsetY + shakeY,
    );
  }
}
