import 'package:flutter/material.dart';

class StackPulseLogo extends StatelessWidget {
  final double scale;
  final bool showText;
  final bool stackedText;

  const StackPulseLogo({
    super.key,
    this.scale = 1.0,
    this.showText = true,
    this.stackedText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The 3-pill glowing stacked emblem
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPill(
              width: 26 * scale,
              height: 7.5 * scale,
              gradient: const LinearGradient(
                colors: [Color(0xFF55E7FF), Color(0xFF13D9FF)],
              ),
              shadowColor: const Color(0xFF13D9FF),
            ),
            SizedBox(height: 3.5 * scale),
            _buildPill(
              width: 36 * scale,
              height: 7.5 * scale,
              gradient: const LinearGradient(
                colors: [Color(0xFFB485FF), Color(0xFF9658FF)],
              ),
              shadowColor: const Color(0xFF9658FF),
            ),
            SizedBox(height: 3.5 * scale),
            _buildPill(
              width: 48 * scale,
              height: 7.5 * scale,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF72F7), Color(0xFFF34BEA)],
              ),
              shadowColor: const Color(0xFFF34BEA),
            ),
          ],
        ),

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
              'PULSE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26 * scale,
                fontWeight: FontWeight.w900,
                letterSpacing: 4.5 * scale,
                height: 1.0,
              ),
            ),
          ] else ...[
            Text(
              'STACK PULSE',
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
