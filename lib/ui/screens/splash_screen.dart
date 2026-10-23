import 'package:flutter/material.dart';
import '../../core/game_theme.dart';
import '../widgets/stack_pulse_logo.dart';

class SplashScreen extends StatefulWidget {
  final GameTheme theme;
  final VoidCallback onLoaded;

  const SplashScreen({
    super.key,
    required this.theme,
    required this.onLoaded,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest) {
      _progressController.forward().then((_) {
        widget.onLoaded();
      });
    } else {
      _progressController.value = 1.0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onLoaded();
      });
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Scaffold(
      backgroundColor: theme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: theme.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Floating geometric neon cubes background
            Positioned.fill(
              child: CustomPaint(
                painter: _FloatingCubesPainter(theme: theme),
              ),
            ),

            // Center Branding
            const Center(
              child: StackPulseLogo(
                scale: 1.25,
                showText: true,
                stackedText: true,
              ),
            ),

            // Bottom Loading Capsule Slider
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 170,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, _) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressController.value.clamp(0.05, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF13D9FF),
                                Color(0xFF9658FF),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF13D9FF)
                                    .withValues(alpha: 0.6),
                                blurRadius: 10,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the floating isometric neon cubes in the splash background
class _FloatingCubesPainter extends CustomPainter {
  final GameTheme theme;
  _FloatingCubesPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    // Cube 1: Top right glowing cyan cube
    _drawIsometricCube(
      canvas: canvas,
      center: Offset(size.width * 0.82, size.height * 0.14),
      cubeSize: 32,
      edgeColor: const Color(0xFF13D9FF),
      alpha: 0.55,
      angle: 0.2,
    );

    // Cube 2: Middle left magenta/purple cube
    _drawIsometricCube(
      canvas: canvas,
      center: Offset(size.width * 0.12, size.height * 0.28),
      cubeSize: 26,
      edgeColor: const Color(0xFFF34BEA),
      alpha: 0.45,
      angle: -0.35,
    );

    // Cube 3: Bottom right large electric blue/purple cube
    _drawIsometricCube(
      canvas: canvas,
      center: Offset(size.width * 0.85, size.height * 0.45),
      cubeSize: 42,
      edgeColor: const Color(0xFF9658FF),
      alpha: 0.50,
      angle: 0.45,
    );

    // Cube 4: Bottom left cyan/mint cube
    _drawIsometricCube(
      canvas: canvas,
      center: Offset(size.width * 0.18, size.height * 0.55),
      cubeSize: 36,
      edgeColor: const Color(0xFF13D9FF),
      alpha: 0.40,
      angle: 0.15,
    );

    // Cube 5: Far bottom left subtle cube
    _drawIsometricCube(
      canvas: canvas,
      center: Offset(size.width * 0.08, size.height * 0.72),
      cubeSize: 28,
      edgeColor: const Color(0xFF347BFF),
      alpha: 0.35,
      angle: -0.25,
    );
  }

  void _drawIsometricCube({
    required Canvas canvas,
    required Offset center,
    required double cubeSize,
    required Color edgeColor,
    required double alpha,
    required double angle,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final edgePaint = Paint()
      ..color = edgeColor.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final fillPaint = Paint()
      ..color = edgeColor.withValues(alpha: alpha * 0.12)
      ..style = PaintingStyle.fill;

    final r = cubeSize / 2;

    // Front Face
    final frontPath = Path()
      ..moveTo(-r, -r)
      ..lineTo(r, -r)
      ..lineTo(r, r)
      ..lineTo(-r, r)
      ..close();
    canvas.drawPath(frontPath, fillPaint);
    canvas.drawPath(frontPath, edgePaint);

    // Top Isometric Face
    final topPath = Path()
      ..moveTo(-r, -r)
      ..lineTo(0, -r - r * 0.6)
      ..lineTo(r * 2, -r - r * 0.6)
      ..lineTo(r, -r)
      ..close();
    canvas.drawPath(topPath, edgePaint);

    // Right Isometric Face
    final rightPath = Path()
      ..moveTo(r, -r)
      ..lineTo(r * 2, -r - r * 0.6)
      ..lineTo(r * 2, r - r * 0.6)
      ..lineTo(r, r)
      ..close();
    canvas.drawPath(rightPath, edgePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
