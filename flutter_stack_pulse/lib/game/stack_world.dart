import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../core/game_config.dart';
import '../core/game_theme.dart';

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
    // 1. Subtle vertical guideline grid
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double x = 36.0; x < GameConfig.logicalWidth; x += 36.0) {
      canvas.drawLine(
        Offset(x, -5000),
        Offset(x, GameConfig.logicalHeight + 500),
        gridPaint,
      );
    }

    // 2. Base Pedestal below the starting block
    final pedestalPaint = Paint()
      ..color = theme.surface
      ..style = PaintingStyle.fill;

    final pedestalRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(
        GameConfig.boundaryPadding,
        GameConfig.basePositionY + GameConfig.blockHeight + 2,
        GameConfig.logicalWidth - GameConfig.boundaryPadding * 2,
        8,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(pedestalRRect, pedestalPaint);

    final pedestalBorder = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(pedestalRRect, pedestalBorder);

    super.render(canvas);

    // 3. Perfect Snap Glow / Flash overlay
    if (flashOpacity > 0.001) {
      final flashPaint = Paint()
        ..color = theme.primaryAccent.withValues(alpha: flashOpacity * 0.25)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        const Rect.fromLTWH(0, -5000, GameConfig.logicalWidth, 10000),
        flashPaint,
      );
    }
  }
}
