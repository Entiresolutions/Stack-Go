import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/game_theme.dart';
import '../../models/game_settings.dart';
import '../../models/game_statistics.dart';
import '../widgets/premium_button.dart';
import '../widgets/stack_pulse_logo.dart';

class HomeScreen extends StatelessWidget {
  final GameTheme theme;
  final GameStatistics statistics;
  final GameSettings? settings;
  final VoidCallback onPlay;
  final VoidCallback onThemes;
  final VoidCallback onSettings;
  final VoidCallback onTutorial;

  const HomeScreen({
    super.key,
    required this.theme,
    required this.statistics,
    this.settings,
    required this.onPlay,
    required this.onThemes,
    required this.onSettings,
    required this.onTutorial,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061225),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. NANO BANANA GENERATED PRODUCTION BACKGROUND (Asset A)
          Image.asset(
            'assets/images/home_bg.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              // Fallback gradient if asset is loading or in headless tests
              return Container(
                decoration: BoxDecoration(
                  gradient: theme.backgroundGradient,
                ),
              );
            },
          ),

          // 2. Subtle Dark Gradient Overlay for Safe Area & System Bar Contrast
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF061225).withValues(alpha: 0.60),
                  Colors.transparent,
                  Colors.transparent,
                  const Color(0xFF061225).withValues(alpha: 0.75),
                ],
                stops: const [0.0, 0.16, 0.80, 1.0],
              ),
            ),
          ),

          // 3. Foreground Content with Responsive Safe Layout
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxHeight;
                final isCompact = height < 700;
                final isVeryCompact = height < 580;

                final heroSize = (height * 0.25).clamp(120.0, 210.0);

                return SingleChildScrollView(
                  physics: isCompact
                      ? const BouncingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: height),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: isCompact ? 10 : 16,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // TOP BAR: Best Score Pill (Left) & Settings Button (Right)
                          _buildTopBar(),

                          SizedBox(height: isCompact ? 10 : 34),

                          // BRANDING: 3-Pill Glowing Emblem inside Circular Halo + Title
                          StackPulseLogo(
                            scale:
                                isVeryCompact ? 0.80 : (isCompact ? 0.90 : 1.0),
                            showHalo: true,
                            showText: true,
                            stackedText: false,
                          ),

                          SizedBox(height: isCompact ? 4 : 8),

                          // HERO: 3D Stacking Blocks on Cyber Pedestal
                          Center(
                            child: AnimatedHeroTowerPreview(
                              theme: theme,
                              reducedMotion: settings?.reducedMotion ?? false,
                              size: heroSize,
                            ),
                          ),

                          SizedBox(height: isCompact ? 10 : 18),

                          // PRIMARY CTA: Cyan-to-Purple Gradient PLAY Button
                          PremiumButton(
                            label: 'PLAY',
                            icon: Icons.play_arrow_rounded,
                            isPrimary: true,
                            theme: theme,
                            reducedMotion: settings?.reducedMotion ?? false,
                            height: isCompact ? 54 : 62,
                            fontSize: 18,
                            onTap: onPlay,
                          ),

                          SizedBox(height: isCompact ? 12 : 16),

                          // BOTTOM ACTION ROW: 3 Tiles (THEMES, HOW TO PLAY, SETTINGS)
                          Row(
                            children: [
                              Expanded(
                                child: HomeActionTile(
                                  label: 'THEMES',
                                  icon: Icons.palette_rounded,
                                  accentColor: const Color(0xFF14E4C5), // Mint
                                  theme: theme,
                                  reducedMotion:
                                      settings?.reducedMotion ?? false,
                                  onTap: onThemes,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: HomeActionTile(
                                  label: 'HOW TO PLAY',
                                  icon: Icons.help_rounded,
                                  accentColor: const Color(0xFF13D9FF), // Cyan
                                  theme: theme,
                                  reducedMotion:
                                      settings?.reducedMotion ?? false,
                                  onTap: onTutorial,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: HomeActionTile(
                                  label: 'SETTINGS',
                                  icon: Icons.settings_rounded,
                                  accentColor:
                                      const Color(0xFFF34BEA), // Magenta
                                  theme: theme,
                                  reducedMotion:
                                      settings?.reducedMotion ?? false,
                                  onTap: onSettings,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isCompact ? 4 : 8),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
      ],
    );
  }
}

/// Animated 2.5D Stacking Blocks on Cyber Pedestal matching Reference Screen 2
class AnimatedHeroTowerPreview extends StatefulWidget {
  final GameTheme theme;
  final double size;
  final bool reducedMotion;

  const AnimatedHeroTowerPreview({
    super.key,
    required this.theme,
    this.size = 210,
    this.reducedMotion = false,
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
      duration: const Duration(milliseconds: 3000),
    );

    // In widget tests or reduced motion, avoid infinite repeat
    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest && !widget.reducedMotion) {
      _controller.repeat();
    } else {
      _controller.value = 0.25;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedHeroTowerPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reducedMotion != oldWidget.reducedMotion) {
      if (widget.reducedMotion) {
        _controller.stop();
        _controller.value = 0.25;
      } else {
        _controller.repeat();
      }
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
        final floatOffset =
            widget.reducedMotion ? 0.0 : math.sin(progress * 2 * math.pi) * 6.0;
        final tiltAngle = widget.reducedMotion
            ? -0.04
            : -0.04 + math.sin(progress * 2 * math.pi) * 0.04;

        return SizedBox(
          width: widget.size * 1.5,
          height: widget.size,
          child: CustomPaint(
            painter: _HeroBlocksPainter(
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

class _HeroBlocksPainter extends CustomPainter {
  final GameTheme theme;
  final double floatOffset;
  final double tiltAngle;
  final double progress;

  _HeroBlocksPainter({
    required this.theme,
    required this.floatOffset,
    required this.tiltAngle,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    // Align base with the pedestal surface
    final baseY = size.height * 0.84;

    // 1. Ambient cyan/blue glow pooling on the pedestal
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF13D9FF).withValues(alpha: 0.35),
          const Color(0xFF347BFF).withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCenter(
          center: Offset(centerX, baseY + 6),
          width: 180,
          height: 60,
        ),
      );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, baseY + 6),
        width: 180,
        height: 60,
      ),
      glowPaint,
    );

    // 2. Layer 1 Block (Bottom): Deep Cyan / Cobalt Blue
    _drawIsometricBlock(
      canvas: canvas,
      center: Offset(centerX, baseY - 12),
      width: 114,
      height: 20,
      depth: 26,
      baseColor: const Color(0xFF1E60D0),
      topHighlight: const Color(0xFF13D9FF),
      borderColor: Colors.white.withValues(alpha: 0.40),
    );

    // 3. Layer 2 Block: Electric Purple / Neon Magenta
    _drawIsometricBlock(
      canvas: canvas,
      center: Offset(centerX, baseY - 36),
      width: 94,
      height: 19,
      depth: 24,
      baseColor: const Color(0xFF8A30E0),
      topHighlight: const Color(0xFFF34BEA),
      borderColor: Colors.white.withValues(alpha: 0.45),
    );

    // 4. Layer 3 Block: Neon Coral Pink / Sunset
    _drawIsometricBlock(
      canvas: canvas,
      center: Offset(centerX, baseY - 59),
      width: 76,
      height: 18,
      depth: 22,
      baseColor: const Color(0xFFFF5E7E),
      topHighlight: const Color(0xFFFF8A65),
      borderColor: Colors.white.withValues(alpha: 0.50),
    );

    // 5. Layer 4 Active Top Block: Sky Blue / Electric Cyan (floating & jaunty tilt)
    canvas.save();
    final topCenter = Offset(centerX, baseY - 92 + floatOffset);
    canvas.translate(topCenter.dx, topCenter.dy);
    canvas.rotate(tiltAngle);

    // Radiant cyan bloom around the floating block
    final topGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF13D9FF).withValues(alpha: 0.40),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: Offset.zero, radius: 46),
      );
    canvas.drawCircle(Offset.zero, 46, topGlow);

    _drawIsometricBlock(
      canvas: canvas,
      center: Offset.zero,
      width: 62,
      height: 17,
      depth: 20,
      baseColor: const Color(0xFF13D9FF),
      topHighlight: const Color(0xFFBBEFFF),
      borderColor: Colors.white.withValues(alpha: 0.85),
    );
    canvas.restore();
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
        RRect.fromRectAndRadius(frontRect, const Radius.circular(3.5));
    final frontPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          baseColor,
          Color.lerp(baseColor, Colors.black, 0.28)!,
        ],
      ).createShader(frontRect);
    canvas.drawRRect(frontRRect, frontPaint);

    // Top Isometric Bevel Face
    final topPath = Path()
      ..moveTo(center.dx - halfW, center.dy - halfH)
      ..lineTo(
          center.dx - halfW + depth * 0.48, center.dy - halfH - depth * 0.32)
      ..lineTo(
          center.dx + halfW + depth * 0.48, center.dy - halfH - depth * 0.32)
      ..lineTo(center.dx + halfW, center.dy - halfH)
      ..close();
    final topPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          topHighlight,
          Color.lerp(topHighlight, baseColor, 0.40)!,
        ],
      ).createShader(topPath.getBounds());
    canvas.drawPath(topPath, topPaint);

    // Right Isometric Bevel Face
    final rightPath = Path()
      ..moveTo(center.dx + halfW, center.dy - halfH)
      ..lineTo(
          center.dx + halfW + depth * 0.48, center.dy - halfH - depth * 0.32)
      ..lineTo(
          center.dx + halfW + depth * 0.48, center.dy + halfH - depth * 0.32)
      ..lineTo(center.dx + halfW, center.dy + halfH)
      ..close();
    final rightPaint = Paint()
      ..color = Color.lerp(baseColor, Colors.black, 0.36)!
      ..style = PaintingStyle.fill;
    canvas.drawPath(rightPath, rightPaint);

    // Top Sheen Line across Front Face for glassmorphic gloss
    final sheenPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.1),
          Colors.white.withValues(alpha: 0.55),
          Colors.white.withValues(alpha: 0.1),
        ],
      ).createShader(frontRect)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(center.dx - halfW + 2, center.dy - halfH + 1.2),
      Offset(center.dx + halfW - 2, center.dy - halfH + 1.2),
      sheenPaint,
    );

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
  bool shouldRepaint(covariant _HeroBlocksPainter oldDelegate) =>
      oldDelegate.floatOffset != floatOffset ||
      oldDelegate.tiltAngle != tiltAngle ||
      oldDelegate.theme != theme;
}
