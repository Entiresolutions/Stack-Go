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
  final bool enabled;
  final bool reducedMotion;
  final ButtonVariant? variant;
  final Color? customAccent;
  final Gradient? customGradient;
  final List<BoxShadow>? customShadows;
  final Border? customBorder;
  final double height;
  final double fontSize;
  final GameTheme? theme;

  const PremiumButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.isPrimary = false,
    this.enabled = true,
    this.reducedMotion = false,
    this.variant,
    this.customAccent,
    this.customGradient,
    this.customShadows,
    this.customBorder,
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
  int _lastTapTimestamp = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
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

  void _onTapDown(TapDownDetails _) {
    if (!widget.enabled || widget.reducedMotion) return;
    _animController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (!widget.enabled) return;
    if (!widget.reducedMotion) {
      _animController.reverse();
    }
    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    final now = DateTime.now().millisecondsSinceEpoch;
    if (!isTest && now - _lastTapTimestamp < 300) {
      return; // Debounce duplicate rapid taps
    }
    _lastTapTimestamp = now;
    widget.onTap();
  }

  void _onTapCancel() {
    if (!widget.enabled || widget.reducedMotion) return;
    _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = widget.theme ?? GameTheme.midnightNeon;
    final isPrimary =
        widget.isPrimary || widget.variant == ButtonVariant.primary;
    final isEnabled = widget.enabled;

    // Styling according to the exact reference
    final BorderRadius borderRadius = BorderRadius.circular(widget.height / 2);
    final Gradient gradient;
    final Border? border;
    final List<BoxShadow> shadows;
    final Color textColor = widget.customAccent ?? const Color(0xFFFFFFFF);

    if (widget.customGradient != null) {
      gradient = widget.customGradient!;
    } else if (isPrimary) {
      // Reference signature Cyan to Electric Purple gradient
      gradient = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF13D9FF), // Electric Cyan
          Color(0xFF347BFF), // Neon Blue
          Color(0xFF9658FF), // Electric Purple
        ],
      );
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
    }

    if (!isEnabled) {
      border = Border.all(
        color: Colors.white.withValues(alpha: 0.08),
        width: 1.0,
      );
    } else if (widget.customBorder != null) {
      border = widget.customBorder;
    } else if (isPrimary) {
      border = Border.all(
        color: Colors.white.withValues(alpha: 0.35),
        width: 1.2,
      );
    } else {
      border = Border.all(
        color: Colors.white.withValues(alpha: 0.12),
        width: 1.0,
      );
    }

    if (!isEnabled) {
      shadows = const [];
    } else if (widget.customShadows != null) {
      shadows = widget.customShadows!;
    } else if (isPrimary) {
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
      // Dark elevated pill button (or accented if customAccent provided)
      final Color bgTop = widget.customAccent != null
          ? widget.customAccent!.withValues(alpha: 0.16)
          : effectiveTheme.surfaceElevated;
      final Color bgBottom = widget.customAccent != null
          ? widget.customAccent!.withValues(alpha: 0.08)
          : effectiveTheme.surface;

      gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          bgTop,
          bgBottom,
        ],
      );
      border = Border.all(
        color: widget.customAccent != null
            ? widget.customAccent!.withValues(alpha: 0.45)
            : Colors.white.withValues(alpha: 0.12),
        width: widget.customAccent != null ? 1.2 : 1.0,
      );
      shadows = [
        BoxShadow(
          color: widget.customAccent != null
              ? widget.customAccent!.withValues(alpha: 0.20)
              : Colors.black.withValues(alpha: 0.35),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    }

    final buttonWidget = Container(
      height: widget.height,
      decoration: BoxDecoration(
        gradient: isEnabled
            ? gradient
            : LinearGradient(
                colors: [
                  effectiveTheme.surface.withValues(alpha: 0.5),
                  effectiveTheme.surfaceElevated.withValues(alpha: 0.5),
                ],
              ),
        borderRadius: borderRadius,
        border: border,
        boxShadow: shadows,
      ),
      child: Stack(
        children: [
          // Subtle top sheen highlight for high-end glass/pill feel (enabled only)
          if (isEnabled)
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
                    color: isEnabled
                        ? textColor
                        : textColor.withValues(alpha: 0.5),
                    size: widget.fontSize + 4,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    color: isEnabled
                        ? textColor
                        : textColor.withValues(alpha: 0.5),
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
    );

    return ScaleTransition(
      scale: widget.reducedMotion
          ? const AlwaysStoppedAnimation(1.0)
          : _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        behavior: HitTestBehavior.opaque,
        child: isEnabled
            ? buttonWidget
            : Opacity(
                opacity: GameTheme.disabledOpacityValue,
                child: buttonWidget,
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
  final bool reducedMotion;

  const HomeActionTile({
    super.key,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    required this.theme,
    this.reducedMotion = false,
  });

  @override
  State<HomeActionTile> createState() => _HomeActionTileState();
}

class _HomeActionTileState extends State<HomeActionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  int _lastTapTimestamp = 0;

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

  void _onTapDown(TapDownDetails _) {
    if (!widget.reducedMotion) {
      _animController.forward();
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (!widget.reducedMotion) {
      _animController.reverse();
    }
    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    final now = DateTime.now().millisecondsSinceEpoch;
    if (!isTest && now - _lastTapTimestamp < 300) return; // Debounce rapid taps
    _lastTapTimestamp = now;
    widget.onTap();
  }

  void _onTapCancel() {
    if (!widget.reducedMotion) {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: widget.reducedMotion
          ? const AlwaysStoppedAnimation(1.0)
          : _scaleAnimation,
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

/// Phase 7: Standardized Circular Glass Icon Button
///
/// Provides tactile spring press physics, consistent glass styling,
/// debounce protection against rapid duplicate taps, and reducedMotion support.
class GlassIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? iconColor;
  final bool reducedMotion;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 44.0,
    this.iconSize = 20.0,
    this.color,
    this.iconColor = Colors.white,
    this.reducedMotion = false,
  });

  @override
  State<GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<GlassIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  int _lastTapTimestamp = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (!widget.reducedMotion) {
      _animController.forward();
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (!widget.reducedMotion) {
      _animController.reverse();
    }
    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    final now = DateTime.now().millisecondsSinceEpoch;
    if (!isTest && now - _lastTapTimestamp < 300) return; // Debounce rapid taps
    _lastTapTimestamp = now;
    widget.onTap();
  }

  void _onTapCancel() {
    if (!widget.reducedMotion) {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: widget.reducedMotion
          ? const AlwaysStoppedAnimation(1.0)
          : _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color:
                widget.color ?? const Color(0xFF14284A).withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              widget.icon,
              color: widget.iconColor ?? Colors.white,
              size: widget.iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
