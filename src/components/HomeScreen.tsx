import React from 'react';
import { Play, Palette, HelpCircle, Settings, Code, Trophy } from 'lucide-react';
import { GameTheme, GameStatistics } from '../types/game';

interface HomeScreenProps {
  theme: GameTheme;
  statistics: GameStatistics;
  onPlay: () => void;
  onThemes: () => void;
  onSettings: () => void;
  onTutorial: () => void;
  onFlutterHub: () => void;
}

export const HomeScreen: React.FC<HomeScreenProps> = ({
  theme,
  statistics,
  onPlay,
  onThemes,
  onSettings,
  onTutorial,
  onFlutterHub,
}) => {
  return (
    <div
      className="absolute inset-0 z-20 flex flex-col justify-between p-6 sm:p-8 select-none overflow-y-auto"
      style={{ backgroundColor: theme.background }}
    >
      {/* Top Bar with Trophy & Settings */}
      <div className="flex items-center justify-between w-full">
        <div
          className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full text-xs font-semibold"
          style={{
            backgroundColor: theme.surface,
            border: '1px solid rgba(255, 255, 255, 0.08)',
            color: theme.text,
          }}
        >
          <Trophy size={14} style={{ color: theme.warningAccent }} />
          <span>BEST SCORE</span>
          <span className="font-mono font-bold tabular-nums" style={{ color: theme.primaryAccent }}>
            {statistics.bestScore}
          </span>
        </div>

        <button
          onClick={onSettings}
          className="w-10 h-10 rounded-full flex items-center justify-center transition-transform active:scale-90 hover:brightness-110"
          style={{
            backgroundColor: theme.surface,
            border: '1px solid rgba(255, 255, 255, 0.08)',
            color: theme.text,
          }}
          aria-label="Settings"
        >
          <Settings size={18} />
        </button>
      </div>

      {/* Hero Centerpiece: Bespoke SVG Title Lockup & Geometric Stacking Icon */}
      <div className="flex flex-col items-center justify-center my-auto py-8">
        {/* Animated Geometric Neon Stack Emblem */}
        <div
          className="relative w-28 h-28 rounded-3xl flex flex-col items-center justify-center p-3 mb-6 transition-transform hover:scale-105"
          style={{
            backgroundColor: theme.surface,
            border: `1.5px solid ${theme.primaryAccent}40`,
            boxShadow: `0 12px 32px -4px ${theme.primaryAccent}30`,
          }}
        >
          <div
            className="w-10 h-3 rounded-sm mb-1.5 shadow-sm animate-pulse"
            style={{ backgroundColor: theme.blockPalette[0] }}
          />
          <div
            className="w-14 h-3 rounded-sm mb-1.5 shadow-sm"
            style={{ backgroundColor: theme.blockPalette[1] }}
          />
          <div
            className="w-18 h-3 rounded-sm mb-1.5 shadow-sm"
            style={{ backgroundColor: theme.blockPalette[2] }}
          />
          <div
            className="w-22 h-3.5 rounded-sm shadow-sm"
            style={{ backgroundColor: theme.blockPalette[3] || theme.blockPalette[0] }}
          />
        </div>

        {/* Bespoke Inline SVG Title Lockup */}
        <svg
          viewBox="0 0 320 48"
          className="w-64 sm:w-72 h-auto max-w-full drop-shadow-lg"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <text
            x="50%"
            y="36"
            textAnchor="middle"
            fill={theme.text}
            fontSize="32"
            fontWeight="900"
            letterSpacing="6"
            fontFamily="'Plus Jakarta Sans', sans-serif"
          >
            STACK PULSE
          </text>
        </svg>

        <p
          className="text-xs sm:text-sm font-medium tracking-wide mt-1.5 text-center"
          style={{ color: theme.secondaryText }}
        >
          One Tap. Perfect Stack.
        </p>

        {/* Current Theme Pill */}
        <div
          className="mt-4 px-3 py-1 rounded-full text-[11px] font-semibold tracking-wider uppercase flex items-center gap-1.5"
          style={{
            backgroundColor: `${theme.primaryAccent}15`,
            color: theme.primaryAccent,
            border: `1px solid ${theme.primaryAccent}30`,
          }}
        >
          <span className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: theme.primaryAccent }} />
          <span>{theme.name} Theme</span>
        </div>
      </div>

      {/* Action Cluster & Flat Control-Hint Line */}
      <div className="flex flex-col gap-3 w-full max-w-sm mx-auto">
        {/* Primary Start CTA */}
        <button
          onClick={onPlay}
          className="w-full py-4 rounded-2xl flex items-center justify-center gap-2.5 font-bold text-base transition-all active:scale-[0.98] shadow-lg cursor-pointer"
          style={{
            backgroundColor: theme.primaryAccent,
            color: '#0B1020',
            boxShadow: `0 8px 24px -2px ${theme.primaryAccent}50`,
          }}
        >
          <Play size={20} fill="#0B1020" />
          <span>START GAME</span>
        </button>

        {/* Secondary Buttons Row */}
        <div className="grid grid-cols-2 gap-2.5">
          <button
            onClick={onThemes}
            className="py-3 px-3 rounded-xl flex items-center justify-center gap-2 text-xs font-bold transition-all active:scale-[0.98] hover:brightness-110 cursor-pointer"
            style={{
              backgroundColor: theme.surface,
              color: theme.text,
              border: '1px solid rgba(255, 255, 255, 0.08)',
            }}
          >
            <Palette size={15} style={{ color: theme.secondaryAccent }} />
            <span>THEMES</span>
          </button>

          <button
            onClick={onTutorial}
            className="py-3 px-3 rounded-xl flex items-center justify-center gap-2 text-xs font-bold transition-all active:scale-[0.98] hover:brightness-110 cursor-pointer"
            style={{
              backgroundColor: theme.surface,
              color: theme.text,
              border: '1px solid rgba(255, 255, 255, 0.08)',
            }}
          >
            <HelpCircle size={15} style={{ color: theme.primaryAccent }} />
            <span>HOW TO PLAY</span>
          </button>
        </div>

        {/* Flutter Project Source & APK Guide Hub Button */}
        <button
          onClick={onFlutterHub}
          className="py-2.5 px-3 rounded-xl flex items-center justify-center gap-2 text-xs font-semibold transition-all active:scale-[0.98] hover:brightness-110 cursor-pointer"
          style={{
            backgroundColor: `${theme.surface}90`,
            color: theme.secondaryText,
            border: '1px solid rgba(255, 255, 255, 0.06)',
          }}
        >
          <Code size={14} style={{ color: theme.successAccent }} />
          <span>Flutter + Flame Project Files & APK Guide</span>
        </button>

        {/* Flat Control-Hint Line */}
        <div className="text-center mt-2">
          <span className="text-[11px] font-medium tracking-wider uppercase opacity-60" style={{ color: theme.secondaryText }}>
            Tap / Space to Stack · Esc Pause
          </span>
        </div>
      </div>
    </div>
  );
};
