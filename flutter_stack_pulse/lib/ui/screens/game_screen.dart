import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../core/game_theme.dart';
import '../../models/game_settings.dart';
import '../../models/game_statistics.dart';
import '../../game/stack_pulse_game.dart';
import '../overlays/pause_overlay.dart';
import '../overlays/game_over_overlay.dart';
import '../widgets/score_display.dart';

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
  String? _streakBadge;
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
          _streakBadge = badge;
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
      _streakBadge = null;
    });
    _game.initializeGame();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        children: [
          // The Flame Game Viewport
          Positioned.fill(
            child: GameWidget(game: _game),
          ),

          // Top Non-occluding Centered HUD
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 48), // Balances pause icon
                  Expanded(
                    child: Center(
                      child: ScoreDisplay(
                        score: _currentScore,
                        bestScore: widget.statistics.bestScore,
                        streakBadge: _streakBadge,
                        textColor: theme.text,
                        accentColor: theme.primaryAccent,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.pause_rounded,
                      color: theme.text,
                      size: 28,
                    ),
                    onPressed: _onPause,
                  ),
                ],
              ),
            ),
          ),

          // Pause Overlay
          if (_isPaused)
            PauseOverlay(
              theme: theme,
              onResume: _onResume,
              onRestart: _onRestart,
              onSettings: widget.onOpenSettings,
              onHome: widget.onHome,
            ),

          // Game Over Overlay
          if (_isGameOver)
            GameOverOverlay(
              theme: theme,
              finalScore: _finalScore,
              bestScore: widget.statistics.bestScore,
              bestStreak: _bestStreakInRun,
              isNewBest: _isNewBest,
              onRetry: _onRestart,
              onHome: widget.onHome,
            ),
        ],
      ),
    );
  }
}
