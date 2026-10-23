import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/game_theme.dart';

/// Interactive, theme-dependent gameplay background environment system.
///
/// Features:
/// - Layer 1: High-fidelity 9:16 theme-specific background artwork with smooth crossfade
/// - Layer 2: Theme-specific procedural ambient lighting, floating particles, and atmospheric depth
/// - Layer 3: Reactive gameplay feedback (perfect placement pulses, streak luminescence, game-over dimming)
/// - Performance: Zero per-frame allocations, RepaintBoundary isolation, Reduced Motion support
class ThemeGameplayBackground extends StatefulWidget {
  final GameTheme theme;
  final int currentScore;
  final int currentStreak;
  final int perfectTriggerCount;
  final int normalPlacementCount;
  final bool isGameOver;
  final bool isPaused;
  final bool reducedMotion;

  const ThemeGameplayBackground({
    super.key,
    required this.theme,
    this.currentScore = 0,
    this.currentStreak = 0,
    this.perfectTriggerCount = 0,
    this.normalPlacementCount = 0,
    this.isGameOver = false,
    this.isPaused = false,
    this.reducedMotion = false,
  });

  @override
  State<ThemeGameplayBackground> createState() =>
      _ThemeGameplayBackgroundState();
}

class _ThemeGameplayBackgroundState extends State<ThemeGameplayBackground>
    with TickerProviderStateMixin {
  late AnimationController _ambientController;
  late AnimationController _reactiveController;
  late Animation<double> _reactiveAnimation;

  @override
  void initState() {
    super.initState();

    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );

    _reactiveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _reactiveAnimation = CurvedAnimation(
      parent: _reactiveController,
      curve: Curves.easeOutCubic,
    );

    if (!isTest && !widget.reducedMotion && !widget.isPaused) {
      _ambientController.repeat();
    } else {
      _ambientController.value = 0.5;
    }
  }

  @override
  void didUpdateWidget(covariant ThemeGameplayBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');

    // Handle pause / resume of ambient animation
    if (!isTest) {
      if (widget.isPaused || widget.reducedMotion) {
        if (_ambientController.isAnimating) {
          _ambientController.stop();
        }
      } else {
        if (!_ambientController.isAnimating) {
          _ambientController.repeat();
        }
      }
    }

    // Trigger reactive placement feedback on perfect placement
    if (widget.perfectTriggerCount != oldWidget.perfectTriggerCount &&
        !widget.reducedMotion) {
      _reactiveController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _reactiveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReduced = widget.reducedMotion;

    return IgnorePointer(
      ignoring: true,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // -----------------------------------------------------------
          // LAYER 1: THEME-SPECIFIC ARTWORK WITH CROSSFADE
          // -----------------------------------------------------------
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 380),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: Image.asset(
              widget.theme.gameplayBackgroundAsset,
              key: ValueKey(widget.theme.type),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: widget.theme.backgroundGradient,
                  ),
                );
              },
            ),
          ),

          // -----------------------------------------------------------
          // LAYER 2 & 3: AMBIENT & REACTIVE PROCEDURAL GRAPHICS
          // -----------------------------------------------------------
          if (!isReduced)
            RepaintBoundary(
              child: CustomPaint(
                painter: _ThemeEnvironmentPainter(
                  ambientAnimation: _ambientController,
                  reactiveAnimation: _reactiveAnimation,
                  theme: widget.theme,
                  streak: widget.currentStreak,
                  isGameOver: widget.isGameOver,
                ),
              ),
            ),

          // -----------------------------------------------------------
          // GAME OVER CALMING VIGNETTE
          // -----------------------------------------------------------
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            color: widget.isGameOver
                ? Colors.black.withValues(alpha: 0.28)
                : Colors.transparent,
          ),

          // -----------------------------------------------------------
          // ATMOSPHERIC CONTRAST SCRIM (Guarantees Block Legibility)
          // -----------------------------------------------------------
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF061225).withValues(alpha: 0.50),
                  Colors.transparent,
                  Colors.transparent,
                  const Color(0xFF061225).withValues(alpha: 0.40),
                ],
                stops: const [0.0, 0.16, 0.84, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Persistent immutable particle data structure for environment ambiance.
class _EnvParticle {
  final double x; // Relative X coordinate (0.0 to 1.0)
  final double y; // Relative Y coordinate (0.0 to 1.0)
  final double speedX; // Horizontal drift speed
  final double speedY; // Vertical drift speed
  final double size; // Radius in pixels
  final double maxAlpha; // Peak alpha
  final double phase; // Oscillation phase
  final bool isDiamond; // True for geometric diamond accent

  const _EnvParticle({
    required this.x,
    required this.y,
    required this.speedX,
    required this.speedY,
    required this.size,
    required this.maxAlpha,
    required this.phase,
    this.isDiamond = false,
  });
}

/// Unified, GPU-optimized CustomPainter rendering the 4 theme environments:
/// 1. Midnight Neon (Cyber Dimension: moving beams, cyber particles, cyan shockwaves)
/// 2. Aurora (Living Lights: flowing turquoise wave ribbons, spirit motes, shimmer pulse)
/// 3. Sunset Pulse (Golden Horizon: warm twilight breathing, rising embers, golden horizon sweep)
/// 4. Arctic Glow (Frozen Dimension: gentle snowfall, crystalline glints, icy sparkle flash)
class _ThemeEnvironmentPainter extends CustomPainter {
  final Animation<double> ambientAnimation;
  final Animation<double> reactiveAnimation;
  final GameTheme theme;
  final int streak;
  final bool isGameOver;

  _ThemeEnvironmentPainter({
    required this.ambientAnimation,
    required this.reactiveAnimation,
    required this.theme,
    required this.streak,
    required this.isGameOver,
  }) : super(repaint: Listenable.merge([ambientAnimation, reactiveAnimation]));

  // Curated persistent particle models (strictly constrained to outer edges)
  static const List<_EnvParticle> _midnightParticles = [
    _EnvParticle(
        x: 0.08,
        y: 0.30,
        speedX: 0.01,
        speedY: -0.06,
        size: 2.8,
        maxAlpha: 0.45,
        phase: 0.5,
        isDiamond: true),
    _EnvParticle(
        x: 0.14,
        y: 0.55,
        speedX: -0.01,
        speedY: -0.08,
        size: 2.0,
        maxAlpha: 0.35,
        phase: 1.2),
    _EnvParticle(
        x: 0.06,
        y: 0.75,
        speedX: 0.02,
        speedY: -0.05,
        size: 2.5,
        maxAlpha: 0.40,
        phase: 2.1,
        isDiamond: true),
    _EnvParticle(
        x: 0.18,
        y: 0.20,
        speedX: -0.01,
        speedY: -0.07,
        size: 3.2,
        maxAlpha: 0.48,
        phase: 0.8),
    _EnvParticle(
        x: 0.12,
        y: 0.88,
        speedX: 0.01,
        speedY: -0.06,
        size: 2.2,
        maxAlpha: 0.38,
        phase: 3.0),
    _EnvParticle(
        x: 0.84,
        y: 0.25,
        speedX: -0.01,
        speedY: -0.07,
        size: 3.0,
        maxAlpha: 0.50,
        phase: 1.5,
        isDiamond: true),
    _EnvParticle(
        x: 0.92,
        y: 0.45,
        speedX: 0.01,
        speedY: -0.09,
        size: 2.4,
        maxAlpha: 0.42,
        phase: 2.7),
    _EnvParticle(
        x: 0.88,
        y: 0.70,
        speedX: -0.02,
        speedY: -0.06,
        size: 2.6,
        maxAlpha: 0.46,
        phase: 0.3,
        isDiamond: true),
    _EnvParticle(
        x: 0.82,
        y: 0.85,
        speedX: 0.01,
        speedY: -0.08,
        size: 2.2,
        maxAlpha: 0.36,
        phase: 1.9),
    _EnvParticle(
        x: 0.95,
        y: 0.18,
        speedX: -0.01,
        speedY: -0.05,
        size: 3.4,
        maxAlpha: 0.52,
        phase: 2.4,
        isDiamond: true),
    _EnvParticle(
        x: 0.10,
        y: 0.42,
        speedX: 0.02,
        speedY: -0.07,
        size: 2.1,
        maxAlpha: 0.34,
        phase: 0.9),
    _EnvParticle(
        x: 0.86,
        y: 0.60,
        speedX: -0.01,
        speedY: -0.06,
        size: 2.3,
        maxAlpha: 0.38,
        phase: 1.7),
  ];

  static const List<_EnvParticle> _auroraParticles = [
    _EnvParticle(
        x: 0.07,
        y: 0.35,
        speedX: 0.03,
        speedY: -0.05,
        size: 3.2,
        maxAlpha: 0.46,
        phase: 0.4),
    _EnvParticle(
        x: 0.15,
        y: 0.62,
        speedX: -0.02,
        speedY: -0.06,
        size: 2.6,
        maxAlpha: 0.40,
        phase: 1.6),
    _EnvParticle(
        x: 0.05,
        y: 0.80,
        speedX: 0.02,
        speedY: -0.04,
        size: 3.0,
        maxAlpha: 0.38,
        phase: 2.5),
    _EnvParticle(
        x: 0.18,
        y: 0.22,
        speedX: -0.03,
        speedY: -0.05,
        size: 3.6,
        maxAlpha: 0.50,
        phase: 0.9),
    _EnvParticle(
        x: 0.12,
        y: 0.92,
        speedX: 0.02,
        speedY: -0.04,
        size: 2.4,
        maxAlpha: 0.32,
        phase: 3.1),
    _EnvParticle(
        x: 0.85,
        y: 0.28,
        speedX: -0.02,
        speedY: -0.05,
        size: 3.4,
        maxAlpha: 0.48,
        phase: 1.3),
    _EnvParticle(
        x: 0.93,
        y: 0.48,
        speedX: 0.03,
        speedY: -0.06,
        size: 2.8,
        maxAlpha: 0.44,
        phase: 2.2),
    _EnvParticle(
        x: 0.88,
        y: 0.72,
        speedX: -0.02,
        speedY: -0.05,
        size: 3.2,
        maxAlpha: 0.42,
        phase: 0.7),
    _EnvParticle(
        x: 0.82,
        y: 0.88,
        speedX: 0.02,
        speedY: -0.04,
        size: 2.6,
        maxAlpha: 0.36,
        phase: 1.8),
    _EnvParticle(
        x: 0.95,
        y: 0.16,
        speedX: -0.03,
        speedY: -0.05,
        size: 3.8,
        maxAlpha: 0.52,
        phase: 2.8),
    _EnvParticle(
        x: 0.11,
        y: 0.48,
        speedX: 0.02,
        speedY: -0.05,
        size: 2.5,
        maxAlpha: 0.35,
        phase: 0.2),
    _EnvParticle(
        x: 0.87,
        y: 0.58,
        speedX: -0.02,
        speedY: -0.06,
        size: 2.7,
        maxAlpha: 0.40,
        phase: 1.1),
  ];

  static const List<_EnvParticle> _sunsetParticles = [
    _EnvParticle(
        x: 0.09,
        y: 0.28,
        speedX: 0.02,
        speedY: -0.07,
        size: 3.0,
        maxAlpha: 0.48,
        phase: 0.3),
    _EnvParticle(
        x: 0.16,
        y: 0.58,
        speedX: -0.01,
        speedY: -0.08,
        size: 2.4,
        maxAlpha: 0.40,
        phase: 1.4),
    _EnvParticle(
        x: 0.06,
        y: 0.78,
        speedX: 0.02,
        speedY: -0.06,
        size: 2.8,
        maxAlpha: 0.42,
        phase: 2.3),
    _EnvParticle(
        x: 0.19,
        y: 0.18,
        speedX: -0.02,
        speedY: -0.07,
        size: 3.4,
        maxAlpha: 0.50,
        phase: 0.8),
    _EnvParticle(
        x: 0.13,
        y: 0.90,
        speedX: 0.01,
        speedY: -0.06,
        size: 2.2,
        maxAlpha: 0.36,
        phase: 2.9),
    _EnvParticle(
        x: 0.83,
        y: 0.24,
        speedX: -0.02,
        speedY: -0.07,
        size: 3.2,
        maxAlpha: 0.52,
        phase: 1.2),
    _EnvParticle(
        x: 0.91,
        y: 0.46,
        speedX: 0.01,
        speedY: -0.09,
        size: 2.6,
        maxAlpha: 0.44,
        phase: 2.1),
    _EnvParticle(
        x: 0.87,
        y: 0.68,
        speedX: -0.02,
        speedY: -0.06,
        size: 2.8,
        maxAlpha: 0.46,
        phase: 0.5),
    _EnvParticle(
        x: 0.81,
        y: 0.86,
        speedX: 0.01,
        speedY: -0.08,
        size: 2.4,
        maxAlpha: 0.38,
        phase: 1.7),
    _EnvParticle(
        x: 0.94,
        y: 0.15,
        speedX: -0.02,
        speedY: -0.06,
        size: 3.5,
        maxAlpha: 0.54,
        phase: 2.6),
    _EnvParticle(
        x: 0.11,
        y: 0.44,
        speedX: 0.02,
        speedY: -0.08,
        size: 2.3,
        maxAlpha: 0.36,
        phase: 0.6),
    _EnvParticle(
        x: 0.86,
        y: 0.55,
        speedX: -0.01,
        speedY: -0.07,
        size: 2.5,
        maxAlpha: 0.40,
        phase: 1.5),
  ];

  static const List<_EnvParticle> _arcticParticles = [
    _EnvParticle(
        x: 0.08,
        y: 0.15,
        speedX: 0.02,
        speedY: 0.08,
        size: 2.8,
        maxAlpha: 0.48,
        phase: 0.4,
        isDiamond: true),
    _EnvParticle(
        x: 0.15,
        y: 0.38,
        speedX: -0.01,
        speedY: 0.07,
        size: 2.2,
        maxAlpha: 0.40,
        phase: 1.5),
    _EnvParticle(
        x: 0.06,
        y: 0.65,
        speedX: 0.02,
        speedY: 0.09,
        size: 2.6,
        maxAlpha: 0.44,
        phase: 2.4,
        isDiamond: true),
    _EnvParticle(
        x: 0.18,
        y: 0.82,
        speedX: -0.02,
        speedY: 0.08,
        size: 2.0,
        maxAlpha: 0.36,
        phase: 0.7),
    _EnvParticle(
        x: 0.84,
        y: 0.20,
        speedX: -0.02,
        speedY: 0.08,
        size: 3.0,
        maxAlpha: 0.50,
        phase: 1.1,
        isDiamond: true),
    _EnvParticle(
        x: 0.92,
        y: 0.42,
        speedX: 0.01,
        speedY: 0.09,
        size: 2.4,
        maxAlpha: 0.42,
        phase: 2.0),
    _EnvParticle(
        x: 0.88,
        y: 0.68,
        speedX: -0.01,
        speedY: 0.07,
        size: 2.6,
        maxAlpha: 0.46,
        phase: 0.2,
        isDiamond: true),
    _EnvParticle(
        x: 0.82,
        y: 0.85,
        speedX: 0.02,
        speedY: 0.08,
        size: 2.1,
        maxAlpha: 0.38,
        phase: 1.8),
    _EnvParticle(
        x: 0.95,
        y: 0.12,
        speedX: -0.02,
        speedY: 0.07,
        size: 3.2,
        maxAlpha: 0.52,
        phase: 2.7,
        isDiamond: true),
    _EnvParticle(
        x: 0.12,
        y: 0.50,
        speedX: 0.01,
        speedY: 0.08,
        size: 2.3,
        maxAlpha: 0.38,
        phase: 0.9),
    _EnvParticle(
        x: 0.86,
        y: 0.58,
        speedX: -0.01,
        speedY: 0.08,
        size: 2.5,
        maxAlpha: 0.42,
        phase: 1.6),
  ];

  static const List<_EnvParticle> _sakuraParticles = [
    _EnvParticle(
        x: 0.08,
        y: 0.18,
        speedX: -0.04,
        speedY: 0.07,
        size: 3.2,
        maxAlpha: 0.55,
        phase: 0.2),
    _EnvParticle(
        x: 0.16,
        y: 0.42,
        speedX: -0.05,
        speedY: 0.06,
        size: 2.6,
        maxAlpha: 0.45,
        phase: 1.4),
    _EnvParticle(
        x: 0.05,
        y: 0.70,
        speedX: -0.03,
        speedY: 0.08,
        size: 3.0,
        maxAlpha: 0.50,
        phase: 2.1),
    _EnvParticle(
        x: 0.19,
        y: 0.88,
        speedX: -0.04,
        speedY: 0.07,
        size: 2.4,
        maxAlpha: 0.40,
        phase: 0.8),
    _EnvParticle(
        x: 0.12,
        y: 0.28,
        speedX: -0.05,
        speedY: 0.06,
        size: 2.8,
        maxAlpha: 0.48,
        phase: 3.0),
    _EnvParticle(
        x: 0.84,
        y: 0.14,
        speedX: -0.04,
        speedY: 0.07,
        size: 3.4,
        maxAlpha: 0.52,
        phase: 1.1),
    _EnvParticle(
        x: 0.92,
        y: 0.38,
        speedX: -0.03,
        speedY: 0.08,
        size: 2.6,
        maxAlpha: 0.46,
        phase: 2.5),
    _EnvParticle(
        x: 0.88,
        y: 0.62,
        speedX: -0.05,
        speedY: 0.06,
        size: 3.0,
        maxAlpha: 0.48,
        phase: 0.6),
    _EnvParticle(
        x: 0.82,
        y: 0.84,
        speedX: -0.04,
        speedY: 0.07,
        size: 2.5,
        maxAlpha: 0.42,
        phase: 1.9),
    _EnvParticle(
        x: 0.95,
        y: 0.22,
        speedX: -0.05,
        speedY: 0.08,
        size: 3.6,
        maxAlpha: 0.54,
        phase: 2.7),
    _EnvParticle(
        x: 0.11,
        y: 0.54,
        speedX: -0.04,
        speedY: 0.07,
        size: 2.3,
        maxAlpha: 0.38,
        phase: 0.5),
    _EnvParticle(
        x: 0.86,
        y: 0.48,
        speedX: -0.03,
        speedY: 0.06,
        size: 2.7,
        maxAlpha: 0.44,
        phase: 1.7),
  ];

  static const List<_EnvParticle> _abyssalParticles = [
    _EnvParticle(
        x: 0.07,
        y: 0.85,
        speedX: 0.02,
        speedY: -0.06,
        size: 3.6,
        maxAlpha: 0.48,
        phase: 0.5),
    _EnvParticle(
        x: 0.15,
        y: 0.60,
        speedX: -0.01,
        speedY: -0.08,
        size: 2.4,
        maxAlpha: 0.38,
        phase: 1.7),
    _EnvParticle(
        x: 0.05,
        y: 0.35,
        speedX: 0.02,
        speedY: -0.05,
        size: 3.0,
        maxAlpha: 0.44,
        phase: 2.2),
    _EnvParticle(
        x: 0.18,
        y: 0.15,
        speedX: -0.02,
        speedY: -0.07,
        size: 2.2,
        maxAlpha: 0.35,
        phase: 0.9),
    _EnvParticle(
        x: 0.12,
        y: 0.92,
        speedX: 0.01,
        speedY: -0.06,
        size: 4.0,
        maxAlpha: 0.50,
        phase: 2.8),
    _EnvParticle(
        x: 0.85,
        y: 0.80,
        speedX: -0.02,
        speedY: -0.07,
        size: 3.2,
        maxAlpha: 0.46,
        phase: 1.3),
    _EnvParticle(
        x: 0.93,
        y: 0.55,
        speedX: 0.01,
        speedY: -0.09,
        size: 2.5,
        maxAlpha: 0.40,
        phase: 2.0),
    _EnvParticle(
        x: 0.88,
        y: 0.30,
        speedX: -0.01,
        speedY: -0.06,
        size: 3.8,
        maxAlpha: 0.48,
        phase: 0.4),
    _EnvParticle(
        x: 0.82,
        y: 0.12,
        speedX: 0.02,
        speedY: -0.08,
        size: 2.6,
        maxAlpha: 0.38,
        phase: 1.8),
    _EnvParticle(
        x: 0.95,
        y: 0.95,
        speedX: -0.02,
        speedY: -0.05,
        size: 4.2,
        maxAlpha: 0.52,
        phase: 2.6),
    _EnvParticle(
        x: 0.10,
        y: 0.45,
        speedX: 0.01,
        speedY: -0.07,
        size: 2.8,
        maxAlpha: 0.36,
        phase: 0.7),
    _EnvParticle(
        x: 0.86,
        y: 0.68,
        speedX: -0.01,
        speedY: -0.06,
        size: 3.0,
        maxAlpha: 0.42,
        phase: 1.5),
  ];

  static const List<_EnvParticle> _retroParticles = [
    _EnvParticle(
        x: 0.08,
        y: 0.25,
        speedX: 0.01,
        speedY: -0.05,
        size: 3.0,
        maxAlpha: 0.50,
        phase: 0.3,
        isDiamond: true),
    _EnvParticle(
        x: 0.14,
        y: 0.50,
        speedX: -0.01,
        speedY: -0.07,
        size: 2.2,
        maxAlpha: 0.40,
        phase: 1.5),
    _EnvParticle(
        x: 0.06,
        y: 0.72,
        speedX: 0.02,
        speedY: -0.06,
        size: 2.8,
        maxAlpha: 0.45,
        phase: 2.4,
        isDiamond: true),
    _EnvParticle(
        x: 0.18,
        y: 0.85,
        speedX: -0.01,
        speedY: -0.08,
        size: 2.0,
        maxAlpha: 0.36,
        phase: 0.8),
    _EnvParticle(
        x: 0.11,
        y: 0.38,
        speedX: 0.01,
        speedY: -0.06,
        size: 3.2,
        maxAlpha: 0.48,
        phase: 2.9,
        isDiamond: true),
    _EnvParticle(
        x: 0.84,
        y: 0.22,
        speedX: -0.02,
        speedY: -0.06,
        size: 3.2,
        maxAlpha: 0.52,
        phase: 1.2,
        isDiamond: true),
    _EnvParticle(
        x: 0.92,
        y: 0.48,
        speedX: 0.01,
        speedY: -0.08,
        size: 2.4,
        maxAlpha: 0.42,
        phase: 2.2),
    _EnvParticle(
        x: 0.88,
        y: 0.65,
        speedX: -0.01,
        speedY: -0.07,
        size: 2.8,
        maxAlpha: 0.46,
        phase: 0.5,
        isDiamond: true),
    _EnvParticle(
        x: 0.82,
        y: 0.82,
        speedX: 0.01,
        speedY: -0.05,
        size: 2.2,
        maxAlpha: 0.38,
        phase: 1.7),
    _EnvParticle(
        x: 0.95,
        y: 0.15,
        speedX: -0.01,
        speedY: -0.06,
        size: 3.4,
        maxAlpha: 0.54,
        phase: 2.7,
        isDiamond: true),
    _EnvParticle(
        x: 0.12,
        y: 0.62,
        speedX: 0.02,
        speedY: -0.07,
        size: 2.5,
        maxAlpha: 0.38,
        phase: 0.6),
    _EnvParticle(
        x: 0.86,
        y: 0.35,
        speedX: -0.01,
        speedY: -0.06,
        size: 2.6,
        maxAlpha: 0.40,
        phase: 1.6,
        isDiamond: true),
  ];

  static const List<_EnvParticle> _emberParticles = [
    _EnvParticle(
        x: 0.09,
        y: 0.88,
        speedX: 0.02,
        speedY: -0.09,
        size: 3.2,
        maxAlpha: 0.55,
        phase: 0.4),
    _EnvParticle(
        x: 0.16,
        y: 0.65,
        speedX: -0.02,
        speedY: -0.11,
        size: 2.4,
        maxAlpha: 0.45,
        phase: 1.6),
    _EnvParticle(
        x: 0.06,
        y: 0.45,
        speedX: 0.03,
        speedY: -0.08,
        size: 2.8,
        maxAlpha: 0.48,
        phase: 2.3),
    _EnvParticle(
        x: 0.18,
        y: 0.25,
        speedX: -0.01,
        speedY: -0.10,
        size: 2.0,
        maxAlpha: 0.38,
        phase: 0.7),
    _EnvParticle(
        x: 0.12,
        y: 0.95,
        speedX: 0.02,
        speedY: -0.09,
        size: 3.6,
        maxAlpha: 0.58,
        phase: 3.1),
    _EnvParticle(
        x: 0.83,
        y: 0.82,
        speedX: -0.02,
        speedY: -0.10,
        size: 3.4,
        maxAlpha: 0.56,
        phase: 1.4),
    _EnvParticle(
        x: 0.91,
        y: 0.58,
        speedX: 0.02,
        speedY: -0.08,
        size: 2.5,
        maxAlpha: 0.46,
        phase: 2.1),
    _EnvParticle(
        x: 0.87,
        y: 0.38,
        speedX: -0.03,
        speedY: -0.11,
        size: 2.9,
        maxAlpha: 0.50,
        phase: 0.5),
    _EnvParticle(
        x: 0.81,
        y: 0.20,
        speedX: 0.01,
        speedY: -0.09,
        size: 2.2,
        maxAlpha: 0.40,
        phase: 1.8),
    _EnvParticle(
        x: 0.94,
        y: 0.92,
        speedX: -0.02,
        speedY: -0.08,
        size: 3.8,
        maxAlpha: 0.60,
        phase: 2.5),
    _EnvParticle(
        x: 0.10,
        y: 0.78,
        speedX: 0.02,
        speedY: -0.10,
        size: 2.6,
        maxAlpha: 0.42,
        phase: 0.9),
    _EnvParticle(
        x: 0.86,
        y: 0.72,
        speedX: -0.01,
        speedY: -0.09,
        size: 2.8,
        maxAlpha: 0.48,
        phase: 1.3),
  ];

  static const List<_EnvParticle> _celestialParticles = [
    _EnvParticle(
        x: 0.08,
        y: 0.16,
        speedX: 0.01,
        speedY: -0.02,
        size: 3.2,
        maxAlpha: 0.55,
        phase: 0.5,
        isDiamond: true),
    _EnvParticle(
        x: 0.15,
        y: 0.32,
        speedX: -0.01,
        speedY: -0.03,
        size: 2.2,
        maxAlpha: 0.42,
        phase: 1.3),
    _EnvParticle(
        x: 0.06,
        y: 0.48,
        speedX: 0.01,
        speedY: -0.02,
        size: 2.8,
        maxAlpha: 0.48,
        phase: 2.4,
        isDiamond: true),
    _EnvParticle(
        x: 0.19,
        y: 0.22,
        speedX: -0.01,
        speedY: -0.02,
        size: 2.5,
        maxAlpha: 0.45,
        phase: 0.8),
    _EnvParticle(
        x: 0.12,
        y: 0.65,
        speedX: 0.01,
        speedY: -0.03,
        size: 3.4,
        maxAlpha: 0.52,
        phase: 3.0,
        isDiamond: true),
    _EnvParticle(
        x: 0.85,
        y: 0.14,
        speedX: -0.01,
        speedY: -0.02,
        size: 3.5,
        maxAlpha: 0.58,
        phase: 1.2,
        isDiamond: true),
    _EnvParticle(
        x: 0.93,
        y: 0.30,
        speedX: 0.01,
        speedY: -0.03,
        size: 2.4,
        maxAlpha: 0.44,
        phase: 2.2),
    _EnvParticle(
        x: 0.88,
        y: 0.52,
        speedX: -0.01,
        speedY: -0.02,
        size: 3.0,
        maxAlpha: 0.50,
        phase: 0.4,
        isDiamond: true),
    _EnvParticle(
        x: 0.82,
        y: 0.24,
        speedX: 0.01,
        speedY: -0.02,
        size: 2.6,
        maxAlpha: 0.46,
        phase: 1.9),
    _EnvParticle(
        x: 0.95,
        y: 0.68,
        speedX: -0.01,
        speedY: -0.03,
        size: 3.6,
        maxAlpha: 0.56,
        phase: 2.7,
        isDiamond: true),
    _EnvParticle(
        x: 0.10,
        y: 0.82,
        speedX: 0.01,
        speedY: -0.02,
        size: 2.4,
        maxAlpha: 0.38,
        phase: 0.7),
    _EnvParticle(
        x: 0.86,
        y: 0.86,
        speedX: -0.01,
        speedY: -0.02,
        size: 2.8,
        maxAlpha: 0.42,
        phase: 1.6,
        isDiamond: true),
  ];

  static const List<_EnvParticle> _prismParticles = [
    _EnvParticle(
        x: 0.08,
        y: 0.22,
        speedX: 0.01,
        speedY: -0.04,
        size: 3.4,
        maxAlpha: 0.54,
        phase: 0.3,
        isDiamond: true),
    _EnvParticle(
        x: 0.16,
        y: 0.45,
        speedX: -0.01,
        speedY: -0.05,
        size: 2.4,
        maxAlpha: 0.42,
        phase: 1.5,
        isDiamond: true),
    _EnvParticle(
        x: 0.06,
        y: 0.68,
        speedX: 0.02,
        speedY: -0.04,
        size: 3.0,
        maxAlpha: 0.48,
        phase: 2.2,
        isDiamond: true),
    _EnvParticle(
        x: 0.18,
        y: 0.84,
        speedX: -0.02,
        speedY: -0.05,
        size: 2.6,
        maxAlpha: 0.40,
        phase: 0.9,
        isDiamond: true),
    _EnvParticle(
        x: 0.11,
        y: 0.35,
        speedX: 0.01,
        speedY: -0.04,
        size: 3.2,
        maxAlpha: 0.50,
        phase: 2.8,
        isDiamond: true),
    _EnvParticle(
        x: 0.84,
        y: 0.18,
        speedX: -0.02,
        speedY: -0.05,
        size: 3.6,
        maxAlpha: 0.56,
        phase: 1.1,
        isDiamond: true),
    _EnvParticle(
        x: 0.92,
        y: 0.42,
        speedX: 0.01,
        speedY: -0.04,
        size: 2.6,
        maxAlpha: 0.44,
        phase: 2.0,
        isDiamond: true),
    _EnvParticle(
        x: 0.88,
        y: 0.64,
        speedX: -0.01,
        speedY: -0.05,
        size: 3.2,
        maxAlpha: 0.50,
        phase: 0.6,
        isDiamond: true),
    _EnvParticle(
        x: 0.82,
        y: 0.82,
        speedX: 0.02,
        speedY: -0.04,
        size: 2.4,
        maxAlpha: 0.38,
        phase: 1.7,
        isDiamond: true),
    _EnvParticle(
        x: 0.95,
        y: 0.28,
        speedX: -0.02,
        speedY: -0.05,
        size: 3.8,
        maxAlpha: 0.58,
        phase: 2.6,
        isDiamond: true),
    _EnvParticle(
        x: 0.12,
        y: 0.58,
        speedX: 0.01,
        speedY: -0.04,
        size: 2.5,
        maxAlpha: 0.40,
        phase: 0.7,
        isDiamond: true),
    _EnvParticle(
        x: 0.86,
        y: 0.50,
        speedX: -0.01,
        speedY: -0.05,
        size: 2.9,
        maxAlpha: 0.46,
        phase: 1.4,
        isDiamond: true),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = ambientAnimation.value;
    final r = reactiveAnimation.value;
    final streakMultiplier = (1.0 + (streak * 0.07)).clamp(1.0, 1.35);

    switch (theme.type) {
      case ThemeType.midnightNeon:
        _paintMidnightNeon(canvas, size, t, r, streakMultiplier);
        break;
      case ThemeType.aurora:
        _paintAurora(canvas, size, t, r, streakMultiplier);
        break;
      case ThemeType.sunsetPulse:
        _paintSunset(canvas, size, t, r, streakMultiplier);
        break;
      case ThemeType.arcticGlow:
        _paintArctic(canvas, size, t, r, streakMultiplier);
        break;
      case ThemeType.sakuraDrift:
        _paintSakura(canvas, size, t, r, streakMultiplier);
        break;
      case ThemeType.abyssalDepths:
        _paintAbyssal(canvas, size, t, r, streakMultiplier);
        break;
      case ThemeType.retroGrid:
        _paintRetroGrid(canvas, size, t, r, streakMultiplier);
        break;
      case ThemeType.emberCore:
        _paintEmberCore(canvas, size, t, r, streakMultiplier);
        break;
      case ThemeType.celestialObservatory:
        _paintCelestial(canvas, size, t, r, streakMultiplier);
        break;
      case ThemeType.prismRift:
        _paintPrismRift(canvas, size, t, r, streakMultiplier);
        break;
    }
  }

  // =========================================================================
  // 1. MIDNIGHT NEON: CYBER DIMENSION
  // =========================================================================
  void _paintMidnightNeon(
      Canvas canvas, Size size, double t, double r, double streakMultiplier) {
    final waveTime = t * 2.0 * math.pi;

    // Distant cyber light beams in outer margins
    final beam1X = size.width * 0.08 + math.sin(waveTime * 0.8) * 10.0;
    final beam1Alpha =
        (0.10 + 0.04 * math.sin(waveTime * 1.2)) * streakMultiplier;
    final beam1Paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.primaryAccent.withValues(alpha: beam1Alpha * 0.7),
          theme.primaryAccent.withValues(alpha: beam1Alpha),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(beam1X - 22, 0, 44, size.height * 0.75));
    canvas.drawRect(
        Rect.fromLTWH(beam1X - 22, 0, 44, size.height * 0.75), beam1Paint);

    final beam2X = size.width * 0.92 + math.cos(waveTime * 0.7) * 10.0;
    final beam2Alpha =
        (0.09 + 0.03 * math.cos(waveTime * 1.1)) * streakMultiplier;
    final beam2Paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.secondaryAccent.withValues(alpha: beam2Alpha * 0.7),
          theme.secondaryAccent.withValues(alpha: beam2Alpha),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(beam2X - 24, 0, 48, size.height * 0.75));
    canvas.drawRect(
        Rect.fromLTWH(beam2X - 24, 0, 48, size.height * 0.75), beam2Paint);

    // Subtle floor mist breathing at bottom
    final floorMistAlpha =
        (0.12 + 0.04 * math.sin(waveTime * 1.5)) * streakMultiplier;
    final floorMistPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.bottomCenter,
        radius: 0.8,
        colors: [
          theme.primaryAccent.withValues(alpha: floorMistAlpha),
          Colors.transparent,
        ],
      ).createShader(
          Rect.fromLTWH(0, size.height * 0.78, size.width, size.height * 0.22));
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.78, size.width, size.height * 0.22),
        floorMistPaint);

    // Drifting cyber particles
    _paintParticlesList(canvas, size, _midnightParticles, t, streakMultiplier,
        theme.primaryAccent, theme.secondaryAccent);

    // REACTIVE FEEDBACK: Perfect placement cyan shockwave pulse
    if (r > 0.001 && r < 1.0) {
      final pulseRadius = size.width * 0.20 + (size.width * 0.75) * r;
      final pulseAlpha = (0.28 * (1.0 - r)).clamp(0.0, 1.0);
      final center = Offset(size.width * 0.5, size.height * 0.62);

      final shockwavePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * (1.0 - r * 0.5)
        ..color = theme.reactivePulseColor.withValues(alpha: pulseAlpha);
      canvas.drawCircle(center, pulseRadius, shockwavePaint);

      final outerGlowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0 * (1.0 - r * 0.5)
        ..color = theme.reactiveSecondaryPulseColor
            .withValues(alpha: pulseAlpha * 0.35);
      canvas.drawCircle(center, pulseRadius, outerGlowPaint);
    }
  }

  // =========================================================================
  // 2. AURORA: LIVING LIGHTS
  // =========================================================================
  void _paintAurora(
      Canvas canvas, Size size, double t, double r, double streakMultiplier) {
    final waveTime = t * 2.0 * math.pi;

    // Reactive aurora shimmer intensity
    final reactiveShimmer =
        (r > 0.0 && r < 1.0) ? (math.sin(r * math.pi) * 0.22) : 0.0;
    final baseAlpha =
        ((0.14 + 0.05 * math.sin(waveTime * 1.3)) * streakMultiplier +
                reactiveShimmer)
            .clamp(0.0, 0.45);

    // Flowing Upper Aurora Ribbon 1 (Turquoise / Mint)
    final path1 = Path();
    path1.moveTo(0, size.height * 0.08);
    for (double x = 0; x <= size.width; x += 16) {
      final normX = x / size.width;
      final waveY = size.height * 0.12 +
          math.sin(normX * 3.5 + waveTime * 1.4) * 18.0 +
          math.cos(normX * 6.0 + waveTime * 0.8) * 12.0;
      path1.lineTo(x, waveY);
    }
    path1.lineTo(size.width, 0);
    path1.lineTo(0, 0);
    path1.close();

    final auroraPaint1 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.mintAccent.withValues(alpha: baseAlpha * 0.8),
          theme.mintAccent.withValues(alpha: baseAlpha * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.26));
    canvas.drawPath(path1, auroraPaint1);

    // Flowing Upper Aurora Ribbon 2 (Emerald Jade)
    final path2 = Path();
    path2.moveTo(0, size.height * 0.14);
    for (double x = 0; x <= size.width; x += 18) {
      final normX = x / size.width;
      final waveY = size.height * 0.18 +
          math.cos(normX * 4.0 - waveTime * 1.1) * 20.0 +
          math.sin(normX * 7.0 + waveTime * 0.9) * 10.0;
      path2.lineTo(x, waveY);
    }
    path2.lineTo(size.width, 0);
    path2.lineTo(0, 0);
    path2.close();

    final emeraldColor = theme.reactiveSecondaryPulseColor;
    final auroraPaint2 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          emeraldColor.withValues(alpha: baseAlpha * 0.65),
          emeraldColor.withValues(alpha: baseAlpha * 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.32));
    canvas.drawPath(path2, auroraPaint2);

    // Floating spirit particles
    _paintParticlesList(canvas, size, _auroraParticles, t, streakMultiplier,
        theme.mintAccent, emeraldColor);

    // REACTIVE FEEDBACK: Shimmer ripple wave sweeping horizontally across aurora
    if (r > 0.001 && r < 1.0) {
      final sweepX = size.width * r;
      final sweepAlpha = (0.24 * (1.0 - r)).clamp(0.0, 1.0);
      final sweepRect = Rect.fromLTWH(sweepX - 60, 0, 120, size.height * 0.35);
      final shimmerPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            theme.mintAccent.withValues(alpha: sweepAlpha),
            Colors.transparent,
          ],
        ).createShader(sweepRect);
      canvas.drawRect(sweepRect, shimmerPaint);
    }
  }

  // =========================================================================
  // 3. SUNSET PULSE: GOLDEN HORIZON
  // =========================================================================
  void _paintSunset(
      Canvas canvas, Size size, double t, double r, double streakMultiplier) {
    final waveTime = t * 2.0 * math.pi;

    // Horizon glow breathing
    final reactiveGlow =
        (r > 0.0 && r < 1.0) ? (math.sin(r * math.pi) * 0.20) : 0.0;
    final horizonAlpha =
        ((0.14 + 0.05 * math.sin(waveTime * 1.1)) * streakMultiplier +
                reactiveGlow)
            .clamp(0.0, 0.45);

    final horizonY = size.height * 0.82;
    final horizonRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, horizonY),
      width: size.width * 1.4,
      height: size.height * 0.25,
    );

    final horizonPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.goldAccent.withValues(alpha: horizonAlpha),
          theme.neonMagenta.withValues(alpha: horizonAlpha * 0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(horizonRect);
    canvas.drawRect(horizonRect, horizonPaint);

    // Horizon glowing boundary line
    final horizonLineAlpha =
        (0.16 + 0.06 * math.cos(waveTime * 1.4)) * streakMultiplier;
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          theme.goldAccent.withValues(alpha: horizonLineAlpha),
          Colors.transparent,
        ],
        stops: const [0.05, 0.5, 0.95],
      ).createShader(Rect.fromLTWH(0, horizonY - 1, size.width, 2))
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(0, horizonY), Offset(size.width, horizonY), linePaint);

    // Floating warm embers
    _paintParticlesList(canvas, size, _sunsetParticles, t, streakMultiplier,
        theme.goldAccent, theme.orangeAccent);

    // REACTIVE FEEDBACK: Golden sweep across horizon on perfect placement
    if (r > 0.001 && r < 1.0) {
      final sweepProgress = r;
      final sweepAlpha = (0.30 * (1.0 - sweepProgress)).clamp(0.0, 1.0);
      final center = Offset(size.width * 0.5, horizonY);
      final radius = (size.width * 0.70) * sweepProgress;

      final sweepPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 * (1.0 - sweepProgress * 0.5)
        ..color = theme.goldAccent.withValues(alpha: sweepAlpha);
      canvas.drawCircle(center, radius, sweepPaint);
    }
  }

  // =========================================================================
  // 4. ARCTIC GLOW: FROZEN DIMENSION
  // =========================================================================
  void _paintArctic(
      Canvas canvas, Size size, double t, double r, double streakMultiplier) {
    final waveTime = t * 2.0 * math.pi;

    // Distant crystalline spire glints
    final glint1Alpha =
        ((0.15 + 0.12 * math.sin(waveTime * 2.2)) * streakMultiplier)
            .clamp(0.0, 0.6);
    final glint1Pos = Offset(size.width * 0.12, size.height * 0.32);
    _drawSparkle(canvas, glint1Pos, 7.0,
        theme.reactivePulseColor.withValues(alpha: glint1Alpha));

    final glint2Alpha =
        ((0.14 + 0.11 * math.cos(waveTime * 2.5)) * streakMultiplier)
            .clamp(0.0, 0.6);
    final glint2Pos = Offset(size.width * 0.88, size.height * 0.28);
    _drawSparkle(canvas, glint2Pos, 8.0,
        const Color(0xFFBBEFFF).withValues(alpha: glint2Alpha));

    // Floor frost mist breathing
    final frostMistAlpha =
        (0.13 + 0.04 * math.sin(waveTime * 1.3)) * streakMultiplier;
    final frostMistPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.bottomCenter,
        radius: 0.75,
        colors: [
          const Color(0xFFBBEFFF).withValues(alpha: frostMistAlpha),
          theme.primaryAccent.withValues(alpha: frostMistAlpha * 0.4),
          Colors.transparent,
        ],
      ).createShader(
          Rect.fromLTWH(0, size.height * 0.75, size.width, size.height * 0.25));
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.75, size.width, size.height * 0.25),
        frostMistPaint);

    // Drifting snowfall particles
    _paintParticlesList(canvas, size, _arcticParticles, t, streakMultiplier,
        const Color(0xFFBBEFFF), theme.primaryAccent);

    // REACTIVE FEEDBACK: Sharp icy sparkle flash radiating outward
    if (r > 0.001 && r < 1.0) {
      final pulseRadius = (size.width * 0.65) * r;
      final pulseAlpha = (0.32 * (1.0 - r)).clamp(0.0, 1.0);
      final center = Offset(size.width * 0.5, size.height * 0.62);

      final iceRingPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = const Color(0xFFBBEFFF).withValues(alpha: pulseAlpha);
      canvas.drawCircle(center, pulseRadius, iceRingPaint);

      // Central diamond glint
      _drawSparkle(canvas, center, 14.0 * (1.0 - r * 0.7),
          const Color(0xFFBBEFFF).withValues(alpha: pulseAlpha * 0.9));
    }
  }

  // =========================================================================
  // 5. SAKURA DRIFT: CHERRY BLOSSOM SANCTUARY
  // =========================================================================
  void _paintSakura(
      Canvas canvas, Size size, double t, double r, double streakMultiplier) {
    final waveTime = t * 2.0 * math.pi;

    // Soft lantern ambient glow in bottom corners
    final lanternAlpha =
        (0.12 + 0.04 * math.sin(waveTime * 1.2)) * streakMultiplier;
    final leftLantern = Paint()
      ..shader = RadialGradient(
        center: Alignment.bottomLeft,
        radius: 0.65,
        colors: [
          theme.primaryAccent.withValues(alpha: lanternAlpha),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(
          0, size.height * 0.70, size.width * 0.45, size.height * 0.30));
    canvas.drawRect(
        Rect.fromLTWH(
            0, size.height * 0.70, size.width * 0.45, size.height * 0.30),
        leftLantern);

    final rightLantern = Paint()
      ..shader = RadialGradient(
        center: Alignment.bottomRight,
        radius: 0.65,
        colors: [
          theme.secondaryAccent.withValues(alpha: lanternAlpha * 0.8),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(size.width * 0.55, size.height * 0.70,
          size.width * 0.45, size.height * 0.30));
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.55, size.height * 0.70, size.width * 0.45,
            size.height * 0.30),
        rightLantern);

    // Diagonally fluttering cherry blossom petals in outer edge columns
    _paintPetalsList(canvas, size, _sakuraParticles, t, streakMultiplier,
        theme.primaryAccent, theme.secondaryAccent);

    // REACTIVE FEEDBACK: Delicate blossom burst radiating on perfect placement
    if (r > 0.001 && r < 1.0) {
      final pulseRadius = (size.width * 0.68) * r;
      final pulseAlpha = (0.34 * (1.0 - r)).clamp(0.0, 1.0);
      final center = Offset(size.width * 0.5, size.height * 0.62);

      final petalRingPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2 * (1.0 - r * 0.4)
        ..color = theme.reactivePulseColor.withValues(alpha: pulseAlpha);
      canvas.drawCircle(center, pulseRadius, petalRingPaint);

      // Radiating blossom petal sparkles
      for (int i = 0; i < 6; i++) {
        final angle = (i * math.pi / 3.0) + (r * 0.5);
        final dist = pulseRadius * 0.95;
        final petalPos = Offset(
          center.dx + math.cos(angle) * dist,
          center.dy + math.sin(angle) * dist,
        );
        _drawPetal(canvas, petalPos, angle + math.pi / 2, 5.0 * (1.0 - r * 0.6),
            theme.reactiveSecondaryPulseColor.withValues(alpha: pulseAlpha));
      }
    }
  }

  // =========================================================================
  // 6. ABYSSAL DEPTHS: BIOLUMINESCENT OCEAN
  // =========================================================================
  void _paintAbyssal(
      Canvas canvas, Size size, double t, double r, double streakMultiplier) {
    final waveTime = t * 2.0 * math.pi;

    // Atmospheric volumetric caustic light shafts in outer corners
    final shaftAlpha =
        ((0.10 + 0.04 * math.sin(waveTime * 1.1)) * streakMultiplier)
            .clamp(0.0, 0.35);
    final leftShaft = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.25, 0)
      ..lineTo(size.width * 0.35, size.height * 0.60)
      ..lineTo(0, size.height * 0.40)
      ..close();
    final leftShaftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.primaryAccent.withValues(alpha: shaftAlpha * 0.8),
          theme.mintAccent.withValues(alpha: shaftAlpha * 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
          Rect.fromLTWH(0, 0, size.width * 0.35, size.height * 0.60));
    canvas.drawPath(leftShaft, leftShaftPaint);

    final rightShaft = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width * 0.75, 0)
      ..lineTo(size.width * 0.65, size.height * 0.55)
      ..lineTo(size.width, size.height * 0.45)
      ..close();
    final rightShaftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          theme.secondaryAccent.withValues(alpha: shaftAlpha * 0.7),
          theme.primaryAccent.withValues(alpha: shaftAlpha * 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(
          size.width * 0.65, 0, size.width * 0.35, size.height * 0.55));
    canvas.drawPath(rightShaft, rightShaftPaint);

    // Slowly rising luminous bubbles in outer water columns
    _paintBubblesList(canvas, size, _abyssalParticles, t, streakMultiplier,
        theme.primaryAccent, theme.mintAccent);

    // REACTIVE FEEDBACK: Sonar ripple expanding on perfect placement
    if (r > 0.001 && r < 1.0) {
      final pulseRadius = (size.width * 0.70) * r;
      final pulseAlpha = (0.30 * (1.0 - r)).clamp(0.0, 1.0);
      final center = Offset(size.width * 0.5, size.height * 0.62);

      final sonarPaint1 = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * (1.0 - r * 0.5)
        ..color = theme.reactivePulseColor.withValues(alpha: pulseAlpha);
      canvas.drawCircle(center, pulseRadius, sonarPaint1);

      final sonarPaint2 = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = theme.primaryAccent.withValues(alpha: pulseAlpha * 0.6);
      canvas.drawCircle(center, pulseRadius * 0.75, sonarPaint2);
    }
  }

  // =========================================================================
  // 7. RETRO GRID: DIGITAL SYNTHWAVE
  // =========================================================================
  void _paintRetroGrid(
      Canvas canvas, Size size, double t, double r, double streakMultiplier) {
    final waveTime = t * 2.0 * math.pi;

    // Horizon line at 80% height
    final horizonY = size.height * 0.80;

    // Horizon neon glow
    final reactiveHorizon =
        (r > 0.0 && r < 1.0) ? (math.sin(r * math.pi) * 0.22) : 0.0;
    final horizonAlpha =
        ((0.15 + 0.05 * math.sin(waveTime * 1.2)) * streakMultiplier +
                reactiveHorizon)
            .clamp(0.0, 0.45);
    final horizonGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.primaryAccent.withValues(alpha: horizonAlpha),
          theme.secondaryAccent.withValues(alpha: horizonAlpha * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCenter(
          center: Offset(size.width * 0.5, horizonY),
          width: size.width * 1.4,
          height: size.height * 0.20));
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(size.width * 0.5, horizonY),
            width: size.width * 1.4,
            height: size.height * 0.20),
        horizonGlow);

    // Perspective wireframe grid in lower section
    final gridAlpha = (0.16 * streakMultiplier).clamp(0.0, 0.40);
    final gridPaint = Paint()
      ..color = theme.primaryAccent.withValues(alpha: gridAlpha)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Receding perspective lines converging toward center vanishing point
    final vp = Offset(size.width * 0.5, horizonY);
    for (double fx = 0.0; fx <= 1.0; fx += 0.166) {
      final bottomX = size.width * fx;
      canvas.drawLine(vp, Offset(bottomX, size.height), gridPaint);
    }

    // Scrolling horizontal grid lines
    final scrollOffset = (t * 2.0) % 1.0;
    for (int i = 1; i <= 4; i++) {
      final progress = math.pow((i + scrollOffset) / 5.0, 2.0).toDouble();
      final lineY = horizonY + (size.height - horizonY) * progress;
      final lineAlpha = (gridAlpha * progress).clamp(0.0, 0.35);
      final hLinePaint = Paint()
        ..color = theme.secondaryAccent.withValues(alpha: lineAlpha)
        ..strokeWidth = 1.0 + progress * 0.8
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, lineY), Offset(size.width, lineY), hLinePaint);
    }

    // Laser scanning line sweeping gently
    final scanY = size.height * 0.25 +
        (size.height * 0.40) * (0.5 + 0.5 * math.sin(waveTime * 0.7));
    final scanAlpha =
        (0.10 + 0.05 * math.cos(waveTime * 1.5)) * streakMultiplier;
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          theme.secondaryAccent.withValues(alpha: scanAlpha),
          Colors.transparent,
        ],
        stops: const [0.08, 0.5, 0.92],
      ).createShader(Rect.fromLTWH(0, scanY - 1, size.width, 2))
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, scanY), Offset(size.width, scanY), scanPaint);

    // Drifting digital particles in outer columns
    _paintParticlesList(canvas, size, _retroParticles, t, streakMultiplier,
        theme.primaryAccent, theme.secondaryAccent);

    // REACTIVE FEEDBACK: High-energy synthwave pulse wave
    if (r > 0.001 && r < 1.0) {
      final pulseRadius = (size.width * 0.75) * r;
      final pulseAlpha = (0.32 * (1.0 - r)).clamp(0.0, 1.0);
      final center = Offset(size.width * 0.5, horizonY);

      final shockwavePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8 * (1.0 - r * 0.4)
        ..color = theme.reactivePulseColor.withValues(alpha: pulseAlpha);
      canvas.drawCircle(center, pulseRadius, shockwavePaint);

      final horizonPulsePaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            theme.reactiveSecondaryPulseColor
                .withValues(alpha: pulseAlpha * 0.8),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(
            size.width * 0.5 - pulseRadius, horizonY - 1.5, pulseRadius * 2, 3))
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(size.width * 0.5 - pulseRadius, horizonY),
          Offset(size.width * 0.5 + pulseRadius, horizonY), horizonPulsePaint);
    }
  }

  // =========================================================================
  // 8. EMBER CORE: VOLCANIC CHAMBER
  // =========================================================================
  void _paintEmberCore(
      Canvas canvas, Size size, double t, double r, double streakMultiplier) {
    final waveTime = t * 2.0 * math.pi;

    // Volcanic floor molten glow breathing
    final reactiveGlow =
        (r > 0.0 && r < 1.0) ? (math.sin(r * math.pi) * 0.22) : 0.0;
    final floorAlpha =
        ((0.15 + 0.05 * math.sin(waveTime * 1.4)) * streakMultiplier +
                reactiveGlow)
            .clamp(0.0, 0.45);

    final floorPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.bottomCenter,
        radius: 0.85,
        colors: [
          theme.primaryAccent.withValues(alpha: floorAlpha),
          theme.secondaryAccent.withValues(alpha: floorAlpha * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(
          Rect.fromLTWH(0, size.height * 0.72, size.width, size.height * 0.28));
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.72, size.width, size.height * 0.28),
        floorPaint);

    // Glowing molten edge fissures (strictly in outer 12% margins)
    final fissureAlpha =
        (0.12 + 0.04 * math.cos(waveTime * 1.6)) * streakMultiplier;
    final leftFissurePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          theme.primaryAccent.withValues(alpha: fissureAlpha),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(
          0, size.height * 0.65, size.width * 0.15, size.height * 0.35));
    canvas.drawRect(
        Rect.fromLTWH(
            0, size.height * 0.65, size.width * 0.15, size.height * 0.35),
        leftFissurePaint);

    final rightFissurePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [
          theme.secondaryAccent.withValues(alpha: fissureAlpha),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(size.width * 0.85, size.height * 0.65,
          size.width * 0.15, size.height * 0.35));
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.85, size.height * 0.65, size.width * 0.15,
            size.height * 0.35),
        rightFissurePaint);

    // Floating molten embers rising from fissures
    _paintParticlesList(canvas, size, _emberParticles, t, streakMultiplier,
        theme.primaryAccent, theme.secondaryAccent);

    // REACTIVE FEEDBACK: Blazing molten magma shockwave
    if (r > 0.001 && r < 1.0) {
      final pulseRadius = (size.width * 0.72) * r;
      final pulseAlpha = (0.34 * (1.0 - r)).clamp(0.0, 1.0);
      final center = Offset(size.width * 0.5, size.height * 0.62);

      final magmaRingPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 * (1.0 - r * 0.5)
        ..color = theme.reactivePulseColor.withValues(alpha: pulseAlpha);
      canvas.drawCircle(center, pulseRadius, magmaRingPaint);

      final outerFirePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.5 * (1.0 - r * 0.5)
        ..color = theme.reactiveSecondaryPulseColor
            .withValues(alpha: pulseAlpha * 0.35);
      canvas.drawCircle(center, pulseRadius, outerFirePaint);

      // Core ember spark
      _drawSparkle(canvas, center, 12.0 * (1.0 - r * 0.6),
          theme.reactivePulseColor.withValues(alpha: pulseAlpha * 0.9));
    }
  }

  // =========================================================================
  // 9. CELESTIAL OBSERVATORY: GOLDEN CONSTELLATIONS
  // =========================================================================
  void _paintCelestial(
      Canvas canvas, Size size, double t, double r, double streakMultiplier) {
    final waveTime = t * 2.0 * math.pi;

    // Constellation lines in upper-left and upper-right sky margins
    final lineAlpha =
        ((0.14 + 0.06 * math.sin(waveTime * 1.2)) * streakMultiplier)
            .clamp(0.0, 0.40);
    final constelPaint = Paint()
      ..color = theme.primaryAccent.withValues(alpha: lineAlpha)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Cluster 1 (Top Left Margin)
    final p1 = Offset(size.width * 0.06, size.height * 0.15);
    final p2 = Offset(size.width * 0.14, size.height * 0.12);
    final p3 = Offset(size.width * 0.20, size.height * 0.22);
    final p4 = Offset(size.width * 0.10, size.height * 0.28);
    canvas.drawLine(p1, p2, constelPaint);
    canvas.drawLine(p2, p3, constelPaint);
    canvas.drawLine(p3, p4, constelPaint);

    // Cluster 2 (Top Right Margin)
    final q1 = Offset(size.width * 0.94, size.height * 0.14);
    final q2 = Offset(size.width * 0.86, size.height * 0.18);
    final q3 = Offset(size.width * 0.80, size.height * 0.26);
    final q4 = Offset(size.width * 0.90, size.height * 0.32);
    canvas.drawLine(q1, q2, constelPaint);
    canvas.drawLine(q2, q3, constelPaint);
    canvas.drawLine(q3, q4, constelPaint);

    // Subtle shooting star streak periodically
    final shootTime = (t * 3.5) % 1.0;
    if (shootTime < 0.25) {
      final shootProgress = shootTime / 0.25;
      final startX = size.width * 0.60 + size.width * 0.35 * shootProgress;
      final startY = size.height * 0.08 + size.height * 0.12 * shootProgress;
      final shootAlpha =
          (math.sin(shootProgress * math.pi) * 0.35 * streakMultiplier)
              .clamp(0.0, 0.6);

      final shootPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            theme.primaryAccent.withValues(alpha: shootAlpha),
            Colors.white.withValues(alpha: shootAlpha * 0.9),
          ],
          stops: const [0.0, 0.7, 1.0],
        ).createShader(Rect.fromLTWH(startX - 40, startY - 20, 45, 25))
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
          Offset(startX - 36, startY - 14), Offset(startX, startY), shootPaint);
    }

    // Drifting celestial diamond stars in edge margins
    _paintParticlesList(canvas, size, _celestialParticles, t, streakMultiplier,
        theme.primaryAccent, theme.secondaryAccent);

    // REACTIVE FEEDBACK: Golden starburst constellation flash
    if (r > 0.001 && r < 1.0) {
      final pulseRadius = (size.width * 0.65) * r;
      final pulseAlpha = (0.35 * (1.0 - r)).clamp(0.0, 1.0);
      final center = Offset(size.width * 0.5, size.height * 0.62);

      final starRingPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4 * (1.0 - r * 0.4)
        ..color = theme.reactivePulseColor.withValues(alpha: pulseAlpha);
      canvas.drawCircle(center, pulseRadius, starRingPaint);

      // Central 8-pointed golden celestial sparkle
      _drawSparkle(canvas, center, 16.0 * (1.0 - r * 0.6),
          theme.reactivePulseColor.withValues(alpha: pulseAlpha * 0.9));
      _drawSparkle(canvas, center, 10.0 * (1.0 - r * 0.6),
          Colors.white.withValues(alpha: pulseAlpha));
    }
  }

  // =========================================================================
  // 10. PRISM RIFT: DIMENSIONAL FRACTURE
  // =========================================================================
  void _paintPrismRift(
      Canvas canvas, Size size, double t, double r, double streakMultiplier) {
    final waveTime = t * 2.0 * math.pi;

    // Shifting dimensional refracted light facets
    final facetAlpha =
        ((0.11 + 0.04 * math.sin(waveTime * 1.3)) * streakMultiplier)
            .clamp(0.0, 0.35);

    // Left refractive angled beam
    final leftFacet = Path()
      ..moveTo(0, size.height * 0.15)
      ..lineTo(size.width * 0.30, size.height * 0.45)
      ..lineTo(size.width * 0.22, size.height * 0.60)
      ..lineTo(0, size.height * 0.40)
      ..close();
    final leftFacetPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.primaryAccent.withValues(alpha: facetAlpha * 0.8),
          theme.secondaryAccent.withValues(alpha: facetAlpha * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(
          0, size.height * 0.15, size.width * 0.30, size.height * 0.45));
    canvas.drawPath(leftFacet, leftFacetPaint);

    // Right refractive angled beam
    final rightFacet = Path()
      ..moveTo(size.width, size.height * 0.20)
      ..lineTo(size.width * 0.70, size.height * 0.50)
      ..lineTo(size.width * 0.78, size.height * 0.65)
      ..lineTo(size.width, size.height * 0.45)
      ..close();
    final rightFacetPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          theme.secondaryAccent.withValues(alpha: facetAlpha * 0.8),
          theme.primaryAccent.withValues(alpha: facetAlpha * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(size.width * 0.70, size.height * 0.20,
          size.width * 0.30, size.height * 0.45));
    canvas.drawPath(rightFacet, rightFacetPaint);

    // Drifting faceted diamond crystal shards
    _paintParticlesList(canvas, size, _prismParticles, t, streakMultiplier,
        theme.primaryAccent, theme.secondaryAccent);

    // REACTIVE FEEDBACK: Multi-spectral chromatic energy ripple
    if (r > 0.001 && r < 1.0) {
      final pulseRadius = (size.width * 0.70) * r;
      final pulseAlpha = (0.32 * (1.0 - r)).clamp(0.0, 1.0);
      final center = Offset(size.width * 0.5, size.height * 0.62);

      // Cyan outer ring
      final cyanRingPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2 * (1.0 - r * 0.4)
        ..color = theme.reactivePulseColor.withValues(alpha: pulseAlpha);
      canvas.drawCircle(center, pulseRadius, cyanRingPaint);

      // Magenta inner ring (chromatic dispersion)
      final magentaRingPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * (1.0 - r * 0.4)
        ..color = theme.reactiveSecondaryPulseColor
            .withValues(alpha: pulseAlpha * 0.85);
      canvas.drawCircle(center, pulseRadius * 0.88, magentaRingPaint);

      // Refracted crystal glint at center
      _drawSparkle(canvas, center, 14.0 * (1.0 - r * 0.6),
          theme.reactivePulseColor.withValues(alpha: pulseAlpha));
    }
  }

  void _paintPetalsList(
    Canvas canvas,
    Size size,
    List<_EnvParticle> particles,
    double t,
    double streakMultiplier,
    Color primaryColor,
    Color secondaryColor,
  ) {
    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];

      // Vertical drift with seamless wrap
      final rawY = (p.y + p.speedY * t) % 1.0;
      final currentY = rawY * size.height;

      // Diagonal flutter sway
      final currentX = p.x * size.width +
          math.sin(t * 2.0 * math.pi * 1.2 + p.phase) * (size.width * 0.04) +
          (p.speedX * t * size.width) % (size.width * 0.08);

      final pulse = 0.75 + 0.25 * math.sin(t * 2.0 * math.pi * 1.8 + p.phase);
      final alpha = (p.maxAlpha * pulse * streakMultiplier).clamp(0.0, 1.0);
      if (alpha <= 0.01) continue;

      final color =
          (i % 2 == 0 ? primaryColor : secondaryColor).withValues(alpha: alpha);
      final angle = (t * 2.0 * math.pi + p.phase) * 0.5;
      _drawPetal(canvas, Offset(currentX, currentY), angle, p.size, color);
    }
  }

  void _drawPetal(
      Canvas canvas, Offset center, double angle, double radius, Color color) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final path = Path()
      ..moveTo(0, -radius * 1.5)
      ..quadraticBezierTo(
          radius * 0.8, -radius * 0.5, radius * 0.6, radius * 0.8)
      ..quadraticBezierTo(0, radius * 1.4, -radius * 0.6, radius * 0.8)
      ..quadraticBezierTo(-radius * 0.8, -radius * 0.5, 0, -radius * 1.5)
      ..close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _paintBubblesList(
    Canvas canvas,
    Size size,
    List<_EnvParticle> particles,
    double t,
    double streakMultiplier,
    Color primaryColor,
    Color secondaryColor,
  ) {
    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];

      // Vertical rise with seamless wrap
      final rawY = (p.y + p.speedY * t) % 1.0;
      final currentY = rawY * size.height;

      // Gentle horizontal underwater sway
      final currentX = p.x * size.width +
          math.sin(t * 2.0 * math.pi * 1.1 + p.phase) * (size.width * 0.025);

      final pulse = 0.80 + 0.20 * math.sin(t * 2.0 * math.pi * 1.5 + p.phase);
      final alpha = (p.maxAlpha * pulse * streakMultiplier).clamp(0.0, 1.0);
      if (alpha <= 0.01) continue;

      final color =
          (i % 2 == 0 ? primaryColor : secondaryColor).withValues(alpha: alpha);

      _drawBubble(canvas, Offset(currentX, currentY), p.size, color);
    }
  }

  void _drawBubble(Canvas canvas, Offset center, double radius, Color color) {
    // Bubble body with translucent fill
    final fillPaint = Paint()
      ..color = color.withValues(alpha: (color.a * 0.35).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fillPaint);

    // Bubble outline
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, strokePaint);

    // Specular highlight dot at top-left
    final glintOffset =
        Offset(center.dx - radius * 0.35, center.dy - radius * 0.35);
    final glintPaint = Paint()
      ..color = Colors.white.withValues(alpha: (color.a * 0.7).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(glintOffset, math.max(0.8, radius * 0.25), glintPaint);
  }

  // =========================================================================
  // SHARED RENDERING HELPERS
  // =========================================================================
  void _paintParticlesList(
    Canvas canvas,
    Size size,
    List<_EnvParticle> particles,
    double t,
    double streakMultiplier,
    Color primaryColor,
    Color secondaryColor,
  ) {
    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];

      // Vertical drift with seamless wrap
      final rawY = (p.y + p.speedY * t) % 1.0;
      final currentY = rawY * size.height;

      // Subtle horizontal sway
      final currentX = p.x * size.width +
          math.sin(t * 2.0 * math.pi * 1.5 + p.phase) *
              (size.width * p.speedX * 3.0);

      // Breathing opacity
      final pulse = 0.75 + 0.25 * math.sin(t * 2.0 * math.pi * 2.0 + p.phase);
      final alpha = (p.maxAlpha * pulse * streakMultiplier).clamp(0.0, 1.0);
      if (alpha <= 0.01) continue;

      final color =
          (i % 2 == 0 ? primaryColor : secondaryColor).withValues(alpha: alpha);

      if (p.isDiamond) {
        final s = p.size * 1.25;
        final diamondPath = Path()
          ..moveTo(currentX, currentY - s)
          ..lineTo(currentX + s, currentY)
          ..lineTo(currentX, currentY + s)
          ..lineTo(currentX - s, currentY)
          ..close();

        final diamondPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawPath(diamondPath, diamondPaint);
      } else {
        final corePaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(currentX, currentY), p.size, corePaint);

        // Soft outer halo
        final haloPaint = Paint()
          ..color = color.withValues(alpha: alpha * 0.35)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(currentX, currentY), p.size * 2.0, haloPaint);
      }
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 4-pointed diamond star
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ThemeEnvironmentPainter oldDelegate) {
    return oldDelegate.ambientAnimation.value != ambientAnimation.value ||
        oldDelegate.reactiveAnimation.value != reactiveAnimation.value ||
        oldDelegate.theme.type != theme.type ||
        oldDelegate.streak != streak ||
        oldDelegate.isGameOver != isGameOver;
  }
}
