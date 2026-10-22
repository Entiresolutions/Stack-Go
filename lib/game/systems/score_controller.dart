class ScoreController {
  int _currentScore = 0;
  int _currentStreak = 0;
  int _bestStreakInRun = 0;

  int get currentScore => _currentScore;
  int get currentStreak => _currentStreak;
  int get bestStreakInRun => _bestStreakInRun;

  void reset() {
    _currentScore = 0;
    _currentStreak = 0;
    _bestStreakInRun = 0;
  }

  void recordPlacement({required bool isPerfect}) {
    _currentScore++;
    if (isPerfect) {
      _currentStreak++;
      if (_currentStreak > _bestStreakInRun) {
        _bestStreakInRun = _currentStreak;
      }
    } else {
      _currentStreak = 0;
    }
  }
}
