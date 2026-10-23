import 'package:flutter/material.dart';

enum ThemeType {
  midnightNeon,
  aurora,
  sunsetPulse,
  arcticGlow,
}

/// Centralized Single Source of Truth for all Stack Pulse styling, palettes,
/// semantic tokens, and visual effects across Flutter UI and Flame rendering.
class GameTheme {
  final ThemeType type;
  final String name;
  final String description;
  final int unlockScore;

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

  static const List<GameTheme> allThemes = [
    midnightNeon,
    aurora,
    sunsetPulse,
    arcticGlow,
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
    }
  }

  Color getBlockColor(int index) {
    return blockPalette[index % blockPalette.length];
  }

  /// Path to the dedicated 3D isometric theme preview asset (Phase 5)
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
    }
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
