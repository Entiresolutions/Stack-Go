import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_statistics.dart';
import '../models/game_settings.dart';

class LocalStorageService {
  static const _keyStats = 'stack_pulse_statistics';
  static const _keySettings = 'stack_pulse_settings';

  Future<GameStatistics> loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyStats);
    if (data != null) {
      try {
        final map = jsonDecode(data) as Map<String, dynamic>;
        return GameStatistics.fromJson(map);
      } catch (_) {}
    }
    return const GameStatistics();
  }

  Future<void> saveStatistics(GameStatistics stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStats, jsonEncode(stats.toJson()));
  }

  Future<GameSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keySettings);
    if (data != null) {
      try {
        final map = jsonDecode(data) as Map<String, dynamic>;
        return GameSettings.fromJson(map);
      } catch (_) {}
    }
    return const GameSettings();
  }

  Future<void> saveSettings(GameSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettings, jsonEncode(settings.toJson()));
  }
}
