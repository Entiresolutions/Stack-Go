import React, { useEffect, useRef, useImperativeHandle, forwardRef } from 'react';
import { GameEngine, GameCallbacks } from '../engine/gameLoop';
import { GameTheme } from '../types/game';

export interface GameCanvasHandle {
  startNewGame: () => void;
  handleTap: () => boolean;
  pause: () => void;
  resume: () => void;
  updateTheme: (theme: GameTheme) => void;
  updateAudioHaptics: (sound: boolean, haptics: boolean, reducedMotion: boolean) => void;
}

interface GameCanvasProps {
  theme: GameTheme;
  soundEnabled: boolean;
  hapticsEnabled: boolean;
  reducedMotion: boolean;
  callbacks: GameCallbacks;
  onCanvasClick?: () => void;
}

export const GameCanvas = forwardRef<GameCanvasHandle, GameCanvasProps>(
  ({ theme, soundEnabled, hapticsEnabled, reducedMotion, callbacks, onCanvasClick }, ref) => {
    const canvasRef = useRef<HTMLCanvasElement | null>(null);
    const engineRef = useRef<GameEngine | null>(null);

    // Instantiate engine once
    useEffect(() => {
      if (!canvasRef.current) return;

      const engine = new GameEngine(canvasRef.current, theme, callbacks);
      engine.soundEnabled = soundEnabled;
      engine.hapticsEnabled = hapticsEnabled;
      engine.reducedMotion = reducedMotion;
      engineRef.current = engine;

      return () => {
        engine.destroy();
        engineRef.current = null;
      };
    }, []); // eslint-disable-line react-hooks/exhaustive-deps

    // Sync theme & settings dynamically without resetting game loop
    useEffect(() => {
      if (engineRef.current) {
        engineRef.current.updateTheme(theme);
        engineRef.current.soundEnabled = soundEnabled;
        engineRef.current.hapticsEnabled = hapticsEnabled;
        engineRef.current.reducedMotion = reducedMotion;
      }
    }, [theme, soundEnabled, hapticsEnabled, reducedMotion]);

    useImperativeHandle(ref, () => ({
      startNewGame: () => {
        engineRef.current?.startNewGame();
      },
      handleTap: () => {
        return engineRef.current?.handleTap() ?? false;
      },
      pause: () => {
        engineRef.current?.pause();
      },
      resume: () => {
        engineRef.current?.resume();
      },
      updateTheme: (newTheme: GameTheme) => {
        engineRef.current?.updateTheme(newTheme);
      },
      updateAudioHaptics: (sound: boolean, haptics: boolean, reduced: boolean) => {
        if (engineRef.current) {
          engineRef.current.soundEnabled = sound;
          engineRef.current.hapticsEnabled = haptics;
          engineRef.current.reducedMotion = reduced;
        }
      },
    }));

    const handlePointerDown = (e: React.PointerEvent) => {
      // Prevent default to avoid mobile double-tap zoom
      e.preventDefault();
      const placed = engineRef.current?.handleTap();
      if (placed && onCanvasClick) {
        onCanvasClick();
      }
    };

    return (
      <div className="relative w-full h-full flex items-center justify-center overflow-hidden touch-none select-none">
        <canvas
          ref={canvasRef}
          onPointerDown={handlePointerDown}
          className="cursor-pointer block shadow-2xl"
          style={{ imageRendering: 'auto' }}
        />
      </div>
    );
  }
);

GameCanvas.displayName = 'GameCanvas';
