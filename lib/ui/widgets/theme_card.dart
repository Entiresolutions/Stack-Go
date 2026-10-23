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
    final accent = theme.primaryAccent;

    return GestureDetector(
      onTap: isUnlocked ? onSelect : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.surface,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isUnlocked
                ? [
                    theme.surfaceElevated.withValues(alpha: 0.95),
                    theme.surface.withValues(alpha: 0.95),
                  ]
                : [
                    theme.surface.withValues(alpha: 0.55),
                    theme.surface.withValues(alpha: 0.35),
                  ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? accent
                : isUnlocked
                    ? accent.withValues(alpha: 0.35)
                    : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.35),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Top-Right Indicator: Checkmark (if selected) or Lock Icon (if locked)
            Positioned(
              top: 0,
              right: 0,
              child: isSelected
                  ? Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFF347BFF),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF347BFF),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    )
                  : (!isUnlocked)
                      ? Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.lock_rounded,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 13,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
            ),

            // Card Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 1),

                // Miniature 3D Glowing Stack Preview matching Reference Screen 7
                Center(
                  child: _buildMiniTowerPreview(accent),
                ),

                const Spacer(flex: 2),

                // Theme Name
                Text(
                  theme.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isUnlocked
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),

                // Lock Condition Text
                if (!isUnlocked) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Unlock at Best Score ${theme.unlockScore}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFA8C4E4).withValues(alpha: 0.8),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniTowerPreview(Color accent) {
    return Container(
      width: 78,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF061225).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Layer Block (small)
            _miniBlock(
              width: 32,
              height: 9,
              color: theme.blockPalette[2 % theme.blockPalette.length],
            ),
            const SizedBox(height: 3.5),
            // Middle Layer Block
            _miniBlock(
              width: 44,
              height: 9,
              color: theme.blockPalette[1 % theme.blockPalette.length],
            ),
            const SizedBox(height: 3.5),
            // Base Layer Block
            _miniBlock(
              width: 58,
              height: 10,
              color: theme.blockPalette[0],
            ),
            const SizedBox(height: 4),
            // Mini Pedestal
            Container(
              width: 64,
              height: 3,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? accent.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
                boxShadow: isUnlocked
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniBlock({
    required double width,
    required double height,
    required Color color,
  }) {
    final effectiveColor = isUnlocked ? color : color.withValues(alpha: 0.35);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(2.5),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(effectiveColor, Colors.white, 0.25)!,
            effectiveColor,
            Color.lerp(effectiveColor, Colors.black, 0.20)!,
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: isUnlocked ? 0.35 : 0.12),
          width: 0.6,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: effectiveColor.withValues(alpha: 0.35),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 1,
            left: 2,
            right: 2,
            height: 1.2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: isUnlocked ? 0.6 : 0.2),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
