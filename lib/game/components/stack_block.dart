import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class StackBlockComponent extends PositionComponent {
  final Color blockColor;
  final bool isBase;
  final double cornerRadius;

  StackBlockComponent({
    required Vector2 position,
    required Vector2 size,
    required this.blockColor,
    this.isBase = false,
    this.cornerRadius = 4.0,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));

    // Main block body
    final paint = Paint()
      ..color = blockColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, paint);

    // Subtle top highlight sheen
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;
    final highlightRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, size.x - 4, 3),
      const Radius.circular(2),
    );
    canvas.drawRRect(highlightRRect, highlightPaint);

    // Subtle hairline stroke outline
    final outlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, outlinePaint);
  }
}
