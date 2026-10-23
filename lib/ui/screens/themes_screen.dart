import 'package:flutter/material.dart';
import '../../core/game_theme.dart';
import '../widgets/theme_card.dart';

class ThemesScreen extends StatelessWidget {
  final GameTheme currentTheme;
  final int bestScore;
  final Function(GameTheme) onSelectTheme;
  final VoidCallback onDismiss;

  const ThemesScreen({
    super.key,
    required this.currentTheme,
    required this.bestScore,
    required this.onSelectTheme,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = currentTheme;

    return Scaffold(
      backgroundColor: theme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: theme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Top Header Bar matching Reference Screen 7
                Row(
                  children: [
                    // Back Arrow
                    GestureDetector(
                      onTap: onDismiss,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF14284A).withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.10),
                            width: 1.0,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'CHOOSE YOUR VIBE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Make every stack your own.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFA8C4E4),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40), // Balances back arrow
                  ],
                ),
                const SizedBox(height: 24),

                // 2x2 Grid of Theme Cards matching Reference Screen 7
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.86,
                    ),
                    itemCount: GameTheme.allThemes.length,
                    itemBuilder: (context, index) {
                      final item = GameTheme.allThemes[index];
                      final isUnlocked = bestScore >= item.unlockScore;
                      final isSelected = item.type == currentTheme.type;

                      return ThemeCard(
                        theme: item,
                        isSelected: isSelected,
                        isUnlocked: isUnlocked,
                        onSelect: () => onSelectTheme(item),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
