import 'package:flutter/material.dart';
import '../../core/game_theme.dart';

/// Phase 5: Production Theme Card Widget
///
/// Faithfully reconstructs Reference Screen 7:
/// - Distinct miniature 3D isometric glowing preview asset for each theme.
/// - Selected state: Bright illuminated electric cyan border with neon drop glow
///   and circular electric blue checkmark badge at top-right.
/// - Unlocked state: Subtle theme-colored border with dark elevated cyber surface.
/// - Locked state: Top-right lock icon, subtle disabled styling, and clear unlock
///   requirement text ('Unlock at Best Score X').
/// - Interactive spring scale physics and accessible touch behavior.
class ThemeCard extends StatefulWidget {
  final GameTheme theme;
  final bool isSelected;
  final bool isUnlocked;
  final VoidCallback onSelect;
  final bool reducedMotion;

  const ThemeCard({
    super.key,
    required this.theme,
    required this.isSelected,
    required this.isUnlocked,
    required this.onSelect,
    this.reducedMotion = false,
  });

  @override
  State<ThemeCard> createState() => _ThemeCardState();
}

class _ThemeCardState extends State<ThemeCard> with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late AnimationController _lockShakeController;
  late Animation<double> _lockShakeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );

    _lockShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _lockShakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: -3.5), weight: 25),
      TweenSequenceItem(
          tween: Tween<double>(begin: -3.5, end: 3.5), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 3.5, end: 0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _lockShakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animController.dispose();
    _lockShakeController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.isUnlocked && !widget.reducedMotion) {
      _animController.forward();
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.isUnlocked) {
      if (!widget.reducedMotion) {
        _animController.reverse();
      }
      widget.onSelect();
    } else {
      if (!widget.reducedMotion) {
        _lockShakeController.forward(from: 0.0);
      }
    }
  }

  void _onTapCancel() {
    if (widget.isUnlocked && !widget.reducedMotion) {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final isSelected = widget.isSelected;
    final isUnlocked = widget.isUnlocked;
    final accent = theme.primaryAccent;

    return AnimatedBuilder(
      animation: _lockShakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset:
              Offset(widget.reducedMotion ? 0.0 : _lockShakeAnimation.value, 0),
          child: child,
        );
      },
      child: ScaleTransition(
        scale: widget.reducedMotion
            ? const AlwaysStoppedAnimation(1.0)
            : _scaleAnimation,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: widget.reducedMotion
                ? Duration.zero
                : const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: theme.surface,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [
                        theme.surfaceElevated.withValues(alpha: 0.95),
                        theme.surface.withValues(alpha: 0.95),
                      ]
                    : isUnlocked
                        ? [
                            theme.surfaceElevated.withValues(alpha: 0.85),
                            theme.surface.withValues(alpha: 0.85),
                          ]
                        : [
                            theme.surface.withValues(alpha: 0.45),
                            theme.surface.withValues(alpha: 0.30),
                          ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? accent
                    : isUnlocked
                        ? accent.withValues(alpha: 0.40)
                        : Colors.white.withValues(alpha: 0.08),
                width: isSelected ? 2.0 : 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.45),
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.40),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Stack(
              children: [
                // 1. Top-Right Corner Status Badge (Checkmark for selected, Lock for locked)
                Positioned(
                  top: 10,
                  right: 10,
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
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16,
                              weight: 800,
                            ),
                          ),
                        )
                      : (!isUnlocked)
                          ? Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.lock_rounded,
                                  color: Colors.white.withValues(alpha: 0.55),
                                  size: 14,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                ),

                // 2. Card Content Layout
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    children: [
                      // Miniature 3D Isometric Tower Preview
                      Expanded(
                        child: Center(
                          child: _buildArtworkPreview(isUnlocked, accent),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Theme Name
                      Text(
                        theme.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isUnlocked
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.60),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),

                      // Unlock Requirement Text (Locked state only)
                      if (!isUnlocked) ...[
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            theme.unlockRequirementText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFFA8C4E4)
                                  .withValues(alpha: 0.75),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 2),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Displays the 3D isometric preview asset matching Reference Screen 7
  Widget _buildArtworkPreview(bool isUnlocked, Color accent) {
    final imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        widget.theme.previewAssetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackMiniTower(accent);
        },
      ),
    );

    if (!isUnlocked) {
      return Opacity(
        opacity: 0.50,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            0.4,
            0.4,
            0.4,
            0,
            0,
            0.4,
            0.4,
            0.4,
            0,
            0,
            0.4,
            0.4,
            0.4,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
          ]),
          child: imageWidget,
        ),
      );
    }

    return imageWidget;
  }

  /// Programmatic geometric fallback in case asset fails to load
  Widget _buildFallbackMiniTower(Color accent) {
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
            _miniBlock(
              width: 32,
              height: 9,
              color: widget
                  .theme.blockPalette[2 % widget.theme.blockPalette.length],
            ),
            const SizedBox(height: 3.5),
            _miniBlock(
              width: 44,
              height: 9,
              color: widget
                  .theme.blockPalette[1 % widget.theme.blockPalette.length],
            ),
            const SizedBox(height: 3.5),
            _miniBlock(
              width: 58,
              height: 10,
              color: widget.theme.blockPalette[0],
            ),
            const SizedBox(height: 4),
            Container(
              width: 64,
              height: 3,
              decoration: BoxDecoration(
                color: widget.isUnlocked
                    ? accent.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
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
    final effectiveColor =
        widget.isUnlocked ? color : color.withValues(alpha: 0.35);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }
}
