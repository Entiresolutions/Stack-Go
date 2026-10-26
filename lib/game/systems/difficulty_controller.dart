import 'dart:math';
import '../../core/game_config.dart';

class DifficultyController {
  static double calculateSpeed(int score) {
    if (score <= 0) return GameConfig.initialSpeed;
    final int tiers = score ~/ GameConfig.speedStepInterval;
    final double rawSpeed =
        GameConfig.initialSpeed + (tiers * GameConfig.speedIncrementPerStep);
    return min(GameConfig.maxSpeed, rawSpeed);
  }

  static String getStreakBadge(int streak) {
    if (streak >= 10) return 'LEGENDARY!';
    if (streak >= 5) return 'AMAZING!';
    if (streak >= 3) return 'GREAT!';
    if (streak >= 2) return 'NICE!';
    if (streak == 1) return 'PERFECT!';
    return '';
  }
}
