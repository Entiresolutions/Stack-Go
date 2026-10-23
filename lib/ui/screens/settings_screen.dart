import 'package:flutter/material.dart';
import '../../core/game_theme.dart';
import '../../models/game_settings.dart';
import '../../services/music_service.dart';
import '../widgets/premium_button.dart';

/// Phase 6: Production Settings Screen
///
/// Faithfully reconstructs Reference Screen 8:
/// - Clean, premium futuristic aesthetic with deep navy background.
/// - Top bar: Circular glass back button, centered bold 'SETTINGS' header.
/// - Three distinct setting rows:
///   1. Sound Effects (speaker icon + custom cyan neon toggle).
///   2. Haptic Feedback (phone vibration icon + custom cyan neon toggle).
///   3. Reduced Motion (crescent moon icon + custom toggle).
/// - THEME Section:
///   - 'THEME' section header.
///   - Interactive theme shortcut card displaying active theme preview,
///     'Current Theme' label, theme name, and chevron navigation arrow.
/// - Immediate persistence to local storage and live service updates.
class SettingsScreen extends StatefulWidget {
  final GameTheme theme;
  final GameSettings settings;
  final Function(GameSettings) onSave;
  final VoidCallback onDismiss;
  final VoidCallback? onOpenThemes;

  const SettingsScreen({
    super.key,
    required this.theme,
    required this.settings,
    required this.onSave,
    required this.onDismiss,
    this.onOpenThemes,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _sound;
  late bool _music;
  late bool _haptics;
  late bool _reducedMotion;

  @override
  void initState() {
    super.initState();
    _sound = widget.settings.soundEnabled;
    _music = widget.settings.musicEnabled;
    _haptics = widget.settings.hapticsEnabled;
    _reducedMotion = widget.settings.reducedMotion;
  }

  void _updateSettings({bool? sound, bool? haptics, bool? motion}) {
    setState(() {
      if (sound != null) {
        _sound = sound;
        _music = sound; // Synchronize music state with sound effects toggle
      }
      if (haptics != null) _haptics = haptics;
      if (motion != null) _reducedMotion = motion;
    });

    final updated = widget.settings.copyWith(
      soundEnabled: _sound,
      musicEnabled: _music,
      hapticsEnabled: _haptics,
      reducedMotion: _reducedMotion,
    );
    widget.onSave(updated);
    MusicService.instance.setMusicEnabled(_music);
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Header Bar matching Reference Screen 8
                Row(
                  children: [
                    // Back Arrow Button
                    GlassIconButton(
                      icon: Icons.arrow_back_rounded,
                      size: 42,
                      iconSize: 20,
                      reducedMotion: _reducedMotion,
                      onTap: widget.onDismiss,
                    ),

                    // Centered 'SETTINGS' Title
                    const Expanded(
                      child: Text(
                        'SETTINGS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.2,
                        ),
                      ),
                    ),

                    const SizedBox(
                        width: 42), // Balances back arrow symmetrically
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Scrollable Settings Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card 1: Sound Effects matching Reference Screen 8
                        _buildSettingCard(
                          icon: Icons.volume_up_rounded,
                          title: 'Sound Effects',
                          value: _sound,
                          onChanged: (val) => _updateSettings(sound: val),
                        ),
                        const SizedBox(height: 12),

                        // Card 2: Haptic Feedback matching Reference Screen 8
                        _buildSettingCard(
                          icon: Icons.vibration_rounded,
                          title: 'Haptic Feedback',
                          value: _haptics,
                          onChanged: (val) => _updateSettings(haptics: val),
                        ),
                        const SizedBox(height: 12),

                        // Card 3: Reduced Motion matching Reference Screen 8
                        _buildSettingCard(
                          icon: Icons.nightlight_round,
                          title: 'Reduced Motion',
                          value: _reducedMotion,
                          onChanged: (val) => _updateSettings(motion: val),
                        ),
                        const SizedBox(height: 32),

                        // THEME Section Header matching Reference Screen 8
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 10),
                          child: Text(
                            'THEME',
                            style: TextStyle(
                              color: Color(0xFFA8C4E4),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.6,
                            ),
                          ),
                        ),

                        // Theme Shortcut Card matching Reference Screen 8
                        GestureDetector(
                          onTap: widget.onOpenThemes,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14284A)
                                  .withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Mini Theme Preview Thumbnail
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0A1832),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: theme.primaryAccent
                                          .withValues(alpha: 0.40),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(13),
                                    child: Image.asset(
                                      theme.previewAssetPath,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(
                                            Icons.palette_rounded,
                                            color: theme.primaryAccent,
                                            size: 24,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Current Theme Labels
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Current Theme',
                                        style: TextStyle(
                                          color: Color(0xFFA8C4E4),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        theme.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Chevron Navigation Indicator
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFFA8C4E4),
                                  size: 26,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Individual Setting Card matching Reference Screen 8
  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Container(
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
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Icon Container matching Reference Screen 8
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1.0,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Setting Label Text
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            // Custom Neon Pill Switch matching Reference Screen 8
            _NeonPillSwitch(
              value: value,
              activeColor: const Color(0xFF13D9FF),
              reducedMotion: _reducedMotion,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Neon Pill Switch matching Reference Screen 8
/// Features electric cyan illuminated track with glowing bloom when active,
/// and smooth sliding pure white circular thumb.
class _NeonPillSwitch extends StatelessWidget {
  final bool value;
  final Color activeColor;
  final bool reducedMotion;
  final ValueChanged<bool> onChanged;

  const _NeonPillSwitch({
    required this.value,
    required this.activeColor,
    required this.reducedMotion,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const double width = 50.0;
    const double height = 28.0;
    const double thumbSize = 22.0;

    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration:
            reducedMotion ? Duration.zero : const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 3.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          gradient: value
              ? LinearGradient(
                  colors: [
                    activeColor,
                    const Color(0xFF347BFF),
                  ],
                )
              : null,
          color: value ? null : const Color(0xFF152A4A),
          border: Border.all(
            color: value
                ? Colors.white.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.15),
            width: 1.0,
          ),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.45),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.30),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: AnimatedAlign(
          duration:
              reducedMotion ? Duration.zero : const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: thumbSize,
            height: thumbSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 4,
                  offset: const Offset(0, 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
