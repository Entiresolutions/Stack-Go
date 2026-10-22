import React from 'react';
import { Play, RotateCcw, Settings, Home } from 'lucide-react';
import { GameTheme } from '../types/game';

interface PauseModalProps {
  theme: GameTheme;
  onResume: () => void;
  onRestart: () => void;
  onSettings: () => void;
  onHome: () => void;
}

export const PauseModal: React.FC<PauseModalProps> = ({
  theme,
  onResume,
  onRestart,
  onSettings,
  onHome,
}) => {
  return (
    <div
      className="absolute inset-0 z-30 flex items-center justify-center p-6 select-none"
      style={{ backgroundColor: 'rgba(11, 16, 32, 0.82)' }}
    >
      <div
        className="w-full max-w-xs rounded-3xl p-6 shadow-2xl flex flex-col items-center"
        style={{
          backgroundColor: theme.surface,
          border: '1px solid rgba(255, 255, 255, 0.1)',
        }}
      >
        <span
          className="text-xs font-black tracking-widest uppercase mb-1"
          style={{ color: theme.secondaryText }}
        >
          Session
        </span>
        <h2 className="text-2xl font-black tracking-wider uppercase mb-6" style={{ color: theme.text }}>
          Paused
        </h2>

        <div className="flex flex-col gap-2.5 w-full">
          <button
            onClick={onResume}
            className="w-full py-3.5 px-4 rounded-xl flex items-center justify-center gap-2 font-bold text-sm transition-all active:scale-95 cursor-pointer"
            style={{
              backgroundColor: theme.primaryAccent,
              color: '#0B1020',
              boxShadow: `0 4px 16px ${theme.primaryAccent}40`,
            }}
          >
            <Play size={18} fill="#0B1020" />
            <span>RESUME</span>
          </button>

          <button
            onClick={onRestart}
            className="w-full py-3 px-4 rounded-xl flex items-center justify-center gap-2 font-semibold text-sm transition-all active:scale-95 cursor-pointer"
            style={{
              backgroundColor: 'rgba(255, 255, 255, 0.05)',
              color: theme.text,
              border: '1px solid rgba(255, 255, 255, 0.08)',
            }}
          >
            <RotateCcw size={16} />
            <span>RESTART</span>
          </button>

          <button
            onClick={onSettings}
            className="w-full py-3 px-4 rounded-xl flex items-center justify-center gap-2 font-semibold text-sm transition-all active:scale-95 cursor-pointer"
            style={{
              backgroundColor: 'rgba(255, 255, 255, 0.05)',
              color: theme.text,
              border: '1px solid rgba(255, 255, 255, 0.08)',
            }}
          >
            <Settings size={16} />
            <span>SETTINGS</span>
          </button>

          <button
            onClick={onHome}
            className="w-full py-3 px-4 rounded-xl flex items-center justify-center gap-2 font-semibold text-sm transition-all active:scale-95 cursor-pointer"
            style={{
              backgroundColor: 'rgba(255, 255, 255, 0.05)',
              color: theme.secondaryText,
              border: '1px solid rgba(255, 255, 255, 0.06)',
            }}
          >
            <Home size={16} />
            <span>HOME</span>
          </button>
        </div>
      </div>
    </div>
  );
};
