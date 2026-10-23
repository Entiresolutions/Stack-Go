import 'package:flutter/material.dart';
import '../../core/game_theme.dart';

class TutorialScreen extends StatelessWidget {
  final GameTheme theme;
  final VoidCallback onDismiss;

  const TutorialScreen({
    super.key,
    required this.theme,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: theme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Top Header Bar matching Reference Screen 9
                Row(
                  children: [
                    // Back Arrow
                    GestureDetector(
                      onTap: onDismiss,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF14284A).withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.10),
                            width: 1.0,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'HOW TO PLAY',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // Balances back arrow
                  ],
                ),
                const SizedBox(height: 20),

                // 5 Instructional Step Rows matching Reference Screen 9
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildStepRow(
                        step: '1',
                        instruction: 'Block moves automatically',
                        diagram: _buildMovingBlockDiagram(),
                      ),
                      const SizedBox(height: 12),
                      _buildStepRow(
                        step: '2',
                        instruction: 'Tap to stack it',
                        diagram: _buildTapDiagram(),
                      ),
                      const SizedBox(height: 12),
                      _buildStepRow(
                        step: '3',
                        instruction: 'Perfect alignment keeps the width',
                        diagram: _buildPerfectAlignmentDiagram(),
                      ),
                      const SizedBox(height: 12),
                      _buildStepRow(
                        step: '4',
                        instruction: 'Inaccurate alignment trims the block',
                        diagram: _buildTrimmingDiagram(),
                      ),
                      const SizedBox(height: 12),
                      _buildStepRow(
                        step: '5',
                        instruction: 'Miss the tower and it\'s game over',
                        diagram: _buildMissDiagram(),
                      ),
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

  Widget _buildStepRow({
    required String step,
    required String instruction,
    required Widget diagram,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF14284A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              color: Color(0xFF347BFF),
              shape: BoxShape.circle,
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

          // Short Instruction
          Expanded(
            child: Text(
              instruction,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Geometric Illustrated Diagram
          SizedBox(
            width: 72,
            height: 48,
            child: Center(child: diagram),
          ),
        ],
      ),
    );
  }

  // Diagram 1: Block with horizontal motion trail
  Widget _buildMovingBlockDiagram() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Motion trail
        Positioned(
          left: 4,
          child: Container(
            width: 32,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFF9658FF).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Active moving block
        Positioned(
          right: 4,
          child: Container(
            width: 44,
            height: 13,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF13D9FF), Color(0xFF9658FF)],
              ),
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF13D9FF).withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Diagram 2: Block with hand finger pointer
  Widget _buildTapDiagram() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 50,
          height: 13,
          decoration: BoxDecoration(
            color: const Color(0xFF13D9FF),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF13D9FF).withValues(alpha: 0.4),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const Positioned(
          right: 2,
          bottom: 2,
          child: Icon(
            Icons.touch_app_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ],
    );
  }

  // Diagram 3: Block aligned cleanly with dashed alignment guide
  Widget _buildPerfectAlignmentDiagram() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 52,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFF14E4C5),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.white, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF14E4C5).withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Diagram 4: Sliced block with falling orange piece
  Widget _buildTrimmingDiagram() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 13,
          decoration: BoxDecoration(
            color: const Color(0xFF347BFF),
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
        const SizedBox(width: 4),
        Transform.rotate(
          angle: 0.35,
          child: Container(
            width: 14,
            height: 13,
            decoration: BoxDecoration(
              color: const Color(0xFFFF995B),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  // Diagram 5: Missed block falling into void
  Widget _buildMissDiagram() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 11,
          decoration: BoxDecoration(
            color: const Color(0xFF1C3A70),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Transform.rotate(
          angle: 0.5,
          child: Container(
            width: 24,
            height: 11,
            decoration: BoxDecoration(
              color: const Color(0xFF13D9FF).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}
