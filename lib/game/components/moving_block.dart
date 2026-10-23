import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'isometric_slab_renderer.dart';

class MovingBlockComponent extends PositionComponent {
  Color blockColor;
  double speed;
  int direction; // 1 = moving right, -1 = moving left
  final double minX;
  final double maxX;
  final int blockIndex;

  MovingBlockComponent({
    required Vector2 position,
    required Vector2 size,
    required this.blockColor,
    required this.speed,
    required this.direction,
    required this.minX,
    required this.maxX,
    this.blockIndex = 0,
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
    IsometricSlabRenderer.renderSlab(
      canvas: canvas,
      width: size.x,
      height: size.y,
      baseColor: blockColor,
      blockIndex: blockIndex,
      isCentered: false,
    );
  }
}
