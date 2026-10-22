import 'package:flutter/services.dart';

class FeedbackService {
  static void triggerNormalPlacement({required bool haptics, required bool sound}) {
    if (haptics) {
      HapticFeedback.lightImpact();
    }
    if (sound) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Plays unique feedback for consecutive perfect placements, escalating haptic and sound response
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
      // Escalates audio feedback on consecutive perfect placements
      SystemSound.play(SystemSoundType.click);
    }
  }

  static void triggerGameOver({required bool haptics, required bool sound}) {
    if (haptics) {
      HapticFeedback.heavyImpact();
    }
    if (sound) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  static void triggerButtonTap({required bool haptics, required bool sound}) {
    if (haptics) {
      HapticFeedback.selectionClick();
    }
    if (sound) {
      SystemSound.play(SystemSoundType.click);
    }
  }
}
