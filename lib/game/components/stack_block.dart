import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'isometric_slab_renderer.dart';

class StackBlockComponent extends PositionComponent {
  final Color blockColor;
  final bool isBase;
  final int blockIndex;

  StackBlockComponent({
    required Vector2 position,
    required Vector2 size,
    required this.blockColor,
    this.isBase = false,
    this.blockIndex = 0,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

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
