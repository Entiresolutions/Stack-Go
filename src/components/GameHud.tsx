import React from 'react';
import { Pause, Volume2, VolumeX } from 'lucide-react';
import { GameTheme } from '../types/game';

interface GameHudProps {
  score: number;
  bestScore: number;
  streakBadge: string | null;
  theme: GameTheme;
  soundEnabled: boolean;
  onToggleSound: () => void;
  onPause: () => void;
}

export const GameHud: React.FC<GameHudProps> = ({
  score,
  bestScore,
  streakBadge,
  theme,
  soundEnabled,
  onToggleSound,
  onPause,
}) => {
  return (
    <div className="absolute inset-0 pointer-events-none z-10 flex flex-col justify-between p-4 sm:p-6">
      {/* Top HUD Cluster */}
      <div className="flex items-start justify-between w-full">
        {/* Score & Streak */}
        <div className="flex flex-col">
          <div className="flex items-baseline gap-2">
            <span
              className="text-4xl sm:text-5xl font-black tracking-tight tabular-nums drop-shadow-md"
              style={{ color: theme.text }}
            >
              {score}
            </span>
            <span
              className="text-xs font-bold tracking-wider opacity-60 tabular-nums uppercase"
              style={{ color: theme.secondaryText }}
            >
              BEST {bestScore}
            </span>
          </div>

          {/* Animated Combo Badge */}
          {streakBadge && (
            <div
              key={streakBadge + score}
              className="mt-1 inline-flex items-center self-start text-xs font-black tracking-widest px-2.5 py-0.5 rounded-full shadow-lg animate-bounce"
              style={{
                backgroundColor: `${theme.primaryAccent}25`,
                color: theme.primaryAccent,
                border: `1px solid ${theme.primaryAccent}`,
              }}
            >
              {streakBadge}
            </div>
          )}
        </div>

        {/* Quick Controls */}
        <div className="flex items-center gap-2 pointer-events-auto">
          <button
            onClick={onToggleSound}
            aria-label={soundEnabled ? 'Mute Sound' : 'Enable Sound'}
            className="w-10 h-10 rounded-full flex items-center justify-center transition-transform active:scale-90 hover:brightness-110"
            style={{
              backgroundColor: `${theme.surface}CC`,
              border: '1px solid rgba(255, 255, 255, 0.1)',
              color: theme.text,
            }}
          >
            {soundEnabled ? <Volume2 size={18} /> : <VolumeX size={18} />}
          </button>

          <button
            onClick={onPause}
            aria-label="Pause Game"
            className="w-10 h-10 rounded-full flex items-center justify-center transition-transform active:scale-90 hover:brightness-110"
            style={{
              backgroundColor: `${theme.surface}CC`,
              border: '1px solid rgba(255, 255, 255, 0.1)',
              color: theme.text,
            }}
          >
            <Pause size={18} />
          </button>
        </div>
      </div>

      {/* Subtle Bottom Tap Hint on start */}
      {score === 0 && (
        <div className="self-center mb-8 text-center animate-pulse">
          <span
            className="text-xs font-semibold tracking-wider uppercase px-3 py-1 rounded-full"
            style={{
              backgroundColor: `${theme.surface}99`,
              color: theme.secondaryText,
              border: '1px solid rgba(255, 255, 255, 0.05)',
            }}
          >
            Tap anywhere to stack
          </span>
        </div>
      )}
    </div>
  );
};
