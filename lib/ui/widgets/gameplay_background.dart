import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/game_theme.dart';

/// STACK PULSE — PREMIUM ANIMATED THEME ENVIRONMENTS
///
/// Features a 4-layer living background architecture:
/// - Layer 1: High-fidelity static theme artwork with smooth crossfade
/// - Layer 2: Theme-specific animated living environmental elements with depth & parallax
/// - Layer 3: Theme-aware gameplay-safe center corridor blend (zero visual distraction in stack zone)
/// - Layer 4: Cosmetic gameplay-reactive effects (normal taps, perfect placement, streaks, game-over)
///
/// Performance optimizations:
/// - Isolated RepaintBoundary for zero rebuilds of HUD or Flame engine
/// - Frame-rate independent timing via synchronized AnimationControllers
/// - Strictly bounded particle counts and precomputed persistent models
/// - Full Reduced Motion & App Lifecycle support
class ThemeGameplayBackground extends StatefulWidget {
  final GameTheme theme;
  final int currentScore;
  final int currentStreak;
  final int perfectTriggerCount;
  final int normalPlacementCount;
  final bool isGameOver;
  final bool isPaused;
  final bool reducedMotion;

  const ThemeGameplayBackground({
    super.key,
    required this.theme,
    this.currentScore = 0,
    this.currentStreak = 0,
    this.perfectTriggerCount = 0,
    this.normalPlacementCount = 0,
    this.isGameOver = false,
    this.isPaused = false,
    this.reducedMotion = false,
  });

  @override
  State<ThemeGameplayBackground> createState() =>
      _ThemeGameplayBackgroundState();
}

class _ThemeGameplayBackgroundState extends State<ThemeGameplayBackground>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _ambientController;
  late AnimationController _reactiveController;
  late AnimationController _normalReactiveController;
  late Animation<double> _reactiveAnimation;
  late Animation<double> _normalReactiveAnimation;

  // Dedicated Video Background Controller (Pilot: Aurora only)
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  String? _activeVideoAsset;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16000),
    );

    _reactiveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _normalReactiveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _reactiveAnimation = CurvedAnimation(
      parent: _reactiveController,
      curve: Curves.easeOutCubic,
    );

    _normalReactiveAnimation = CurvedAnimation(
      parent: _normalReactiveController,
      curve: Curves.easeOutQuad,
    );

    if (!isTest && !widget.reducedMotion && !widget.isPaused) {
      _ambientController.repeat();
    } else {
      _ambientController.value = 0.5;
    }

    if (!isTest && !widget.reducedMotion) {
      _initializeVideoForTheme(widget.theme);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _videoController?.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (!widget.isPaused && !widget.reducedMotion && _isVideoInitialized) {
        _videoController?.play();
      }
    }
  }

  Future<void> _initializeVideoForTheme(GameTheme theme) async {
    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (isTest) return;

    final videoAsset = theme.gameplayBackgroundVideoAsset;

    // All 10 themes have dedicated animated video assets; falls back to static artwork if reducedMotion
    if (widget.reducedMotion) {
      _disposeVideoController();
      if (mounted) {
        setState(() {});
      }
      return;
    }

    // Avoid duplicate initialization for the same video asset
    if (_activeVideoAsset == videoAsset && _videoController != null) {
      if (!widget.isPaused && !widget.reducedMotion && _isVideoInitialized) {
        _videoController?.play();
      }
      return;
    }

    _disposeVideoController();
    _activeVideoAsset = videoAsset;

    final controller = VideoPlayerController.asset(videoAsset);
    _videoController = controller;

    try {
      await controller.initialize();
      // Strict audio protection: always keep video volume at zero to avoid audio focus conflicts
      await controller.setVolume(0.0);
      await controller.setLooping(true);

      if (!mounted) {
        controller.dispose();
        return;
      }

      if (_videoController == controller && widget.theme.type == theme.type) {
        setState(() {
          _isVideoInitialized = true;
        });
        if (!widget.isPaused && !widget.reducedMotion) {
          controller.play();
        }
      } else {
        controller.dispose();
      }
    } catch (e) {
      // Graceful fallback to static artwork: never crash or block gameplay
      debugPrint('Animated background video initialization fallback: $e');
      if (mounted && _videoController == controller) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
      controller.dispose();
      _videoController = null;
    }
  }

  void _disposeVideoController() {
    final controller = _videoController;
    _videoController = null;
    _isVideoInitialized = false;
    _activeVideoAsset = null;
    controller?.pause();
    controller?.dispose();
  }

  @override
  void didUpdateWidget(covariant ThemeGameplayBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');

    // Handle pause / resume of ambient animation
    if (!isTest) {
      if (widget.isPaused || widget.reducedMotion) {
        if (_ambientController.isAnimating) {
          _ambientController.stop();
        }
      } else {
        if (!_ambientController.isAnimating) {
          _ambientController.repeat();
        }
      }
    }

    // Handle theme switching or reducedMotion toggling
    if (widget.theme.type != oldWidget.theme.type) {
      if (!isTest) {
        _initializeVideoForTheme(widget.theme);
      }
    } else if (widget.reducedMotion != oldWidget.reducedMotion) {
      if (widget.reducedMotion) {
        _videoController?.pause();
      } else if (!isTest) {
        if (_videoController == null) {
          _initializeVideoForTheme(widget.theme);
        } else if (_isVideoInitialized && !widget.isPaused) {
          _videoController?.play();
        }
      }
    }

    // Handle game pause / resume
    if (widget.isPaused != oldWidget.isPaused) {
      if (widget.isPaused) {
        _videoController?.pause();
      } else if (!widget.reducedMotion && _isVideoInitialized) {
        _videoController?.play();
      }
    }

    // Trigger reactive placement feedback on perfect placement
    if (widget.perfectTriggerCount != oldWidget.perfectTriggerCount &&
        !widget.reducedMotion) {
      _reactiveController.forward(from: 0.0);
    }

    // Trigger subtle normal placement feedback
    if (widget.normalPlacementCount != oldWidget.normalPlacementCount &&
        !widget.reducedMotion) {
      _normalReactiveController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeVideoController();
    _ambientController.dispose();
    _reactiveController.dispose();
    _normalReactiveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReduced = widget.reducedMotion;
    final isVideoActive = !isReduced &&
        _isVideoInitialized &&
        _videoController != null &&
        _videoController!.value.isInitialized;

    return IgnorePointer(
      ignoring: true,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // -----------------------------------------------------------
          // LAYER 1: THEME-SPECIFIC STATIC ARTWORK WITH CROSSFADE
          // (Always present as rock-solid fallback & initial state)
          // -----------------------------------------------------------
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 380),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: Image.asset(
              widget.theme.gameplayBackgroundAsset,
              key: ValueKey(widget.theme.type),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: widget.theme.backgroundGradient,
                  ),
                );
              },
            ),
          ),

          // -----------------------------------------------------------
          // LAYER 1B: HIGH-FIDELITY ANIMATED VIDEO PILOT (AURORA ONLY)
          // Seamlessly loops the living environment video sampled from
          // original artwork. Fades in smoothly without flash.
          // -----------------------------------------------------------
          if (isVideoActive)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _videoController!.value.size.width > 0
                      ? _videoController!.value.size.width
                      : 720,
                  height: _videoController!.value.size.height > 0
                      ? _videoController!.value.size.height
                      : 1280,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),

          // -----------------------------------------------------------
          // LAYER 2: LIVING THEME ENVIRONMENT (PROCEDURAL ACCENTS)
          // -----------------------------------------------------------
          if (!isReduced)
            RepaintBoundary(
              child: CustomPaint(
                painter: _ThemeEnvironmentPainter(
                  ambientAnimation: _ambientController,
                  reactiveAnimation: _reactiveAnimation,
                  normalReactiveAnimation: _normalReactiveAnimation,
                  theme: widget.theme,
                  streak: widget.currentStreak,
                  isGameOver: widget.isGameOver,
                  isVideoActive: isVideoActive,
                ),
              ),
            ),

          // -----------------------------------------------------------
          // GAME OVER CALMING VIGNETTE
          // -----------------------------------------------------------
          AnimatedContainer(
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeInOut,
            color: widget.isGameOver
                ? Colors.black.withValues(alpha: 0.32)
                : Colors.transparent,
          ),

          // -----------------------------------------------------------
          // ATMOSPHERIC CONTRAST SCRIM (Theme-Aware Legibility Layer)
          // -----------------------------------------------------------
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.theme.corridorBaseColor.withValues(alpha: 0.38),
                  Colors.transparent,
                  Colors.transparent,
                  widget.theme.corridorBaseColor.withValues(alpha: 0.35),
                ],
                stops: const [0.0, 0.16, 0.84, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Particle representation supporting 3-depth multi-layer parallax
class _EnvParticle {
  final double x; // Relative X coordinate (0.0 to 1.0)
  final double y; // Relative Y coordinate (0.0 to 1.0)
  final double speedX; // Horizontal drift speed
  final double speedY; // Vertical drift speed
  final double size; // Base radius in pixels
  final double maxAlpha; // Peak alpha
  final double phase; // Oscillation phase
  final bool isDiamond; // Diamond geometry vs circle
  final int layer; // 0 = Deep background, 1 = Midground, 2 = Foreground

  const _EnvParticle({
    required this.x,
    required this.y,
    required this.speedX,
    required this.speedY,
    required this.size,
    required this.maxAlpha,
    required this.phase,
    this.isDiamond = false,
    this.layer = 1,
  });
}

/// Unified, GPU-optimized CustomPainter rendering the 10 living environments
class _ThemeEnvironmentPainter extends CustomPainter {
  final Animation<double> ambientAnimation;
  final Animation<double> reactiveAnimation;
  final Animation<double> normalReactiveAnimation;
  final GameTheme theme;
  final int streak;
  final bool isGameOver;
  final bool isVideoActive;

  _ThemeEnvironmentPainter({
    required this.ambientAnimation,
    required this.reactiveAnimation,
    required this.normalReactiveAnimation,
    required this.theme,
    required this.streak,
    required this.isGameOver,
    this.isVideoActive = false,
  }) : super(
          repaint: Listenable.merge([
            ambientAnimation,
            reactiveAnimation,
            normalReactiveAnimation,
          ]),
        );

  // =========================================================================
  // PERSISTENT PARTICLE CONFIGURATIONS (Outer Edge Margins)
  // =========================================================================

  // 1. Midnight Neon: Cyber glyphs & micro-pixels
  static const List<_EnvParticle> _midnightParticles = [
    _EnvParticle(
        x: 0.08,
        y: 0.30,
        speedX: 0.01,
        speedY: -0.06,
        size: 2.2,
        maxAlpha: 0.40,
        phase: 1.2,
        layer: 0),
    _EnvParticle(
        x: 0.05,
        y: 0.72,
        speedX: 0.02,
        speedY: -0.05,
        size: 2.8,
        maxAlpha: 0.45,
        phase: 2.1,
        isDiamond: true,
        layer: 2),
    _EnvParticle(
        x: 0.16,
        y: 0.18,
        speedX: -0.01,
        speedY: -0.07,
        size: 3.4,
        maxAlpha: 0.52,
        phase: 0.8,
        layer: 1),
    _EnvParticle(
        x: 0.11,
        y: 0.88,
        speedX: 0.01,
        speedY: -0.06,
        size: 2.2,
        maxAlpha: 0.38,
        phase: 3.0,
        layer: 0),
    _EnvParticle(
        x: 0.85,
        y: 0.22,
        speedX: -0.01,
        speedY: -0.07,
        size: 3.2,
        maxAlpha: 0.50,
        phase: 1.5,
        isDiamond: true,
        layer: 1),
    _EnvParticle(
        x: 0.93,
        y: 0.45,
        speedX: 0.01,
        speedY: -0.09,
        size: 2.6,
        maxAlpha: 0.45,
        phase: 2.7,
        layer: 2),
    _EnvParticle(
        x: 0.88,
        y: 0.68,
        speedX: -0.02,
        speedY: -0.06,
        size: 2.8,
        maxAlpha: 0.48,
        phase: 0.3,
        isDiamond: true,
        layer: 1),
    _EnvParticle(
        x: 0.82,
        y: 0.86,
        speedX: 0.01,
        speedY: -0.08,
        size: 2.0,
        maxAlpha: 0.36,
        phase: 1.9,
        layer: 0),
    _EnvParticle(
        x: 0.96,
        y: 0.15,
        speedX: -0.01,
        speedY: -0.05,
        size: 3.6,
        maxAlpha: 0.55,
        phase: 2.4,
        isDiamond: true,
        layer: 2),
    _EnvParticle(
        x: 0.12,
        y: 0.46,
        speedX: 0.02,
        speedY: -0.07,
        size: 2.0,
        maxAlpha: 0.34,
        phase: 0.9,
        layer: 0),
    _EnvParticle(
        x: 0.86,
        y: 0.58,
        speedX: -0.01,
        speedY: -0.06,
        size: 2.4,
        maxAlpha: 0.42,
        phase: 1.7,
        layer: 1),
  ];

  // 2. Aurora: Luminous spirit motes
  static const List<_EnvParticle> _auroraParticles = [
    _EnvParticle(
        x: 0.07,
        y: 0.35,
        speedX: 0.03,
        speedY: -0.05,
        size: 3.4,
        maxAlpha: 0.48,
        phase: 0.4,
        layer: 1),
    _EnvParticle(
        x: 0.15,
        y: 0.62,
        speedX: -0.02,
        speedY: -0.06,
        size: 2.6,
        maxAlpha: 0.42,
        phase: 1.6,
        layer: 0),
    _EnvParticle(
        x: 0.05,
        y: 0.82,
        speedX: 0.02,
        speedY: -0.04,
        size: 3.2,
        maxAlpha: 0.40,
        phase: 2.5,
        layer: 1),
    _EnvParticle(
        x: 0.18,
        y: 0.20,
        speedX: -0.03,
        speedY: -0.05,
        size: 3.8,
        maxAlpha: 0.52,
        phase: 0.9,
        layer: 2),
    _EnvParticle(
        x: 0.11,
        y: 0.92,
        speedX: 0.02,
        speedY: -0.04,
        size: 2.2,
        maxAlpha: 0.32,
        phase: 3.1,
        layer: 0),
    _EnvParticle(
        x: 0.85,
        y: 0.28,
        speedX: -0.02,
        speedY: -0.05,
        size: 3.6,
        maxAlpha: 0.50,
        phase: 1.3,
        layer: 1),
    _EnvParticle(
        x: 0.94,
        y: 0.50,
        speedX: 0.03,
        speedY: -0.06,
        size: 2.8,
        maxAlpha: 0.46,
        phase: 2.2,
        layer: 0),
    _EnvParticle(
        x: 0.88,
        y: 0.74,
        speedX: -0.02,
        speedY: -0.05,
        size: 3.2,
        maxAlpha: 0.44,
        phase: 0.7,
        layer: 1),
    _EnvParticle(
        x: 0.82,
        y: 0.88,
        speedX: 0.02,
        speedY: -0.04,
        size: 2.4,
        maxAlpha: 0.36,
        phase: 1.8,
        layer: 0),
    _EnvParticle(
        x: 0.95,
        y: 0.18,
        speedX: -0.03,
        speedY: -0.05,
        size: 4.0,
        maxAlpha: 0.54,
        phase: 2.7,
        layer: 2),
    _EnvParticle(
        x: 0.12,
        y: 0.48,
        speedX: 0.02,
        speedY: -0.05,
        size: 2.5,
        maxAlpha: 0.38,
        phase: 1.1,
        layer: 0),
    _EnvParticle(
        x: 0.87,
        y: 0.60,
        speedX: -0.02,
        speedY: -0.05,
        size: 2.7,
        maxAlpha: 0.42,
        phase: 1.5,
        layer: 1),
  ];

  // 3. Sunset Pulse: Warm floating dust motes
  static const List<_EnvParticle> _sunsetParticles = [
    _EnvParticle(
        x: 0.08,
        y: 0.26,
        speedX: 0.02,
        speedY: -0.06,
        size: 2.6,
        maxAlpha: 0.45,
        phase: 0.8,
        layer: 1),
    _EnvParticle(
        x: 0.16,
        y: 0.52,
        speedX: -0.02,
        speedY: -0.07,
        size: 3.2,
        maxAlpha: 0.50,
        phase: 2.0,
        layer: 2),
    _EnvParticle(
        x: 0.05,
        y: 0.74,
        speedX: 0.01,
        speedY: -0.05,
        size: 2.2,
        maxAlpha: 0.38,
        phase: 1.4,
        layer: 0),
    _EnvParticle(
        x: 0.17,
        y: 0.88,
        speedX: -0.01,
        speedY: -0.08,
        size: 3.5,
        maxAlpha: 0.55,
        phase: 2.9,
        layer: 2),
    _EnvParticle(
        x: 0.85,
        y: 0.32,
        speedX: -0.02,
        speedY: -0.06,
        size: 3.0,
        maxAlpha: 0.48,
        phase: 1.1,
        layer: 1),
    _EnvParticle(
        x: 0.93,
        y: 0.64,
        speedX: 0.02,
        speedY: -0.07,
        size: 2.8,
        maxAlpha: 0.46,
        phase: 0.5,
        layer: 1),
    _EnvParticle(
        x: 0.81,
        y: 0.86,
        speedX: 0.01,
        speedY: -0.08,
        size: 2.4,
        maxAlpha: 0.38,
        phase: 1.7,
        layer: 0),
    _EnvParticle(
        x: 0.94,
        y: 0.15,
        speedX: -0.02,
        speedY: -0.06,
        size: 3.6,
        maxAlpha: 0.55,
        phase: 2.6,
        layer: 2),
    _EnvParticle(
        x: 0.11,
        y: 0.44,
        speedX: 0.02,
        speedY: -0.08,
        size: 2.3,
        maxAlpha: 0.36,
        phase: 0.6,
        layer: 0),
    _EnvParticle(
        x: 0.86,
        y: 0.55,
        speedX: -0.01,
        speedY: -0.07,
        size: 2.5,
        maxAlpha: 0.40,
        phase: 1.5,
        layer: 0),
  ];

  // 4. Arctic Glow: 3-Depth Multi-Layered Snowfall
  static const List<_EnvParticle> _arcticParticles = [
    // Layer 0: Distant micro snow dust (slow, small, high density)
    _EnvParticle(
        x: 0.04,
        y: 0.10,
        speedX: 0.01,
        speedY: 0.04,
        size: 1.4,
        maxAlpha: 0.30,
        phase: 0.2,
        layer: 0),
    _EnvParticle(
        x: 0.14,
        y: 0.28,
        speedX: -0.01,
        speedY: 0.05,
        size: 1.6,
        maxAlpha: 0.32,
        phase: 1.1,
        layer: 0),
    _EnvParticle(
        x: 0.85,
        y: 0.12,
        speedX: 0.01,
        speedY: 0.04,
        size: 1.5,
        maxAlpha: 0.28,
        phase: 2.3,
        layer: 0),
    _EnvParticle(
        x: 0.95,
        y: 0.35,
        speedX: -0.01,
        speedY: 0.05,
        size: 1.4,
        maxAlpha: 0.30,
        phase: 0.8,
        layer: 0),
    // Layer 1: Midground snowflakes (medium size, gentle wind sway)
    _EnvParticle(
        x: 0.08,
        y: 0.45,
        speedX: 0.02,
        speedY: 0.07,
        size: 2.6,
        maxAlpha: 0.45,
        phase: 1.7,
        layer: 1),
    _EnvParticle(
        x: 0.18,
        y: 0.70,
        speedX: -0.02,
        speedY: 0.08,
        size: 2.4,
        maxAlpha: 0.42,
        phase: 0.4,
        layer: 1),
    _EnvParticle(
        x: 0.82,
        y: 0.52,
        speedX: 0.02,
        speedY: 0.07,
        size: 2.8,
        maxAlpha: 0.46,
        phase: 2.8,
        layer: 1),
    _EnvParticle(
        x: 0.90,
        y: 0.78,
        speedX: -0.02,
        speedY: 0.08,
        size: 2.5,
        maxAlpha: 0.44,
        phase: 1.5,
        layer: 1),
    // Layer 2: Foreground faceted crystalline flakes (larger, faster descent)
    _EnvParticle(
        x: 0.06,
        y: 0.22,
        speedX: 0.03,
        speedY: 0.11,
        size: 4.2,
        maxAlpha: 0.65,
        phase: 0.9,
        isDiamond: true,
        layer: 2),
    _EnvParticle(
        x: 0.16,
        y: 0.85,
        speedX: -0.03,
        speedY: 0.12,
        size: 3.8,
        maxAlpha: 0.60,
        phase: 2.1,
        isDiamond: true,
        layer: 2),
    _EnvParticle(
        x: 0.88,
        y: 0.24,
        speedX: 0.03,
        speedY: 0.11,
        size: 4.5,
        maxAlpha: 0.68,
        phase: 1.3,
        isDiamond: true,
        layer: 2),
    _EnvParticle(
        x: 0.94,
        y: 0.65,
        speedX: -0.03,
        speedY: 0.12,
        size: 4.0,
        maxAlpha: 0.62,
        phase: 3.0,
        isDiamond: true,
        layer: 2),
  ];

  // 5. Sakura Drift: Tumbling 3D cherry blossom petals
  static const List<_EnvParticle> _sakuraParticles = [
    _EnvParticle(
        x: 0.08,
        y: 0.18,
        speedX: -0.04,
        speedY: 0.07,
        size: 3.6,
        maxAlpha: 0.58,
        phase: 0.2,
        layer: 1),
    _EnvParticle(
        x: 0.16,
        y: 0.42,
        speedX: -0.05,
        speedY: 0.06,
        size: 2.8,
        maxAlpha: 0.48,
        phase: 1.4,
        layer: 0),
    _EnvParticle(
        x: 0.05,
        y: 0.70,
        speedX: -0.03,
        speedY: 0.08,
        size: 4.2,
        maxAlpha: 0.62,
        phase: 2.1,
        layer: 2),
    _EnvParticle(
        x: 0.19,
        y: 0.88,
        speedX: -0.04,
        speedY: 0.07,
        size: 3.0,
        maxAlpha: 0.45,
        phase: 0.8,
        layer: 1),
    _EnvParticle(
        x: 0.12,
        y: 0.28,
        speedX: -0.05,
        speedY: 0.06,
        size: 3.2,
        maxAlpha: 0.52,
        phase: 3.0,
        layer: 0),
    _EnvParticle(
        x: 0.84,
        y: 0.14,
        speedX: -0.04,
        speedY: 0.07,
        size: 4.5,
        maxAlpha: 0.65,
        phase: 1.1,
        layer: 2),
    _EnvParticle(
        x: 0.92,
        y: 0.38,
        speedX: -0.03,
        speedY: 0.08,
        size: 2.8,
        maxAlpha: 0.48,
        phase: 2.5,
        layer: 0),
    _EnvParticle(
        x: 0.88,
        y: 0.62,
        speedX: -0.05,
        speedY: 0.06,
        size: 3.5,
        maxAlpha: 0.54,
        phase: 0.6,
        layer: 1),
    _EnvParticle(
        x: 0.82,
        y: 0.84,
        speedX: -0.04,
        speedY: 0.08,
        size: 3.8,
        maxAlpha: 0.56,
        phase: 1.8,
        layer: 2),
    _EnvParticle(
        x: 0.95,
        y: 0.22,
        speedX: -0.05,
        speedY: 0.07,
        size: 3.0,
        maxAlpha: 0.46,
        phase: 2.8,
        layer: 0),
  ];

  // 6. Abyssal Depths: Rising wobbling bubbles
  static const List<_EnvParticle> _abyssalParticles = [
    _EnvParticle(
        x: 0.07,
        y: 0.88,
        speedX: 0.02,
        speedY: -0.06,
        size: 3.5,
        maxAlpha: 0.55,
        phase: 0.5,
        layer: 1),
    _EnvParticle(
        x: 0.14,
        y: 0.65,
        speedX: -0.02,
        speedY: -0.08,
        size: 4.8,
        maxAlpha: 0.62,
        phase: 1.7,
        layer: 2),
    _EnvParticle(
        x: 0.05,
        y: 0.40,
        speedX: 0.01,
        speedY: -0.05,
        size: 2.6,
        maxAlpha: 0.42,
        phase: 2.3,
        layer: 0),
    _EnvParticle(
        x: 0.18,
        y: 0.20,
        speedX: -0.02,
        speedY: -0.07,
        size: 3.2,
        maxAlpha: 0.50,
        phase: 0.9,
        layer: 1),
    _EnvParticle(
        x: 0.84,
        y: 0.92,
        speedX: -0.02,
        speedY: -0.07,
        size: 5.2,
        maxAlpha: 0.65,
        phase: 1.2,
        layer: 2),
    _EnvParticle(
        x: 0.92,
        y: 0.70,
        speedX: 0.02,
        speedY: -0.06,
        size: 3.0,
        maxAlpha: 0.48,
        phase: 2.6,
        layer: 0),
    _EnvParticle(
        x: 0.87,
        y: 0.45,
        speedX: -0.01,
        speedY: -0.08,
        size: 4.0,
        maxAlpha: 0.56,
        phase: 0.3,
        layer: 1),
    _EnvParticle(
        x: 0.95,
        y: 0.25,
        speedX: 0.02,
        speedY: -0.06,
        size: 2.8,
        maxAlpha: 0.44,
        phase: 1.9,
        layer: 0),
  ];

  // 7. Retro Grid: Electronic digital data glyphs
  static const List<_EnvParticle> _retroParticles = [
    _EnvParticle(
        x: 0.08,
        y: 0.32,
        speedX: 0.01,
        speedY: -0.07,
        size: 2.8,
        maxAlpha: 0.48,
        phase: 0.4,
        isDiamond: true,
        layer: 1),
    _EnvParticle(
        x: 0.15,
        y: 0.58,
        speedX: -0.01,
        speedY: -0.06,
        size: 2.2,
        maxAlpha: 0.40,
        phase: 1.5,
        layer: 0),
    _EnvParticle(
        x: 0.06,
        y: 0.78,
        speedX: 0.02,
        speedY: -0.08,
        size: 3.2,
        maxAlpha: 0.52,
        phase: 2.2,
        isDiamond: true,
        layer: 2),
    _EnvParticle(
        x: 0.85,
        y: 0.25,
        speedX: -0.01,
        speedY: -0.07,
        size: 3.0,
        maxAlpha: 0.50,
        phase: 1.2,
        isDiamond: true,
        layer: 1),
    _EnvParticle(
        x: 0.93,
        y: 0.48,
        speedX: 0.01,
        speedY: -0.09,
        size: 2.4,
        maxAlpha: 0.42,
        phase: 2.7,
        layer: 0),
    _EnvParticle(
        x: 0.88,
        y: 0.72,
        speedX: -0.02,
        speedY: -0.07,
        size: 3.5,
        maxAlpha: 0.55,
        phase: 0.8,
        isDiamond: true,
        layer: 2),
  ];

  // 8. Ember Core: Turbulent buoyant embers
  static const List<_EnvParticle> _emberParticles = [
    _EnvParticle(
        x: 0.07,
        y: 0.92,
        speedX: 0.02,
        speedY: -0.09,
        size: 3.6,
        maxAlpha: 0.65,
        phase: 0.3,
        layer: 2),
    _EnvParticle(
        x: 0.14,
        y: 0.75,
        speedX: -0.03,
        speedY: -0.08,
        size: 2.8,
        maxAlpha: 0.52,
        phase: 1.4,
        layer: 1),
    _EnvParticle(
        x: 0.05,
        y: 0.52,
        speedX: 0.02,
        speedY: -0.07,
        size: 2.0,
        maxAlpha: 0.38,
        phase: 2.2,
        layer: 0),
    _EnvParticle(
        x: 0.18,
        y: 0.35,
        speedX: -0.02,
        speedY: -0.06,
        size: 1.6,
        maxAlpha: 0.28,
        phase: 0.7,
        layer: 0),
    _EnvParticle(
        x: 0.84,
        y: 0.95,
        speedX: -0.02,
        speedY: -0.10,
        size: 4.2,
        maxAlpha: 0.70,
        phase: 1.0,
        layer: 2),
    _EnvParticle(
        x: 0.92,
        y: 0.78,
        speedX: 0.03,
        speedY: -0.09,
        size: 3.0,
        maxAlpha: 0.55,
        phase: 2.5,
        layer: 1),
    _EnvParticle(
        x: 0.87,
        y: 0.55,
        speedX: -0.02,
        speedY: -0.07,
        size: 2.2,
        maxAlpha: 0.40,
        phase: 0.5,
        layer: 0),
    _EnvParticle(
        x: 0.95,
        y: 0.38,
        speedX: 0.01,
        speedY: -0.06,
        size: 1.8,
        maxAlpha: 0.30,
        phase: 1.8,
        layer: 0),
  ];

  // 9. Celestial Observatory: Multi-phase twinkling starry dust
  static const List<_EnvParticle> _celestialParticles = [
    _EnvParticle(
        x: 0.08,
        y: 0.16,
        speedX: 0.01,
        speedY: -0.02,
        size: 3.8,
        maxAlpha: 0.65,
        phase: 0.5,
        isDiamond: true,
        layer: 2),
    _EnvParticle(
        x: 0.15,
        y: 0.32,
        speedX: -0.01,
        speedY: -0.03,
        size: 2.4,
        maxAlpha: 0.46,
        phase: 1.3,
        layer: 1),
    _EnvParticle(
        x: 0.06,
        y: 0.48,
        speedX: 0.01,
        speedY: -0.02,
        size: 3.2,
        maxAlpha: 0.54,
        phase: 2.4,
        isDiamond: true,
        layer: 1),
    _EnvParticle(
        x: 0.19,
        y: 0.22,
        speedX: -0.01,
        speedY: -0.02,
        size: 2.2,
        maxAlpha: 0.40,
        phase: 0.8,
        layer: 0),
    _EnvParticle(
        x: 0.85,
        y: 0.14,
        speedX: -0.01,
        speedY: -0.02,
        size: 4.0,
        maxAlpha: 0.70,
        phase: 1.2,
        isDiamond: true,
        layer: 2),
    _EnvParticle(
        x: 0.93,
        y: 0.30,
        speedX: 0.01,
        speedY: -0.03,
        size: 2.6,
        maxAlpha: 0.48,
        phase: 2.2,
        layer: 1),
    _EnvParticle(
        x: 0.88,
        y: 0.52,
        speedX: -0.01,
        speedY: -0.02,
        size: 3.4,
        maxAlpha: 0.55,
        phase: 0.4,
        isDiamond: true,
        layer: 1),
    _EnvParticle(
        x: 0.81,
        y: 0.70,
        speedX: 0.01,
        speedY: -0.03,
        size: 2.0,
        maxAlpha: 0.38,
        phase: 1.6,
        layer: 0),
  ];

  // 10. Prism Rift: Faceted floating crystal shards
  static const List<_EnvParticle> _prismParticles = [
    _EnvParticle(
        x: 0.08,
        y: 0.22,
        speedX: 0.01,
        speedY: -0.04,
        size: 3.8,
        maxAlpha: 0.60,
        phase: 0.4,
        isDiamond: true,
        layer: 2),
    _EnvParticle(
        x: 0.16,
        y: 0.45,
        speedX: -0.01,
        speedY: -0.05,
        size: 2.6,
        maxAlpha: 0.46,
        phase: 1.2,
        layer: 1),
    _EnvParticle(
        x: 0.06,
        y: 0.72,
        speedX: 0.02,
        speedY: -0.04,
        size: 3.4,
        maxAlpha: 0.52,
        phase: 2.3,
        isDiamond: true,
        layer: 1),
    _EnvParticle(
        x: 0.85,
        y: 0.18,
        speedX: -0.01,
        speedY: -0.04,
        size: 4.2,
        maxAlpha: 0.65,
        phase: 1.0,
        isDiamond: true,
        layer: 2),
    _EnvParticle(
        x: 0.93,
        y: 0.42,
        speedX: 0.01,
        speedY: -0.05,
        size: 2.8,
        maxAlpha: 0.48,
        phase: 2.5,
        layer: 1),
    _EnvParticle(
        x: 0.88,
        y: 0.68,
        speedX: -0.01,
        speedY: -0.04,
        size: 3.6,
        maxAlpha: 0.54,
        phase: 0.6,
        isDiamond: true,
        layer: 1),
  ];

  // Restrained Corridor particles for theme atmosphere
  static const List<_EnvParticle> _corridorParticles = [
    _EnvParticle(
        x: 0.35,
        y: 0.28,
        speedX: 0.01,
        speedY: -0.04,
        size: 1.4,
        maxAlpha: 0.18,
        phase: 0.4),
    _EnvParticle(
        x: 0.46,
        y: 0.52,
        speedX: -0.01,
        speedY: -0.05,
        size: 1.6,
        maxAlpha: 0.20,
        phase: 1.2),
    _EnvParticle(
        x: 0.58,
        y: 0.38,
        speedX: 0.01,
        speedY: -0.04,
        size: 1.3,
        maxAlpha: 0.16,
        phase: 2.1),
    _EnvParticle(
        x: 0.65,
        y: 0.72,
        speedX: -0.01,
        speedY: -0.05,
        size: 1.5,
        maxAlpha: 0.18,
        phase: 0.8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = ambientAnimation.value;
    final r = reactiveAnimation.value;
    final nr = normalReactiveAnimation.value;

    // Streak multiplier with distinct milestones at 5x and 10x
    final streakBoost = streak >= 10
        ? 0.35
        : streak >= 5
            ? 0.20
            : (streak * 0.04);
    final streakMultiplier = (1.0 + streakBoost).clamp(1.0, 1.40);

    // 0. THEME-AWARE GAMEPLAY-SAFE CORRIDOR BLEND
    _paintThemeCorridor(canvas, size, t, r, nr, streakMultiplier);

    // 1-10. DEDICATED THEME ENVIRONMENTAL ANIMATION ENGINES
    switch (theme.type) {
      case ThemeType.midnightNeon:
        _paintMidnightNeon(canvas, size, t, r, nr, streakMultiplier);
        break;
      case ThemeType.aurora:
        _paintAurora(canvas, size, t, r, nr, streakMultiplier);
        break;
      case ThemeType.sunsetPulse:
        _paintSunset(canvas, size, t, r, nr, streakMultiplier);
        break;
      case ThemeType.arcticGlow:
        _paintArctic(canvas, size, t, r, nr, streakMultiplier);
        break;
      case ThemeType.sakuraDrift:
        _paintSakura(canvas, size, t, r, nr, streakMultiplier);
        break;
      case ThemeType.abyssalDepths:
        _paintAbyssal(canvas, size, t, r, nr, streakMultiplier);
        break;
      case ThemeType.retroGrid:
        _paintRetroGrid(canvas, size, t, r, nr, streakMultiplier);
        break;
      case ThemeType.emberCore:
        _paintEmberCore(canvas, size, t, r, nr, streakMultiplier);
        break;
      case ThemeType.celestialObservatory:
        _paintCelestial(canvas, size, t, r, nr, streakMultiplier);
        break;
      case ThemeType.prismRift:
        _paintPrismRift(canvas, size, t, r, nr, streakMultiplier);
        break;
    }
  }

  // =========================================================================
  // 0. THEME-AWARE GAMEPLAY-SAFE CORRIDOR
  // =========================================================================
  void _paintThemeCorridor(Canvas canvas, Size size, double t, double r,
      double nr, double streakMultiplier) {
    final waveTime = t * 2.0 * math.pi;

    // Horizontal Soft Feather Blend (Center 32% - 68% remains visually quiet)
    final corridorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          theme.corridorBaseColor.withValues(alpha: 0.0),
          theme.corridorBaseColor.withValues(alpha: 0.12),
          theme.corridorCenterColor.withValues(alpha: 0.25),
          theme.corridorBaseColor.withValues(alpha: 0.12),
          theme.corridorBaseColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.22, 0.50, 0.78, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), corridorPaint);

    // Subtle Lower Fog Continuation near Pedestal Base
    final fogPulse = 0.18 + 0.04 * math.sin(waveTime * 1.5);
    final fogHeight = size.height * 0.28;
    final fogY = size.height - fogHeight;
    final lowerFogPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          theme.corridorLowerFogColor.withValues(
              alpha: (fogPulse * streakMultiplier).clamp(0.0, 0.26)),
          theme.corridorHazeColor.withValues(alpha: fogPulse * 0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(
          Rect.fromLTWH(size.width * 0.10, fogY, size.width * 0.80, fogHeight));
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.10, fogY, size.width * 0.80, fogHeight),
        lowerFogPaint);

    // Restrained corridor ambient particles
    _paintParticlesList(
      canvas,
      size,
      _corridorParticles,
      t,
      streakMultiplier,
      theme.corridorLowerFogColor,
      theme.secondaryAccent,
    );

    // Subtle atmospheric bloom on perfect placement
    if (r > 0.001 && r < 1.0) {
      final corridorBloomAlpha = (0.16 * (1.0 - r)).clamp(0.0, 0.25);
      final corridorBloomPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.0, 0.30),
          radius: 0.70,
          colors: [
            theme.reactivePulseColor.withValues(alpha: corridorBloomAlpha),
            theme.reactiveSecondaryPulseColor
                .withValues(alpha: corridorBloomAlpha * 0.4),
            Colors.transparent,
          ],
          stops: const [0.0, 0.48, 1.0],
        ).createShader(Rect.fromLTWH(size.width * 0.18, size.height * 0.25,
            size.width * 0.64, size.height * 0.55));
      canvas.drawRect(
          Rect.fromLTWH(size.width * 0.18, size.height * 0.25,
              size.width * 0.64, size.height * 0.55),
          corridorBloomPaint);
    }
  }

  // =========================================================================
  // 1. MIDNIGHT NEON: CYBER DIMENSION
  // =========================================================================
  void _paintMidnightNeon(Canvas canvas, Size size, double t, double r,
      double nr, double streakMultiplier) {
    final waveTime = t * 2.0 * math.pi;

    // 1. Holographic Light Beams swaying gently in outer margins
    final beam1X = size.width * 0.08 + math.sin(waveTime * 0.8) * 12.0;
    final beam1Alpha =
        ((0.12 + 0.04 * math.sin(waveTime * 1.2)) * streakMultiplier +
                (nr * 0.05))
            .clamp(0.0, 0.40);
    final beam1Paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.primaryAccent.withValues(alpha: beam1Alpha * 0.8),
          theme.primaryAccent.withValues(alpha: beam1Alpha),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(beam1X - 24, 0, 48, size.height * 0.75));
    canvas.drawRect(
        Rect.fromLTWH(beam1X - 24, 0, 48, size.height * 0.75), beam1Paint);

    final beam2X = size.width * 0.92 + math.cos(waveTime * 0.7) * 12.0;
    final beam2Alpha =
        ((0.11 + 0.03 * math.cos(waveTime * 1.1)) * streakMultiplier +
                (nr * 0.05))
            .clamp(0.0, 0.40);
    final beam2Paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.secondaryAccent.withValues(alpha: beam2Alpha * 0.8),
          theme.secondaryAccent.withValues(alpha: beam2Alpha),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(beam2X - 26, 0, 52, size.height * 0.75));
    canvas.drawRect(
        Rect.fromLTWH(beam2X - 26, 0, 52, size.height * 0.75), beam2Paint);

    // 2. Distant Architectural Neon Pulse Lines
    final conduitPulse = (t * 2.5) % 1.0;
    final leftLineY = size.height * 0.20 + (size.height * 0.50) * conduitPulse;
    final leftLinePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          theme.primaryAccent.withValues(alpha: 0.25 * streakMultiplier),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, leftLineY - 12, size.width * 0.16, 24));
    canvas.drawRect(
        Rect.fromLTWH(0, leftLineY - 12, size.width * 0.16, 24), leftLinePaint);

    final rightLineY = size.height * 0.70 - (size.height * 0.50) * conduitPulse;
    final rightLinePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          theme.secondaryAccent.withValues(alpha: 0.25 * streakMultiplier),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(
          size.width * 0.84, rightLineY - 12, size.width * 0.16, 24));
    canvas.drawRect(
        Rect.fromLTWH(
            size.width * 0.84, rightLineY - 12, size.width * 0.16, 24),
        rightLinePaint);

    // 3. Ambient cyber particles with multi-layer parallax
    _paintParticlesList(canvas, size, _midnightParticles, t, streakMultiplier,
        theme.primaryAccent, theme.secondaryAccent);

    // 4. REACTIVE FEEDBACK: Short cyan energy wave radiating on perfect hit
    if (r > 0.001 && r < 1.0) {
      final pulseRadius = size.width * 0.20 + (size.width * 0.75) * r;
      final pulseAlpha = (0.32 * (1.0 - r)).clamp(0.0, 1.0);
      final center = Offset(size.width * 0.5, size.height * 0.62);

      final shockwavePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6 * (1.0 - r * 0.5)
        ..color = theme.reactivePulseColor.withValues(alpha: pulseAlpha);
      canvas.drawCircle(center, pulseRadius, shockwavePaint);

      final outerGlowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0 * (1.0 - r * 0.5)
        ..color = theme.reactiveSecondaryPulseColor
            .withValues(alpha: pulseAlpha * 0.35);
      canvas.drawCircle(center, pulseRadius, outerGlowPaint);
    }
  }

  // =========================================================================
  // 2. AURORA: LIVING LIGHTS (Smoothly Flowing Curtains)
  // =========================================================================
  void _paintAurora(Canvas canvas, Size size, double t, double r, double nr,
      double streakMultiplier) {
    final waveTime = t * 2.0 * math.pi;

    // Reactive aurora shimmer intensity
    final reactiveShimmer =
        (r > 0.0 && r < 1.0) ? (math.sin(r * math.pi) * 0.25) : (nr * 0.05);
    var baseAlpha =
        ((0.16 + 0.05 * math.sin(waveTime * 1.2)) * streakMultiplier +
                reactiveShimmer)
            .clamp(0.0, 0.50);

    // When the animated video pilot is active, the artwork itself has living northern
    // lights and emerald/turquoise flowing curtains; tone down procedural curves so
    // authentic video movement is clearly visible while keeping reactive sweeps & motes.
    if (isVideoActive) {
      baseAlpha = (baseAlpha * 0.25 + reactiveShimmer).clamp(0.0, 0.35);
    }

    // Multi-Layer Flowing Aurora Ribbon 1 (Turquoise / Mint Curtains)
    final path1 = Path();
    path1.moveTo(0, size.height * 0.06);
    for (double x = 0; x <= size.width; x += 14) {
      final normX = x / size.width;
      final waveY = size.height * 0.12 +
          math.sin(normX * 3.2 + waveTime * 1.5) * 22.0 +
          math.cos(normX * 6.5 + waveTime * 0.9) * 14.0;
      path1.lineTo(x, waveY);
    }
    path1.lineTo(size.width, 0);
    path1.lineTo(0, 0);
    path1.close();

    final auroraPaint1 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.mintAccent.withValues(alpha: baseAlpha * 0.85),
          theme.mintAccent.withValues(alpha: baseAlpha * 0.45),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.30));
    canvas.drawPath(path1, auroraPaint1);

    // Multi-Layer Flowing Aurora Ribbon 2 (Emerald Jade Undulation)
    final path2 = Path();
    path2.moveTo(0, size.height * 0.12);
    for (double x = 0; x <= size.width; x += 16) {
      final normX = x / size.width;
      final waveY = size.height * 0.18 +
          math.cos(normX * 4.2 - waveTime * 1.2) * 24.0 +
          math.sin(normX * 7.5 + waveTime * 1.0) * 12.0;
      path2.lineTo(x, waveY);
    }
    path2.lineTo(size.width, 0);
    path2.lineTo(0, 0);
    path2.close();

    final emeraldColor = theme.reactiveSecondaryPulseColor;
    final auroraPaint2 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          emeraldColor.withValues(alpha: baseAlpha * 0.70),
          emeraldColor.withValues(alpha: baseAlpha * 0.35),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.36));
    canvas.drawPath(path2, auroraPaint2);

    // Vertical luminous curtain striations (ray bands)
    for (int i = 0; i < 5; i++) {
      final rayNormX = 0.10 + i * 0.20 + math.sin(waveTime + i) * 0.05;
      final rayX = rayNormX * size.width;
      final rayAlpha =
          (0.08 * math.sin(waveTime * 2.0 + i * 1.5).abs() * streakMultiplier)
              .clamp(0.0, 0.25);
      final rayPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.mintAccent.withValues(alpha: rayAlpha),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(rayX - 16, 0, 32, size.height * 0.32));
      canvas.drawRect(
          Rect.fromLTWH(rayX - 16, 0, 32, size.height * 0.32), rayPaint);
    }

    // Floating spirit motes
    _paintParticlesList(canvas, size, _auroraParticles, t, streakMultiplier,
        theme.mintAccent, emeraldColor);

    // REACTIVE FEEDBACK: Shimmer ripple wave sweeping horizontally
    if (r > 0.001 && r < 1.0) {
      final sweepX = size.width * r;
      final sweepAlpha = (0.28 * (1.0 - r)).clamp(0.0, 1.0);
      final sweepRect = Rect.fromLTWH(sweepX - 70, 0, 140, size.height * 0.38);
      final shimmerPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            theme.mintAccent.withValues(alpha: sweepAlpha),
            Colors.transparent,
          ],
        ).createShader(sweepRect);
      canvas.drawRect(sweepRect, shimmerPaint);
    }
  }

  // =========================================================================
  // 3. SUNSET PULSE: GOLDEN HORIZON (Drifting Clouds & Sun Rays)
  // =========================================================================
  void _paintSunset(Canvas canvas, Size size, double t, double r, double nr,
      double streakMultiplier) {
    final waveTime = t * 2.0 * math.pi;
    final horizonY = size.height * 0.80;

    // 1. Moving Crepuscular Sunlight Rays radiating from the setting sun
    final rayCenter = Offset(size.width * 0.5, horizonY);
    for (int i = -3; i <= 3; i++) {
      final baseAngle = (-math.pi / 2.0) + (i * 0.22);
      final dynamicAngle = baseAngle + math.sin(waveTime * 0.8 + i) * 0.06;
      final rayLength = size.height * 0.65;
      final rayAlpha = (0.07 + 0.03 * math.cos(waveTime * 1.2 + i)) *
          streakMultiplier *
          (1.0 - (i.abs() * 0.15));
      final rayEndpoint = Offset(
        rayCenter.dx + math.cos(dynamicAngle) * rayLength,
        rayCenter.dy + math.sin(dynamicAngle) * rayLength,
      );

      final rayPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            theme.goldAccent.withValues(alpha: rayAlpha),
            Colors.transparent,
          ],
        ).createShader(Rect.fromPoints(rayCenter, rayEndpoint))
        ..strokeWidth = 22.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(rayCenter, rayEndpoint, rayPaint);
    }

    // 2. Drifting Layered Clouds (Distant Wisps & Midground Cumulus Lobes)
    final cloudOffset = (t * size.width * 0.08) % size.width;
    _drawCloudLobe(
      canvas: canvas,
      center: Offset(
          (size.width * 0.20 + cloudOffset) % (size.width * 1.3) -
              size.width * 0.15,
          horizonY - 80),
      radiusX: 85,
      radiusY: 26,
      color: theme.neonMagenta.withValues(alpha: 0.12 * streakMultiplier),
    );
    _drawCloudLobe(
      canvas: canvas,
      center: Offset(
          (size.width * 0.75 - cloudOffset * 0.7) % (size.width * 1.3) -
              size.width * 0.15,
          horizonY - 110),
      radiusX: 110,
      radiusY: 30,
      color: theme.orangeAccent.withValues(alpha: 0.14 * streakMultiplier),
    );

    // 3. Horizon Glow Breathing
    final reactiveGlow =
        (r > 0.0 && r < 1.0) ? (math.sin(r * math.pi) * 0.22) : (nr * 0.06);
    final horizonAlpha =
        ((0.15 + 0.05 * math.sin(waveTime * 1.1)) * streakMultiplier +
                reactiveGlow)
            .clamp(0.0, 0.48);

    final horizonRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, horizonY),
      width: size.width * 1.4,
      height: size.height * 0.28,
    );

    final horizonPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.goldAccent.withValues(alpha: horizonAlpha),
          theme.neonMagenta.withValues(alpha: horizonAlpha * 0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(horizonRect);
    canvas.drawRect(horizonRect, horizonPaint);

    // 4. Floating warm embers & golden dust
    _paintParticlesList(canvas, size, _sunsetParticles, t, streakMultiplier,
        theme.goldAccent, theme.orangeAccent);

    // REACTIVE FEEDBACK: Golden sweep radiating across horizon
    if (r > 0.001 && r < 1.0) {
      final sweepProgress = r;
      final sweepAlpha = (0.34 * (1.0 - sweepProgress)).clamp(0.0, 1.0);
      final center = Offset(size.width * 0.5, horizonY);
      final radius = (size.width * 0.75) * sweepProgress;

      final sweepPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2 * (1.0 - sweepProgress * 0.5)
        ..color = theme.goldAccent.withValues(alpha: sweepAlpha);
      canvas.drawCircle(center, radius, sweepPaint);
    }
  }

  // =========================================================================
  // 4. ARCTIC GLOW: FROZEN DIMENSION (Multi-Depth Natural Snowfall)
  // =========================================================================
  void _paintArctic(Canvas canvas, Size size, double t, double r, double nr,
      double streakMultiplier) {
    final waveTime = t * 2.0 * math.pi;

    // 1. Crystalline Spire Glints (Twinkling star reflections)
    final glint1Alpha =
        ((0.18 + 0.14 * math.sin(waveTime * 2.2)) * streakMultiplier +
                (nr * 0.08))
            .clamp(0.0, 0.70);
    final glint1Pos = Offset(size.width * 0.12, size.height * 0.32);
    _drawSparkle(canvas, glint1Pos, 8.0,
        theme.reactivePulseColor.withValues(alpha: glint1Alpha));

    final glint2Alpha =
        ((0.16 + 0.12 * math.cos(waveTime * 2.5)) * streakMultiplier +
                (nr * 0.08))
            .clamp(0.0, 0.70);
    final glint2Pos = Offset(size.width * 0.88, size.height * 0.28);
    _drawSparkle(canvas, glint2Pos, 9.0,
        const Color(0xFFBBEFFF).withValues(alpha: glint2Alpha));

    // 2. Rolling Ground Frost Mist
    final frostMistAlpha =
        (0.14 + 0.04 * math.sin(waveTime * 1.3)) * streakMultiplier;
    final frostMistPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.bottomCenter,
        radius: 0.75,
        colors: [
          const Color(0xFFBBEFFF).withValues(alpha: frostMistAlpha),
          theme.primaryAccent.withValues(alpha: frostMistAlpha * 0.4),
          Colors.transparent,
        ],
      ).createShader(
          Rect.fromLTWH(0, size.height * 0.75, size.width, size.height * 0.25));
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.75, size.width, size.height * 0.25),
        frostMistPaint);

    // 3. Multi-Depth Snowfall Particles (Layer 0 = Deep, 1 = Mid, 2 = Foreground)
    _paintParticlesList(canvas, size, _arcticParticles, t, streakMultiplier,
        const Color(0xFFBBEFFF), theme.primaryAccent);

    // REACTIVE FEEDBACK: Sharp icy sparkle flash radiating outward
    if (r > 0.001 && r < 1.0) {
      final pulseRadius = (size.width * 0.68) * r;
      final pulseAlpha = (0.35 * (1.0 - r)).clamp(0.0, 1.0);
      final center = Offset(size.width * 0.5, size.height * 0.62);

      final iceRingPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = const Color(0xFFBBEFFF).withValues(alpha: pulseAlpha);
      canvas.drawCircle(center, pulseRadius, iceRingPaint);

      // Central diamond glint burst
      _drawSparkle(canvas, center, 16.0 * (1.0 - r * 0.7),
          const Color(0xFFBBEFFF).withValues(alpha: pulseAlpha * 0.9));
    }
  }

  // =========================================================================
  // 5. SAKURA DRIFT: CHERRY BLOSSOM SANCTUARY (Tumbling 3D Petals & Lanterns)
  // =========================================================================
  void _paintSakura(Canvas canvas, Size size, double t, double r, double nr,
      double streakMultiplier) {
    final waveTime = t * 2.0 * math.pi;

    // 1. Gently Swaying Hanging Lanterns with Warm Radial Light
    final lanternSway = math.sin(waveTime * 1.2) * 0.08;
    final lanternFlicker = 0.88 + 0.12 * math.sin(waveTime * 4.5);
    final lanternAlpha = ((0.14 + 0.04 * math.sin(waveTime * 1.5)) *
            streakMultiplier *
            lanternFlicker)
        .clamp(0.0, 0.35);

    // Left Lantern Pool
    final leftLantern = Paint()
      ..shader = RadialGradient(
        center: Alignment(-0.85 + lanternSway, 0.75),
        radius: 0.55,
        colors: [
          theme.primaryAccent.withValues(alpha: lanternAlpha),
          theme.secondaryAccent.withValues(alpha: lanternAlpha * 0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(
          0, size.height * 0.65, size.width * 0.45, size.height * 0.35));
    canvas.drawRect(
        Rect.fromLTWH(
            0, size.height * 0.65, size.width * 0.45, size.height * 0.35),
        leftLantern);

    // Right Lantern Pool
    final rightLantern = Paint()
      ..shader = RadialGradient(
        center: Alignment(0.85 - lanternSway, 0.75),
        radius: 0.55,
        colors: [
          theme.secondaryAccent.withValues(alpha: lanternAlpha * 0.9),
          theme.primaryAccent.withValues(alpha: lanternAlpha * 0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(size.width * 0.55, size.height * 0.65,
          size.width * 0.45, size.height * 0.35));
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.55, size.height * 0.65, size.width * 0.45,
            size.height * 0.35),
        rightLantern);

    // 2. Diagonally Fluttering 3D Cherry Blossom Petals
    _paintPetalsList(canvas, size, _sakuraParticles, t, streakMultiplier,
        theme.primaryAccent, theme.secondaryAccent);

    // REACTIVE FEEDBACK: Delicate blossom burst radiating on perfect placement
    if (r > 0.001 && r < 1.0) {
      final pulseRadius = (size.width * 0.70) * r;
      final pulseAlpha = (0.36 * (1.0 - r)).clamp(0.0, 1.0);
      final center = Offset(size.width * 0.5, size.height * 0.62);

      final petalRingPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4 * (1.0 - r * 0.4)
        ..color = theme.reactivePulseColor.withValues(alpha: pulseAlpha);
      canvas.drawCircle(center, pulseRadius, petalRingPaint);

      // Radiating blossom petal sparkles
      for (int i = 0; i < 8; i++) {
        final angle = (i * math.pi / 4.0) + (r * 0.5);
        final dist = pulseRadius * 0.95;
        final petalPos = Offset(
          center.dx + math.cos(angle) * dist,
          center.dy + math.sin(angle) * dist,
        );
        _drawPetal(
            canvas,
            petalPos,
            angle + math.pi / 2,
            5.5 * (1.0 - r * 0.6),
            1.0,
            theme.reactiveSecondaryPulseColor.withValues(alpha: pulseAlpha));
      }
    }
  }

  // =========================================================================
  // 6. ABYSSAL DEPTHS: BIOLUMINESCENT OCEAN (Rising Bubbles & Swaying Flora)
  // =========================================================================
  void _paintAbyssal(Canvas canvas, Size size, double t, double r, double nr,
      double streakMultiplier) {
    final waveTime = t * 2.0 * math.pi;

    // 1. Swaying Aquatic Kelp Silhouettes at bottom-left and bottom-right edges
    _drawSwayingFlora(canvas, size, waveTime, streakMultiplier);

    // 2. Volumetric Underwater Caustic Light Shafts
    final shaftAlpha =
        ((0.11 + 0.04 * math.sin(waveTime * 1.1)) * streakMultiplier +
                (nr * 0.04))
            .clamp(0.0, 0.38);

    final leftShaft = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.25, 0)
      ..lineTo(size.width * 0.36, size.height * 0.62)
      ..lineTo(0, size.height * 0.42)
      ..close();
    final leftShaftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.primaryAccent.withValues(alpha: shaftAlpha * 0.8),
          theme.mintAccent.withValues(alpha: shaftAlpha * 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
          Rect.fromLTWH(0, 0, size.width * 0.36, size.height * 0.62));
    canvas.drawPath(leftShaft, leftShaftPaint);

    final rightShaft = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width * 0.75, 0)
      ..lineTo(size.width * 0.64, size.height * 0.58)
      ..lineTo(size.width, size.height * 0.45)
      ..close();
    final rightShaftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          theme.secondaryAccent.withValues(alpha: shaftAlpha * 0.7),
          theme.primaryAccent.withValues(alpha: shaftAlpha * 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(
          size.width * 0.64, 0, size.width * 0.36, size.height * 0.58));
    canvas.drawPath(rightShaft, rightShaftPaint);

    // 3. Multi-Speed Rising Bubbles with Organic Wobble
    _paintBubblesList(canvas, size, _abyssalParticles, t, streakMultiplier,
        theme.primaryAccent, theme.mintAccent);

    // REACTIVE FEEDBACK: Sonar ripple expanding on perfect placement
    if (r > 0.001 && r < 1.0) {
      final pulseRadius = (size.width * 0.72) * r;
      final pulseAlpha = (0.32 * (1.0 - r)).clamp(0.0, 1.0);
      final center = Offset(size.width * 0.5, size.height * 0.62);

      final sonarPaint1 = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6 * (1.0 - r * 0.5)
        ..color = theme.reactivePulseColor.withValues(alpha: pulseAlpha);
      canvas.drawCircle(center, pulseRadius, sonarPaint1);

      final sonarPaint2 = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = theme.primaryAccent.withValues(alpha: pulseAlpha * 0.6);
      canvas.drawCircle(center, pulseRadius * 0.75, sonarPaint2);
    }
  }

  // =========================================================================
  // 7. RETRO GRID: DIGITAL SYNTHWAVE (3D Perspective Grid & Laser Scan)
  // =========================================================================
  void _paintRetroGrid(Canvas canvas, Size size, double t, double r, double nr,
      double streakMultiplier) {
    final waveTime = t * 2.0 * math.pi;
    final horizonY = size.height * 0.78;

    // 1. Segmented Synthwave Sun at Horizon
    final sunCenter = Offset(size.width * 0.5, horizonY);
    final sunRadius = size.width * 0.22;
    final sunPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.secondaryAccent.withValues(alpha: 0.32 * streakMultiplier),
          theme.primaryAccent.withValues(alpha: 0.18 * streakMultiplier),
        ],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: sunRadius));
    canvas.drawCircle(sunCenter, sunRadius, sunPaint);

    // 2. Horizon Neon Glow
    final horizonAlpha =
        ((0.16 + 0.05 * math.sin(waveTime * 1.2)) * streakMultiplier +
                (r > 0.0 ? math.sin(r * math.pi) * 0.20 : 0.0))
            .clamp(0.0, 0.48);
    final horizonGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.primaryAccent.withValues(alpha: horizonAlpha),
          theme.secondaryAccent.withValues(alpha: horizonAlpha * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCenter(
          center: Offset(size.width * 0.5, horizonY),
          width: size.width * 1.4,
          height: size.height * 0.20));
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(size.width * 0.5, horizonY),
            width: size.width * 1.4,
            height: size.height * 0.20),
        horizonGlow);

    // 3. Perspective Wireframe Grid in Lower Section (Continuous Scroll)
    final gridAlpha = (0.18 * streakMultiplier).clamp(0.0, 0.42);
    final gridPaint = Paint()
      ..color = theme.primaryAccent.withValues(alpha: gridAlpha)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final vp = Offset(size.width * 0.5, horizonY);
    for (double fx = 0.0; fx <= 1.0; fx += 0.14) {
      final bottomX = size.width * fx;
      canvas.drawLine(vp, Offset(bottomX, size.height), gridPaint);
    }

    // Infinite quadratic scrolling horizontal grid lines
    final scrollOffset = (t * 2.5) % 1.0;
    for (int i = 1; i <= 5; i++) {
      final progress = math.pow((i + scrollOffset) / 6.0, 2.2).toDouble();
      final lineY = horizonY + (size.height - horizonY) * progress;
      final lineAlpha = (gridAlpha * progress).clamp(0.0, 0.38);
      final hLinePaint = Paint()
        ..color = theme.secondaryAccent.withValues(alpha: lineAlpha)
        ..strokeWidth = 1.0 + progress * 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, lineY), Offset(size.width, lineY), hLinePaint);
    }

    // 4. Digital Laser Scanline Sweeping Vertically
    final scanY = size.height * 0.22 +
        (size.height * 0.45) * (0.5 + 0.5 * math.sin(waveTime * 0.8));
    final scanAlpha =
        (0.12 + 0.05 * math.cos(waveTime * 1.6)) * streakMultiplier;
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          theme.secondaryAccent.withValues(alpha: scanAlpha),
          Colors.transparent,
        ],
        stops: const [0.08, 0.5, 0.92],
      ).createShader(Rect.fromLTWH(0, scanY - 1, size.width, 2))
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, scanY), Offset(size.width, scanY), scanPaint);

    // 5. Electronic digital bits in outer columns
    _paintParticlesList(canvas, size, _retroParticles, t, streakMultiplier,
        theme.primaryAccent, theme.secondaryAccent);

    // REACTIVE FEEDBACK: High-energy synthwave pulse wave
    if (r > 0.001 && r < 1.0) {
      final pulseRadius = (size.width * 0.78) * r;
      final pulseAlpha = (0.34 * (1.0 - r)).clamp(0.0, 1.0);

      final shockwavePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 * (1.0 - r * 0.4)
        ..color = theme.reactivePulseColor.withValues(alpha: pulseAlpha);
      canvas.drawCircle(vp, pulseRadius, shockwavePaint);
    }
  }

  // =========================================================================
  // 8. EMBER CORE: VOLCANIC CHAMBER (Buoyant Embers & Lava Reservoir)
  // =========================================================================
  void _paintEmberCore(Canvas canvas, Size size, double t, double r, double nr,
      double streakMultiplier) {
    final waveTime = t * 2.0 * math.pi;

    // 1. Boiling Magma Reservoir at Bottom with Viscous Undulation
    final magmaHeight = size.height * 0.22;
    final magmaY = size.height - magmaHeight;
    final reactiveGlow =
        (r > 0.0 && r < 1.0) ? (math.sin(r * math.pi) * 0.24) : (nr * 0.06);
    final floorAlpha =
        ((0.18 + 0.05 * math.sin(waveTime * 1.4)) * streakMultiplier +
                reactiveGlow)
            .clamp(0.0, 0.50);

    final magmaPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.bottomCenter,
        radius: 0.85,
        colors: [
          theme.primaryAccent.withValues(alpha: floorAlpha),
          theme.secondaryAccent.withValues(alpha: floorAlpha * 0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, magmaY, size.width, magmaHeight));
    canvas.drawRect(
        Rect.fromLTWH(0, magmaY, size.width, magmaHeight), magmaPaint);

    // 2. Atmospheric Heat Shimmer Waves (Rising heat convection)
    for (int i = 0; i < 4; i++) {
      final shimmerProgress = ((t * 2.0) + (i * 0.25)) % 1.0;
      final shimmerY =
          size.height * 0.85 - (size.height * 0.50) * shimmerProgress;
      final shimmerAlpha =
          (0.06 * math.sin(shimmerProgress * math.pi) * streakMultiplier)
              .clamp(0.0, 0.18);
      final shimmerPaint = Paint()
        ..color = theme.primaryAccent.withValues(alpha: shimmerAlpha)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      // Draw wave lines in side margins only
      canvas.drawLine(Offset(0, shimmerY), Offset(size.width * 0.18, shimmerY),
          shimmerPaint);
      canvas.drawLine(Offset(size.width * 0.82, shimmerY),
          Offset(size.width, shimmerY), shimmerPaint);
    }

    // 3. Glowing Volcanic Fissures along Outer Edges
    final fissureAlpha =
        (0.14 + 0.05 * math.cos(waveTime * 1.6)) * streakMultiplier;
    final leftFissure = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          theme.primaryAccent.withValues(alpha: fissureAlpha),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(
          0, size.height * 0.60, size.width * 0.16, size.height * 0.40));
    canvas.drawRect(
        Rect.fromLTWH(
            0, size.height * 0.60, size.width * 0.16, size.height * 0.40),
        leftFissure);

    // 4. Turbulent Buoyant Floating Embers
    _paintEmbersList(canvas, size, _emberParticles, t, streakMultiplier,
        theme.primaryAccent, theme.secondaryAccent);

    // REACTIVE FEEDBACK: Blazing molten magma shockwave
    if (r > 0.001 && r < 1.0) {
      final pulseRadius = (size.width * 0.74) * r;
      final pulseAlpha = (0.36 * (1.0 - r)).clamp(0.0, 1.0);
      final center = Offset(size.width * 0.5, size.height * 0.62);

      final magmaRingPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2 * (1.0 - r * 0.5)
        ..color = theme.reactivePulseColor.withValues(alpha: pulseAlpha);
      canvas.drawCircle(center, pulseRadius, magmaRingPaint);

      final outerFirePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.5 * (1.0 - r * 0.5)
        ..color = theme.reactiveSecondaryPulseColor
            .withValues(alpha: pulseAlpha * 0.35);
      canvas.drawCircle(center, pulseRadius, outerFirePaint);

      _drawSparkle(canvas, center, 14.0 * (1.0 - r * 0.6),
          theme.reactivePulseColor.withValues(alpha: pulseAlpha * 0.9));
    }
  }

  // =========================================================================
  // 9. CELESTIAL OBSERVATORY: GOLDEN CONSTELLATIONS (Twinkling & Revolving)
  // =========================================================================
  void _paintCelestial(Canvas canvas, Size size, double t, double r, double nr,
      double streakMultiplier) {
    final waveTime = t * 2.0 * math.pi;

    // 1. Slowly Revolving Constellation Geometry in Outer Skies
    final constelAngle = waveTime * 0.2;
    _drawConstellationCluster(
      canvas: canvas,
      center: Offset(size.width * 0.12, size.height * 0.20),
      radius: 44.0,
      angle: constelAngle,
      alpha: (0.18 * streakMultiplier).clamp(0.0, 0.45),
      color: theme.primaryAccent,
    );
    _drawConstellationCluster(
      canvas: canvas,
      center: Offset(size.width * 0.88, size.height * 0.22),
      radius: 46.0,
      angle: -constelAngle * 0.8,
      alpha: (0.18 * streakMultiplier).clamp(0.0, 0.45),
      color: theme.primaryAccent,
    );

    // 2. Periodic Incandescent Shooting Star
    final shootCycle = (t * 4.0) % 1.0;
    if (shootCycle < 0.22) {
      final progress = shootCycle / 0.22;
      final startX = size.width * 0.55 + (size.width * 0.40) * progress;
      final startY = size.height * 0.06 + (size.height * 0.16) * progress;
      final shootAlpha =
          (math.sin(progress * math.pi) * 0.42 * streakMultiplier)
              .clamp(0.0, 0.75);

      final shootPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            theme.primaryAccent.withValues(alpha: shootAlpha),
            Colors.white.withValues(alpha: shootAlpha * 0.95),
          ],
          stops: const [0.0, 0.65, 1.0],
        ).createShader(Rect.fromLTWH(startX - 45, startY - 20, 50, 25))
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
          Offset(startX - 40, startY - 16), Offset(startX, startY), shootPaint);
    }

    // 3. Multi-Phase Twinkling Star Dust
    _paintParticlesList(canvas, size, _celestialParticles, t, streakMultiplier,
        theme.primaryAccent, theme.secondaryAccent);

    // REACTIVE FEEDBACK: Golden starburst constellation flash
    if (r > 0.001 && r < 1.0) {
      final pulseRadius = (size.width * 0.68) * r;
      final pulseAlpha = (0.36 * (1.0 - r)).clamp(0.0, 1.0);
      final center = Offset(size.width * 0.5, size.height * 0.62);

      final starRingPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * (1.0 - r * 0.4)
        ..color = theme.reactivePulseColor.withValues(alpha: pulseAlpha);
      canvas.drawCircle(center, pulseRadius, starRingPaint);

      _drawSparkle(canvas, center, 18.0 * (1.0 - r * 0.6),
          theme.reactivePulseColor.withValues(alpha: pulseAlpha * 0.9));
      _drawSparkle(canvas, center, 10.0 * (1.0 - r * 0.6),
          Colors.white.withValues(alpha: pulseAlpha));
    }
  }

  // =========================================================================
  // 10. PRISM RIFT: DIMENSIONAL FRACTURE (Faceted Shards & Dispersion)
  // =========================================================================
  void _paintPrismRift(Canvas canvas, Size size, double t, double r, double nr,
      double streakMultiplier) {
    final waveTime = t * 2.0 * math.pi;

    // 1. Shifting Refraction Dispersion Beams (Split Cyan/Magenta)
    final facetAlpha =
        ((0.13 + 0.04 * math.sin(waveTime * 1.3)) * streakMultiplier +
                (nr * 0.05))
            .clamp(0.0, 0.40);

    final leftFacet = Path()
      ..moveTo(0, size.height * 0.15)
      ..lineTo(size.width * 0.32, size.height * 0.46)
      ..lineTo(size.width * 0.22, size.height * 0.62)
      ..lineTo(0, size.height * 0.42)
      ..close();
    final leftFacetPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.primaryAccent.withValues(alpha: facetAlpha * 0.85),
          theme.secondaryAccent.withValues(alpha: facetAlpha * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(
          0, size.height * 0.15, size.width * 0.32, size.height * 0.47));
    canvas.drawPath(leftFacet, leftFacetPaint);

    final rightFacet = Path()
      ..moveTo(size.width, size.height * 0.20)
      ..lineTo(size.width * 0.68, size.height * 0.52)
      ..lineTo(size.width * 0.78, size.height * 0.66)
      ..lineTo(size.width, size.height * 0.45)
      ..close();
    final rightFacetPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          theme.secondaryAccent.withValues(alpha: facetAlpha * 0.85),
          theme.primaryAccent.withValues(alpha: facetAlpha * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(size.width * 0.68, size.height * 0.20,
          size.width * 0.32, size.height * 0.46));
    canvas.drawPath(rightFacet, rightFacetPaint);

    // 2. Drifting 3D Faceted Crystal Shards
    _paintFacetedShardsList(canvas, size, _prismParticles, t, streakMultiplier,
        theme.primaryAccent, theme.secondaryAccent);

    // REACTIVE FEEDBACK: Multi-spectral chromatic energy ripple
    if (r > 0.001 && r < 1.0) {
      final pulseRadius = (size.width * 0.72) * r;
      final pulseAlpha = (0.34 * (1.0 - r)).clamp(0.0, 1.0);
      final center = Offset(size.width * 0.5, size.height * 0.62);

      // Cyan outer ring
      final cyanRingPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4 * (1.0 - r * 0.4)
        ..color = theme.reactivePulseColor.withValues(alpha: pulseAlpha);
      canvas.drawCircle(center, pulseRadius, cyanRingPaint);

      // Magenta inner ring (chromatic dispersion offset)
      final magentaRingPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8 * (1.0 - r * 0.4)
        ..color = theme.reactiveSecondaryPulseColor
            .withValues(alpha: pulseAlpha * 0.85);
      canvas.drawCircle(center, pulseRadius * 0.88, magentaRingPaint);

      _drawSparkle(canvas, center, 15.0 * (1.0 - r * 0.6),
          theme.reactivePulseColor.withValues(alpha: pulseAlpha));
    }
  }

  // =========================================================================
  // SPECIALIZED GEOMETRIC & PROCEDURAL RENDERING HELPERS
  // =========================================================================

  void _drawCloudLobe({
    required Canvas canvas,
    required Offset center,
    required double radiusX,
    required double radiusY,
    required Color color,
  }) {
    final rect = Rect.fromCenter(
        center: center, width: radiusX * 2, height: radiusY * 2);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color,
          color.withValues(alpha: color.a * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(rect);
    canvas.drawOval(rect, paint);
  }

  void _drawSwayingFlora(
      Canvas canvas, Size size, double waveTime, double streakMultiplier) {
    final floraPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          theme.mintAccent.withValues(alpha: 0.22 * streakMultiplier),
          Colors.transparent,
        ],
      ).createShader(
          Rect.fromLTWH(0, size.height * 0.60, size.width, size.height * 0.40))
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Left frond
    final leftTipSway = math.sin(waveTime * 1.3) * 16.0;
    final leftFrond = Path()
      ..moveTo(size.width * 0.06, size.height)
      ..quadraticBezierTo(
          size.width * 0.08 + leftTipSway * 0.5,
          size.height * 0.82,
          size.width * 0.10 + leftTipSway,
          size.height * 0.68);
    canvas.drawPath(leftFrond, floraPaint);

    // Right frond
    final rightTipSway = math.cos(waveTime * 1.1) * 16.0;
    final rightFrond = Path()
      ..moveTo(size.width * 0.94, size.height)
      ..quadraticBezierTo(
          size.width * 0.92 + rightTipSway * 0.5,
          size.height * 0.84,
          size.width * 0.90 + rightTipSway,
          size.height * 0.70);
    canvas.drawPath(rightFrond, floraPaint);
  }

  void _drawConstellationCluster({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double angle,
    required double alpha,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color.withValues(alpha: alpha)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final nodePaint = Paint()
      ..color = color.withValues(alpha: alpha * 1.5)
      ..style = PaintingStyle.fill;

    // 4 connected geometric nodes
    final p0 = Offset(
      center.dx + math.cos(angle) * radius * 0.5,
      center.dy + math.sin(angle) * radius * 0.5,
    );
    final p1 = Offset(
      center.dx + math.cos(angle + 1.2) * radius,
      center.dy + math.sin(angle + 1.2) * radius,
    );
    final p2 = Offset(
      center.dx + math.cos(angle + 2.5) * radius * 0.8,
      center.dy + math.sin(angle + 2.5) * radius * 0.8,
    );
    final p3 = Offset(
      center.dx + math.cos(angle + 4.0) * radius * 1.1,
      center.dy + math.sin(angle + 4.0) * radius * 1.1,
    );

    canvas.drawLine(p0, p1, paint);
    canvas.drawLine(p1, p2, paint);
    canvas.drawLine(p2, p3, paint);

    canvas.drawCircle(p0, 2.0, nodePaint);
    canvas.drawCircle(p1, 2.4, nodePaint);
    canvas.drawCircle(p2, 2.2, nodePaint);
    canvas.drawCircle(p3, 2.6, nodePaint);
  }

  void _paintParticlesList(
    Canvas canvas,
    Size size,
    List<_EnvParticle> particles,
    double t,
    double streakMultiplier,
    Color primaryColor,
    Color secondaryColor,
  ) {
    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];

      // Parallax speed modifier by layer
      final layerSpeedFactor = p.layer == 2
          ? 1.35
          : p.layer == 0
              ? 0.70
              : 1.0;

      // Vertical drift with seamless wrap
      final rawY = (p.y + p.speedY * t * layerSpeedFactor) % 1.0;
      final currentY = rawY * size.height;

      // Subtle horizontal sway
      final currentX = p.x * size.width +
          math.sin(t * 2.0 * math.pi * 1.5 + p.phase) *
              (size.width * p.speedX * 3.0);

      // Breathing opacity
      final pulse = 0.75 + 0.25 * math.sin(t * 2.0 * math.pi * 2.0 + p.phase);
      final alpha = (p.maxAlpha * pulse * streakMultiplier).clamp(0.0, 1.0);
      if (alpha <= 0.01) continue;

      final color =
          (i % 2 == 0 ? primaryColor : secondaryColor).withValues(alpha: alpha);

      if (p.isDiamond) {
        final s = p.size * 1.25;
        final diamondPath = Path()
          ..moveTo(currentX, currentY - s)
          ..lineTo(currentX + s, currentY)
          ..lineTo(currentX, currentY + s)
          ..lineTo(currentX - s, currentY)
          ..close();

        final diamondPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawPath(diamondPath, diamondPaint);
      } else {
        final corePaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(currentX, currentY), p.size, corePaint);

        // Soft outer glow halo
        final haloPaint = Paint()
          ..color = color.withValues(alpha: alpha * 0.35)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(currentX, currentY), p.size * 2.0, haloPaint);
      }
    }
  }

  void _paintPetalsList(
    Canvas canvas,
    Size size,
    List<_EnvParticle> particles,
    double t,
    double streakMultiplier,
    Color primaryColor,
    Color secondaryColor,
  ) {
    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];

      // Vertical drift with seamless wrap
      final rawY = (p.y + p.speedY * t) % 1.0;
      final currentY = rawY * size.height;

      // Wind gust acceleration wave
      final windGust =
          0.85 + 0.30 * math.sin(t * 2.0 * math.pi * 1.2 + p.phase);
      final currentX = p.x * size.width +
          math.sin(t * 2.0 * math.pi * 1.2 + p.phase) * (size.width * 0.04) +
          (p.speedX * t * size.width * windGust) % (size.width * 0.12);

      final pulse = 0.75 + 0.25 * math.sin(t * 2.0 * math.pi * 1.8 + p.phase);
      final alpha = (p.maxAlpha * pulse * streakMultiplier).clamp(0.0, 1.0);
      if (alpha <= 0.01) continue;

      final color =
          (i % 2 == 0 ? primaryColor : secondaryColor).withValues(alpha: alpha);
      final angle = (t * 2.0 * math.pi + p.phase) * 0.6;
      // 3D aspect ratio flip simulation
      final flipScale = math.cos(t * 2.0 * math.pi * 2.0 + p.phase).abs();

      _drawPetal(canvas, Offset(currentX, currentY), angle, p.size,
          math.max(0.3, flipScale), color);
    }
  }

  void _drawPetal(Canvas canvas, Offset center, double angle, double radius,
      double flipScale, Color color) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.scale(flipScale, 1.0);

    final path = Path()
      ..moveTo(0, -radius * 1.5)
      ..quadraticBezierTo(
          radius * 0.8, -radius * 0.5, radius * 0.6, radius * 0.8)
      ..quadraticBezierTo(0, radius * 1.4, -radius * 0.6, radius * 0.8)
      ..quadraticBezierTo(-radius * 0.8, -radius * 0.5, 0, -radius * 1.5)
      ..close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _paintBubblesList(
    Canvas canvas,
    Size size,
    List<_EnvParticle> particles,
    double t,
    double streakMultiplier,
    Color primaryColor,
    Color secondaryColor,
  ) {
    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];

      // Vertical rise with seamless wrap
      final rawY = (p.y + p.speedY * t) % 1.0;
      final currentY = rawY * size.height;

      // Gentle horizontal underwater sinusoidal wobble
      final currentX = p.x * size.width +
          math.sin(t * 2.0 * math.pi * 1.4 + p.phase) * (size.width * 0.03);

      final pulse = 0.80 + 0.20 * math.sin(t * 2.0 * math.pi * 1.5 + p.phase);
      final alpha = (p.maxAlpha * pulse * streakMultiplier).clamp(0.0, 1.0);
      if (alpha <= 0.01) continue;

      final color =
          (i % 2 == 0 ? primaryColor : secondaryColor).withValues(alpha: alpha);

      _drawBubble(canvas, Offset(currentX, currentY), p.size, color);
    }
  }

  void _drawBubble(Canvas canvas, Offset center, double radius, Color color) {
    // Bubble body with translucent fill
    final fillPaint = Paint()
      ..color = color.withValues(alpha: (color.a * 0.35).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fillPaint);

    // Bubble outline
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, strokePaint);

    // Specular highlight dot at top-left
    final glintOffset =
        Offset(center.dx - radius * 0.35, center.dy - radius * 0.35);
    final glintPaint = Paint()
      ..color = Colors.white.withValues(alpha: (color.a * 0.75).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(glintOffset, math.max(0.8, radius * 0.25), glintPaint);
  }

  void _paintEmbersList(
    Canvas canvas,
    Size size,
    List<_EnvParticle> particles,
    double t,
    double streakMultiplier,
    Color primaryColor,
    Color secondaryColor,
  ) {
    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];

      // Turbulent buoyant rise
      final rawY = (p.y + p.speedY * t) % 1.0;
      final currentY = rawY * size.height;

      // Turbulent horizontal sway
      final currentX = p.x * size.width +
          math.sin(t * 2.0 * math.pi * 2.2 + p.phase) * (size.width * 0.035);

      // Embers cool down and fade as they rise higher
      final heightFactor = (currentY / size.height).clamp(0.2, 1.0);
      final alpha =
          (p.maxAlpha * heightFactor * streakMultiplier).clamp(0.0, 1.0);
      if (alpha <= 0.01) continue;

      // Hot core -> cooling halo
      final coreColor = Colors.white.withValues(alpha: alpha);
      final bodyColor = (i % 2 == 0 ? primaryColor : secondaryColor)
          .withValues(alpha: alpha * 0.85);

      final haloPaint = Paint()
        ..color = bodyColor.withValues(alpha: alpha * 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(currentX, currentY), p.size * 2.2, haloPaint);

      final bodyPaint = Paint()
        ..color = bodyColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(currentX, currentY), p.size, bodyPaint);

      final corePaint = Paint()
        ..color = coreColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(currentX, currentY), p.size * 0.45, corePaint);
    }
  }

  void _paintFacetedShardsList(
    Canvas canvas,
    Size size,
    List<_EnvParticle> particles,
    double t,
    double streakMultiplier,
    Color primaryColor,
    Color secondaryColor,
  ) {
    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];

      final rawY = (p.y + p.speedY * t) % 1.0;
      final currentY = rawY * size.height;
      final currentX = p.x * size.width +
          math.sin(t * 2.0 * math.pi * 0.9 + p.phase) * (size.width * 0.025);

      final alpha = (p.maxAlpha * streakMultiplier).clamp(0.0, 1.0);
      if (alpha <= 0.01) continue;

      final color =
          (i % 2 == 0 ? primaryColor : secondaryColor).withValues(alpha: alpha);
      final rotAngle = (t * 2.0 * math.pi + p.phase) * 0.4;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(rotAngle);

      final s = p.size * 1.5;
      final shardPath = Path()
        ..moveTo(0, -s)
        ..lineTo(s * 0.7, -s * 0.2)
        ..lineTo(s * 0.4, s * 0.9)
        ..lineTo(-s * 0.5, s * 0.6)
        ..close();

      final fillPaint = Paint()
        ..color = color.withValues(alpha: alpha * 0.35)
        ..style = PaintingStyle.fill;
      canvas.drawPath(shardPath, fillPaint);

      final edgePaint = Paint()
        ..color = color
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawPath(shardPath, edgePaint);

      canvas.restore();
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 4-pointed diamond star sparkle
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ThemeEnvironmentPainter oldDelegate) {
    return oldDelegate.ambientAnimation.value != ambientAnimation.value ||
        oldDelegate.reactiveAnimation.value != reactiveAnimation.value ||
        oldDelegate.normalReactiveAnimation.value !=
            normalReactiveAnimation.value ||
        oldDelegate.theme.type != theme.type ||
        oldDelegate.streak != streak ||
        oldDelegate.isGameOver != isGameOver ||
        oldDelegate.isVideoActive != isVideoActive;
  }
}
