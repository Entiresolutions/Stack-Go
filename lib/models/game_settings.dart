class GameSettings {
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;
  final bool tutorialCompleted;
  final String selectedTheme;

  const GameSettings({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.tutorialCompleted = false,
    this.selectedTheme = 'midnightNeon',
  });

  GameSettings copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? tutorialCompleted,
    String? selectedTheme,
  }) {
    return GameSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
      selectedTheme: selectedTheme ?? this.selectedTheme,
    );
  }

  Map<String, dynamic> toJson() => {
    'soundEnabled': soundEnabled,
    'hapticsEnabled': hapticsEnabled,
    'reducedMotion': reducedMotion,
    'tutorialCompleted': tutorialCompleted,
    'selectedTheme': selectedTheme,
  };

  factory GameSettings.fromJson(Map<String, dynamic> json) => GameSettings(
    soundEnabled: json['soundEnabled'] as bool? ?? true,
    hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
    reducedMotion: json['reducedMotion'] as bool? ?? false,
    tutorialCompleted: json['tutorialCompleted'] as bool? ?? false,
    selectedTheme: json['selectedTheme'] as String? ?? 'midnightNeon',
  );
}
