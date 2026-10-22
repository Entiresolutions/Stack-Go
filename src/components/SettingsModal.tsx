import React from 'react';
import { X, Volume2, Smartphone, EyeOff, Sparkles, Trash2 } from 'lucide-react';
import { GameTheme, GameSettings } from '../types/game';

interface SettingsModalProps {
  theme: GameTheme;
  settings: GameSettings;
  onUpdateSettings: (newSettings: GameSettings) => void;
  onResetStats: () => void;
  onClose: () => void;
}

export const SettingsModal: React.FC<SettingsModalProps> = ({
  theme,
  settings,
  onUpdateSettings,
  onResetStats,
  onClose,
}) => {
  const toggleSound = () => onUpdateSettings({ ...settings, soundEnabled: !settings.soundEnabled });
  const toggleHaptics = () => onUpdateSettings({ ...settings, hapticsEnabled: !settings.hapticsEnabled });
  const toggleReducedMotion = () => onUpdateSettings({ ...settings, reducedMotion: !settings.reducedMotion });
  const toggleDeviceFrame = () => onUpdateSettings({ ...settings, deviceFrame: !settings.deviceFrame });

  return (
    <div
      className="absolute inset-0 z-40 flex items-center justify-center p-4 sm:p-6 select-none"
      style={{ backgroundColor: 'rgba(11, 16, 32, 0.88)' }}
    >
      <div
        className="w-full max-w-md rounded-3xl p-6 shadow-2xl flex flex-col max-h-[90vh] overflow-hidden"
        style={{
          backgroundColor: theme.surface,
          border: '1px solid rgba(255, 255, 255, 0.1)',
        }}
      >
        {/* Header */}
        <div className="flex items-center justify-between pb-4 border-b border-white/10">
          <div>
            <h2 className="text-xl font-black tracking-wide uppercase" style={{ color: theme.text }}>
              Settings
            </h2>
            <p className="text-xs opacity-70 mt-0.5" style={{ color: theme.secondaryText }}>
              Tune feedback, motion, and viewport presentation
            </p>
          </div>
          <button
            onClick={onClose}
            className="w-9 h-9 rounded-full flex items-center justify-center transition-transform active:scale-90"
            style={{ backgroundColor: 'rgba(255, 255, 255, 0.08)', color: theme.text }}
          >
            <X size={18} />
          </button>
        </div>

        {/* Options List */}
        <div className="flex flex-col gap-3 my-4 overflow-y-auto pr-1">
          {/* Sound */}
          <div
            onClick={toggleSound}
            className="p-3.5 rounded-2xl flex items-center justify-between cursor-pointer active:scale-[0.99] transition-all"
            style={{ backgroundColor: 'rgba(0, 0, 0, 0.25)', border: '1px solid rgba(255, 255, 255, 0.06)' }}
          >
            <div className="flex items-center gap-3">
              <div
                className="w-10 h-10 rounded-xl flex items-center justify-center"
                style={{ backgroundColor: `${theme.primaryAccent}15`, color: theme.primaryAccent }}
              >
                <Volume2 size={20} />
              </div>
              <div>
                <span className="font-bold text-sm block" style={{ color: theme.text }}>
                  Sound Effects
                </span>
                <span className="text-xs opacity-70" style={{ color: theme.secondaryText }}>
                  Musical pentatonic chords on placement & streaks
                </span>
              </div>
            </div>
            <div
              className={`w-12 h-6 rounded-full transition-colors p-1 flex items-center ${
                settings.soundEnabled ? 'justify-end' : 'justify-start'
              }`}
              style={{ backgroundColor: settings.soundEnabled ? theme.primaryAccent : 'rgba(255,255,255,0.15)' }}
            >
              <div className="w-4 h-4 rounded-full bg-white shadow-md" />
            </div>
          </div>

          {/* Haptics */}
          <div
            onClick={toggleHaptics}
            className="p-3.5 rounded-2xl flex items-center justify-between cursor-pointer active:scale-[0.99] transition-all"
            style={{ backgroundColor: 'rgba(0, 0, 0, 0.25)', border: '1px solid rgba(255, 255, 255, 0.06)' }}
          >
            <div className="flex items-center gap-3">
              <div
                className="w-10 h-10 rounded-xl flex items-center justify-center"
                style={{ backgroundColor: `${theme.primaryAccent}15`, color: theme.primaryAccent }}
              >
                <Sparkles size={20} />
              </div>
              <div>
                <span className="font-bold text-sm block" style={{ color: theme.text }}>
                  Haptic Feedback
                </span>
                <span className="text-xs opacity-70" style={{ color: theme.secondaryText }}>
                  Device tactile pulses on perfect alignment
                </span>
              </div>
            </div>
            <div
              className={`w-12 h-6 rounded-full transition-colors p-1 flex items-center ${
                settings.hapticsEnabled ? 'justify-end' : 'justify-start'
              }`}
              style={{ backgroundColor: settings.hapticsEnabled ? theme.primaryAccent : 'rgba(255,255,255,0.15)' }}
            >
              <div className="w-4 h-4 rounded-full bg-white shadow-md" />
            </div>
          </div>

          {/* Reduced Motion */}
          <div
            onClick={toggleReducedMotion}
            className="p-3.5 rounded-2xl flex items-center justify-between cursor-pointer active:scale-[0.99] transition-all"
            style={{ backgroundColor: 'rgba(0, 0, 0, 0.25)', border: '1px solid rgba(255, 255, 255, 0.06)' }}
          >
            <div className="flex items-center gap-3">
              <div
                className="w-10 h-10 rounded-xl flex items-center justify-center"
                style={{ backgroundColor: `${theme.primaryAccent}15`, color: theme.primaryAccent }}
              >
                <EyeOff size={20} />
              </div>
              <div>
                <span className="font-bold text-sm block" style={{ color: theme.text }}>
                  Reduced Motion
                </span>
                <span className="text-xs opacity-70" style={{ color: theme.secondaryText }}>
                  Disable particle firework bursts and camera shake
                </span>
              </div>
            </div>
            <div
              className={`w-12 h-6 rounded-full transition-colors p-1 flex items-center ${
                settings.reducedMotion ? 'justify-end' : 'justify-start'
              }`}
              style={{ backgroundColor: settings.reducedMotion ? theme.primaryAccent : 'rgba(255,255,255,0.15)' }}
            >
              <div className="w-4 h-4 rounded-full bg-white shadow-md" />
            </div>
          </div>

          {/* Android Mobile Frame Simulator */}
          <div
            onClick={toggleDeviceFrame}
            className="p-3.5 rounded-2xl flex items-center justify-between cursor-pointer active:scale-[0.99] transition-all"
            style={{ backgroundColor: 'rgba(0, 0, 0, 0.25)', border: '1px solid rgba(255, 255, 255, 0.06)' }}
          >
            <div className="flex items-center gap-3">
              <div
                className="w-10 h-10 rounded-xl flex items-center justify-center"
                style={{ backgroundColor: `${theme.primaryAccent}15`, color: theme.primaryAccent }}
              >
                <Smartphone size={20} />
              </div>
              <div>
                <span className="font-bold text-sm block" style={{ color: theme.text }}>
                  Mobile Device Frame
                </span>
                <span className="text-xs opacity-70" style={{ color: theme.secondaryText }}>
                  Display in sleek simulated portrait phone chassis
                </span>
              </div>
            </div>
            <div
              className={`w-12 h-6 rounded-full transition-colors p-1 flex items-center ${
                settings.deviceFrame ? 'justify-end' : 'justify-start'
              }`}
              style={{ backgroundColor: settings.deviceFrame ? theme.primaryAccent : 'rgba(255,255,255,0.15)' }}
            >
              <div className="w-4 h-4 rounded-full bg-white shadow-md" />
            </div>
          </div>

          {/* Reset Stats */}
          <button
            onClick={() => {
              if (window.confirm('Reset all high scores and streaks to zero?')) {
                onResetStats();
              }
            }}
            className="mt-2 py-3 px-4 rounded-xl flex items-center justify-center gap-2 text-xs font-bold text-rose-400 hover:bg-rose-500/10 border border-rose-500/20 transition-all cursor-pointer"
          >
            <Trash2 size={15} />
            <span>RESET HIGH SCORE & STATS</span>
          </button>
        </div>

        {/* Footer */}
        <button
          onClick={onClose}
          className="w-full py-3 rounded-xl font-bold text-sm transition-all active:scale-95 cursor-pointer"
          style={{
            backgroundColor: theme.primaryAccent,
            color: '#0B1020',
          }}
        >
          SAVE & CLOSE
        </button>
      </div>
    </div>
  );
};
