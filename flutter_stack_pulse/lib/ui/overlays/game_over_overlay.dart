import 'package:flutter/material.dart';
import '../../core/game_theme.dart';
import '../widgets/premium_button.dart';

class GameOverOverlay extends StatelessWidget {
  final GameTheme theme;
  final int finalScore;
  final int bestScore;
  final int bestStreak;
  final bool isNewBest;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  const GameOverOverlay({
    super.key,
    required this.theme,
    required this.finalScore,
    required this.bestScore,
    required this.bestStreak,
    required this.isNewBest,
    required this.onRetry,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isNewBest ? theme.primaryAccent : Colors.white.withOpacity(0.1),
              width: isNewBest ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GAME OVER',
                style: TextStyle(
                  color: theme.text.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$finalScore',
                style: TextStyle(
                  color: theme.text,
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2.0,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (isNewBest) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primaryAccent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.primaryAccent),
                  ),
                  child: Text(
                    'NEW BEST SCORE!',
                    style: TextStyle(
                      color: theme.primaryAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statItem('ALL-TIME BEST', '$bestScore', theme),
                  Container(width: 1, height: 32, color: Colors.white.withOpacity(0.1)),
                  _statItem('BEST STREAK', '$bestStreak', theme),
                ],
              ),
              const SizedBox(height: 28),
              PremiumButton(
                label: 'PLAY AGAIN',
                icon: Icons.refresh_rounded,
                isPrimary: true,
                customAccent: theme.primaryAccent,
                onTap: onRetry,
              ),
              const SizedBox(height: 12),
              PremiumButton(
                label: 'HOME',
                icon: Icons.home_rounded,
                onTap: onHome,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, GameTheme theme) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.secondaryText,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: theme.text,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
