import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../core/game_theme.dart';
import '../../models/game_settings.dart';
import '../../models/game_statistics.dart';
import '../../game/stack_pulse_game.dart';
import '../overlays/pause_overlay.dart';
import '../overlays/game_over_overlay.dart';
import '../widgets/score_display.dart';
import '../../services/ad_service.dart';

class GameScreen extends StatefulWidget {
  final GameTheme theme;
  final GameSettings settings;
  final GameStatistics statistics;
  final Function(GameStatistics) onUpdateStatistics;
  final VoidCallback onHome;
  final VoidCallback onOpenSettings;

  const GameScreen({
    super.key,
    required this.theme,
    required this.settings,
    required this.statistics,
    required this.onUpdateStatistics,
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initGame();
  }

  void _initGame() {
    _game = StackPulseGame(
      theme: widget.theme,
      settings: widget.settings,
      onScoreUpdate: (score, streak, badge) {
        setState(() {
          _currentScore = score;
          _currentStreak = streak;
          _streakBadge = badge;
          if (streak > 0 && badge != null) {
            _showPerfectBanner = true;
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

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        children: [
          // 1. The Flame Game Viewport
          Positioned.fill(
            child: GameWidget(game: _game),
          ),

          // 2. Top HUD (Positioned at Top Center)
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
                    // Center: Large Score & COMBO Underline Badge (Top Center!)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: ScoreDisplay(
                        score: _currentScore,
                        streak: _currentStreak,
                        streakBadge: _streakBadge,
                        textColor: Colors.white,
                        accentColor: theme.primaryAccent,
                      ),
                    ),

                    // Top-Left: Crown Best Score Pill
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14284A).withValues(alpha: 0.85),
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
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Top-Right: Circular Glass Pause Button
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: _onPause,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF14284A).withValues(alpha: 0.85),
                            shape: BoxShape.circle,
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
                          child: const Center(
                            child: Icon(
                              Icons.pause_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Floating PERFECT! xN Banner matching Reference Screen 4
          if (_showPerfectBanner)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.22,
              left: 0,
              right: 0,
              child: Center(
                child: PerfectComboBanner(
                  key: ValueKey('streak_$_currentScore$_currentStreak'),
                  streak: _currentStreak,
                  onDismissed: () {
                    if (mounted) {
                      setState(() => _showPerfectBanner = false);
                    }
                  },
                ),
              ),
            ),

          // 4. Pause Overlay matching Reference Screen 6
          if (_isPaused)
            PauseOverlay(
              theme: theme,
              onResume: _onResume,
              onRestart: _onRestart,
              onSettings: widget.onOpenSettings,
              onHome: widget.onHome,
            ),

          // 5. Game Over Overlay matching Reference Screen 5
          if (_isGameOver)
            GameOverOverlay(
              theme: theme,
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
