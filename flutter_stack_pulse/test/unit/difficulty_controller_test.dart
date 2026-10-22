import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/game_config.dart';
import '../../lib/game/systems/difficulty_controller.dart';

void main() {
  group('DifficultyController Tests', () {
    test('Initial speed at score 0 equals initialSpeed', () {
      final speed = DifficultyController.calculateSpeed(0);
      expect(speed, equals(GameConfig.initialSpeed));
    });

    test('Speed scales with score linearly', () {
      final speed = DifficultyController.calculateSpeed(10);
      expect(speed, equals(GameConfig.initialSpeed + 10 * 5.0));
    });

    test('Speed is capped at maxSpeed for high scores', () {
      final speed = DifficultyController.calculateSpeed(200);
      expect(speed, equals(GameConfig.maxSpeed));
    });

    test('Streak badges match milestone progression', () {
      expect(DifficultyController.getStreakBadge(1), equals('PERFECT!'));
      expect(DifficultyController.getStreakBadge(2), equals('NICE!'));
      expect(DifficultyController.getStreakBadge(3), equals('GREAT!'));
      expect(DifficultyController.getStreakBadge(5), equals('AMAZING!'));
      expect(DifficultyController.getStreakBadge(10), equals('LEGENDARY!'));
    });
  });
}
