import 'package:flutter/material.dart';
import '../../core/game_theme.dart';
import '../../models/game_settings.dart';
import '../widgets/stack_pulse_logo.dart';

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
  late bool _haptics;
  late bool _reducedMotion;

  @override
  void initState() {
    super.initState();
    _sound = widget.settings.soundEnabled;
    _haptics = widget.settings.hapticsEnabled;
    _reducedMotion = widget.settings.reducedMotion;
  }

  void _updateSettings({bool? sound, bool? haptics, bool? motion}) {
    setState(() {
      if (sound != null) _sound = sound;
      if (haptics != null) _haptics = haptics;
      if (motion != null) _reducedMotion = motion;
    });

    final updated = widget.settings.copyWith(
      soundEnabled: _sound,
      hapticsEnabled: _haptics,
      reducedMotion: _reducedMotion,
    );
    widget.onSave(updated);
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Bar matching Reference Screen 8
                Row(
                  children: [
                    // Back Arrow
                    GestureDetector(
                      onTap: widget.onDismiss,
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
                        'SETTINGS',
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
                const SizedBox(height: 28),

                // Grouped Settings Card matching Reference Screen 8
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF14284A).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildRow(
                        icon: Icons.volume_up_rounded,
                        label: 'Sound Effects',
                        value: _sound,
                        onChanged: (val) => _updateSettings(sound: val),
                      ),
                      _buildDivider(),
                      _buildRow(
                        icon: Icons.vibration_rounded,
                        label: 'Haptic Feedback',
                        value: _haptics,
                        onChanged: (val) => _updateSettings(haptics: val),
                      ),
                      _buildDivider(),
                      _buildRow(
                        icon: Icons.nightlight_round,
                        label: 'Reduced Motion',
                        value: _reducedMotion,
                        onChanged: (val) => _updateSettings(motion: val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // THEME Section Header
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    'THEME',
                    style: TextStyle(
                      color: Color(0xFFA8C4E4),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                // Theme Selection Card matching Reference Screen 8
                GestureDetector(
                  onTap: widget.onOpenThemes,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14284A).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.30),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Mini 3-pill emblem
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF061225).withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: StackPulseLogo(
                              scale: 0.60,
                              showText: false,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Current Theme Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Theme',
                                style: TextStyle(
                                  color: Color(0xFFA8C4E4),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                theme.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Chevron
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFFA8C4E4),
                          size: 24,
                        ),
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

  Widget _buildRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF13D9FF),
            inactiveThumbColor: const Color(0xFFA8C4E4),
            inactiveTrackColor: const Color(0xFF0B1B38),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1.0,
      color: Colors.white.withValues(alpha: 0.07),
    );
  }
}
