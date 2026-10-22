import { GameSettings, GameStatistics, ThemeId } from '../types/game';

const SETTINGS_KEY = 'stack_pulse_web_settings';
const STATS_KEY = 'stack_pulse_web_stats';

const DEFAULT_SETTINGS: GameSettings = {
  soundEnabled: true,
  hapticsEnabled: true,
  reducedMotion: false,
  deviceFrame: false,
  selectedTheme: 'midnightNeon',
  tutorialCompleted: false,
};

const DEFAULT_STATS: GameStatistics = {
  bestScore: 0,
  bestStreak: 0,
  totalGamesPlayed: 0,
  totalBlocksPlaced: 0,
  totalPerfectPlacements: 0,
};

export const storageService = {
  loadSettings(): GameSettings {
    try {
      const data = localStorage.getItem(SETTINGS_KEY);
      if (data) {
        return { ...DEFAULT_SETTINGS, ...JSON.parse(data) };
      }
    } catch (_) {}
    return DEFAULT_SETTINGS;
  },

  saveSettings(settings: GameSettings) {
    try {
      localStorage.setItem(SETTINGS_KEY, JSON.stringify(settings));
    } catch (_) {}
  },

  loadStatistics(): GameStatistics {
    try {
      const data = localStorage.getItem(STATS_KEY);
      if (data) {
        return { ...DEFAULT_STATS, ...JSON.parse(data) };
      }
    } catch (_) {}
    return DEFAULT_STATS;
  },

  saveStatistics(stats: GameStatistics) {
    try {
      localStorage.setItem(STATS_KEY, JSON.stringify(stats));
    } catch (_) {}
  },

  triggerHaptic(type: 'light' | 'medium' | 'heavy' = 'light', enabled = true) {
    if (!enabled || typeof navigator === 'undefined' || !navigator.vibrate) return;
    try {
      if (type === 'light') navigator.vibrate(12);
      else if (type === 'medium') navigator.vibrate(28);
      else if (type === 'heavy') navigator.vibrate([40, 20, 40]);
    } catch (_) {}
  },
};
