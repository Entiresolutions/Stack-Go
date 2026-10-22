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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THEMES',
                        style: TextStyle(
                          color: theme.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Unlock vibrant palettes as your high score grows',
                        style: TextStyle(
                          color: theme.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.text),
                    onPressed: onDismiss,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: GameTheme.allThemes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
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
    );
  }
}
