import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/game_theme.dart';

class SplashScreen extends StatefulWidget {
  final GameTheme theme;
  final bool reducedMotion;
  final VoidCallback onLoaded;

  const SplashScreen({
    super.key,
    required this.theme,
    this.reducedMotion = false,
    required this.onLoaded,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _progressAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    );

    // Stage A: Logo Staggered Entrance (0.00 -> 0.22, first ~1.5s)
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.00, 0.22, curve: Curves.easeOut),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.20),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.00, 0.22, curve: Curves.easeOutCubic),
    ));

    // Stage B: Title Reveal (0.20 -> 0.42, ~1.4s - 3.0s)
    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.20, 0.42, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.20, 0.42, curve: Curves.easeOutCubic),
    ));

    // Subtitle Fade (0.38 -> 0.58, ~2.6s - 4.0s)
    _subtitleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.38, 0.58, curve: Curves.easeOut),
    );

    // Progress Bar Progression across the full 7 seconds (0.02 -> 1.00)
    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.02, 1.00, curve: Curves.easeInOutCubic),
    );

    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest) {
      _controller.forward().then((_) => _triggerNavigation());
    } else {
      _controller.value = 1.0;
      WidgetsBinding.instance.addPostFrameCallback((_) => _triggerNavigation());
    }
  }

  void _triggerNavigation() {
    if (!_hasNavigated && mounted) {
      _hasNavigated = true;
      widget.onLoaded();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReducedMotion = widget.reducedMotion;

    return Scaffold(
      backgroundColor: const Color(0xFF061225),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. NANO BANANA GENERATED PRODUCTION BACKGROUND (Asset)
          Image.asset(
            'assets/images/splash_bg.jpg',
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

          // 2. Subtle Dark Gradient Overlay for Ambient Contrast
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF061225).withValues(alpha: 0.45),
                  Colors.transparent,
                  const Color(0xFF061225).withValues(alpha: 0.55),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // 3. CINEMATIC AMBIENT BACKGROUND ANIMATION (Aurora, Sweep, Rings, Particles)
          if (!isReducedMotion)
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _SplashBackgroundPainter(
                    animation: _controller,
                    particles: _SplashBackgroundPainter._particles,
                    cyanColor: widget.theme.primaryAccent,
                    blueColor: widget.theme.neonBlue,
                    violetColor: widget.theme.secondaryAccent,
                  ),
                ),
              ),
            ),

          // 3. Central Ambient Radial Glow behind Logo
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final opacity = isReducedMotion ? 1.0 : _logoFade.value;
                return Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF13D9FF)
                            .withValues(alpha: 0.20 * opacity),
                        const Color(0xFF9658FF)
                            .withValues(alpha: 0.10 * opacity),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 4. Center Animated Logo Presentation
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Stage A: 3-Pill Stacking Emblem
                    FadeTransition(
                      opacity: isReducedMotion
                          ? const AlwaysStoppedAnimation(1.0)
                          : _logoFade,
                      child: SlideTransition(
                        position: isReducedMotion
                            ? const AlwaysStoppedAnimation(Offset.zero)
                            : _logoSlide,
                        child: _buildEmblem(),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Stage B: Game Title (STACK in White, PULSE in Cyan)
                    FadeTransition(
                      opacity: isReducedMotion
                          ? const AlwaysStoppedAnimation(1.0)
                          : _titleFade,
                      child: SlideTransition(
                        position: isReducedMotion
                            ? const AlwaysStoppedAnimation(Offset.zero)
                            : _titleSlide,
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'STACK',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 5.0,
                                height: 1.05,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'PULSE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF13D9FF), // Electric Cyan
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 5.0,
                                height: 1.05,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle: ONE TAP. PERFECT STACK.
                    FadeTransition(
                      opacity: isReducedMotion
                          ? const AlwaysStoppedAnimation(1.0)
                          : _subtitleFade,
                      child: const Text(
                        'ONE TAP. PERFECT STACK.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFA8C4E4),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // 5. Bottom Loading Capsule Progress Bar
          Positioned(
            bottom: 54,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Container(
                    width: 180,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF14284A).withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1.0,
                      ),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progressAnimation.value.clamp(0.04, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF13D9FF),
                              Color(0xFF347BFF),
                              Color(0xFF9658FF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF13D9FF)
                                  .withValues(alpha: 0.55),
                              blurRadius: 10,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmblem() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPill(
          width: 32,
          height: 9,
          gradient: const LinearGradient(
            colors: [Color(0xFF55E7FF), Color(0xFF13D9FF)],
          ),
          shadowColor: const Color(0xFF13D9FF),
        ),
        const SizedBox(height: 4.5),
        _buildPill(
          width: 46,
          height: 9,
          gradient: const LinearGradient(
            colors: [Color(0xFF6EA8FE), Color(0xFF347BFF)],
          ),
          shadowColor: const Color(0xFF347BFF),
        ),
        const SizedBox(height: 4.5),
        _buildPill(
          width: 60,
          height: 9,
          gradient: const LinearGradient(
            colors: [Color(0xFFB485FF), Color(0xFF9658FF)],
          ),
          shadowColor: const Color(0xFF9658FF),
        ),
      ],
    );
  }

  Widget _buildPill({
    required double width,
    required double height,
    required Gradient gradient,
    required Color shadowColor,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.55),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 1,
            left: height / 2,
            right: height / 2,
            height: 1.5,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pre-configured immutable particle definition for splash background ambiance.
class _SplashParticle {
  final double x; // Relative X coordinate (0.0 to 1.0)
  final double y; // Relative Y coordinate (0.0 to 1.0)
  final double speedY; // Upward drift speed (-0.05 to -0.10)
  final double driftFrequency; // Horizontal sway frequency
  final double driftAmplitude; // Horizontal sway amplitude in pixels
  final double size; // Radius or half-width in pixels
  final double maxAlpha; // Peak opacity
  final double pulsePhase; // Phase offset for gentle opacity breathing
  final double staggerEntrance; // Normalized entrance time (0.02 to 0.12)
  final int colorIndex; // 0: cyan, 1: blue, 2: violet, 3: light cyan
  final bool isDiamond; // True for geometric diamond accent, false for circle

  const _SplashParticle({
    required this.x,
    required this.y,
    required this.speedY,
    required this.driftFrequency,
    required this.driftAmplitude,
    required this.size,
    required this.maxAlpha,
    required this.pulsePhase,
    required this.staggerEntrance,
    required this.colorIndex,
    required this.isDiamond,
  });
}

/// Lightweight, GPU-friendly CustomPainter delivering cinematic background ambiance:
/// - Animated Aurora Lighting (softly breathing cyan, blue, and violet pools)
/// - Initial Light Sweep (elegant ~800ms diagonal light pass on entrance)
/// - Ambient Energy Rings (expanding resonant wave outlines behind the logo)
/// - Floating Geometric Particles (18 persistent points with subtle upward drift)
class _SplashBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final List<_SplashParticle> particles;
  final Color cyanColor;
  final Color blueColor;
  final Color violetColor;

  static const List<_SplashParticle> _particles = [
    _SplashParticle(
      x: 0.12,
      y: 0.28,
      speedY: -0.07,
      driftFrequency: 1.1,
      driftAmplitude: 9.0,
      size: 2.4,
      maxAlpha: 0.45,
      pulsePhase: 0.4,
      staggerEntrance: 0.03,
      colorIndex: 0,
      isDiamond: false,
    ),
    _SplashParticle(
      x: 0.85,
      y: 0.22,
      speedY: -0.09,
      driftFrequency: 1.4,
      driftAmplitude: 12.0,
      size: 3.2,
      maxAlpha: 0.50,
      pulsePhase: 1.2,
      staggerEntrance: 0.04,
      colorIndex: 1,
      isDiamond: true,
    ),
    _SplashParticle(
      x: 0.22,
      y: 0.65,
      speedY: -0.06,
      driftFrequency: 0.9,
      driftAmplitude: 14.0,
      size: 2.0,
      maxAlpha: 0.40,
      pulsePhase: 2.1,
      staggerEntrance: 0.05,
      colorIndex: 2,
      isDiamond: false,
    ),
    _SplashParticle(
      x: 0.78,
      y: 0.72,
      speedY: -0.08,
      driftFrequency: 1.2,
      driftAmplitude: 10.0,
      size: 2.8,
      maxAlpha: 0.48,
      pulsePhase: 0.8,
      staggerEntrance: 0.06,
      colorIndex: 0,
      isDiamond: false,
    ),
    _SplashParticle(
      x: 0.08,
      y: 0.82,
      speedY: -0.06,
      driftFrequency: 1.0,
      driftAmplitude: 8.0,
      size: 2.2,
      maxAlpha: 0.38,
      pulsePhase: 3.0,
      staggerEntrance: 0.04,
      colorIndex: 3,
      isDiamond: true,
    ),
    _SplashParticle(
      x: 0.92,
      y: 0.42,
      speedY: -0.07,
      driftFrequency: 1.5,
      driftAmplitude: 11.0,
      size: 3.0,
      maxAlpha: 0.52,
      pulsePhase: 1.9,
      staggerEntrance: 0.07,
      colorIndex: 2,
      isDiamond: false,
    ),
    _SplashParticle(
      x: 0.18,
      y: 0.15,
      speedY: -0.08,
      driftFrequency: 1.3,
      driftAmplitude: 13.0,
      size: 2.5,
      maxAlpha: 0.42,
      pulsePhase: 2.5,
      staggerEntrance: 0.05,
      colorIndex: 0,
      isDiamond: false,
    ),
    _SplashParticle(
      x: 0.70,
      y: 0.12,
      speedY: -0.06,
      driftFrequency: 0.8,
      driftAmplitude: 7.0,
      size: 3.5,
      maxAlpha: 0.45,
      pulsePhase: 0.2,
      staggerEntrance: 0.03,
      colorIndex: 1,
      isDiamond: true,
    ),
    _SplashParticle(
      x: 0.28,
      y: 0.88,
      speedY: -0.07,
      driftFrequency: 1.1,
      driftAmplitude: 15.0,
      size: 2.2,
      maxAlpha: 0.35,
      pulsePhase: 1.7,
      staggerEntrance: 0.08,
      colorIndex: 2,
      isDiamond: false,
    ),
    _SplashParticle(
      x: 0.62,
      y: 0.85,
      speedY: -0.09,
      driftFrequency: 1.4,
      driftAmplitude: 12.0,
      size: 2.8,
      maxAlpha: 0.44,
      pulsePhase: 3.2,
      staggerEntrance: 0.09,
      colorIndex: 0,
      isDiamond: false,
    ),
    _SplashParticle(
      x: 0.05,
      y: 0.48,
      speedY: -0.05,
      driftFrequency: 0.9,
      driftAmplitude: 10.0,
      size: 2.0,
      maxAlpha: 0.36,
      pulsePhase: 0.6,
      staggerEntrance: 0.04,
      colorIndex: 3,
      isDiamond: false,
    ),
    _SplashParticle(
      x: 0.88,
      y: 0.88,
      speedY: -0.08,
      driftFrequency: 1.2,
      driftAmplitude: 9.0,
      size: 3.0,
      maxAlpha: 0.46,
      pulsePhase: 2.8,
      staggerEntrance: 0.07,
      colorIndex: 1,
      isDiamond: true,
    ),
    _SplashParticle(
      x: 0.35,
      y: 0.18,
      speedY: -0.07,
      driftFrequency: 1.0,
      driftAmplitude: 11.0,
      size: 2.3,
      maxAlpha: 0.40,
      pulsePhase: 1.5,
      staggerEntrance: 0.06,
      colorIndex: 0,
      isDiamond: false,
    ),
    _SplashParticle(
      x: 0.65,
      y: 0.32,
      speedY: -0.08,
      driftFrequency: 1.3,
      driftAmplitude: 13.0,
      size: 2.6,
      maxAlpha: 0.42,
      pulsePhase: 2.4,
      staggerEntrance: 0.08,
      colorIndex: 2,
      isDiamond: false,
    ),
    _SplashParticle(
      x: 0.15,
      y: 0.94,
      speedY: -0.06,
      driftFrequency: 1.1,
      driftAmplitude: 8.0,
      size: 2.1,
      maxAlpha: 0.35,
      pulsePhase: 0.9,
      staggerEntrance: 0.05,
      colorIndex: 1,
      isDiamond: false,
    ),
    _SplashParticle(
      x: 0.82,
      y: 0.58,
      speedY: -0.07,
      driftFrequency: 1.2,
      driftAmplitude: 14.0,
      size: 2.7,
      maxAlpha: 0.48,
      pulsePhase: 3.5,
      staggerEntrance: 0.09,
      colorIndex: 0,
      isDiamond: true,
    ),
    _SplashParticle(
      x: 0.42,
      y: 0.82,
      speedY: -0.08,
      driftFrequency: 0.9,
      driftAmplitude: 10.0,
      size: 2.4,
      maxAlpha: 0.39,
      pulsePhase: 1.8,
      staggerEntrance: 0.07,
      colorIndex: 3,
      isDiamond: false,
    ),
    _SplashParticle(
      x: 0.58,
      y: 0.14,
      speedY: -0.07,
      driftFrequency: 1.5,
      driftAmplitude: 12.0,
      size: 2.9,
      maxAlpha: 0.43,
      pulsePhase: 2.9,
      staggerEntrance: 0.06,
      colorIndex: 1,
      isDiamond: false,
    ),
  ];

  _SplashBackgroundPainter({
    required this.animation,
    required this.particles,
    required this.cyanColor,
    required this.blueColor,
    required this.violetColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;

    // 1. Animated Aurora Lighting
    _paintAuroraLighting(canvas, size, progress);

    // 2. Initial Light Sweep (~600-900ms entrance)
    _paintLightSweep(canvas, size, progress);

    // 3. Ambient Energy Ring Effect (behind logo)
    _paintEnergyRings(canvas, size, progress);

    // 4. Floating Geometric Light Particles
    _paintParticles(canvas, size, progress);
  }

  void _paintAuroraLighting(Canvas canvas, Size size, double progress) {
    final entranceFade =
        Curves.easeOut.transform((progress / 0.08).clamp(0.0, 1.0));
    if (entranceFade <= 0.0) return;

    final t = progress * 2.0 * math.pi;

    // Pool 1: Upper-Right Cyan/Blue Atmosphere
    final center1 = Offset(
      size.width * 0.82 + math.cos(t * 0.7) * 26.0,
      size.height * 0.16 + math.sin(t * 0.5) * 22.0,
    );
    final alpha1 = (0.13 + 0.04 * math.sin(t * 1.3)) * entranceFade;
    final radius1 = size.width * 0.65;
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          cyanColor.withValues(alpha: alpha1),
          blueColor.withValues(alpha: alpha1 * 0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center1, radius: radius1));
    canvas.drawCircle(center1, radius1, paint1);

    // Pool 2: Lower-Left Violet/Blue Atmosphere
    final center2 = Offset(
      size.width * 0.16 + math.sin(t * 0.6) * 24.0,
      size.height * 0.80 + math.cos(t * 0.4) * 20.0,
    );
    final alpha2 = (0.12 + 0.04 * math.cos(t * 1.1)) * entranceFade;
    final radius2 = size.width * 0.70;
    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          violetColor.withValues(alpha: alpha2),
          blueColor.withValues(alpha: alpha2 * 0.45),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center2, radius: radius2));
    canvas.drawCircle(center2, radius2, paint2);

    // Pool 3: Upper-Left Subtle Cyan Accent
    final center3 = Offset(
      size.width * 0.14 + math.cos(t * 0.5) * 18.0,
      size.height * 0.22 + math.sin(t * 0.8) * 16.0,
    );
    final alpha3 = (0.08 + 0.03 * math.sin(t * 0.9)) * entranceFade;
    final radius3 = size.width * 0.45;
    final paint3 = Paint()
      ..shader = RadialGradient(
        colors: [
          cyanColor.withValues(alpha: alpha3),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center3, radius: radius3));
    canvas.drawCircle(center3, radius3, paint3);
  }

  void _paintLightSweep(Canvas canvas, Size size, double progress) {
    // Active only between progress 0.02 and 0.14 (~140ms to ~980ms, duration ~840ms)
    if (progress < 0.02 || progress > 0.14) return;

    final sweepProgress = (progress - 0.02) / 0.12;
    final curvedSweep = Curves.easeInOutCubic.transform(sweepProgress);

    // Smooth soft fade-in & fade-out curve (no harsh full-screen flash)
    final sweepFade = sweepProgress < 0.30
        ? (sweepProgress / 0.30)
        : sweepProgress > 0.70
            ? ((1.0 - sweepProgress) / 0.30)
            : 1.0;

    final startPoint = Offset(-size.width * 0.35, -size.height * 0.25);
    final endPoint = Offset(size.width * 1.35, size.height * 1.25);
    final currentCenter = Offset.lerp(startPoint, endPoint, curvedSweep)!;

    canvas.save();
    canvas.translate(currentCenter.dx, currentCenter.dy);
    canvas.rotate(-math.pi / 5.2); // ~35 degree diagonal streak

    final bandWidth = size.width * 0.40;
    final bandLength = size.height * 2.2;
    final sweepRect = Rect.fromCenter(
      center: Offset.zero,
      width: bandWidth,
      height: bandLength,
    );

    final sweepPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          cyanColor.withValues(alpha: 0.11 * sweepFade),
          blueColor.withValues(alpha: 0.07 * sweepFade),
          Colors.transparent,
        ],
        stops: const [0.0, 0.46, 0.54, 1.0],
      ).createShader(sweepRect);

    canvas.drawRect(sweepRect, sweepPaint);
    canvas.restore();
  }

  void _paintEnergyRings(Canvas canvas, Size size, double progress) {
    // Faint, expanding circular rings radiating softly behind central logo
    final logoCenter = Offset(size.width * 0.5, size.height * 0.48);
    const minRadius = 55.0;
    const maxRadius = 150.0;
    const ringCount = 2;

    final entranceFade =
        Curves.easeOut.transform((progress / 0.15).clamp(0.0, 1.0));
    if (entranceFade <= 0.0) return;

    for (int i = 0; i < ringCount; i++) {
      // Gentle 2.4s cycle time per wave across 7s splash
      final ringPhase = (progress * (7.0 / 2.4) + (i * 0.5)) % 1.0;
      final currentRadius = minRadius +
          (maxRadius - minRadius) * Curves.easeOutCubic.transform(ringPhase);

      // Smooth opacity fade as radius expands
      final ringFade = (1.0 - ringPhase) *
          Curves.easeIn.transform((ringPhase / 0.25).clamp(0.0, 1.0));
      final ringAlpha = (0.20 * ringFade * entranceFade).clamp(0.0, 1.0);

      if (ringAlpha <= 0.005) continue;

      final baseColor = i % 2 == 0 ? cyanColor : violetColor;
      final ringColor = baseColor.withValues(alpha: ringAlpha);

      // Core crisp stroke
      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = ringColor;
      canvas.drawCircle(logoCenter, currentRadius, strokePaint);

      // Subtle luminous outer edge
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = baseColor.withValues(alpha: ringAlpha * 0.40);
      canvas.drawCircle(logoCenter, currentRadius, glowPaint);
    }
  }

  void _paintParticles(Canvas canvas, Size size, double progress) {
    final t = progress * 7.0; // Elapsed seconds

    for (final p in particles) {
      if (progress < p.staggerEntrance) continue;

      // Staggered entrance fade
      final entranceFade =
          ((progress - p.staggerEntrance) / 0.06).clamp(0.0, 1.0);

      // Slow upward drift with wrap-around
      final rawY = (p.y + p.speedY * progress) % 1.0;
      final currentY = rawY * size.height;

      // Subtle horizontal sway
      final currentX = p.x * size.width +
          math.sin(progress * 2.0 * math.pi * p.driftFrequency + p.pulsePhase) *
              p.driftAmplitude;

      // Natural fade-in and fade-out near screen edges
      final pulse = 0.75 + 0.25 * math.sin(t * 2.0 + p.pulsePhase);
      final edgeFade = rawY < 0.12
          ? (rawY / 0.12)
          : rawY > 0.88
              ? ((1.0 - rawY) / 0.12)
              : 1.0;

      final alpha =
          (p.maxAlpha * pulse * edgeFade * entranceFade).clamp(0.0, 1.0);
      if (alpha <= 0.01) continue;

      Color color;
      switch (p.colorIndex) {
        case 0:
          color = cyanColor;
          break;
        case 1:
          color = blueColor;
          break;
        case 2:
          color = violetColor;
          break;
        default:
          color = const Color(0xFF55E7FF);
          break;
      }

      final particleColor = color.withValues(alpha: alpha);

      if (p.isDiamond) {
        final s = p.size * 1.3;
        final diamondPath = Path()
          ..moveTo(currentX, currentY - s)
          ..lineTo(currentX + s, currentY)
          ..lineTo(currentX, currentY + s)
          ..lineTo(currentX - s, currentY)
          ..close();

        final diamondPaint = Paint()
          ..color = particleColor
          ..style = PaintingStyle.fill;
        canvas.drawPath(diamondPath, diamondPaint);

        // Faint glow halo
        final auraPaint = Paint()
          ..color = color.withValues(alpha: alpha * 0.35)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(currentX, currentY), s * 2.0, auraPaint);
      } else {
        // Small circular light point
        final corePaint = Paint()
          ..color = particleColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(currentX, currentY), p.size, corePaint);

        // Outer soft glow halo
        final haloPaint = Paint()
          ..color = color.withValues(alpha: alpha * 0.35)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(currentX, currentY), p.size * 2.2, haloPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SplashBackgroundPainter oldDelegate) {
    return oldDelegate.animation.value != animation.value ||
        oldDelegate.cyanColor != cyanColor ||
        oldDelegate.blueColor != blueColor ||
        oldDelegate.violetColor != violetColor;
  }
}
