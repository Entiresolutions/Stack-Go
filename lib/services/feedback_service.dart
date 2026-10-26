import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/game_settings.dart';
import 'sound_synthesizer.dart';

class FeedbackService {
  static const MethodChannel _hapticChannel =
      MethodChannel('com.stackpulse.game/haptics');

  static bool hapticsEnabled = true;
  static bool soundEnabled = true;

  static void updateSettings(GameSettings settings) {
    hapticsEnabled = settings.hapticsEnabled;
    soundEnabled = settings.soundEnabled;
    SoundSynthesizer.instance.setVolume(settings.soundVolume);
  }

  static Future<void> _vibrate({
    required int duration,
    required int amplitude,
  }) async {
    if (!hapticsEnabled) return;

    bool nativeSuccess = false;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final success = await _hapticChannel.invokeMethod<bool>('vibrate', {
          'duration': duration,
          'amplitude': amplitude,
        });
        nativeSuccess = (success == true);
      } catch (_) {}
    }

    // Direct hardware motor fallback (guarantees physical vibration even if native channel is not yet built)
    if (!nativeSuccess) {
      try {
        await HapticFeedback.heavyImpact();
        await HapticFeedback.vibrate();
      } catch (_) {}
    }
  }

  static void triggerNormalPlacement({
    bool? haptics,
    bool? sound,
    int score = 0,
  }) {
    final useHaptics = haptics ?? hapticsEnabled;
    final useSound = sound ?? soundEnabled;

    if (useHaptics) {
      _vibrate(duration: 75, amplitude: 255);
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
      if (streak >= 7) {
        _vibrate(duration: 180, amplitude: 255);
      } else if (streak >= 4) {
        _vibrate(duration: 130, amplitude: 255);
      } else {
        _vibrate(duration: 90, amplitude: 255);
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
      _vibrate(duration: 260, amplitude: 255);
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
      _vibrate(duration: 45, amplitude: 255);
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
      _vibrate(duration: 35, amplitude: 255);
    }
  }
}
