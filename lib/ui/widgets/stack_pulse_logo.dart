import 'package:flutter/material.dart';

class StackGoLogo extends StatelessWidget {
  final double scale;
  final bool showText;
  final bool stackedText;
  final bool showHalo;

  const StackGoLogo({
    super.key,
    this.scale = 1.0,
    this.showText = true,
    this.stackedText = false,
    this.showHalo = false,
  });

  @override
  Widget build(BuildContext context) {
    final logoImage = ClipRRect(
      borderRadius: BorderRadius.circular(14 * scale),
      child: Image.asset(
        'assets/stack_go_logo.png',
        width: 58 * scale,
        height: 58 * scale,
        fit: BoxFit.contain,
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

    final emblem = showHalo
        ? Container(
            width: 70 * scale,
            height: 70 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0C1B36).withValues(alpha: 0.65),
              border: Border.all(
                color: const Color(0xFF13D9FF).withValues(alpha: 0.25),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF13D9FF).withValues(alpha: 0.28),
                  blurRadius: 20 * scale,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: const Color(0xFF9658FF).withValues(alpha: 0.20),
                  blurRadius: 24 * scale,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Center(child: logoImage),
          )
        : logoImage;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        emblem,
        if (showText) ...[
          SizedBox(height: 14 * scale),
          if (stackedText) ...[
            Text(
              'STACK',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26 * scale,
                fontWeight: FontWeight.w900,
                letterSpacing: 4.5 * scale,
                height: 1.0,
              ),
            ),
            SizedBox(height: 3 * scale),
            Text(
              'GO',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF13D9FF),
                fontSize: 28 * scale,
                fontWeight: FontWeight.w900,
                letterSpacing: 5.0 * scale,
                height: 1.0,
              ),
            ),
          ] else ...[
            Text(
              'STACK GO',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24 * scale,
                fontWeight: FontWeight.w900,
                letterSpacing: 4.0 * scale,
                height: 1.1,
              ),
            ),
          ],
          SizedBox(height: 6 * scale),
          Text(
            'ONE TAP. PERFECT STACK.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFA8C4E4),
              fontSize: 11 * scale,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5 * scale,
            ),
          ),
        ],
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
