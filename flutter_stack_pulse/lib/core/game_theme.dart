import 'package:flutter/material.dart';

enum ThemeType {
  midnightNeon,
  aurora,
  sunsetPulse,
  arcticGlow,
}

class GameTheme {
  final ThemeType type;
  final String name;
  final String description;
  final int unlockScore;
  final Color background;
  final Color secondaryBackground;
  final Color surface;
  final Color primaryAccent;
  final Color secondaryAccent;
  final Color successAccent;
  final Color warningAccent;
  final Color text;
  final Color secondaryText;
  final List<Color> blockPalette;

  const GameTheme({
    required this.type,
    required this.name,
    required this.description,
    required this.unlockScore,
    required this.background,
    required this.secondaryBackground,
    required this.surface,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.successAccent,
    required this.warningAccent,
    required this.text,
    required this.secondaryText,
    required this.blockPalette,
  });

  static const GameTheme midnightNeon = GameTheme(
    type: ThemeType.midnightNeon,
    name: 'Midnight Neon',
    description: 'Electric cyan and violet pulses against deep midnight navy.',
    unlockScore: 0,
    background: Color(0xFF0B1020),
    secondaryBackground: Color(0xFF141C30),
    surface: Color(0xFF1D2940),
    primaryAccent: Color(0xFF55DDFB),
    secondaryAccent: Color(0xFF8B5CF6),
    successAccent: Color(0xFF57E5B3),
    warningAccent: Color(0xFFF7C76D),
    text: Color(0xFFF7FAFF),
    secondaryText: Color(0xFF9CAEC8),
    blockPalette: [
      Color(0xFF55DDFB),
      Color(0xFF60A5FA),
      Color(0xFF8B5CF6),
      Color(0xFFA78BFA),
      Color(0xFF57E5B3),
      Color(0xFF2DD4BF),
    ],
  );

  static const GameTheme aurora = GameTheme(
    type: ThemeType.aurora,
    name: 'Aurora',
    description: 'Ethereal emerald and turquoise shimmering in arctic polar skies.',
    unlockScore: 10,
    background: Color(0xFF071B19),
    secondaryBackground: Color(0xFF0D2C28),
    surface: Color(0xFF143D38),
    primaryAccent: Color(0xFF34D399),
    secondaryAccent: Color(0xFF2DD4BF),
    successAccent: Color(0xFF6EE7B7),
    warningAccent: Color(0xFFFCD34D),
    text: Color(0xFFF0FDF4),
    secondaryText: Color(0xFF86EFAC),
    blockPalette: [
      Color(0xFF10B981),
      Color(0xFF34D399),
      Color(0xFF2DD4BF),
      Color(0xFF06B6D4),
      Color(0xFF14B8A6),
      Color(0xFF059669),
    ],
  );

  static const GameTheme sunsetPulse = GameTheme(
    type: ThemeType.sunsetPulse,
    name: 'Sunset Pulse',
    description: 'Vibrant amber, radiant coral and velvet violet horizons.',
    unlockScore: 25,
    background: Color(0xFF1C0D1E),
    secondaryBackground: Color(0xFF2C132F),
    surface: Color(0xFF3D1B42),
    primaryAccent: Color(0xFFF97316),
    secondaryAccent: Color(0xFFEC4899),
    successAccent: Color(0xFFF43F5E),
    warningAccent: Color(0xFFFBBF24),
    text: Color(0xFFFFF1F2),
    secondaryText: Color(0xFFFDA4AF),
    blockPalette: [
      Color(0xFFF97316),
      Color(0xFFFB923C),
      Color(0xFFF43F5E),
      Color(0xFFE11D48),
      Color(0xFFC026D3),
      Color(0xFF9333EA),
    ],
  );

  static const GameTheme arcticGlow = GameTheme(
    type: ThemeType.arcticGlow,
    name: 'Arctic Glow',
    description: 'Pristine glacial ice, deep oceanic sapphire and frost crystal white.',
    unlockScore: 50,
    background: Color(0xFF061325),
    secondaryBackground: Color(0xFF0C203B),
    surface: Color(0xFF142F54),
    primaryAccent: Color(0xFF38BDF8),
    secondaryAccent: Color(0xFFE0F2FE),
    successAccent: Color(0xFF7DD3FC),
    warningAccent: Color(0xFFFDE68A),
    text: Color(0xFFF8FAFC),
    secondaryText: Color(0xFFBAE6FD),
    blockPalette: [
      Color(0xFF38BDF8),
      Color(0xFF0284C7),
      Color(0xFF7DD3FC),
      Color(0xFFBAE6FD),
      Color(0xFFE0F2FE),
      Color(0xFF60A5FA),
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
      default:
        return midnightNeon;
    }
  }

  Color getBlockColor(int index) {
    return blockPalette[index % blockPalette.length];
  }
}
