import 'package:flutter/material.dart';

class ScoreDisplay extends StatelessWidget {
  final int score;
  final int bestScore;
  final String? streakBadge;
  final Color textColor;
  final Color accentColor;

  const ScoreDisplay({
    super.key,
    required this.score,
    required this.bestScore,
    this.streakBadge,
    required this.textColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$score',
          style: TextStyle(
            color: textColor,
            fontSize: 54,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          'BEST $bestScore',
          style: TextStyle(
            color: textColor.withOpacity(0.55),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (streakBadge != null && streakBadge!.isNotEmpty) ...[
          const SizedBox(height: 6),
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              streakBadge!,
              style: TextStyle(
                color: accentColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
