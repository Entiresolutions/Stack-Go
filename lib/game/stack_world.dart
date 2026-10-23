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
    // Background is rendered by high-fidelity production asset gameplay_bg.jpg
  }

  void _renderAuroraAtmosphere(Canvas canvas, double width, double height) {
    // Polar emerald aurora curtain
    final auroraPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF14E4C5).withValues(alpha: 0.18),
          const Color(0xFF10B981).withValues(alpha: 0.10),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, -3000, width, 8000));
    canvas.drawRect(Rect.fromLTWH(0, -3000, width, 8000), auroraPaint);

    // Subtle mountain silhouettes
    final mountainPaint = Paint()
      ..color = const Color(0xFF092924).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, height)
      ..lineTo(0, height * 0.7)
      ..lineTo(width * 0.35, height * 0.45)
      ..lineTo(width * 0.7, height * 0.65)
      ..lineTo(width, height * 0.4)
      ..lineTo(width, height)
      ..close();
    canvas.drawPath(path, mountainPaint);
  }

  void _renderSunsetPulseAtmosphere(
      Canvas canvas, double width, double height) {
    // Dusk glowing horizon
    final horizonGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF995B).withValues(alpha: 0.22),
          const Color(0xFFF34BEA).withValues(alpha: 0.12),
          Colors.transparent,
        ],
        radius: 0.9,
      ).createShader(Rect.fromLTWH(0, height * 0.2, width, height));
    canvas.drawRect(Rect.fromLTWH(0, -3000, width, 8000), horizonGlow);

    // City skyline silhouettes
    final skylinePaint = Paint()
      ..color = const Color(0xFF260D25).withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;
    canvas.drawRect(const Rect.fromLTWH(20, -2000, 30, 7000), skylinePaint);
    canvas.drawRect(Rect.fromLTWH(width - 55, -2000, 35, 7000), skylinePaint);
  }

  void _renderArcticGlowAtmosphere(Canvas canvas, double width, double height) {
    // Ice crystal light beams
    final iceBeam = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF7DD3FC).withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(const Rect.fromLTWH(40, -3000, 16, 8000));
    canvas.drawRect(const Rect.fromLTWH(40, -3000, 16, 8000), iceBeam);

    final mountainPaint = Paint()
      ..color = const Color(0xFF0C2448).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, height)
      ..lineTo(0, height * 0.55)
      ..lineTo(width * 0.45, height * 0.35)
      ..lineTo(width * 0.85, height * 0.6)
      ..lineTo(width, height * 0.45)
      ..lineTo(width, height)
      ..close();
    canvas.drawPath(path, mountainPaint);
  }
}
