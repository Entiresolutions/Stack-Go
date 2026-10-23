import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ParticleEffectComponent extends PositionComponent {
  final Color particleColor;
  final int count;
  late final List<_SparkParticle> _particles;
  double _elapsed = 0.0;
  final double duration = 0.65;

  ParticleEffectComponent({
    required Vector2 position,
    required this.particleColor,
    this.count = 24,
  }) : super(position: position, anchor: Anchor.center);

  @override
  void onLoad() {
    super.onLoad();
    final random = Random();
    _particles = List.generate(count, (index) {
      final speed = 90.0 + random.nextDouble() * 190.0;
      final angle = random.nextDouble() * 2 * pi;
      final isDiamond = index % 3 == 0;
      return _SparkParticle(
        velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
        size: isDiamond
            ? 3.5 + random.nextDouble() * 3.5
            : 2.0 + random.nextDouble() * 3.0,
        isDiamond: isDiamond,
        rotation: random.nextDouble() * 2 * pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 8.0,
      );
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    for (final p in _particles) {
      p.offset += p.velocity * dt;
      p.velocity.x *= 0.96; // air drag
      p.velocity.y += 140.0 * dt; // gentle gravity pull
      p.rotation += p.rotationSpeed * dt;
    }
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = (_elapsed / duration).clamp(0.0, 1.0);
    final alpha = (1.0 - progress);

    final sparkPaint = Paint()
      ..color = particleColor.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;

    final whiteCorePaint = Paint()
      ..color = Colors.white.withValues(alpha: alpha * 0.8)
      ..style = PaintingStyle.fill;

    for (final p in _particles) {
      final currentSize = p.size * (1.0 - progress * 0.35);

      if (p.isDiamond) {
        // Draw rotating luminous diamond prism
        canvas.save();
        canvas.translate(p.offset.x, p.offset.y);
        canvas.rotate(p.rotation);

        final path = Path()
          ..moveTo(0, -currentSize)
          ..lineTo(currentSize * 0.75, 0)
          ..lineTo(0, currentSize)
          ..lineTo(-currentSize * 0.75, 0)
          ..close();

        canvas.drawPath(path, sparkPaint);
        canvas.restore();
      } else {
        // Draw circular glowing spark with bright white core
        canvas.drawCircle(
          Offset(p.offset.x, p.offset.y),
          currentSize,
          sparkPaint,
        );
        if (currentSize > 2.0) {
          canvas.drawCircle(
            Offset(p.offset.x, p.offset.y),
            currentSize * 0.45,
            whiteCorePaint,
          );
        }
      }
    }
  }
}

class _SparkParticle {
  Vector2 offset = Vector2.zero();
  final Vector2 velocity;
  final double size;
  final bool isDiamond;
  double rotation;
  final double rotationSpeed;

  _SparkParticle({
    required this.velocity,
    required this.size,
    required this.isDiamond,
    required this.rotation,
    required this.rotationSpeed,
  });
}
