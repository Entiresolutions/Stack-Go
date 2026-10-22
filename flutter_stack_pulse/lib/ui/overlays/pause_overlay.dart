import 'package:flutter/material.dart';
import '../../core/game_theme.dart';
import '../widgets/premium_button.dart';

class PauseOverlay extends StatelessWidget {
  final GameTheme theme;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onSettings;
  final VoidCallback onHome;

  const PauseOverlay({
    super.key,
    required this.theme,
    required this.onResume,
    required this.onRestart,
    required this.onSettings,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          width: 310,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PAUSED',
                style: TextStyle(
                  color: theme.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 24),
              PremiumButton(
                label: 'RESUME',
                icon: Icons.play_arrow_rounded,
                isPrimary: true,
                customAccent: theme.primaryAccent,
                onTap: onResume,
              ),
              const SizedBox(height: 12),
              PremiumButton(
                label: 'RESTART',
                icon: Icons.refresh_rounded,
                onTap: onRestart,
              ),
              const SizedBox(height: 12),
              PremiumButton(
                label: 'SETTINGS',
                icon: Icons.settings_rounded,
                onTap: onSettings,
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
}
