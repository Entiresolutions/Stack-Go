import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../core/game_config.dart';
import '../core/game_theme.dart';
import 'components/isometric_slab_renderer.dart';

class StackWorld extends World {
  GameTheme theme;
  double flashOpacity = 0.0;

  StackWorld({required this.theme});

  void updateTheme(GameTheme newTheme) {
    theme = newTheme;
  }

  void triggerFlash(double intensity) {
    flashOpacity = intensity.clamp(0.0, 1.0);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (flashOpacity > 0.0) {
      flashOpacity = (flashOpacity - dt * 2.8).clamp(0.0, 1.0);
    }
  }

  @override
  void render(Canvas canvas) {
    // 1. Theme-Specific Atmospheric Background (Matching Reference Screen 10)
    _renderThemeAtmosphere(canvas);

    // 2. Base 3D Isometric Pedestal supporting the starting block
    const pedestalW = GameConfig.baseBlockWidth + 40.0;
    const pedestalX = (GameConfig.logicalWidth - pedestalW) / 2;
    const pedestalY = GameConfig.basePositionY + GameConfig.blockHeight;

    IsometricSlabRenderer.renderSlab(
      canvas: canvas,
      width: pedestalW,
      height: 18.0,
      baseColor: const Color(0xFF14223A),
      blockIndex: 0,
      offsetX: pedestalX,
      offsetY: pedestalY,
    );

    super.render(canvas);

    // 3. Perfect Snap Glow / Flash overlay
    if (flashOpacity > 0.001) {
      final flashPaint = Paint()
        ..color = theme.primaryAccent.withValues(alpha: flashOpacity * 0.28)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        const Rect.fromLTWH(0, -5000, GameConfig.logicalWidth, 10000),
        flashPaint,
      );
    }
  }

  void _renderThemeAtmosphere(Canvas canvas) {
    // Atmosphere and procedural effects are rendered by ThemeGameplayBackground
  }
}
