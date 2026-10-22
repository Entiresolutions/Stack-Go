import React from 'react';
import { X, Check, Lock } from 'lucide-react';
import { GameTheme, ThemeId, GAME_THEMES } from '../types/game';

interface ThemesModalProps {
  currentTheme: GameTheme;
  bestScore: number;
  onSelectTheme: (themeId: ThemeId) => void;
  onClose: () => void;
}

export const ThemesModal: React.FC<ThemesModalProps> = ({
  currentTheme,
  bestScore,
  onSelectTheme,
  onClose,
}) => {
  const themesList = Object.values(GAME_THEMES);

  return (
    <div
      className="absolute inset-0 z-40 flex items-center justify-center p-4 sm:p-6 select-none"
      style={{ backgroundColor: 'rgba(11, 16, 32, 0.88)' }}
    >
      <div
        className="w-full max-w-md rounded-3xl p-6 shadow-2xl flex flex-col max-h-[90vh] overflow-hidden"
        style={{
          backgroundColor: currentTheme.surface,
          border: '1px solid rgba(255, 255, 255, 0.1)',
        }}
      >
        {/* Header */}
        <div className="flex items-center justify-between pb-4 border-b border-white/10">
          <div>
            <h2 className="text-xl font-black tracking-wide uppercase" style={{ color: currentTheme.text }}>
              Color Themes
            </h2>
            <p className="text-xs opacity-70 mt-0.5" style={{ color: currentTheme.secondaryText }}>
              Unlock dynamic neon palettes as your best score grows
            </p>
          </div>
          <button
            onClick={onClose}
            className="w-9 h-9 rounded-full flex items-center justify-center transition-transform active:scale-90"
            style={{ backgroundColor: 'rgba(255, 255, 255, 0.08)', color: currentTheme.text }}
          >
            <X size={18} />
          </button>
        </div>

        {/* Theme List */}
        <div className="flex flex-col gap-3 my-4 overflow-y-auto pr-1">
          {themesList.map((t) => {
            const isUnlocked = bestScore >= t.unlockScore;
            const isSelected = t.id === currentTheme.id;

            return (
              <div
                key={t.id}
                onClick={() => {
                  if (isUnlocked) onSelectTheme(t.id);
                }}
                className={`p-4 rounded-2xl transition-all flex items-center justify-between ${
                  isUnlocked ? 'cursor-pointer active:scale-[0.98]' : 'opacity-50 cursor-not-allowed'
                }`}
                style={{
                  backgroundColor: isSelected ? `${t.primaryAccent}15` : 'rgba(0, 0, 0, 0.25)',
                  border: isSelected ? `2px solid ${t.primaryAccent}` : '1px solid rgba(255, 255, 255, 0.06)',
                }}
              >
                {/* Left Info & Palette */}
                <div className="flex items-center gap-3.5">
                  {/* Palette Preview Swatch */}
                  <div
                    className="w-12 h-12 rounded-xl flex flex-col items-center justify-center p-1.5 shadow-inner"
                    style={{ backgroundColor: t.background, border: '1px solid rgba(255, 255, 255, 0.1)' }}
                  >
                    <div className="w-8 h-2 rounded-xs mb-1" style={{ backgroundColor: t.blockPalette[0] }} />
                    <div className="w-6 h-2 rounded-xs mb-1" style={{ backgroundColor: t.blockPalette[2] }} />
                    <div className="w-7 h-2 rounded-xs" style={{ backgroundColor: t.blockPalette[4] || t.blockPalette[1] }} />
                  </div>

                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-bold text-sm" style={{ color: currentTheme.text }}>
                        {t.name}
                      </span>
                      {isSelected && (
                        <span
                          className="text-[10px] font-black uppercase px-2 py-0.5 rounded-full"
                          style={{ backgroundColor: t.primaryAccent, color: '#0B1020' }}
                        >
                          Active
                        </span>
                      )}
                    </div>
                    <p className="text-xs line-clamp-1 mt-0.5" style={{ color: currentTheme.secondaryText }}>
                      {isUnlocked ? t.tagline : `Requires Best Score ${t.unlockScore}+`}
                    </p>
                  </div>
                </div>

                {/* Status Indicator */}
                <div>
                  {isSelected ? (
                    <div
                      className="w-8 h-8 rounded-full flex items-center justify-center"
                      style={{ backgroundColor: t.primaryAccent, color: '#0B1020' }}
                    >
                      <Check size={16} strokeWidth={3} />
                    </div>
                  ) : isUnlocked ? (
                    <span className="text-xs font-semibold px-2 py-1 rounded opacity-60" style={{ color: currentTheme.secondaryText }}>
                      Select
                    </span>
                  ) : (
                    <div className="flex items-center gap-1 opacity-70" style={{ color: currentTheme.warningAccent }}>
                      <Lock size={14} />
                      <span className="text-xs font-bold tabular-nums">{t.unlockScore}</span>
                    </div>
                  )}
                </div>
              </div>
            );
          })}
        </div>

        {/* Footer */}
        <button
          onClick={onClose}
          className="w-full py-3 rounded-xl font-bold text-sm transition-all active:scale-95 cursor-pointer"
          style={{
            backgroundColor: currentTheme.primaryAccent,
            color: '#0B1020',
          }}
        >
          DONE
        </button>
      </div>
    </div>
  );
};
