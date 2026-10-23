import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/game_theme.dart';
import '../../models/game_statistics.dart';
import '../widgets/premium_button.dart';
import '../widgets/stack_pulse_logo.dart';

class HomeScreen extends StatelessWidget {
  final GameTheme theme;
  final GameStatistics statistics;
  final VoidCallback onPlay;
  final VoidCallback onThemes;
  final VoidCallback onSettings;
  final VoidCallback onTutorial;

  const HomeScreen({
    super.key,
    required this.theme,
    required this.statistics,
    required this.onPlay,
    required this.onThemes,
    required this.onSettings,
    required this.onTutorial,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: theme.backgroundGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxHeight < 680;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: isCompact ? 10 : 16,
                ),
                child: Column(
                  children: [
                    // TOP BAR: Best Score Pill (Left) & Settings Button (Right)
                    _buildTopBar(),

                    const Spacer(flex: 1),

                    // BRANDING: 3-Pill Logo & Title
                    StackPulseLogo(
                      scale: isCompact ? 0.95 : 1.1,
                      showText: true,
                      stackedText: false,
                    ),

                    SizedBox(height: isCompact ? 14 : 22),

                    // HERO: Futuristic Neon 3D Tower & Cyber Skyline
                    Expanded(
                      flex: 6,
                      child: Center(
                        child: AnimatedHeroTowerPreview(
                          theme: theme,
                          size: isCompact ? 160 : 210,
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // PRIMARY CTA: Cyan-to-Purple Gradient PLAY Button
                    PremiumButton(
                      label: 'PLAY',
                      icon: Icons.play_arrow_rounded,
                      isPrimary: true,
                      theme: theme,
                      height: isCompact ? 56 : 62,
                      fontSize: 18,
                      onTap: onPlay,
                    ),

                    SizedBox(height: isCompact ? 14 : 20),

                    // BOTTOM ACTION ROW: 3 Tiles (THEMES, HOW TO PLAY, SETTINGS)
                    Row(
                      children: [
                        Expanded(
                          child: HomeActionTile(
                            label: 'THEMES',
                            icon: Icons.palette_outlined,
                            accentColor: const Color(0xFF14E4C5), // Mint
                            theme: theme,
                            onTap: onThemes,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: HomeActionTile(
                            label: 'HOW TO PLAY',
                            icon: Icons.help_outline_rounded,
                            accentColor: const Color(0xFF13D9FF), // Cyan
                            theme: theme,
                            onTap: onTutorial,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: HomeActionTile(
                            label: 'SETTINGS',
                            icon: Icons.settings_outlined,
                            accentColor: const Color(0xFFF34BEA), // Magenta
                            theme: theme,
                            onTap: onSettings,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isCompact ? 6 : 12),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Best Score Capsule with Crown Icon matching Reference Screen 2
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF14284A).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gold Crown Icon
              const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFFFFCB78),
                size: 16,
              ),
              const SizedBox(width: 7),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'BEST',
                    style: TextStyle(
                      color: Color(0xFFA8C4E4),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    '${statistics.bestScore}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Settings Icon Button matching Reference Screen 2
        GestureDetector(
          onTap: onSettings,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF14284A).withValues(alpha: 0.85),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Animated 3D Isometric Neon Hero Tower Preview with Cyber Skyline Background
/// matching Reference Screen 2
class AnimatedHeroTowerPreview extends StatefulWidget {
  final GameTheme theme;
  final double size;

  const AnimatedHeroTowerPreview({
    super.key,
    required this.theme,
    this.size = 210,
  });

  @override
  State<AnimatedHeroTowerPreview> createState() =>
      _AnimatedHeroTowerPreviewState();
}

class _AnimatedHeroTowerPreviewState extends State<AnimatedHeroTowerPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // In widget tests, avoid infinite repeat so tester.pumpAndSettle() completes cleanly
    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest) {
      _controller.repeat();
    } else {
      _controller.value = 0.25;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = _controller.value;
        final floatOffset = math.sin(progress * 2 * math.pi) * 8.0;
        final tiltAngle = math.sin(progress * 2 * math.pi) * 0.08;

        return SizedBox(
          width: widget.size * 1.5,
          height: widget.size,
          child: CustomPaint(
            painter: _HeroCyberTowerPainter(
              theme: widget.theme,
              floatOffset: floatOffset,
              tiltAngle: tiltAngle,
              progress: progress,
            ),
          ),
        );
      },
    );
  }
}

class _HeroCyberTowerPainter extends CustomPainter {
  final GameTheme theme;
  final double floatOffset;
  final double tiltAngle;
  final double progress;

  _HeroCyberTowerPainter({
    required this.theme,
    required this.floatOffset,
    required this.tiltAngle,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final baseY = size.height * 0.88;

    // 1. Cyber-City Skyline & Vertical Light Beams (Background)
    _drawSkylineAndBeams(canvas, size);

    // 2. Glowing Light Pool under Pedestal
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF13D9FF).withValues(alpha: 0.38),
          const Color(0xFF9658FF).withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCenter(
          center: Offset(centerX, baseY),
          width: 240,
          height: 90,
        ),
      );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(centerX, baseY + 6), width: 220, height: 60),
      glowPaint,
    );

    // 3. Isometric Base Pedestal Platform
    _drawIsometricBlock(
      canvas: canvas,
      center: Offset(centerX, baseY - 6),
      width: 140,
      height: 18,
      depth: 28,
      baseColor: const Color(0xFF14284A),
      topHighlight: const Color(0xFF1E3C6E),
      borderColor: const Color(0xFF13D9FF).withValues(alpha: 0.6),
    );

    // 4. Layer 1 Block (Deep Navy / Indigo Blue)
    _drawIsometricBlock(
      canvas: canvas,
      center: Offset(centerX, baseY - 28),
      width: 105,
      height: 16,
      depth: 22,
      baseColor: const Color(0xFF1C3A70),
      topHighlight: const Color(0xFF347BFF),
      borderColor: Colors.white.withValues(alpha: 0.3),
    );

    // 5. Layer 2 Block (Vibrant Neon Magenta / Pink)
    _drawIsometricBlock(
      canvas: canvas,
      center: Offset(centerX, baseY - 48),
      width: 85,
      height: 16,
      depth: 20,
      baseColor: const Color(0xFFF34BEA),
      topHighlight: const Color(0xFFFF85F9),
      borderColor: Colors.white.withValues(alpha: 0.4),
    );

    // 6. Layer 3 Block (Electric Cyan / Sky Blue)
    _drawIsometricBlock(
      canvas: canvas,
      center: Offset(centerX, baseY - 68),
      width: 70,
      height: 15,
      depth: 18,
      baseColor: const Color(0xFF13D9FF),
      topHighlight: const Color(0xFF75EDFF),
      borderColor: Colors.white.withValues(alpha: 0.5),
    );

    // 7. Top Active Floating Block (Electric Cyan, floating & tilted!)
    canvas.save();
    final topCenter = Offset(centerX, baseY - 98 + floatOffset);
    canvas.translate(topCenter.dx, topCenter.dy);
    canvas.rotate(tiltAngle);

    // Floating Block Ambient Glow
    final activeGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF13D9FF).withValues(alpha: 0.45),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: Offset.zero, radius: 50),
      );
    canvas.drawCircle(Offset.zero, 50, activeGlow);

    _drawIsometricBlock(
      canvas: canvas,
      center: Offset.zero,
      width: 60,
      height: 14,
      depth: 16,
      baseColor: const Color(0xFF13D9FF),
      topHighlight: Colors.white,
      borderColor: Colors.white.withValues(alpha: 0.8),
    );
    canvas.restore();
  }

  void _drawSkylineAndBeams(Canvas canvas, Size size) {
    final buildingPaint = Paint()
      ..color = const Color(0xFF0C1F42).withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    // Distant cyber buildings
    canvas.drawRect(
      Rect.fromLTWH(
          size.width * 0.08, size.height * 0.25, 26, size.height * 0.7),
      buildingPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
          size.width * 0.18, size.height * 0.35, 32, size.height * 0.6),
      buildingPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
          size.width * 0.75, size.height * 0.30, 28, size.height * 0.7),
      buildingPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
          size.width * 0.86, size.height * 0.22, 24, size.height * 0.7),
      buildingPaint,
    );

    // Vertical neon light beams
    final beamPaintCyan = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFF13D9FF).withValues(alpha: 0.25),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(size.width * 0.22, 0, 14, size.height),
      );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.22, 0, 14, size.height * 0.85),
      beamPaintCyan,
    );

    final beamPaintPurple = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFF9658FF).withValues(alpha: 0.25),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(size.width * 0.78, 0, 16, size.height),
      );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.78, 0, 16, size.height * 0.85),
      beamPaintPurple,
    );
  }

  void _drawIsometricBlock({
    required Canvas canvas,
    required Offset center,
    required double width,
    required double height,
    required double depth,
    required Color baseColor,
    required Color topHighlight,
    required Color borderColor,
  }) {
    final halfW = width / 2;
    final halfH = height / 2;

    // Front Face
    final frontRect = Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    );
    final frontRRect =
        RRect.fromRectAndRadius(frontRect, const Radius.circular(3));
    final frontPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          baseColor,
          Color.lerp(baseColor, Colors.black, 0.25)!,
        ],
      ).createShader(frontRect);
    canvas.drawRRect(frontRRect, frontPaint);

    // Top Isometric Bevel Face
    final topPath = Path()
      ..moveTo(center.dx - halfW, center.dy - halfH)
      ..lineTo(
          center.dx - halfW + depth * 0.5, center.dy - halfH - depth * 0.35)
      ..lineTo(
          center.dx + halfW + depth * 0.5, center.dy - halfH - depth * 0.35)
      ..lineTo(center.dx + halfW, center.dy - halfH)
      ..close();
    final topPaint = Paint()
      ..color = topHighlight.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;
    canvas.drawPath(topPath, topPaint);

    // Right Isometric Bevel Face
    final rightPath = Path()
      ..moveTo(center.dx + halfW, center.dy - halfH)
      ..lineTo(
          center.dx + halfW + depth * 0.5, center.dy - halfH - depth * 0.35)
      ..lineTo(
          center.dx + halfW + depth * 0.5, center.dy + halfH - depth * 0.35)
      ..lineTo(center.dx + halfW, center.dy + halfH)
      ..close();
    final rightPaint = Paint()
      ..color = Color.lerp(baseColor, Colors.black, 0.35)!
      ..style = PaintingStyle.fill;
    canvas.drawPath(rightPath, rightPaint);

    // Perimeter crisp highlight stroke
    final strokePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(frontRRect, strokePaint);
    canvas.drawPath(topPath, strokePaint);
    canvas.drawPath(rightPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _HeroCyberTowerPainter oldDelegate) =>
      oldDelegate.floatOffset != floatOffset ||
      oldDelegate.tiltAngle != tiltAngle;
}
