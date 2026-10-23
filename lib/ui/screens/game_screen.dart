import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../core/game_theme.dart';
import '../../models/game_settings.dart';
import '../../models/game_statistics.dart';
import '../../game/stack_pulse_game.dart';
import '../overlays/pause_overlay.dart';
import '../overlays/game_over_overlay.dart';
import '../widgets/gameplay_background.dart';
import '../widgets/score_display.dart';
import '../../services/ad_service.dart';
import 'settings_screen.dart';
import 'themes_screen.dart';

class GameScreen extends StatefulWidget {
  final GameTheme theme;
  final GameSettings settings;
  final GameStatistics statistics;
  final Function(GameStatistics) onUpdateStatistics;
  final Function(GameSettings)? onUpdateSettings;
  final VoidCallback onHome;
  final VoidCallback onOpenSettings;

  const GameScreen({
    super.key,
    required this.theme,
    required this.settings,
    required this.statistics,
    required this.onUpdateStatistics,
    this.onUpdateSettings,
    required this.onHome,
    required this.onOpenSettings,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late StackPulseGame _game;
  int _currentScore = 0;
  int _currentStreak = 0;
  String? _streakBadge;
  bool _showPerfectBanner = false;
  bool _isPaused = false;
  bool _isGameOver = false;
  bool _isNewBest = false;
  int _finalScore = 0;
  int _bestStreakInRun = 0;
  int _perfectTriggerCount = 0;
  int _normalPlacementCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initGame();
  }

  @override
  void didUpdateWidget(covariant GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.theme.type != oldWidget.theme.type) {
      _game.updateTheme(widget.theme);
    }
    if (widget.settings != oldWidget.settings) {
      _game.updateSettings(widget.settings);
    }
  }

  void _initGame() {
    _game = StackPulseGame(
      theme: widget.theme,
      settings: widget.settings,
      onScoreUpdate: (score, streak, badge) {
        final isPerfect = streak > 0 && badge != null;
        setState(() {
          _currentScore = score;
          _currentStreak = streak;
          _streakBadge = badge;
          if (isPerfect) {
            _showPerfectBanner = true;
            _perfectTriggerCount++;
          } else {
            _normalPlacementCount++;
          }
        });
      },
      onGameOver: (finalScore, bestStreak) {
        final isNew = finalScore > widget.statistics.bestScore;
        final updatedStats = widget.statistics.copyWith(
          bestScore: isNew ? finalScore : widget.statistics.bestScore,
          bestStreak: bestStreak > widget.statistics.bestStreak
              ? bestStreak
              : widget.statistics.bestStreak,
          totalGamesPlayed: widget.statistics.totalGamesPlayed + 1,
          totalBlocksPlaced: widget.statistics.totalBlocksPlaced + finalScore,
          totalPerfectPlacements:
              widget.statistics.totalPerfectPlacements + bestStreak,
        );
        widget.onUpdateStatistics(updatedStats);

        // Preload ads while user views Game Over screen so they are ready instantly
        AdService.instance.preloadAd();
        AdService.instance.preloadRewardedAd();

        setState(() {
          _isGameOver = true;
          _finalScore = finalScore;
          _bestStreakInRun = bestStreak;
          _isNewBest = isNew;
        });
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (!_isGameOver && !_isPaused) {
        _onPause();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onPause() {
    _game.pauseGame();
    setState(() => _isPaused = true);
  }

  void _onResume() {
    _game.resumeGame();
    setState(() => _isPaused = false);
  }

  void _onRestart() {
    setState(() {
      _isPaused = false;
      _isGameOver = false;
      _currentScore = 0;
      _currentStreak = 0;
      _streakBadge = null;
      _showPerfectBanner = false;
      _perfectTriggerCount = 0;
      _normalPlacementCount = 0;
    });
    _game.initializeGame();
  }

  Future<String?> _onRevive() async {
    String? failureReason;
    final bool rewarded = await AdService.instance.showRewardedAd(
      onRewardEarned: () {
        if (!mounted) return;
        setState(() {
          _isGameOver = false;
          _isPaused = false;
        });
        _game.reviveGame();
      },
      onAdUnavailable: (reason) {
        failureReason = reason;
      },
    );

    if (rewarded) {
      return null;
    }
    return failureReason ??
        "Ad not available. Please check your internet connection and try again.";
  }

  /// Opens Settings as a modal route on top of the live GameScreen,
  /// guaranteeing that when dismissed, the paused game state and current
  /// tower run are completely preserved.
  void _openSettings() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.70),
        pageBuilder: (routeContext, animation, secondaryAnimation) {
          final isReduced = widget.settings.reducedMotion;
          final content = SettingsScreen(
            theme: widget.theme,
            settings: widget.settings,
            onSave: (updated) {
              _game.updateSettings(updated);
              if (widget.onUpdateSettings != null) {
                widget.onUpdateSettings!(updated);
              }
            },
            onDismiss: () {
              Navigator.of(routeContext).pop();
            },
            onOpenThemes: () {
              // Allows modal theme browsing directly from pause menu without breaking session
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (ctx, anim, secAnim) {
                    return FadeTransition(
                      opacity: anim,
                      child: ThemesScreen(
                        currentTheme: widget.theme,
                        bestScore: widget.statistics.bestScore,
                        reducedMotion: widget.settings.reducedMotion,
                        onSelectTheme: (newTheme) {
                          if (widget.onUpdateSettings != null) {
                            widget.onUpdateSettings!(
                              widget.settings.copyWith(
                                selectedTheme: newTheme.type.name,
                              ),
                            );
                          }
                        },
                        onDismiss: () => Navigator.of(ctx).pop(),
                      ),
                    );
                  },
                ),
              );
            },
          );

          if (isReduced) {
            return content;
          }
          final scale = Tween<double>(begin: 0.96, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: scale,
              child: content,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Scaffold(
      backgroundColor: const Color(0xFF061225),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. DYNAMIC THEME-BASED INTERACTIVE GAMEPLAY BACKGROUND
          ThemeGameplayBackground(
            theme: theme,
            currentScore: _currentScore,
            currentStreak: _currentStreak,
            perfectTriggerCount: _perfectTriggerCount,
            normalPlacementCount: _normalPlacementCount,
            isGameOver: _isGameOver,
            isPaused: _isPaused,
            reducedMotion: widget.settings.reducedMotion,
          ),

          // 4. The Flame Game Viewport (Blocks & Pedestal)
          Positioned.fill(
            child: GameWidget(game: _game),
          ),

          // 5. Top HUD (Positioned at Top Center)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Center: Large Score & COMBO Underline Badge (Top Center)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: ScoreDisplay(
                        score: _currentScore,
                        streak: _currentStreak,
                        streakBadge: _streakBadge,
                        textColor: Colors.white,
                        accentColor: theme.primaryAccent,
                        reducedMotion: widget.settings.reducedMotion,
                      ),
                    ),

                    // Top-Left: Crown Best Score Pill
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF14284A).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events_rounded,
                              color: Color(0xFFFFCB78),
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'BEST',
                                  style: TextStyle(
                                    color: Color(0xFFA8C4E4),
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                Text(
                                  '${widget.statistics.bestScore}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                    fontFeatures: [
                                      FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Top-Right: Circular Glass Pause Button with Press Spring Feedback
                    Align(
                      alignment: Alignment.topRight,
                      child: _PauseButton(onTap: _onPause),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 6. Floating PERFECT! xN Banner matching Reference Screen 4
          if (_showPerfectBanner)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.22,
              left: 0,
              right: 0,
              child: Center(
                child: PerfectComboBanner(
                  key: ValueKey('streak_$_currentScore$_currentStreak'),
                  streak: _currentStreak,
                  reducedMotion: widget.settings.reducedMotion,
                  onDismissed: () {
                    if (mounted) {
                      setState(() => _showPerfectBanner = false);
                    }
                  },
                ),
              ),
            ),

          // 7. Pause Overlay matching Reference Screen 6
          if (_isPaused)
            PauseOverlay(
              theme: theme,
              reducedMotion: widget.settings.reducedMotion,
              onResume: _onResume,
              onRestart: _onRestart,
              onSettings: _openSettings,
              onHome: widget.onHome,
            ),

          // 8. Game Over Overlay matching Reference Screen 5
          if (_isGameOver)
            GameOverOverlay(
              theme: theme,
              reducedMotion: widget.settings.reducedMotion,
              finalScore: _finalScore,
              bestScore: widget.statistics.bestScore,
              bestStreak: _bestStreakInRun,
              isNewBest: _isNewBest,
              onRetry: _onRestart,
              onHome: widget.onHome,
              onWatchChance: _onRevive,
            ),
        ],
      ),
    );
  }
}

/// Circular Glass Pause Button with Interactive Spring Feedback
class _PauseButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PauseButton({required this.onTap});

  @override
  State<_PauseButton> createState() => _PauseButtonState();
}

class _PauseButtonState extends State<_PauseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF14284A).withValues(alpha: 0.85),
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
          child: const Center(
            child: Icon(
              Icons.pause_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
