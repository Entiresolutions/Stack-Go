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
    // 1. Theme-Specific Atmospheric Background (Matching Reference Screen 10)
    _renderThemeAtmosphere(canvas);

    // 2. Base Pedestal below the starting block
    const pedestalRect = Rect.fromLTWH(
      GameConfig.boundaryPadding,
      GameConfig.basePositionY + GameConfig.blockHeight + 3,
      GameConfig.logicalWidth - GameConfig.boundaryPadding * 2,
      10,
    );
    final pedestalRRect = RRect.fromRectAndRadius(
      pedestalRect,
      const Radius.circular(5.0),
    );

    // Pedestal surface gradient
    final pedestalGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        theme.surfaceElevated,
        theme.surface,
      ],
    );
    final pedestalPaint = Paint()
      ..shader = pedestalGradient.createShader(pedestalRect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(pedestalRRect, pedestalPaint);

    // Pedestal top accent line
    final pedestalTopAccent = Paint()
      ..color = theme.pedestalBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
      const Offset(GameConfig.boundaryPadding + 3,
          GameConfig.basePositionY + GameConfig.blockHeight + 3.5),
      const Offset(GameConfig.logicalWidth - GameConfig.boundaryPadding - 3,
          GameConfig.basePositionY + GameConfig.blockHeight + 3.5),
      pedestalTopAccent,
    );

    // Pedestal border
    final pedestalBorder = Paint()
      ..color = theme.surfaceBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(pedestalRRect, pedestalBorder);

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
    const width = GameConfig.logicalWidth;
    const height = GameConfig.logicalHeight;

    switch (theme.type) {
      case ThemeType.midnightNeon:
        _renderMidnightNeonAtmosphere(canvas, width, height);
        break;
      case ThemeType.aurora:
        _renderAuroraAtmosphere(canvas, width, height);
        break;
      case ThemeType.sunsetPulse:
        _renderSunsetPulseAtmosphere(canvas, width, height);
        break;
      case ThemeType.arcticGlow:
        _renderArcticGlowAtmosphere(canvas, width, height);
        break;
    }
  }

  void _renderMidnightNeonAtmosphere(
      Canvas canvas, double width, double height) {
    // Rendered by high-fidelity production asset and ThemeGameplayBackground
  }

  void _renderAuroraAtmosphere(Canvas canvas, double width, double height) {
    // Rendered by high-fidelity production asset and ThemeGameplayBackground
  }

  void _renderSunsetPulseAtmosphere(
      Canvas canvas, double width, double height) {
    // Rendered by high-fidelity production asset and ThemeGameplayBackground
  }

  void _renderArcticGlowAtmosphere(Canvas canvas, double width, double height) {
    // Rendered by high-fidelity production asset and ThemeGameplayBackground
  }
}
