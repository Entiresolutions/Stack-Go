import 'package:flutter_test/flutter_test.dart';
import 'package:stack_pulse/models/game_settings.dart';

void main() {
  group('GameSettings Tests', () {
    test('Defaults have musicEnabled set to true', () {
      const settings = GameSettings();
      expect(settings.musicEnabled, isTrue);
      expect(settings.soundEnabled, isTrue);
      expect(settings.hapticsEnabled, isTrue);
      expect(settings.reducedMotion, isFalse);
    });

    test('copyWith updates musicEnabled correctly', () {
      const settings = GameSettings();
      final updated = settings.copyWith(musicEnabled: false);
      expect(updated.musicEnabled, isFalse);
      expect(updated.soundEnabled, isTrue);
    });

    test('JSON serialization preserves musicEnabled', () {
      const settings = GameSettings(musicEnabled: false);
      final json = settings.toJson();
      expect(json['musicEnabled'], isFalse);

      final deserialized = GameSettings.fromJson(json);
      expect(deserialized.musicEnabled, isFalse);
    });
  });
}
