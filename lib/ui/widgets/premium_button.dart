import 'package:flutter/material.dart';
import '../../core/game_theme.dart';

enum ButtonVariant {
  primary,
  secondary,
  tile,
}

class PremiumButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isPrimary;
  final ButtonVariant? variant;
  final Color? customAccent;
  final double height;
  final double fontSize;
  final GameTheme? theme;

  const PremiumButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.isPrimary = false,
    this.variant,
    this.customAccent,
    this.height = 56.0,
    this.fontSize = 16.0,
    this.theme,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.955).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _animController.forward();
  void _onTapUp(TapUpDetails _) {
    _animController.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _animController.reverse();

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = widget.theme ?? GameTheme.midnightNeon;
    final isPrimary =
        widget.isPrimary || widget.variant == ButtonVariant.primary;

    // Styling according to the exact reference
    final BorderRadius borderRadius = BorderRadius.circular(widget.height / 2);
    final Gradient gradient;
    final Border? border;
    final List<BoxShadow> shadows;
    const Color textColor = Color(0xFFFFFFFF);

    if (isPrimary) {
      // Reference signature Cyan to Electric Purple gradient
      gradient = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF13D9FF), // Electric Cyan
          Color(0xFF9658FF), // Electric Purple
        ],
      );
      border = Border.all(
        color: Colors.white.withValues(alpha: 0.35),
        width: 1.2,
      );
      shadows = [
        BoxShadow(
          color: const Color(0xFF13D9FF).withValues(alpha: 0.40),
          blurRadius: 20,
          spreadRadius: 1,
          offset: const Offset(-2, 4),
        ),
        BoxShadow(
          color: const Color(0xFF9658FF).withValues(alpha: 0.40),
          blurRadius: 22,
          spreadRadius: 1,
          offset: const Offset(2, 4),
        ),
      ];
    } else {
      // Dark elevated pill button
      gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          effectiveTheme.surfaceElevated,
          effectiveTheme.surface,
        ],
      );
      border = Border.all(
        color: Colors.white.withValues(alpha: 0.12),
        width: 1.0,
      );
      shadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: borderRadius,
            border: border,
            boxShadow: shadows,
          ),
          child: Stack(
            children: [
              // Subtle top sheen highlight for high-end glass/pill feel
              Positioned(
                top: 0,
                left: widget.height / 2,
                right: widget.height / 2,
                height: 1.5,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: isPrimary ? 0.7 : 0.3),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: textColor,
                        size: widget.fontSize + 4,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Home Screen Bottom Action Tile Component (THEMES, HOW TO PLAY, SETTINGS)
class HomeActionTile extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;
  final GameTheme theme;

  const HomeActionTile({
    super.key,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    required this.theme,
  });

  @override
  State<HomeActionTile> createState() => _HomeActionTileState();
}

class _HomeActionTileState extends State<HomeActionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _animController.forward();
  void _onTapUp(TapUpDetails _) {
    _animController.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _animController.reverse();

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: widget.theme.surface.withValues(alpha: 0.8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.theme.surfaceElevated.withValues(alpha: 0.85),
                widget.theme.surface.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.accentColor.withValues(alpha: 0.30),
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    color: widget.accentColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
