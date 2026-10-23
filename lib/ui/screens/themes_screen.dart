import 'package:flutter/material.dart';
import '../../core/game_theme.dart';
import '../widgets/premium_button.dart';
import '../widgets/theme_card.dart';

/// Phase 5: Production Themes Screen
///
/// Faithfully reconstructs Reference Screen 7:
/// - Header: Circular glass back navigation button, centered 'CHOOSE YOUR VIBE' title,
///   and 'Make every stack your own.' subtitle.
/// - 2x2 Gallery Grid: Four distinct theme cards (Midnight Neon, Aurora, Sunset Pulse, Arctic Glow)
///   showcasing 3D isometric glowing previews on elevated cyber surfaces.
/// - Selected state: Bright illuminated electric cyan border with neon drop glow and checkmark badge.
/// - Unlocked state: Seamless immediate tap selection with persistent save.
/// - Locked state: Disabled styling, lock icon, and 'Unlock at Best Score X' condition.
/// - Responsive layout adapting smoothly to varying device heights without clipping.
class ThemesScreen extends StatelessWidget {
  final GameTheme currentTheme;
  final int bestScore;
  final Function(GameTheme) onSelectTheme;
  final VoidCallback onDismiss;
  final bool reducedMotion;

  const ThemesScreen({
    super.key,
    required this.currentTheme,
    required this.bestScore,
    required this.onSelectTheme,
    required this.onDismiss,
    this.reducedMotion = false,
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              children: [
                // 1. Top Header Bar matching Reference Screen 7
                Row(
                  children: [
                    // Back Arrow Button
                    GlassIconButton(
                      icon: Icons.arrow_back_rounded,
                      size: 42,
                      iconSize: 20,
                      reducedMotion: reducedMotion,
                      onTap: onDismiss,
                    ),

                    // Centered Header Title & Subtitle
                    const Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'CHOOSE YOUR VIBE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
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
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 42), // Balances the 42px back button
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Responsive 2x2 Grid of Theme Cards matching Reference Screen 7
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate dynamic aspect ratio to ensure comfortable card layout
                      final double availableWidth = constraints.maxWidth;
                      final double availableHeight = constraints.maxHeight;
                      final double itemWidth = (availableWidth - 16) / 2;
                      final double targetItemHeight =
                          (availableHeight - 16) / 2;

                      // Clamp aspect ratio to maintain attractive proportions across all screens
                      double aspectRatio = itemWidth / targetItemHeight;
                      if (aspectRatio < 0.78) aspectRatio = 0.78;
                      if (aspectRatio > 0.90) aspectRatio = 0.90;

                      return GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: aspectRatio,
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
                            reducedMotion: reducedMotion,
                            onSelect: () => onSelectTheme(item),
                          );
                        },
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
