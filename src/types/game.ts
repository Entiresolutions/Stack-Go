export type ThemeId = 'midnightNeon' | 'aurora' | 'sunsetPulse' | 'arcticGlow';

export interface GameTheme {
  id: ThemeId;
  name: string;
  tagline: string;
  unlockScore: number;
  background: string;
  secondaryBackground: string;
  surface: string;
  primaryAccent: string;
  secondaryAccent: string;
  successAccent: string;
  warningAccent: string;
  text: string;
  secondaryText: string;
  blockPalette: string[];
}

export const GAME_THEMES: Record<ThemeId, GameTheme> = {
  midnightNeon: {
    id: 'midnightNeon',
    name: 'Midnight Neon',
    tagline: 'Electric cyan and violet pulses against deep midnight navy.',
    unlockScore: 0,
    background: '#0B1020',
    secondaryBackground: '#141C30',
    surface: '#1D2940',
    primaryAccent: '#55DDFB',
    secondaryAccent: '#8B5CF6',
    successAccent: '#57E5B3',
    warningAccent: '#F7C76D',
    text: '#F7FAFF',
    secondaryText: '#9CAEC8',
    blockPalette: [
      '#55DDFB',
      '#60A5FA',
      '#818CF8',
      '#A78BFA',
      '#C084FC',
      '#E879F9',
      '#34D399',
      '#2DD4BF',
    ],
  },
  aurora: {
    id: 'aurora',
    name: 'Aurora',
    tagline: 'Ethereal emerald and turquoise shimmering in arctic polar skies.',
    unlockScore: 10,
    background: '#061916',
    secondaryBackground: '#0B2925',
    surface: '#133B36',
    primaryAccent: '#34D399',
    secondaryAccent: '#2DD4BF',
    successAccent: '#6EE7B7',
    warningAccent: '#FCD34D',
    text: '#F0FDF4',
    secondaryText: '#86EFAC',
    blockPalette: [
      '#10B981',
      '#34D399',
      '#2DD4BF',
      '#06B6D4',
      '#14B8A6',
      '#059669',
      '#4ADE80',
      '#22C55E',
    ],
  },
  sunsetPulse: {
    id: 'sunsetPulse',
    name: 'Sunset Pulse',
    tagline: 'Vibrant amber, radiant coral and velvet violet horizons.',
    unlockScore: 25,
    background: '#180B1A',
    secondaryBackground: '#26112A',
    surface: '#381A3E',
    primaryAccent: '#F97316',
    secondaryAccent: '#EC4899',
    successAccent: '#F43F5E',
    warningAccent: '#FBBF24',
    text: '#FFF1F2',
    secondaryText: '#FDA4AF',
    blockPalette: [
      '#F97316',
      '#FB923C',
      '#F43F5E',
      '#E11D48',
      '#C026D3',
      '#9333EA',
      '#D946EF',
      '#F59E0B',
    ],
  },
  arcticGlow: {
    id: 'arcticGlow',
    name: 'Arctic Glow',
    tagline: 'Pristine glacial ice, deep oceanic sapphire and frost crystal white.',
    unlockScore: 50,
    background: '#061325',
    secondaryBackground: '#0B1E38',
    surface: '#122D52',
    primaryAccent: '#38BDF8',
    secondaryAccent: '#E0F2FE',
    successAccent: '#7DD3FC',
    warningAccent: '#FDE68A',
    text: '#F8FAFC',
    secondaryText: '#BAE6FD',
    blockPalette: [
      '#38BDF8',
      '#0284C7',
      '#7DD3FC',
      '#BAE6FD',
      '#E0F2FE',
      '#60A5FA',
      '#93C5FD',
      '#2563EB',
    ],
  },
};

export type GameScreenState = 'TITLE' | 'PLAYING' | 'PAUSED' | 'GAME_OVER';

export interface GameSettings {
  soundEnabled: boolean;
  hapticsEnabled: boolean;
  reducedMotion: boolean;
  deviceFrame: boolean;
  selectedTheme: ThemeId;
  tutorialCompleted: boolean;
}

export interface GameStatistics {
  bestScore: number;
  bestStreak: number;
  totalGamesPlayed: number;
  totalBlocksPlaced: number;
  totalPerfectPlacements: number;
}

export interface PlacementResult {
  type: 'perfect' | 'partial' | 'miss';
  retainedLeft: number;
  retainedRight: number;
  retainedWidth: number;
  excessLeft?: number;
  excessRight?: number;
  excessWidth?: number;
  isExcessOnRight: boolean;
}
