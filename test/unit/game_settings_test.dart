import 'package:flutter_test/flutter_test.dart';
import 'package:stack_pulse/models/game_settings.dart';

void main() {
  group('GameSettings Tests', () {
    test('Defaults have musicEnabled set to true and default volumes', () {
      const settings = GameSettings();
      expect(settings.musicEnabled, isTrue);
      expect(settings.soundEnabled, isTrue);
      expect(settings.soundVolume, equals(0.8));
      expect(settings.musicVolume, equals(0.5));
      expect(settings.hapticsEnabled, isTrue);
      expect(settings.reducedMotion, isFalse);
    });

    test('copyWith updates musicEnabled and volumes correctly', () {
      const settings = GameSettings();
      final updated = settings.copyWith(
        musicEnabled: false,
        soundVolume: 0.4,
        musicVolume: 0.9,
      );
      expect(updated.musicEnabled, isFalse);
      expect(updated.soundEnabled, isTrue);
      expect(updated.soundVolume, equals(0.4));
      expect(updated.musicVolume, equals(0.9));
    });

    test('JSON serialization preserves musicEnabled and volumes', () {
      const settings = GameSettings(
        musicEnabled: false,
        soundVolume: 0.35,
        musicVolume: 0.75,
      );
      final json = settings.toJson();
      expect(json['musicEnabled'], isFalse);
      expect(json['soundVolume'], equals(0.35));
      expect(json['musicVolume'], equals(0.75));

      final deserialized = GameSettings.fromJson(json);
      expect(deserialized.musicEnabled, isFalse);
      expect(deserialized.soundVolume, equals(0.35));
      expect(deserialized.musicVolume, equals(0.75));
    });
  });
}
