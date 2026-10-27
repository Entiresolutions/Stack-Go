import 'package:flutter/material.dart';

class StackGoLogo extends StatelessWidget {
  final double scale;
  final bool showText;
  final bool stackedText;
  final bool showHalo;
  final double? textSpacing;
  final double leftPadding;

  const StackGoLogo({
    super.key,
    this.scale = 1.0,
    this.showText = true,
    this.stackedText = false,
    this.showHalo = false,
    this.textSpacing,
    this.leftPadding = 7.0,
  });

  @override
  Widget build(BuildContext context) {
    final logoImage = ShaderMask(
      shaderCallback: (Rect bounds) {
        return const RadialGradient(
          center: Alignment.center,
          radius: 0.50,
          colors: [
            Colors.white,
            Colors.white,
            Color(0x80FFFFFF),
            Colors.transparent,
          ],
          stops: [0.0, 0.52, 0.78, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: Image.asset(
        'assets/stack_go_logo.png',
        width: 62 * scale,
        height: 62 * scale,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPill(
                width: 24 * scale,
                height: 7.0 * scale,
                gradient: const LinearGradient(
                  colors: [Color(0xFF55E7FF), Color(0xFF13D9FF)],
                ),
                shadowColor: const Color(0xFF13D9FF),
              ),
              SizedBox(height: 3.5 * scale),
              _buildPill(
                width: 34 * scale,
                height: 7.0 * scale,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6EA8FE), Color(0xFF347BFF)],
                ),
                shadowColor: const Color(0xFF347BFF),
              ),
              SizedBox(height: 3.5 * scale),
              _buildPill(
                width: 44 * scale,
                height: 7.0 * scale,
                gradient: const LinearGradient(
                  colors: [Color(0xFFB485FF), Color(0xFF9658FF)],
                ),
                shadowColor: const Color(0xFF9658FF),
              ),
            ],
          );
        },
      ),
    );

    final emblem = Container(
      width: 62 * scale,
      height: 62 * scale,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF13D9FF).withValues(alpha: 0.35),
            blurRadius: 22 * scale,
            spreadRadius: 1 * scale,
          ),
          BoxShadow(
            color: const Color(0xFF9658FF).withValues(alpha: 0.20),
            blurRadius: 28 * scale,
            spreadRadius: 2 * scale,
          ),
        ],
      ),
      child: logoImage,
    );

    return Padding(
      padding: EdgeInsets.only(left: leftPadding * scale),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          emblem,
          if (showText) ...[
            SizedBox(height: textSpacing ?? (34 * scale)),
            if (stackedText) ...[
              Text(
                'STACK',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3.5 * scale,
                  height: 1.0,
                ),
              ),
              SizedBox(height: 3 * scale),
              Text(
                'GO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF13D9FF),
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4.0 * scale,
                  height: 1.0,
                ),
              ),
            ] else ...[
              Text(
                'STACK GO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.5 * scale,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5 * scale,
                  height: 1.1,
                ),
              ),
            ],
            SizedBox(height: 5 * scale),
            Text(
              'ONE TAP. PERFECT STACK.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFA8C4E4),
                fontSize: 8.8 * scale,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.3 * scale,
              ),
            ),
          ],
        ],
      ),
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
            blurRadius: 8,
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
            height: 1.2,
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

/// Backward compatibility alias
typedef StackPulseLogo = StackGoLogo;
