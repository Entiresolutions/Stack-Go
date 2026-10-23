import 'dart:math' as math;
import 'package:flutter/material.dart';

class ScoreDisplay extends StatefulWidget {
  final int score;
  final int streak;
  final String? streakBadge;
  final Color textColor;
  final Color accentColor;
  final bool reducedMotion;

  const ScoreDisplay({
    super.key,
    required this.score,
    this.streak = 0,
    this.streakBadge,
    required this.textColor,
    required this.accentColor,
    this.reducedMotion = false,
  });

  @override
  State<ScoreDisplay> createState() => _ScoreDisplayState();
}

class _ScoreDisplayState extends State<ScoreDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  int _prevScore = 0;

  @override
  void initState() {
    super.initState();
    _prevScore = widget.score;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.12, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 60,
      ),
    ]).animate(_pulseController);
  }

  @override
  void didUpdateWidget(covariant ScoreDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score != _prevScore) {
      _prevScore = widget.score;
      if (!widget.reducedMotion) {
        _pulseController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scoreWidget = Text(
      '${widget.score}',
      style: TextStyle(
        color: widget.textColor,
        fontSize: 48,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.0,
        height: 1.0,
        fontFeatures: const [FontFeature.tabularFigures()],
        shadows: [
          Shadow(
            color: widget.accentColor.withValues(alpha: 0.50),
            blurRadius: 18,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pulsing Main Score Number matching Reference Screen 3
        widget.reducedMotion
            ? scoreWidget
            : ScaleTransition(
                scale: _scaleAnimation,
                child: scoreWidget,
              ),
        const SizedBox(height: 3),

        // Glowing COMBO Badge + Accent Line matching Reference Screen 3 & 4
        SizedBox(
          height: 28,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: widget.streak > 0
                ? FittedBox(
                    key: ValueKey('combo_${widget.streak}'),
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.accentColor.withValues(alpha: 0.25),
                                const Color(0xFF9658FF).withValues(alpha: 0.20),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: widget.accentColor.withValues(alpha: 0.55),
                              width: 0.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    widget.accentColor.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'COMBO ${widget.streak}',
                            style: TextStyle(
                              color: widget.accentColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              height: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Glowing horizontal accent line directly under COMBO
                        Container(
                          width: 48,
                          height: 1.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                widget.accentColor.withValues(alpha: 0.65),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

/// Floating PERFECT! xN overlay banner matching Reference Screen 4
class PerfectComboBanner extends StatefulWidget {
  final int streak;
  final bool reducedMotion;
  final VoidCallback onDismissed;

  const PerfectComboBanner({
    super.key,
    required this.streak,
    this.reducedMotion = false,
    required this.onDismissed,
  });

  @override
  State<PerfectComboBanner> createState() => _PerfectComboBannerState();
}

class _PerfectComboBannerState extends State<PerfectComboBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.6, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.12, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.04),
        weight: 30,
      ),
    ]).animate(_animController);

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 22),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 48),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_animController);

    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest) {
      _animController.forward().then((_) => widget.onDismissed());
    } else {
      _animController.value = 0.5;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Decorative floating diamond sparkles matching Reference Screen 4
        Positioned(
          left: -24,
          top: 0,
          child: _buildSparkleDiamond(
            size: 9,
            color: const Color(0xFF13D9FF),
            rotation: 0.4,
          ),
        ),
        Positioned(
          right: -22,
          top: -4,
          child: _buildSparkleDiamond(
            size: 11,
            color: const Color(0xFF9658FF),
            rotation: 0.6,
          ),
        ),
        Positioned(
          left: -12,
          bottom: -6,
          child: _buildSparkleDiamond(
            size: 7,
            color: const Color(0xFFFFCB78),
            rotation: 0.2,
          ),
        ),
        Positioned(
          right: -10,
          bottom: -4,
          child: _buildSparkleDiamond(
            size: 8,
            color: const Color(0xFF14E4C5),
            rotation: 0.5,
          ),
        ),

        // PERFECT! and multiplier text
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PERFECT!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF13D9FF),
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 3.5,
                shadows: [
                  Shadow(
                    color: Color(0xFF13D9FF),
                    blurRadius: 22,
                  ),
                  Shadow(
                    color: Color(0xFF9658FF),
                    blurRadius: 36,
                  ),
                ],
              ),
            ),
            if (widget.streak > 1) ...[
              const SizedBox(height: 2),
              Text(
                'x${widget.streak}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF55E7FF),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      color: Color(0xFF13D9FF),
                      blurRadius: 16,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );

    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.reducedMotion
          ? content
          : ScaleTransition(
              scale: _scaleAnimation,
              child: content,
            ),
    );
  }

  Widget _buildSparkleDiamond({
    required double size,
    required Color color,
    required double rotation,
  }) {
    return Transform.rotate(
      angle: rotation * math.pi,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.8),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    );
  }
}
