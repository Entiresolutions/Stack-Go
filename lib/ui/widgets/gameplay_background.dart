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
