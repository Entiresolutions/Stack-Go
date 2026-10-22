class GameStatistics {
  final int bestScore;
  final int bestStreak;
  final int totalGamesPlayed;
  final int totalBlocksPlaced;
  final int totalPerfectPlacements;

  const GameStatistics({
    this.bestScore = 0,
    this.bestStreak = 0,
    this.totalGamesPlayed = 0,
    this.totalBlocksPlaced = 0,
    this.totalPerfectPlacements = 0,
  });

  GameStatistics copyWith({
    int? bestScore,
    int? bestStreak,
    int? totalGamesPlayed,
    int? totalBlocksPlaced,
    int? totalPerfectPlacements,
  }) {
    return GameStatistics(
      bestScore: bestScore ?? this.bestScore,
      bestStreak: bestStreak ?? this.bestStreak,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalBlocksPlaced: totalBlocksPlaced ?? this.totalBlocksPlaced,
      totalPerfectPlacements: totalPerfectPlacements ?? this.totalPerfectPlacements,
    );
  }

  Map<String, dynamic> toJson() => {
    'bestScore': bestScore,
    'bestStreak': bestStreak,
    'totalGamesPlayed': totalGamesPlayed,
    'totalBlocksPlaced': totalBlocksPlaced,
    'totalPerfectPlacements': totalPerfectPlacements,
  };

  factory GameStatistics.fromJson(Map<String, dynamic> json) => GameStatistics(
    bestScore: json['bestScore'] as int? ?? 0,
    bestStreak: json['bestStreak'] as int? ?? 0,
    totalGamesPlayed: json['totalGamesPlayed'] as int? ?? 0,
    totalBlocksPlaced: json['totalBlocksPlaced'] as int? ?? 0,
    totalPerfectPlacements: json['totalPerfectPlacements'] as int? ?? 0,
  );
}
