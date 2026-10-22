import 'package:flutter/material.dart';
import '../../core/game_theme.dart';
import '../../models/game_statistics.dart';
import '../widgets/premium_button.dart';

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              // Top Bar with Best Score & Settings Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events_rounded, color: theme.warningAccent, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'BEST: ${statistics.bestScore}',
                          style: TextStyle(
                            color: theme.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings_outlined, color: theme.text.withOpacity(0.8)),
                    onPressed: onSettings,
                  ),
                ],
              ),
              const Spacer(flex: 1),

              // Hero Geometric Logo & Animated Stack Preview
              Center(
                child: Column(
                  children: [
                    // Bespoke minimalist stack icon
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: theme.primaryAccent.withOpacity(0.3), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryAccent.withOpacity(0.18),
                            blurRadius: 24,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 32,
                              height: 10,
                              decoration: BoxDecoration(
                                color: theme.blockPalette[0],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 44,
                              height: 10,
                              decoration: BoxDecoration(
                                color: theme.blockPalette[1],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 54,
                              height: 10,
                              decoration: BoxDecoration(
                                color: theme.blockPalette[2],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'STACK PULSE',
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'One Tap. Perfect Stack.',
                      style: TextStyle(
                        color: theme.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Action Buttons
              PremiumButton(
                label: 'PLAY',
                icon: Icons.play_arrow_rounded,
                isPrimary: true,
                customAccent: theme.primaryAccent,
                height: 58,
                onTap: onPlay,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: PremiumButton(
                      label: 'THEMES',
                      icon: Icons.palette_outlined,
                      height: 48,
                      onTap: onThemes,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PremiumButton(
                      label: 'HOW TO PLAY',
                      icon: Icons.help_outline_rounded,
                      height: 48,
                      onTap: onTutorial,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
