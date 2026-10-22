import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ParticleEffectComponent extends PositionComponent {
  final Color particleColor;
  final int count;
  late final List<_Particle> _particles;
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
    _particles = List.generate(count, (_) {
      final speed = 80.0 + random.nextDouble() * 160.0;
      final angle = random.nextDouble() * 2 * pi;
      return _Particle(
        velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
        size: 2.5 + random.nextDouble() * 3.5,
      );
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    for (final p in _particles) {
      p.offset += p.velocity * dt;
      p.velocity.y += 120.0 * dt; // gentle gravity pull
    }
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = (_elapsed / duration).clamp(0.0, 1.0);
    final alpha = (1.0 - progress);
    final paint = Paint()
      ..color = particleColor.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;

    for (final p in _particles) {
      canvas.drawCircle(
        Offset(p.offset.x, p.offset.y),
        p.size * (1.0 - progress * 0.4),
        paint,
      );
    }
  }
}

class _Particle {
  Vector2 offset = Vector2.zero();
  final Vector2 velocity;
  final double size;
  _Particle({required this.velocity, required this.size});
}
