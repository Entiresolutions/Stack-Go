import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class FallingPieceComponent extends PositionComponent {
  final Color pieceColor;
  double velocityY;
  final double gravity = 800.0;
  double rotationSpeed;
  double opacity = 1.0;
  final double maxY;

  FallingPieceComponent({
    required Vector2 position,
    required Vector2 size,
    required this.pieceColor,
    required this.maxY,
    this.velocityY = 30.0,
    this.rotationSpeed = 1.5,
  }) : super(position: position, size: size, anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    velocityY += gravity * dt;
    position.y += velocityY * dt;
    angle += rotationSpeed * dt;

    if (position.y > maxY - 200) {
      opacity = (opacity - dt * 2.5).clamp(0.0, 1.0);
    }

    if (position.y > maxY || opacity <= 0.0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final rect =
        Rect.fromCenter(center: Offset.zero, width: size.x, height: size.y);
    final paint = Paint()
      ..color = pieceColor.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      paint,
    );
  }
}
