import 'package:flutter/services.dart';
import '../models/game_settings.dart';
import 'sound_synthesizer.dart';

class FeedbackService {
  static bool hapticsEnabled = true;
  static bool soundEnabled = true;

  static void updateSettings(GameSettings settings) {
    hapticsEnabled = settings.hapticsEnabled;
    soundEnabled = settings.soundEnabled;
    SoundSynthesizer.instance.setVolume(settings.soundVolume);
  }

  static void triggerNormalPlacement({
    bool? haptics,
    bool? sound,
    int score = 0,
  }) {
    final useHaptics = haptics ?? hapticsEnabled;
    final useSound = sound ?? soundEnabled;

    if (useHaptics) {
      try {
        // Medium impact provides a distinct, noticeable tactile impulse on all Android devices
        HapticFeedback.mediumImpact();
      } catch (_) {
        HapticFeedback.vibrate();
      }
    }
    if (useSound) {
      try {
        SoundSynthesizer.instance.playNormalPlacement(score);
      } catch (_) {
        SystemSound.play(SystemSoundType.click);
      }
    }
  }

  /// Plays unique feedback for consecutive perfect placements, escalating haptic and procedural musical pitch response
  static void triggerPerfectPlacement({
    bool? haptics,
    bool? sound,
    int streak = 1,
  }) {
    final useHaptics = haptics ?? hapticsEnabled;
    final useSound = sound ?? soundEnabled;

    if (useHaptics) {
      try {
        if (streak >= 5) {
          HapticFeedback.heavyImpact();
        } else if (streak >= 3) {
          HapticFeedback.heavyImpact();
        } else {
          HapticFeedback.mediumImpact();
        }
      } catch (_) {
        HapticFeedback.vibrate();
      }
    }
    if (useSound) {
      try {
        SoundSynthesizer.instance.playPerfectPlacement(streak);
      } catch (_) {
        SystemSound.play(SystemSoundType.click);
      }
    }
  }

  static void triggerGameOver({
    bool? haptics,
    bool? sound,
  }) {
    final useHaptics = haptics ?? hapticsEnabled;
    final useSound = sound ?? soundEnabled;

    if (useHaptics) {
      try {
        HapticFeedback.heavyImpact();
        HapticFeedback.vibrate();
      } catch (_) {
        HapticFeedback.vibrate();
      }
    }
    if (useSound) {
      try {
        SoundSynthesizer.instance.playGameOver();
      } catch (_) {
        SystemSound.play(SystemSoundType.alert);
      }
    }
  }

  static void triggerButtonTap({
    bool? haptics,
    bool? sound,
  }) {
    final useHaptics = haptics ?? hapticsEnabled;
    final useSound = sound ?? soundEnabled;

    if (useHaptics) {
      try {
        HapticFeedback.selectionClick();
      } catch (_) {}
    }
    if (useSound) {
      try {
        SoundSynthesizer.instance.playButton();
      } catch (_) {}
    }
  }

  static void triggerSliderTick() {
    if (hapticsEnabled) {
      try {
        HapticFeedback.selectionClick();
      } catch (_) {}
    }
  }
}
