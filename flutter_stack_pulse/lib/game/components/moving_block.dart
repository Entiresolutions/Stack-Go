import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class MovingBlockComponent extends PositionComponent {
  Color blockColor;
  double speed;
  int direction; // 1 = moving right, -1 = moving left
  final double minX;
  final double maxX;

  MovingBlockComponent({
    required Vector2 position,
    required Vector2 size,
    required this.blockColor,
    required this.speed,
    required this.direction,
    required this.minX,
    required this.maxX,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  void update(double dt) {
    super.update(dt);
    // Frame-rate independent movement
    position.x += speed * direction * dt;

    // Reverse at bounds
    if (position.x <= minX) {
      position.x = minX;
      direction = 1;
    } else if (position.x + size.x >= maxX) {
      position.x = maxX - size.x;
      direction = -1;
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

    // Fill
    final paint = Paint()
      ..color = blockColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, paint);

    // Top highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final highlightRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, size.x - 4, 3),
      const Radius.circular(2),
    );
    canvas.drawRRect(highlightRRect, highlightPaint);

    // Crisp outline
    final outlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, outlinePaint);
  }
}
