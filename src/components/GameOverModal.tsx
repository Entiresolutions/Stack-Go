import React from 'react';
import { RotateCcw, Home, Sparkles } from 'lucide-react';
import { GameTheme } from '../types/game';

interface GameOverModalProps {
  score: number;
  bestScore: number;
  bestStreak: number;
  isNewBest: boolean;
  theme: GameTheme;
  onRetry: () => void;
  onHome: () => void;
}

export const GameOverModal: React.FC<GameOverModalProps> = ({
  score,
  bestScore,
  bestStreak,
  isNewBest,
  theme,
  onRetry,
  onHome,
}) => {
  return (
    <div
      className="absolute inset-0 z-30 flex items-center justify-center p-6 select-none animate-fadeIn"
      style={{ backgroundColor: 'rgba(11, 16, 32, 0.88)' }}
    >
      <div
        className="w-full max-w-xs rounded-3xl p-6 sm:p-7 shadow-2xl flex flex-col items-center text-center animate-scaleUp"
        style={{
          backgroundColor: theme.surface,
          border: `1.5px solid ${isNewBest ? theme.primaryAccent : 'rgba(255, 255, 255, 0.1)'}`,
          boxShadow: isNewBest ? `0 0 32px ${theme.primaryAccent}30` : undefined,
        }}
      >
        <span
          className="text-xs font-black tracking-widest uppercase mb-1"
          style={{ color: theme.secondaryText }}
        >
          Run Completed
        </span>

        <h2 className="text-xl font-black tracking-wider uppercase mb-3" style={{ color: theme.text }}>
          Game Over
        </h2>

        {/* Big Final Score */}
        <div className="my-2">
          <span
            className="text-6xl sm:text-7xl font-black tracking-tighter tabular-nums drop-shadow-lg"
            style={{ color: theme.text }}
          >
            {score}
          </span>
        </div>

        {/* New Best Badge */}
        {isNewBest && (
          <div
            className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-extrabold tracking-wider uppercase my-2 shadow-sm animate-pulse"
            style={{
              backgroundColor: `${theme.primaryAccent}25`,
              color: theme.primaryAccent,
              border: `1px solid ${theme.primaryAccent}`,
            }}
          >
            <Sparkles size={14} />
            <span>New Best Score!</span>
          </div>
        )}

        {/* Stats Row */}
        <div
          className="grid grid-cols-2 gap-4 w-full my-5 py-3.5 px-4 rounded-2xl"
          style={{
            backgroundColor: 'rgba(0, 0, 0, 0.25)',
            border: '1px solid rgba(255, 255, 255, 0.05)',
          }}
        >
          <div className="flex flex-col items-center">
            <span className="text-[10px] font-bold tracking-wider uppercase opacity-60" style={{ color: theme.secondaryText }}>
              All-Time Best
            </span>
            <span className="text-xl font-black tabular-nums mt-0.5" style={{ color: theme.text }}>
              {bestScore}
            </span>
          </div>

          <div className="flex flex-col items-center border-l border-white/10">
            <span className="text-[10px] font-bold tracking-wider uppercase opacity-60" style={{ color: theme.secondaryText }}>
              Best Streak
            </span>
            <span className="text-xl font-black tabular-nums mt-0.5" style={{ color: theme.primaryAccent }}>
              {bestStreak}
            </span>
          </div>
        </div>

        {/* Actions */}
        <div className="flex flex-col gap-2.5 w-full">
          <button
            onClick={onRetry}
            className="w-full py-3.5 px-4 rounded-xl flex items-center justify-center gap-2 font-bold text-sm transition-all active:scale-95 cursor-pointer shadow-lg"
            style={{
              backgroundColor: theme.primaryAccent,
              color: '#0B1020',
              boxShadow: `0 4px 18px ${theme.primaryAccent}40`,
            }}
          >
            <RotateCcw size={18} />
            <span>PLAY AGAIN</span>
          </button>

          <button
            onClick={onHome}
            className="w-full py-3 px-4 rounded-xl flex items-center justify-center gap-2 font-semibold text-sm transition-all active:scale-95 cursor-pointer"
            style={{
              backgroundColor: 'rgba(255, 255, 255, 0.05)',
              color: theme.secondaryText,
              border: '1px solid rgba(255, 255, 255, 0.08)',
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
