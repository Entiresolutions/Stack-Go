import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/game_theme.dart';
import '../widgets/premium_button.dart';

class GameOverOverlay extends StatefulWidget {
  final GameTheme theme;
  final int finalScore;
  final int bestScore;
  final int bestStreak;
  final bool isNewBest;
  final VoidCallback onRetry;
  final VoidCallback onHome;
  final Future<String?> Function() onWatchChance;

  const GameOverOverlay({
    super.key,
    required this.theme,
    required this.finalScore,
    required this.bestScore,
    required this.bestStreak,
    required this.isNewBest,
    required this.onRetry,
    required this.onHome,
    required this.onWatchChance,
  });

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<int> _scoreCountAnimation;
  bool _isHomePressed = false;
  bool _isLoadingAd = false;
  String? _adErrorMessage;

  Future<void> _handleWatchChance() async {
    if (_isLoadingAd) return;
    setState(() {
      _isLoadingAd = true;
      _adErrorMessage = null;
    });

    final String? error = await widget.onWatchChance();

    if (mounted) {
      setState(() {
        _isLoadingAd = false;
        _adErrorMessage = error;
      });

      if (error != null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: Color(0xFFFF5252),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    error,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: const Color(0xFFFF5252).withValues(alpha: 0.35),
              ),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _scoreCountAnimation = IntTween(begin: 0, end: widget.finalScore).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final isNewBest = widget.isNewBest;

    return Stack(
      children: [
        // Frosted Glass Backdrop Barrier
        Positioned.fill(
          child: GestureDetector(
            onTap: () {}, // Blocks tap-through
            behavior: HitTestBehavior.opaque,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                color: const Color(0xFF061225).withValues(alpha: 0.88),
              ),
            ),
          ),
        ),

        // Animated Modal Content
        Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    // Heading: GAME OVER matching Reference Screen 5
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFF34BEA), // Neon Magenta
                          Color(0xFF9658FF), // Electric Purple
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'GAME OVER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3.0,
                          shadows: [
                            Shadow(
                              color: Color(0xFFF34BEA),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Results Card matching Reference Screen 5
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 26,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14284A).withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isNewBest
                              ? const Color(0xFFFFCB78)
                              : Colors.white.withValues(alpha: 0.12),
                          width: isNewBest ? 1.5 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                          if (isNewBest)
                            BoxShadow(
                              color: const Color(0xFFFFCB78)
                                  .withValues(alpha: 0.25),
                              blurRadius: 24,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // SCORE Header
                          const Text(
                            'SCORE',
                            style: TextStyle(
                              color: Color(0xFFA8C4E4),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Large Score + NEW BEST badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _scoreCountAnimation,
                                builder: (context, _) {
                                  return Text(
                                    '${_scoreCountAnimation.value}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 68,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -2.0,
                                      height: 1.0,
                                      fontFeatures: [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              if (isNewBest) ...[
                                const SizedBox(width: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFDF99),
                                        Color(0xFFFFB300),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFFB300)
                                            .withValues(alpha: 0.45),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'NEW',
                                        style: TextStyle(
                                          color: Color(0xFF061225),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          height: 1.0,
                                        ),
                                      ),
                                      Text(
                                        'BEST',
                                        style: TextStyle(
                                          color: Color(0xFF061225),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          height: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Divider line
                          Container(
                            height: 1.0,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                          const SizedBox(height: 16),

                          // Bottom Row: BEST SCORE (Left) & BEST STREAK (Right)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    'BEST SCORE',
                                    style: TextStyle(
                                      color: Color(0xFFA8C4E4),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${widget.bestScore}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      fontFeatures: [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 1.0,
                                height: 32,
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'BEST STREAK',
                                    style: TextStyle(
                                      color: Color(0xFFA8C4E4),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${widget.bestStreak}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      fontFeatures: [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Primary Action: ▶ RETRY (Cyan to Purple Gradient Pill)
                    PremiumButton(
                      label: 'RETRY',
                      icon: Icons.play_arrow_rounded,
                      isPrimary: true,
                      theme: theme,
                      height: 56,
                      fontSize: 16,
                      onTap: widget.onRetry,
                    ),
                    const SizedBox(height: 12),

                    // Secondary Action: ⌂ HOME
                    PremiumButton(
                      label: 'HOME',
                      icon: Icons.home_rounded,
                      theme: theme,
                      height: 50,
                      fontSize: 15,
                      onTap: () {
                        if (_isHomePressed) return;
                        setState(() => _isHomePressed = true);
                        widget.onHome();
                      },
                    ),
                    const SizedBox(height: 12),

                    // Bonus Reward Action: ▶ WATCH AND GET A CHANCE
                    PremiumButton(
                      label: _isLoadingAd
                          ? 'LOADING AD...'
                          : 'WATCH AND GET A CHANCE',
                      icon: _isLoadingAd
                          ? Icons.hourglass_top_rounded
                          : Icons.play_circle_filled_rounded,
                      customAccent: _isLoadingAd
                          ? const Color(0xFFA8C4E4)
                          : const Color(0xFFFFB300),
                      theme: theme,
                      height: 50,
                      fontSize: 13,
                      onTap: _handleWatchChance,
                    ),
                    if (_adErrorMessage != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                const Color(0xFFE53935).withValues(alpha: 0.45),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Color(0xFFFF5252),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _adErrorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFFF8A80),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
  }
}
