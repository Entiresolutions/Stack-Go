import 'package:flutter/material.dart';
import '../../core/game_theme.dart';

class ThemeCard extends StatelessWidget {
  final GameTheme theme;
  final bool isSelected;
  final bool isUnlocked;
  final VoidCallback onSelect;

  const ThemeCard({
    super.key,
    required this.theme,
    required this.isSelected,
    required this.isUnlocked,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUnlocked ? onSelect : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.primaryAccent
                : Colors.white.withValues(alpha: isUnlocked ? 0.08 : 0.03),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.primaryAccent.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Color palette preview blocks
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: theme.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.blockPalette[0],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: 24,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.blockPalette[2],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        theme.name,
                        style: TextStyle(
                          color: isUnlocked ? Colors.white : Colors.white.withValues(alpha: 0.4),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.check_circle, color: theme.primaryAccent, size: 16),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUnlocked
                        ? theme.description
                        : 'Unlock at Best Score ${theme.unlockScore}',
                    style: TextStyle(
                      color: isUnlocked
                          ? theme.secondaryText.withValues(alpha: 0.8)
                          : theme.warningAccent.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (!isUnlocked)
              Icon(Icons.lock_outline, color: Colors.white.withValues(alpha: 0.3), size: 20),
          ],
        ),
      ),
    );
  }
}
