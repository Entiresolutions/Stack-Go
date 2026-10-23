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
    position.x += speed * direction * dt;

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
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3.5));

    // 1. Refined vertical gradient fill
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.lerp(blockColor, Colors.white, 0.22)!,
        blockColor,
        Color.lerp(blockColor, Colors.black, 0.10)!,
      ],
      stops: const [0.0, 0.45, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, paint);

    // 2. Controlled luminous top highlight sheen
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.50)
      ..style = PaintingStyle.fill;
    final highlightRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 1.5, size.x - 4, 2.5),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(highlightRRect, highlightPaint);

    // 3. Crisp geometric hairline perimeter outline
    final outlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, outlinePaint);
  }
}
