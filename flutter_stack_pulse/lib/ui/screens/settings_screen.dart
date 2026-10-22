import 'package:flutter/material.dart';
import '../../core/game_theme.dart';
import '../../models/game_settings.dart';
import '../widgets/premium_button.dart';

class SettingsScreen extends StatefulWidget {
  final GameTheme theme;
  final GameSettings settings;
  final Function(GameSettings) onSave;
  final VoidCallback onDismiss;

  const SettingsScreen({
    super.key,
    required this.theme,
    required this.settings,
    required this.onSave,
    required this.onDismiss,
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

  void _applyChanges() {
    final updated = widget.settings.copyWith(
      soundEnabled: _sound,
      hapticsEnabled: _haptics,
      reducedMotion: _reducedMotion,
    );
    widget.onSave(updated);
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SETTINGS',
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.text),
                    onPressed: widget.onDismiss,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _switchTile(
                title: 'Sound Effects',
                subtitle: 'Auditory feedback on placement, streak combos and game over',
                value: _sound,
                icon: Icons.volume_up_rounded,
                onChanged: (val) => setState(() => _sound = val),
                theme: theme,
              ),
              const SizedBox(height: 16),
              _switchTile(
                title: 'Haptic Feedback',
                subtitle: 'Vibrations when snapping blocks and achieving perfect streaks',
                value: _haptics,
                icon: Icons.vibration_rounded,
                onChanged: (val) => setState(() => _haptics = val),
                theme: theme,
              ),
              const SizedBox(height: 16),
              _switchTile(
                title: 'Reduced Motion',
                subtitle: 'Minimizes particle fireworks and screen shake effects',
                value: _reducedMotion,
                icon: Icons.motion_photos_off_rounded,
                onChanged: (val) => setState(() => _reducedMotion = val),
                theme: theme,
              ),
              const Spacer(),
              PremiumButton(
                label: 'SAVE SETTINGS',
                isPrimary: true,
                customAccent: theme.primaryAccent,
                onTap: _applyChanges,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
    required GameTheme theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.primaryAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: theme.primaryAccent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: theme.secondaryText,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: theme.primaryAccent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
