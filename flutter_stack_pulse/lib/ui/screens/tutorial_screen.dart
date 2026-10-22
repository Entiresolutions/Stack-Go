import 'package:flutter/material.dart';
import '../../core/game_theme.dart';
import '../widgets/premium_button.dart';

class TutorialScreen extends StatelessWidget {
  final GameTheme theme;
  final VoidCallback onDismiss;

  const TutorialScreen({
    super.key,
    required this.theme,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'HOW TO PLAY',
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.text),
                    onPressed: onDismiss,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _stepCard(
                      step: '01',
                      title: 'Automatic Movement',
                      desc: 'A block slides horizontally back and forth across the screen with increasing speed as you climb.',
                      icon: Icons.swap_horiz_rounded,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    _stepCard(
                      step: '02',
                      title: 'Single Tap Timing',
                      desc: 'Tap anywhere on the screen to place the active block right above the previous platform.',
                      icon: Icons.touch_app_rounded,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    _stepCard(
                      step: '03',
                      title: 'Precision Snapping & Pitch Combos',
                      desc: 'Line up closely within precision tolerance to snap cleanly, preserve full width, and elevate musical chimes higher with every consecutive perfect stack!',
                      icon: Icons.stars_rounded,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    _stepCard(
                      step: '04',
                      title: 'Precision Trimming',
                      desc: 'Any misaligned section is sliced off and falls away permanently. Narrower blocks require sharper timing.',
                      icon: Icons.content_cut_rounded,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    _stepCard(
                      step: '05',
                      title: 'Total Miss Ends Run',
                      desc: 'If the block misses the tower with zero overlap, your run concludes and your high score is recorded.',
                      icon: Icons.flag_rounded,
                      theme: theme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PremiumButton(
                label: 'GOT IT, LET\'S STACK',
                isPrimary: true,
                customAccent: theme.primaryAccent,
                onTap: onDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepCard({
    required String step,
    required String title,
    required String desc,
    required IconData icon,
    required GameTheme theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.primaryAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.primaryAccent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      step,
                      style: TextStyle(
                        color: theme.primaryAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: theme.secondaryText,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
