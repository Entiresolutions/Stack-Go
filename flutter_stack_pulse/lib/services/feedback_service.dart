import 'package:flutter/services.dart';
import 'sound_synthesizer.dart';

class FeedbackService {
  static void triggerNormalPlacement({
    required bool haptics,
    required bool sound,
    int score = 0,
  }) {
    if (haptics) {
      HapticFeedback.lightImpact();
    }
    if (sound) {
      try {
        SoundSynthesizer.instance.playNormalPlacement(score);
      } catch (_) {
        SystemSound.play(SystemSoundType.click);
      }
    }
  }

  /// Plays unique feedback for consecutive perfect placements, escalating haptic and procedural musical pitch response
  static void triggerPerfectPlacement({
    required bool haptics,
    required bool sound,
    int streak = 1,
  }) {
    if (haptics) {
      if (streak >= 5) {
        HapticFeedback.heavyImpact();
      } else if (streak >= 3) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    }
    if (sound) {
      try {
        SoundSynthesizer.instance.playPerfectPlacement(streak);
      } catch (_) {
        SystemSound.play(SystemSoundType.click);
      }
    }
  }

  static void triggerGameOver({
    required bool haptics,
    required bool sound,
  }) {
    if (haptics) {
      HapticFeedback.heavyImpact();
    }
    if (sound) {
      try {
        SoundSynthesizer.instance.playGameOver();
      } catch (_) {
        SystemSound.play(SystemSoundType.alert);
      }
    }
  }

  static void triggerButtonTap({
    required bool haptics,
    required bool sound,
  }) {
    if (haptics) {
      HapticFeedback.selectionClick();
    }
    if (sound) {
      try {
        SoundSynthesizer.instance.playButton();
      } catch (_) {
        SystemSound.play(SystemSoundType.click);
      }
    }
  }
}
