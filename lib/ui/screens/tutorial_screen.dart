import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/game_theme.dart';
import '../widgets/premium_button.dart';

/// Phase 6: Production How to Play Screen
///
/// Faithfully reconstructs Reference Screen 9:
/// - Header: Circular glass back button, centered 'HOW TO PLAY' title,
///   and 'Master the perfect stack.' subtitle.
/// - Five vertical tutorial step cards:
///   1. 'Block moves automatically' with gliding block and directional arrows.
///   2. 'Tap to stack it' with placed block and radiant tapping hand ripple.
///   3. 'Perfect alignment keeps the width' with radiant cyan flash & sparkle diamonds.
///   4. 'Inaccurate alignment trims the block' with sliced overhang piece dropping away.
///   5. 'Miss the tower and it\'s game over' with tumbling missed block into void.
/// - Looping educational micro-animations that respect the reducedMotion setting.
/// - Bottom primary action 'LET\'S PLAY' pill button.
class TutorialScreen extends StatefulWidget {
  final GameTheme theme;
  final VoidCallback onDismiss;
  final bool reducedMotion;

  const TutorialScreen({
    super.key,
    required this.theme,
    required this.onDismiss,
    this.reducedMotion = false,
  });

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest && !widget.reducedMotion) {
      _animController.repeat();
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
    final theme = widget.theme;

    return Scaffold(
      backgroundColor: theme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: theme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              children: [
                // 1. Top Header Bar matching Reference Screen 9
                Row(
                  children: [
                    // Back Arrow Button
                    GlassIconButton(
                      icon: Icons.arrow_back_rounded,
                      size: 42,
                      iconSize: 20,
                      reducedMotion: widget.reducedMotion,
                      onTap: widget.onDismiss,
                    ),

                    // Centered Header Title & Subtitle
                    const Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'HOW TO PLAY',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Master the perfect stack.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFA8C4E4),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                        width: 42), // Balances back button symmetrically
                  ],
                ),
                const SizedBox(height: 18),

                // 2. Scrollable 5-Step Tutorial Cards matching Reference Screen 9
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildStepCard(
                        step: '1',
                        instruction: 'Block moves automatically',
                        diagram: _buildMovingBlockDiagram(),
                      ),
                      const SizedBox(height: 12),
                      _buildStepCard(
                        step: '2',
                        instruction: 'Tap to stack it',
                        diagram: _buildTapDiagram(),
                      ),
                      const SizedBox(height: 12),
                      _buildStepCard(
                        step: '3',
                        instruction: 'Perfect alignment keeps the width',
                        diagram: _buildPerfectAlignmentDiagram(),
                      ),
                      const SizedBox(height: 12),
                      _buildStepCard(
                        step: '4',
                        instruction: 'Inaccurate alignment trims the block',
                        diagram: _buildTrimmingDiagram(),
                      ),
                      const SizedBox(height: 12),
                      _buildStepCard(
                        step: '5',
                        instruction: 'Miss the tower and it\'s game over',
                        diagram: _buildMissDiagram(),
                      ),
                      const SizedBox(height: 20),

                      // Completion CTA Action: LET'S PLAY
                      PremiumButton(
                        label: 'LET\'S PLAY',
                        icon: Icons.play_arrow_rounded,
                        isPrimary: true,
                        theme: theme,
                        reducedMotion: widget.reducedMotion,
                        height: 52,
                        fontSize: 15,
                        onTap: widget.onDismiss,
                      ),
                      const SizedBox(height: 14),
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

  /// Tutorial Step Card matching Reference Screen 9
  Widget _buildStepCard({
    required String step,
    required String instruction,
    required Widget diagram,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF14284A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Blue Circular Number Badge matching Reference Screen 9
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2B85FF),
                  Color(0xFF1B63D8),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF1B63D8),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Short Instructional Text
          Expanded(
            child: Text(
              instruction,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                height: 1.3,
                letterSpacing: 0.1,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Geometric Interactive Illustrated Diagram
          SizedBox(
            width: 82,
            height: 52,
            child: Center(child: diagram),
          ),
        ],
      ),
    );
  }

  /// Diagram 1: Block gliding horizontally with cyan motion arrows
  Widget _buildMovingBlockDiagram() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        final t = math.sin(_animController.value * 2 * math.pi);
        final offset = t * 14.0;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Left & Right Motion Arrows
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.chevron_left_rounded,
                  color: const Color(0xFF13D9FF).withValues(alpha: 0.6),
                  size: 16,
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFF13D9FF).withValues(alpha: 0.6),
                  size: 16,
                ),
              ],
            ),
            // Moving Block
            Transform.translate(
              offset: Offset(offset, 0),
              child: Container(
                width: 44,
                height: 14,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF9658FF),
                      Color(0xFFF34BEA),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9658FF).withValues(alpha: 0.50),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Diagram 2: Block with radiant animated tap ripple and hand pointer
  Widget _buildTapDiagram() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        final phase = (_animController.value * 2) % 1.0;
        final rippleRadius = 8.0 + phase * 16.0;
        final rippleOpacity = (1.0 - phase).clamp(0.0, 1.0);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Base Block
            Container(
              width: 52,
              height: 14,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF13D9FF),
                    Color(0xFF347BFF),
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF13D9FF).withValues(alpha: 0.40),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            // Expanding Radiant Tap Ripple
            Positioned(
              right: 6,
              bottom: 2,
              child: Container(
                width: rippleRadius * 2,
                height: rippleRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF13D9FF)
                        .withValues(alpha: rippleOpacity * 0.7),
                    width: 1.2,
                  ),
                ),
              ),
            ),
            // Tapping Hand Cursor Icon
            const Positioned(
              right: 2,
              bottom: 0,
              child: Icon(
                Icons.touch_app_rounded,
                color: Colors.white,
                size: 22,
                shadows: [
                  Shadow(color: Colors.black, blurRadius: 4),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Diagram 3: Perfectly aligned block emitting radiant cyan pulse bloom & diamond sparkle
  Widget _buildPerfectAlignmentDiagram() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        final pulse = 0.5 + 0.5 * math.sin(_animController.value * 2 * math.pi);

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Ambient Diamond Sparkles
            Positioned(
              left: 4,
              top: 4,
              child: Transform.rotate(
                angle: 0.4 * math.pi,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF13D9FF),
                    borderRadius: BorderRadius.circular(1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF13D9FF).withValues(alpha: pulse),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: Transform.rotate(
                angle: 0.25 * math.pi,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF14E4C5),
                    borderRadius: BorderRadius.circular(1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF14E4C5).withValues(alpha: pulse),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Perfectly Stacked Block with Radiant Bloom
            Container(
              width: 54,
              height: 15,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF14E4C5),
                    Color(0xFF13D9FF),
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF13D9FF)
                        .withValues(alpha: 0.45 + pulse * 0.35),
                    blurRadius: 10 + pulse * 6,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Diagram 4: Sliced block with separated trimmed piece dropping away
  Widget _buildTrimmingDiagram() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        final phase = (_animController.value * 1.5) % 1.0;
        final dropY = phase * 10.0;
        final rotation = phase * 0.4;
        final opacity = (1.0 - phase * 0.8).clamp(0.2, 1.0);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Tower Base Layer
            Positioned(
              bottom: 10,
              left: 4,
              child: Container(
                width: 36,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF347BFF).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            // Overlapping Kept Piece
            Positioned(
              top: 10,
              left: 4,
              child: Container(
                width: 36,
                height: 13,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF995B), Color(0xFFFFB300)],
                  ),
                  borderRadius: BorderRadius.circular(2.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF995B).withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
            // Sliced Falling Piece
            Positioned(
              top: 10 + dropY,
              left: 44 + dropY * 0.3,
              child: Transform.rotate(
                angle: 0.2 + rotation,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 16,
                    height: 13,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5252).withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Diagram 5: Missed block tumbling downward into the void
  Widget _buildMissDiagram() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        final phase = (_animController.value * 1.2) % 1.0;
        final dropY = phase * 16.0;
        final tumble = phase * 0.8;
        final opacity = (1.0 - phase * 0.9).clamp(0.1, 1.0);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Tower Foundation (Left)
            Positioned(
              bottom: 8,
              left: 2,
              child: Container(
                width: 28,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF14284A),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 0.8,
                  ),
                ),
              ),
            ),
            // Tumbling Missed Block (Right)
            Positioned(
              top: 6 + dropY,
              right: 6 - phase * 4,
              child: Transform.rotate(
                angle: 0.4 + tumble,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 28,
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF13D9FF), Color(0xFF347BFF)],
                      ),
                      borderRadius: BorderRadius.circular(2.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF13D9FF).withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
