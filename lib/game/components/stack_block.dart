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
    this.cornerRadius = 3.5,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));

    // 1. Refined vertical gradient fill
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.lerp(blockColor, Colors.white, 0.16)!,
        blockColor,
        Color.lerp(blockColor, Colors.black, 0.14)!,
      ],
      stops: const [0.0, 0.45, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, paint);

    // 2. Crisp luminous top highlight sheen
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.42)
      ..style = PaintingStyle.fill;
    final highlightRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 1.5, size.x - 4, 2.5),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(highlightRRect, highlightPaint);

    // 3. Subtle bottom separation shadow line for layer readability
    final bottomShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(2, size.y - 0.5),
      Offset(size.x - 2, size.y - 0.5),
      bottomShadowPaint,
    );

    // 4. Clean geometric hairline perimeter outline
    final outlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, outlinePaint);
  }
}
