class GameSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final double soundVolume;
  final double musicVolume;
  final bool hapticsEnabled;
  final bool reducedMotion;
  final bool tutorialCompleted;
  final String selectedTheme;

  const GameSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.soundVolume = 0.8,
    this.musicVolume = 0.5,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.tutorialCompleted = false,
    this.selectedTheme = 'midnightNeon',
  });

  GameSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    double? soundVolume,
    double? musicVolume,
    bool? hapticsEnabled,
    bool? reducedMotion,
    bool? tutorialCompleted,
    String? selectedTheme,
  }) {
    return GameSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
      selectedTheme: selectedTheme ?? this.selectedTheme,
    );
  }

  Map<String, dynamic> toJson() => {
        'soundEnabled': soundEnabled,
        'musicEnabled': musicEnabled,
        'soundVolume': soundVolume,
        'musicVolume': musicVolume,
        'hapticsEnabled': hapticsEnabled,
        'reducedMotion': reducedMotion,
        'tutorialCompleted': tutorialCompleted,
        'selectedTheme': selectedTheme,
      };

  factory GameSettings.fromJson(Map<String, dynamic> json) => GameSettings(
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        musicEnabled: json['musicEnabled'] as bool? ?? true,
        soundVolume: (json['soundVolume'] as num?)?.toDouble() ?? 0.8,
        musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.5,
        hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
        reducedMotion: json['reducedMotion'] as bool? ?? false,
        tutorialCompleted: json['tutorialCompleted'] as bool? ?? false,
        selectedTheme: json['selectedTheme'] as String? ?? 'midnightNeon',
      );
}
