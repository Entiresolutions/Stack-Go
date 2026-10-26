import 'package:flutter/material.dart';

enum ThemeType {
  midnightNeon,
  aurora,
  sunsetPulse,
  arcticGlow,
  sakuraDrift,
  abyssalDepths,
  retroGrid,
  emberCore,
  celestialObservatory,
  prismRift,
}

enum ThemeTier {
  core, // Themes 1–4
  advanced, // Themes 5–7
  prestige, // Themes 8–10
}

/// Dedicated animation engine types for the 10 living gameplay environments
enum AmbientAnimationType {
  cyberBeams, // Midnight Neon
  auroraCurtains, // Aurora
  sunsetClouds, // Sunset Pulse
  arcticSnowfall, // Arctic Glow
  sakuraWind, // Sakura Drift
  abyssalCaustics, // Abyssal Depths
  synthwaveGrid, // Retro Grid
  moltenEmbers, // Ember Core
  celestialConstellations, // Celestial Observatory
  prismaticRefractions, // Prism Rift
}

/// Data-driven configuration defining theme-specific environmental animation parameters
class ThemeAnimationConfig {
  final AmbientAnimationType type;
  final double baseSpeed;
  final double particleDensity;
  final double reactiveIntensity;
  final List<Color> ambientPalette;
  final String effectDescription;

  const ThemeAnimationConfig({
    required this.type,
    this.baseSpeed = 1.0,
    this.particleDensity = 1.0,
    this.reactiveIntensity = 1.0,
    required this.ambientPalette,
    required this.effectDescription,
  });
}

/// Centralized Single Source of Truth for all Stack Pulse styling, palettes,
/// semantic tokens, and visual effects across Flutter UI and Flame rendering.
class GameTheme {
  final ThemeType type;
  final String name;
  final String description;
  final int unlockScore;
  final int unlockPlacements;
  final ThemeTier tier;

  // Background tokens
  final Color background;
  final Color secondaryBackground;

  // Surface tokens
  final Color surface;
  final Color surfaceElevated;

  // Accent tokens
  final Color primaryAccent; // Electric Cyan #13D9FF
  final Color neonBlue; // Neon Blue #347BFF
  final Color secondaryAccent; // Electric Purple #9658FF
  final Color neonMagenta; // Neon Magenta #F34BEA
  final Color mintAccent; // Mint #14E4C5
  final Color orangeAccent; // Orange #FF995B
  final Color goldAccent; // Gold #FFCB78
  final Color successAccent;
  final Color warningAccent;

  // Typography tokens
  final Color text;
  final Color secondaryText;
  final Color mutedText;

  // Block palette
  final List<Color> blockPalette;

  const GameTheme({
    required this.type,
    required this.name,
    required this.description,
    required this.unlockScore,
    this.unlockPlacements = 0,
    this.tier = ThemeTier.core,
    required this.background,
    required this.secondaryBackground,
    required this.surface,
    required this.surfaceElevated,
    required this.primaryAccent,
    required this.neonBlue,
    required this.secondaryAccent,
    required this.neonMagenta,
    required this.mintAccent,
    required this.orangeAccent,
    required this.goldAccent,
    required this.successAccent,
    required this.warningAccent,
    required this.text,
    required this.secondaryText,
    required this.mutedText,
    required this.blockPalette,
  });

  // ==========================================
  // SEMANTIC GRADIENTS & SURFACE HELPERS
  // ==========================================

  /// Deep immersive background gradient
  LinearGradient get backgroundGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          secondaryBackground,
          background,
        ],
      );

  /// Dynamic card/elevated surface gradient
  LinearGradient get surfaceGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          surfaceElevated,
          surface,
        ],
      );

  /// Reference signature CTA button gradient: Electric Cyan to Electric Purple
  LinearGradient get primaryButtonGradient => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF13D9FF),
          Color(0xFF347BFF),
          Color(0xFF9658FF),
        ],
      );

  /// Game Over RETRY button signature 4-stop gradient: Cyan -> Blue -> Purple -> Magenta
  LinearGradient get retryButtonGradient => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF13D9FF),
          Color(0xFF347BFF),
          Color(0xFF9658FF),
          Color(0xFFF34BEA),
        ],
      );

  /// Game Over Title gradient: Neon Magenta to Electric Purple
  LinearGradient get gameOverHeadingGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF34BEA),
          Color(0xFF9658FF),
        ],
      );

  /// Pause RESUME button gradient: Electric Cyan to Electric Purple
  LinearGradient get resumeButtonGradient => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF20BAFF),
          Color(0xFF4B79FF),
          Color(0xFF9B50FF),
        ],
      );

  /// Modal and card surfaces for Pause and Game Over
  Color get pauseModalBackground =>
      const Color(0xFF0D1B36).withValues(alpha: 0.94);
  Color get scoreCardBackground =>
      const Color(0xFF102242).withValues(alpha: 0.92);
  Color get secondaryPillSurface =>
      const Color(0xFF152A50).withValues(alpha: 0.90);

  /// Vibrant dual-tone accent gradient
  LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryAccent,
          secondaryAccent,
        ],
      );

  /// Subtle glassmorphic sheen gradient
  LinearGradient get glassSheenGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.14),
          Colors.white.withValues(alpha: 0.02),
        ],
      );

  // Borders & Outlines
  Color get surfaceBorder => Colors.white.withValues(alpha: 0.12);
  Color get subtleBorder => Colors.white.withValues(alpha: 0.06);
  Color get activeBorder => primaryAccent;

  // Shadows & Glows
  Color get cardGlow => primaryAccent.withValues(alpha: 0.25);
  Color get softShadow => Colors.black.withValues(alpha: 0.50);

  List<BoxShadow> get buttonGlow => [
        BoxShadow(
          color: primaryAccent.withValues(alpha: 0.45),
          blurRadius: 22,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: secondaryAccent.withValues(alpha: 0.35),
          blurRadius: 26,
          offset: const Offset(0, 6),
        ),
      ];

  List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.40),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  List<BoxShadow> get modalShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.75),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: primaryAccent.withValues(alpha: 0.18),
          blurRadius: 30,
          offset: const Offset(0, 4),
        ),
      ];

  // Gameplay specific tokens
  Color get gridLineColor => Colors.white.withValues(alpha: 0.025);
  Color get pedestalColor => surface;
  Color get pedestalBorderColor => primaryAccent.withValues(alpha: 0.40);
  Color get blockHighlight => Colors.white.withValues(alpha: 0.45);
  Color get blockOutline => Colors.white.withValues(alpha: 0.25);

  // ==========================================
  // THEME DEFINITIONS: EXACT REFERENCE
  // ==========================================

  /// Midnight Neon: Electric cyan, neon blue, electric purple, neon magenta
  static const GameTheme midnightNeon = GameTheme(
    type: ThemeType.midnightNeon,
    name: 'Midnight Neon',
    description: 'Electric cyan and violet pulses against deep midnight navy.',
    unlockScore: 0,
    background: Color(0xFF061225),
    secondaryBackground: Color(0xFF0B1B38),
    surface: Color(0xFF14284A),
    surfaceElevated: Color(0xFF1D3560),
    primaryAccent: Color(0xFF13D9FF), // Electric Cyan
    neonBlue: Color(0xFF347BFF), // Neon Blue
    secondaryAccent: Color(0xFF9658FF), // Electric Purple
    neonMagenta: Color(0xFFF34BEA), // Neon Magenta
    mintAccent: Color(0xFF14E4C5), // Mint
    orangeAccent: Color(0xFFFF995B), // Orange
    goldAccent: Color(0xFFFFCB78), // Gold
    successAccent: Color(0xFF14E4C5),
    warningAccent: Color(0xFFFFCB78),
    text: Color(0xFFFFFFFF),
    secondaryText: Color(0xFFA8C4E4),
    mutedText: Color(0xFF6B8DB5),
    blockPalette: [
      Color(0xFF00E5FF), // 0: Vibrant Electric Cyan
      Color(0xFF2979FF), // 1: Electric Royal Blue
      Color(0xFF7C4DFF), // 2: Vivid Purple
      Color(0xFFE040FB), // 3: Bright Neon Magenta
      Color(0xFFFF1744), // 4: Hot Coral Pink
      Color(0xFFFF6D00), // 5: Sunset Orange
      Color(0xFFFFD600), // 6: Radiant Gold
      Color(0xFF00E676), // 7: Bright Emerald Green
      Color(0xFF1DE9B6), // 8: Mint Turquoise
      Color(0xFF00B0FF), // 9: Bright Cerulean Blue
      Color(0xFF651FFF), // 10: Deep Indigo
      Color(0xFFFF4081), // 11: Vivid Rose Pink
    ],
  );

  /// Aurora: Mint, turquoise, emerald, deep polar green
  static const GameTheme aurora = GameTheme(
    type: ThemeType.aurora,
    name: 'Aurora',
    description:
        'Ethereal emerald and turquoise shimmering in arctic polar skies.',
    unlockScore: 10,
    background: Color(0xFF041A18),
    secondaryBackground: Color(0xFF082C27),
    surface: Color(0xFF0E3D36),
    surfaceElevated: Color(0xFF15544B),
    primaryAccent: Color(0xFF14E4C5), // Mint
    neonBlue: Color(0xFF06B6D4), // Cyan
    secondaryAccent: Color(0xFF2DD4BF), // Turquoise
    neonMagenta: Color(0xFF6EE7B7), // Light Mint
    mintAccent: Color(0xFF14E4C5),
    orangeAccent: Color(0xFFFCD34D),
    goldAccent: Color(0xFFFCD34D),
    successAccent: Color(0xFF14E4C5),
    warningAccent: Color(0xFFFCD34D),
    text: Color(0xFFF0FDF4),
    secondaryText: Color(0xFF9AE6CB),
    mutedText: Color(0xFF5B9E87),
    blockPalette: [
      Color(0xFF14E4C5), // Mint
      Color(0xFF2DD4BF), // Turquoise
      Color(0xFF34D399), // Polar Green
      Color(0xFF10B981), // Emerald
      Color(0xFF06B6D4), // Cyan
      Color(0xFF6EE7B7), // Soft Polar
    ],
  );

  /// Sunset Pulse: Vibrant orange, coral, magenta, velvet violet
  static const GameTheme sunsetPulse = GameTheme(
    type: ThemeType.sunsetPulse,
    name: 'Sunset Pulse',
    description: 'Vibrant amber, radiant coral and velvet violet horizons.',
    unlockScore: 25,
    background: Color(0xFF1F0A1E),
    secondaryBackground: Color(0xFF351133),
    surface: Color(0xFF4A1847),
    surfaceElevated: Color(0xFF63205E),
    primaryAccent: Color(0xFFFF995B), // Neon Orange
    neonBlue: Color(0xFFE040FB), // Magenta
    secondaryAccent: Color(0xFFF34BEA), // Neon Magenta
    neonMagenta: Color(0xFF9658FF), // Electric Purple
    mintAccent: Color(0xFFFFAB91),
    orangeAccent: Color(0xFFFF995B),
    goldAccent: Color(0xFFFFD54F),
    successAccent: Color(0xFFFF5252),
    warningAccent: Color(0xFFFFB74D),
    text: Color(0xFFFFF0F5),
    secondaryText: Color(0xFFE8BCE0),
    mutedText: Color(0xFFA1729B),
    blockPalette: [
      Color(0xFFFF995B), // Neon Orange
      Color(0xFFFF7043), // Coral
      Color(0xFFFF4081), // Vivid Pink
      Color(0xFFF34BEA), // Neon Magenta
      Color(0xFF9658FF), // Electric Purple
      Color(0xFFFFB300), // Sunset Gold
    ],
  );

  /// Arctic Glow: Glacial ice cyan, frost crystal, sapphire, deep ocean
  static const GameTheme arcticGlow = GameTheme(
    type: ThemeType.arcticGlow,
    name: 'Arctic Glow',
    description:
        'Pristine glacial ice, deep oceanic sapphire and frost crystal white.',
    unlockScore: 50,
    background: Color(0xFF05152B),
    secondaryBackground: Color(0xFF0A2445),
    surface: Color(0xFF10335E),
    surfaceElevated: Color(0xFF174780),
    primaryAccent: Color(0xFF38BDF8), // Glacial Cyan
    neonBlue: Color(0xFF347BFF), // Neon Blue
    secondaryAccent: Color(0xFF818CF8), // Frost Indigo
    neonMagenta: Color(0xFF7DD3FC), // Polar Ice
    mintAccent: Color(0xFF7DD3FC),
    orangeAccent: Color(0xFFFDE68A),
    goldAccent: Color(0xFFFDE68A),
    successAccent: Color(0xFF38BDF8),
    warningAccent: Color(0xFFFDE68A),
    text: Color(0xFFF8FAFC),
    secondaryText: Color(0xFFB5D4F5),
    mutedText: Color(0xFF6E95C2),
    blockPalette: [
      Color(0xFFE0F2FE), // Glacial White/Ice
      Color(0xFF7DD3FC), // Polar Ice
      Color(0xFF38BDF8), // Glacial Cyan
      Color(0xFF347BFF), // Neon Blue
      Color(0xFF818CF8), // Frost Indigo
      Color(0xFF0284C7), // Deep Ocean
    ],
  );

  /// Sakura Drift: Sakura pink, soft lavender, deep mauve, lantern amber
  static const GameTheme sakuraDrift = GameTheme(
    type: ThemeType.sakuraDrift,
    name: 'Sakura Drift',
    description:
        'Peaceful nighttime sanctuary of fluttering pink cherry blossoms and warm lantern light.',
    unlockScore: 0,
    unlockPlacements: 100,
    tier: ThemeTier.advanced,
    background: Color(0xFF0D0B1C),
    secondaryBackground: Color(0xFF1A1230),
    surface: Color(0xFF271B42),
    surfaceElevated: Color(0xFF38265E),
    primaryAccent: Color(0xFFFF7EB6), // Sakura Pink
    neonBlue: Color(0xFFC084FC), // Soft Lavender
    secondaryAccent: Color(0xFFA855F7), // Deep Mauve
    neonMagenta: Color(0xFFFDA4AF), // Soft Rose
    mintAccent: Color(0xFFFFD166), // Lantern Amber
    orangeAccent: Color(0xFFFF9E7D),
    goldAccent: Color(0xFFFDE047),
    successAccent: Color(0xFFFF7EB6),
    warningAccent: Color(0xFFFFD166),
    text: Color(0xFFFFF1F2),
    secondaryText: Color(0xFFE2C4D8),
    mutedText: Color(0xFF9B7B94),
    blockPalette: [
      Color(0xFFFF7EB6), // Sakura Pink
      Color(0xFFFDA4AF), // Soft Rose
      Color(0xFFC084FC), // Soft Lavender
      Color(0xFFA855F7), // Deep Mauve
      Color(0xFFFFD166), // Lantern Amber
      Color(0xFFFFF1F2), // Blossom White
    ],
  );

  /// Abyssal Depths: Bioluminescent aqua, electric marine, abyssal cyan, coral glow
  static const GameTheme abyssalDepths = GameTheme(
    type: ThemeType.abyssalDepths,
    name: 'Abyssal Depths',
    description:
        'Deep oceanic trench glowing with bioluminescent aqua and vibrant deep-sea coral.',
    unlockScore: 0,
    unlockPlacements: 250,
    tier: ThemeTier.advanced,
    background: Color(0xFF030F1F),
    secondaryBackground: Color(0xFF061D36),
    surface: Color(0xFF0A2D52),
    surfaceElevated: Color(0xFF0F3E70),
    primaryAccent: Color(0xFF00F5D4), // Bioluminescent Aqua
    neonBlue: Color(0xFF00BBF9), // Electric Marine
    secondaryAccent: Color(0xFF38BDF8), // Abyssal Cyan
    neonMagenta: Color(0xFFF15BB5), // Deep-sea Coral Pink
    mintAccent: Color(0xFF00F5D4),
    orangeAccent: Color(0xFFFF9F1C),
    goldAccent: Color(0xFFFEE440),
    successAccent: Color(0xFF00F5D4),
    warningAccent: Color(0xFFFF9F1C),
    text: Color(0xFFF0FDFA),
    secondaryText: Color(0xFF99E6E6),
    mutedText: Color(0xFF5394A0),
    blockPalette: [
      Color(0xFF00F5D4), // Bioluminescent Aqua
      Color(0xFF00BBF9), // Electric Marine
      Color(0xFF38BDF8), // Abyssal Cyan
      Color(0xFFF15BB5), // Coral Glow
      Color(0xFF7B2CBF), // Deep Violet
      Color(0xFF5EEAD4), // Seafoam Aqua
    ],
  );

  /// Retro Grid: Hot neon pink, synthwave cyan, laser violet, neon yellow
  static const GameTheme retroGrid = GameTheme(
    type: ThemeType.retroGrid,
    name: 'Retro Grid',
    description:
        '80s digital synthwave wireframe universe with laser magenta and neon cyan horizons.',
    unlockScore: 0,
    unlockPlacements: 450,
    tier: ThemeTier.advanced,
    background: Color(0xFF120826),
    secondaryBackground: Color(0xFF210C3D),
    surface: Color(0xFF32135C),
    surfaceElevated: Color(0xFF451A7E),
    primaryAccent: Color(0xFFFF007F), // Hot Neon Pink
    neonBlue: Color(0xFF00F0FF), // Synthwave Cyan
    secondaryAccent: Color(0xFF9D00FF), // Laser Violet
    neonMagenta: Color(0xFFFF00AA), // Vivid Magenta
    mintAccent: Color(0xFF00F0FF),
    orangeAccent: Color(0xFFFF5400),
    goldAccent: Color(0xFFFFE600), // Neon Yellow
    successAccent: Color(0xFF00F0FF),
    warningAccent: Color(0xFFFFE600),
    text: Color(0xFFFDF4FF),
    secondaryText: Color(0xFFE2B6FF),
    mutedText: Color(0xFF9369BA),
    blockPalette: [
      Color(0xFFFF007F), // Hot Neon Pink
      Color(0xFF00F0FF), // Synthwave Cyan
      Color(0xFF9D00FF), // Laser Violet
      Color(0xFFFFE600), // Laser Yellow
      Color(0xFFFF00AA), // Vivid Magenta
      Color(0xFF3A86FF), // Cyber Blue
    ],
  );

  /// Ember Core: Molten lava orange, blazing gold amber, magma red, smoldering coral
  static const GameTheme emberCore = GameTheme(
    type: ThemeType.emberCore,
    name: 'Ember Core',
    description:
        'Dark volcanic obsidian forge illuminated by molten magma veins and rising embers.',
    unlockScore: 0,
    unlockPlacements: 700,
    tier: ThemeTier.prestige,
    background: Color(0xFF140707),
    secondaryBackground: Color(0xFF260D0D),
    surface: Color(0xFF3B1414),
    surfaceElevated: Color(0xFF521C1C),
    primaryAccent: Color(0xFFFF5400), // Molten Lava Orange
    neonBlue: Color(0xFFFF758F), // Smoldering Coral
    secondaryAccent: Color(0xFFFFB703), // Blazing Gold Amber
    neonMagenta: Color(0xFFE63946), // Magma Red
    mintAccent: Color(0xFFFFB703),
    orangeAccent: Color(0xFFFF5400),
    goldAccent: Color(0xFFFFB703),
    successAccent: Color(0xFFFF5400),
    warningAccent: Color(0xFFFFB703),
    text: Color(0xFFFFF7ED),
    secondaryText: Color(0xFFE6B8A2),
    mutedText: Color(0xFF9C6652),
    blockPalette: [
      Color(0xFFFF5400), // Molten Orange
      Color(0xFFFFB703), // Blazing Gold
      Color(0xFFE63946), // Magma Red
      Color(0xFFFF758F), // Smoldering Coral
      Color(0xFFF77F00), // Lava Amber
      Color(0xFFFF9E00), // Golden Flare
    ],
  );

  /// Celestial Observatory: Celestial gold, starlight cyan, stellar white, twilight mauve
  static const GameTheme celestialObservatory = GameTheme(
    type: ThemeType.celestialObservatory,
    name: 'Celestial Observatory',
    description:
        'Royal midnight cosmos adorned with fine golden constellation charts and astrological armillaries.',
    unlockScore: 0,
    unlockPlacements: 1000,
    tier: ThemeTier.prestige,
    background: Color(0xFF070B1E),
    secondaryBackground: Color(0xFF0E1638),
    surface: Color(0xFF162252),
    surfaceElevated: Color(0xFF1F3070),
    primaryAccent: Color(0xFFFFD166), // Celestial Gold
    neonBlue: Color(0xFFA0C4FF), // Starlight Cyan
    secondaryAccent: Color(0xFFBDB2FF), // Twilight Mauve
    neonMagenta: Color(0xFFFFC6FF), // Nebula Pink
    mintAccent: Color(0xFFA0C4FF),
    orangeAccent: Color(0xFFFFB703),
    goldAccent: Color(0xFFFFD166),
    successAccent: Color(0xFFFFD166),
    warningAccent: Color(0xFFFFD166),
    text: Color(0xFFFFFBEB),
    secondaryText: Color(0xFFD6D1E6),
    mutedText: Color(0xFF8882A6),
    blockPalette: [
      Color(0xFFFFD166), // Celestial Gold
      Color(0xFFA0C4FF), // Starlight Cyan
      Color(0xFFBDB2FF), // Twilight Mauve
      Color(0xFFEBF4F6), // Stellar White
      Color(0xFFFFC6FF), // Nebula Pink
      Color(0xFF3A86FF), // Astral Blue
    ],
  );

  /// Prism Rift: Spectral cyan, prismatic violet, laser magenta, pure prism white
  static const GameTheme prismRift = GameTheme(
    type: ThemeType.prismRift,
    name: 'Prism Rift',
    description:
        'Mysterious dimensional fracture with multi-spectral crystalline refraction and prismatic radiance.',
    unlockScore: 0,
    unlockPlacements: 1500,
    tier: ThemeTier.prestige,
    background: Color(0xFF0A0618),
    secondaryBackground: Color(0xFF150C2E),
    surface: Color(0xFF221447),
    surfaceElevated: Color(0xFF321D63),
    primaryAccent: Color(0xFFC77DFF), // Prismatic Violet
    neonBlue: Color(0xFF70D6FF), // Spectral Cyan
    secondaryAccent: Color(0xFFFF70A6), // Laser Magenta
    neonMagenta: Color(0xFFFF9770), // Prism Coral
    mintAccent: Color(0xFF7AE582), // Hologram Mint
    orangeAccent: Color(0xFFFF9770),
    goldAccent: Color(0xFFFFD670),
    successAccent: Color(0xFF70D6FF),
    warningAccent: Color(0xFFFFD670),
    text: Color(0xFFFAFAFA),
    secondaryText: Color(0xFFDFCCF5),
    mutedText: Color(0xFF8F76AD),
    blockPalette: [
      Color(0xFF70D6FF), // Spectral Cyan
      Color(0xFFC77DFF), // Prismatic Violet
      Color(0xFFFF70A6), // Laser Magenta
      Color(0xFFFFFFFF), // Pure Prism White
      Color(0xFF7AE582), // Hologram Mint
      Color(0xFFFFD670), // Rainbow Gold
    ],
  );

  static const List<GameTheme> allThemes = [
    midnightNeon,
    aurora,
    sunsetPulse,
    arcticGlow,
    sakuraDrift,
    abyssalDepths,
    retroGrid,
    emberCore,
    celestialObservatory,
    prismRift,
  ];

  static GameTheme fromType(ThemeType type) {
    switch (type) {
      case ThemeType.aurora:
        return aurora;
      case ThemeType.sunsetPulse:
        return sunsetPulse;
      case ThemeType.arcticGlow:
        return arcticGlow;
      case ThemeType.midnightNeon:
        return midnightNeon;
      case ThemeType.sakuraDrift:
        return sakuraDrift;
      case ThemeType.abyssalDepths:
        return abyssalDepths;
      case ThemeType.retroGrid:
        return retroGrid;
      case ThemeType.emberCore:
        return emberCore;
      case ThemeType.celestialObservatory:
        return celestialObservatory;
      case ThemeType.prismRift:
        return prismRift;
    }
  }

  Color getBlockColor(int index) {
    return blockPalette[index % blockPalette.length];
  }

  /// Path to the dedicated 3D isometric theme preview asset
  String get previewAssetPath {
    switch (type) {
      case ThemeType.midnightNeon:
        return 'assets/images/theme_preview_midnight.jpg';
      case ThemeType.aurora:
        return 'assets/images/theme_preview_aurora.jpg';
      case ThemeType.sunsetPulse:
        return 'assets/images/theme_preview_sunset.jpg';
      case ThemeType.arcticGlow:
        return 'assets/images/theme_preview_arctic.jpg';
      case ThemeType.sakuraDrift:
        return 'assets/images/theme_preview_sakura.jpg';
      case ThemeType.abyssalDepths:
        return 'assets/images/theme_preview_abyssal.jpg';
      case ThemeType.retroGrid:
        return 'assets/images/theme_preview_retro.jpg';
      case ThemeType.emberCore:
        return 'assets/images/theme_preview_ember.jpg';
      case ThemeType.celestialObservatory:
        return 'assets/images/theme_preview_celestial.jpg';
      case ThemeType.prismRift:
        return 'assets/images/theme_preview_prism.jpg';
    }
  }

  /// Path to the dedicated 9:16 high-fidelity gameplay environment background asset
  String get gameplayBackgroundAsset {
    switch (type) {
      case ThemeType.midnightNeon:
        return 'assets/images/gameplay_bg.jpg';
      case ThemeType.aurora:
        return 'assets/images/gameplay_bg_aurora.jpg';
      case ThemeType.sunsetPulse:
        return 'assets/images/gameplay_bg_sunset.jpg';
      case ThemeType.arcticGlow:
        return 'assets/images/gameplay_bg_arctic.jpg';
      case ThemeType.sakuraDrift:
        return 'assets/images/gameplay_bg_sakura.jpg';
      case ThemeType.abyssalDepths:
        return 'assets/images/gameplay_bg_abyssal.jpg';
      case ThemeType.retroGrid:
        return 'assets/images/gameplay_bg_retro.jpg';
      case ThemeType.emberCore:
        return 'assets/images/gameplay_bg_ember.jpg';
      case ThemeType.celestialObservatory:
        return 'assets/images/gameplay_bg_celestial.jpg';
      case ThemeType.prismRift:
        return 'assets/images/gameplay_bg_prism.jpg';
    }
  }

  /// High-fidelity animated video background asset for all 10 living environments
  String get gameplayBackgroundVideoAsset {
    switch (type) {
      case ThemeType.midnightNeon:
        return 'assets/videos/gameplay_bg_midnight.mp4';
      case ThemeType.aurora:
        return 'assets/videos/gameplay_bg_aurora.mp4';
      case ThemeType.sunsetPulse:
        return 'assets/videos/gameplay_bg_sunset.mp4';
      case ThemeType.arcticGlow:
        return 'assets/videos/gameplay_bg_arctic.mp4';
      case ThemeType.sakuraDrift:
        return 'assets/videos/gameplay_bg_sakura.mp4';
      case ThemeType.abyssalDepths:
        return 'assets/videos/gameplay_bg_abyssal.mp4';
      case ThemeType.retroGrid:
        return 'assets/videos/gameplay_bg_retro.mp4';
      case ThemeType.emberCore:
        return 'assets/videos/gameplay_bg_ember.mp4';
      case ThemeType.celestialObservatory:
        return 'assets/videos/gameplay_bg_celestial.mp4';
      case ThemeType.prismRift:
        return 'assets/videos/gameplay_bg_prism.mp4';
    }
  }

  /// Thematic environment designation
  String get environmentName {
    switch (type) {
      case ThemeType.midnightNeon:
        return 'Cyber Dimension';
      case ThemeType.aurora:
        return 'Living Lights';
      case ThemeType.sunsetPulse:
        return 'Golden Horizon';
      case ThemeType.arcticGlow:
        return 'Frozen Dimension';
      case ThemeType.sakuraDrift:
        return 'Cherry Blossom Sanctuary';
      case ThemeType.abyssalDepths:
        return 'Bioluminescent Ocean';
      case ThemeType.retroGrid:
        return 'Digital Synthwave';
      case ThemeType.emberCore:
        return 'Volcanic Chamber';
      case ThemeType.celestialObservatory:
        return 'Golden Constellations';
      case ThemeType.prismRift:
        return 'Dimensional Fracture';
    }
  }

  /// Primary color for interactive reactive pulses on perfect placement
  Color get reactivePulseColor {
    switch (type) {
      case ThemeType.midnightNeon:
        return primaryAccent; // #13D9FF Electric Cyan
      case ThemeType.aurora:
        return mintAccent; // #14E4C5 Mint/Turquoise
      case ThemeType.sunsetPulse:
        return goldAccent; // #FFCB78 Golden Amber
      case ThemeType.arcticGlow:
        return const Color(0xFFBBEFFF); // Glacial Icy White/Cyan
      case ThemeType.sakuraDrift:
        return primaryAccent; // #FF7EB6 Sakura Pink
      case ThemeType.abyssalDepths:
        return primaryAccent; // #00F5D4 Bioluminescent Aqua
      case ThemeType.retroGrid:
        return primaryAccent; // #FF007F Hot Neon Pink
      case ThemeType.emberCore:
        return secondaryAccent; // #FFB703 Blazing Gold
      case ThemeType.celestialObservatory:
        return primaryAccent; // #FFD166 Celestial Gold
      case ThemeType.prismRift:
        return primaryAccent; // #C77DFF Prismatic Violet
    }
  }

  /// Secondary color for atmospheric ambient ripples and shimmer
  Color get reactiveSecondaryPulseColor {
    switch (type) {
      case ThemeType.midnightNeon:
        return secondaryAccent; // #9658FF Electric Purple
      case ThemeType.aurora:
        return const Color(0xFF10B981); // Emerald Green
      case ThemeType.sunsetPulse:
        return neonMagenta; // #F34BEA Neon Magenta
      case ThemeType.arcticGlow:
        return primaryAccent; // #13D9FF Electric Cyan
      case ThemeType.sakuraDrift:
        return neonBlue; // #C084FC Soft Lavender
      case ThemeType.abyssalDepths:
        return neonBlue; // #00BBF9 Electric Marine
      case ThemeType.retroGrid:
        return neonBlue; // #00F0FF Synthwave Cyan
      case ThemeType.emberCore:
        return primaryAccent; // #FF5400 Molten Orange
      case ThemeType.celestialObservatory:
        return neonBlue; // #A0C4FF Starlight Cyan
      case ThemeType.prismRift:
        return neonBlue; // #70D6FF Spectral Cyan
    }
  }

  /// Deep foundation tone for the theme-aware central corridor
  Color get corridorBaseColor {
    switch (type) {
      case ThemeType.midnightNeon:
        return const Color(0xFF061226);
      case ThemeType.aurora:
        return const Color(0xFF041917);
      case ThemeType.sunsetPulse:
        return const Color(0xFF1C091B);
      case ThemeType.arcticGlow:
        return const Color(0xFF061628);
      case ThemeType.sakuraDrift:
        return const Color(0xFF110B22);
      case ThemeType.abyssalDepths:
        return const Color(0xFF031220);
      case ThemeType.retroGrid:
        return const Color(0xFF130826);
      case ThemeType.emberCore:
        return const Color(0xFF180A06);
      case ThemeType.celestialObservatory:
        return const Color(0xFF070E24);
      case ThemeType.prismRift:
        return const Color(0xFF100720);
    }
  }

  /// Dark atmospheric center tone of the central corridor
  Color get corridorCenterColor {
    switch (type) {
      case ThemeType.midnightNeon:
        return const Color(0xFF091934);
      case ThemeType.aurora:
        return const Color(0xFF062320);
      case ThemeType.sunsetPulse:
        return const Color(0xFF280E27);
      case ThemeType.arcticGlow:
        return const Color(0xFF0A2038);
      case ThemeType.sakuraDrift:
        return const Color(0xFF1A1032);
      case ThemeType.abyssalDepths:
        return const Color(0xFF051B2E);
      case ThemeType.retroGrid:
        return const Color(0xFF1D0D38);
      case ThemeType.emberCore:
        return const Color(0xFF240E08);
      case ThemeType.celestialObservatory:
        return const Color(0xFF0B1736);
      case ThemeType.prismRift:
        return const Color(0xFF180B30);
    }
  }

  /// Ambient atmospheric haze tone for central corridor continuation
  Color get corridorHazeColor {
    switch (type) {
      case ThemeType.midnightNeon:
        return const Color(0xFF0D254C);
      case ThemeType.aurora:
        return const Color(0xFF0A332E);
      case ThemeType.sunsetPulse:
        return const Color(0xFF381436);
      case ThemeType.arcticGlow:
        return const Color(0xFF0F2E4F);
      case ThemeType.sakuraDrift:
        return const Color(0xFF281648);
      case ThemeType.abyssalDepths:
        return const Color(0xFF082740);
      case ThemeType.retroGrid:
        return const Color(0xFF2C1252);
      case ThemeType.emberCore:
        return const Color(0xFF35150C);
      case ThemeType.celestialObservatory:
        return const Color(0xFF10214C);
      case ThemeType.prismRift:
        return const Color(0xFF261048);
    }
  }

  /// Subtle lower fog continuation color near base pedestal
  Color get corridorLowerFogColor {
    switch (type) {
      case ThemeType.midnightNeon:
        return primaryAccent; // Electric Cyan
      case ThemeType.aurora:
        return mintAccent; // Turquoise/Mint
      case ThemeType.sunsetPulse:
        return orangeAccent; // Warm Sunset Orange
      case ThemeType.arcticGlow:
        return const Color(0xFFBBEFFF); // Icy Cyan Frost
      case ThemeType.sakuraDrift:
        return const Color(0xFFFF85A2); // Blossom Pink Haze
      case ThemeType.abyssalDepths:
        return primaryAccent; // Bioluminescent Aqua
      case ThemeType.retroGrid:
        return primaryAccent; // Synthwave Magenta
      case ThemeType.emberCore:
        return primaryAccent; // Molten Ember Orange
      case ThemeType.celestialObservatory:
        return primaryAccent; // Celestial Gold
      case ThemeType.prismRift:
        return primaryAccent; // Prismatic Cyan
    }
  }

  /// Centralized environmental animation parameters for the active living background
  ThemeAnimationConfig get animationConfig {
    switch (type) {
      case ThemeType.midnightNeon:
        return ThemeAnimationConfig(
          type: AmbientAnimationType.cyberBeams,
          baseSpeed: 1.0,
          particleDensity: 1.0,
          reactiveIntensity: 1.0,
          ambientPalette: [primaryAccent, secondaryAccent, neonBlue],
          effectDescription:
              'Holographic light beams, cyber conduits, and neon pulses',
        );
      case ThemeType.aurora:
        return ThemeAnimationConfig(
          type: AmbientAnimationType.auroraCurtains,
          baseSpeed: 0.85,
          particleDensity: 1.1,
          reactiveIntensity: 1.15,
          ambientPalette: [
            mintAccent,
            const Color(0xFF10B981),
            const Color(0xFF06B6D4)
          ],
          effectDescription:
              'Flowing multi-harmonic aurora ribbons with polar motes',
        );
      case ThemeType.sunsetPulse:
        return ThemeAnimationConfig(
          type: AmbientAnimationType.sunsetClouds,
          baseSpeed: 0.75,
          particleDensity: 0.9,
          reactiveIntensity: 1.0,
          ambientPalette: [goldAccent, orangeAccent, neonMagenta],
          effectDescription:
              'Drifting cloud strata, shifting crepuscular rays, and warm dust',
        );
      case ThemeType.arcticGlow:
        return ThemeAnimationConfig(
          type: AmbientAnimationType.arcticSnowfall,
          baseSpeed: 1.1,
          particleDensity: 1.3,
          reactiveIntensity: 1.1,
          ambientPalette: [
            const Color(0xFFBBEFFF),
            primaryAccent,
            Colors.white
          ],
          effectDescription:
              'Multi-depth parallax snowfall, ice spires, and ground frost mist',
        );
      case ThemeType.sakuraDrift:
        return ThemeAnimationConfig(
          type: AmbientAnimationType.sakuraWind,
          baseSpeed: 0.95,
          particleDensity: 1.1,
          reactiveIntensity: 1.1,
          ambientPalette: [
            primaryAccent,
            secondaryAccent,
            const Color(0xFFFFB3C6)
          ],
          effectDescription:
              'Tumbling 3D cherry blossom petals, wind gusts, and swaying lanterns',
        );
      case ThemeType.abyssalDepths:
        return ThemeAnimationConfig(
          type: AmbientAnimationType.abyssalCaustics,
          baseSpeed: 0.8,
          particleDensity: 1.0,
          reactiveIntensity: 1.1,
          ambientPalette: [primaryAccent, mintAccent, neonBlue],
          effectDescription:
              'Rising wobbling bubbles, swaying kelp silhouettes, and oceanic caustics',
        );
      case ThemeType.retroGrid:
        return ThemeAnimationConfig(
          type: AmbientAnimationType.synthwaveGrid,
          baseSpeed: 1.25,
          particleDensity: 0.85,
          reactiveIntensity: 1.2,
          ambientPalette: [primaryAccent, secondaryAccent, neonBlue],
          effectDescription:
              'Continuous 3D perspective grid, laser scanline, and segmented synth sun',
        );
      case ThemeType.emberCore:
        return ThemeAnimationConfig(
          type: AmbientAnimationType.moltenEmbers,
          baseSpeed: 1.15,
          particleDensity: 1.2,
          reactiveIntensity: 1.25,
          ambientPalette: [
            primaryAccent,
            secondaryAccent,
            const Color(0xFFFF3D00)
          ],
          effectDescription:
              'Buoyant turbulent embers, boiling magma pool, and thermal heat waves',
        );
      case ThemeType.celestialObservatory:
        return ThemeAnimationConfig(
          type: AmbientAnimationType.celestialConstellations,
          baseSpeed: 0.7,
          particleDensity: 1.1,
          reactiveIntensity: 1.05,
          ambientPalette: [primaryAccent, neonBlue, Colors.white],
          effectDescription:
              'Twinkling starry spheres, revolving constellation geometry, and shooting stars',
        );
      case ThemeType.prismRift:
        return ThemeAnimationConfig(
          type: AmbientAnimationType.prismaticRefractions,
          baseSpeed: 0.9,
          particleDensity: 1.05,
          reactiveIntensity: 1.2,
          ambientPalette: [primaryAccent, secondaryAccent, neonBlue],
          effectDescription:
              'Faceted rotating crystal shards, chromatic dispersion beams, and spectral ripple',
        );
    }
  }

  /// Verifies unlock status using either best score or cumulative lifetime placements
  bool isUnlocked({required int bestScore, required int totalPlacements}) {
    if (unlockScore > 0) {
      return bestScore >= unlockScore;
    }
    if (unlockPlacements > 0) {
      return totalPlacements >= unlockPlacements;
    }
    return true; // Default unlocked (Midnight Neon)
  }

  /// Formatted user-facing requirement string
  String get unlockRequirementText {
    if (unlockScore > 0) {
      return 'Unlock at Best Score $unlockScore';
    }
    if (unlockPlacements > 0) {
      return 'Unlock at $unlockPlacements Placements';
    }
    return 'Unlocked';
  }

  // ==========================================
  // PHASE 7: STANDARDIZED UI TOKENS
  // ==========================================
  static const double cardBorderRadiusValue = 22.0;
  static const double modalBorderRadiusValue = 24.0;
  static const double disabledOpacityValue = 0.45;

  Color get glassSurfaceColor =>
      const Color(0xFF14284A).withValues(alpha: 0.85);
  Color get switchTrackInactiveColor => const Color(0xFF152A4A);
  BorderRadius get cardBorderRadius =>
      BorderRadius.circular(cardBorderRadiusValue);
  BorderRadius get modalBorderRadius =>
      BorderRadius.circular(modalBorderRadiusValue);
}
