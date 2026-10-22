import React from 'react';
import { X, ArrowLeftRight, Fingerprint, Sparkles, Scissors, Flag } from 'lucide-react';
import { GameTheme } from '../types/game';

interface TutorialModalProps {
  theme: GameTheme;
  onClose: () => void;
}

export const TutorialModal: React.FC<TutorialModalProps> = ({ theme, onClose }) => {
  const steps = [
    {
      num: '01',
      title: 'Automatic Movement',
      desc: 'Each block glides horizontally across the playfield with speed scaling gently as the stack climbs.',
      icon: ArrowLeftRight,
      color: theme.primaryAccent,
    },
    {
      num: '02',
      title: 'Single-Tap Timing',
      desc: 'Tap anywhere or hit Space / Enter to lock the moving block directly above the existing tower.',
      icon: Fingerprint,
      color: theme.secondaryAccent,
    },
    {
      num: '03',
      title: 'Precision Snapping & Pitch Combos',
      desc: 'Align within precision tolerance to snap cleanly, preserve width, and escalate musical chimes higher with each consecutive perfect stack (NICE! GREAT! AMAZING! LEGENDARY!).',
      icon: Sparkles,
      color: theme.successAccent,
    },
    {
      num: '04',
      title: 'Physics Trimming',
      desc: 'Any misaligned overhang is sliced away and falls with gravity. The retained overlap becomes your new platform.',
      icon: Scissors,
      color: theme.warningAccent,
    },
    {
      num: '05',
      title: 'Zero Overlap Game Over',
      desc: 'If a block misses the tower completely, the run concludes and your stats are saved to local storage.',
      icon: Flag,
      color: '#F43F5E',
    },
  ];

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
              How to Play
            </h2>
            <p className="text-xs opacity-70 mt-0.5" style={{ color: theme.secondaryText }}>
              Master precision timing to build an infinite tower
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

        {/* Steps List */}
        <div className="flex flex-col gap-3 my-4 overflow-y-auto pr-1">
          {steps.map((s) => {
            const Icon = s.icon;
            return (
              <div
                key={s.num}
                className="p-3.5 rounded-2xl flex items-start gap-3.5"
                style={{
                  backgroundColor: 'rgba(0, 0, 0, 0.25)',
                  border: '1px solid rgba(255, 255, 255, 0.06)',
                }}
              >
                <div
                  className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0 mt-0.5"
                  style={{ backgroundColor: `${s.color}18`, color: s.color }}
                >
                  <Icon size={20} />
                </div>
                <div className="flex-1">
                  <div className="flex items-center justify-between">
                    <span className="font-bold text-sm" style={{ color: theme.text }}>
                      {s.title}
                    </span>
                    <span className="text-[10px] font-black tracking-wider opacity-60" style={{ color: s.color }}>
                      {s.num}
                    </span>
                  </div>
                  <p className="text-xs leading-relaxed mt-1" style={{ color: theme.secondaryText }}>
                    {s.desc}
                  </p>
                </div>
              </div>
            );
          })}
        </div>

        {/* Footer */}
        <button
          onClick={onClose}
          className="w-full py-3.5 rounded-xl font-bold text-sm transition-all active:scale-95 cursor-pointer shadow-lg"
          style={{
            backgroundColor: theme.primaryAccent,
            color: '#0B1020',
            boxShadow: `0 4px 18px ${theme.primaryAccent}40`,
          }}
        >
          GOT IT, LET'S STACK
        </button>
      </div>
    </div>
  );
};
