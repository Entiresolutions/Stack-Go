import 'package:flutter_test/flutter_test.dart';
import 'package:stack_pulse/core/game_config.dart';
import 'package:stack_pulse/game/systems/difficulty_controller.dart';

void main() {
  group('DifficultyController Tests', () {
    test('Initial speed at score 0 equals initialSpeed (170)', () {
      final speed = DifficultyController.calculateSpeed(0);
      expect(speed, equals(GameConfig.initialSpeed));
      expect(speed, equals(170.0));
    });

    test('Speed remains 170 for scores under 5', () {
      expect(DifficultyController.calculateSpeed(1), equals(170.0));
      expect(DifficultyController.calculateSpeed(4), equals(170.0));
    });

    test('Speed increases by 15px every 5 score increments', () {
      expect(DifficultyController.calculateSpeed(5), equals(185.0));
      expect(DifficultyController.calculateSpeed(9), equals(185.0));
      expect(DifficultyController.calculateSpeed(10), equals(200.0));
      expect(DifficultyController.calculateSpeed(15), equals(215.0));
      expect(DifficultyController.calculateSpeed(20), equals(230.0));
    });

    test('Speed is capped at maxSpeed (320) and never increases beyond it', () {
      expect(DifficultyController.calculateSpeed(50), equals(320.0));
      expect(DifficultyController.calculateSpeed(55), equals(320.0));
      expect(DifficultyController.calculateSpeed(100), equals(320.0));
      expect(DifficultyController.calculateSpeed(200), equals(320.0));
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
