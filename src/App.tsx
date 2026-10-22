import React, { useState, useEffect, useRef, useCallback } from 'react';
import { GameScreenState, GameSettings, GameStatistics, GAME_THEMES, ThemeId } from './types/game';
import { storageService } from './services/storage';
import { soundService } from './services/audio';
import { GameCanvas, GameCanvasHandle } from './components/GameCanvas';
import { GameHud } from './components/GameHud';
import { HomeScreen } from './components/HomeScreen';
import { PauseModal } from './components/PauseModal';
import { GameOverModal } from './components/GameOverModal';
import { ThemesModal } from './components/ThemesModal';
import { SettingsModal } from './components/SettingsModal';
import { TutorialModal } from './components/TutorialModal';
import { FlutterProjectModal } from './components/FlutterProjectModal';

export default function App() {
  // State
  const [screenState, setScreenState] = useState<GameScreenState>('TITLE');
  const [currentScore, setCurrentScore] = useState<number>(0);
  const [currentStreak, setCurrentStreak] = useState<number>(0);
  const [streakBadge, setStreakBadge] = useState<string | null>(null);
  const [isNewBest, setIsNewBest] = useState<boolean>(false);
  const [finalScore, setFinalScore] = useState<number>(0);
  const [bestStreakInRun, setBestStreakInRun] = useState<number>(0);

  // Modals
  const [showThemesModal, setShowThemesModal] = useState<boolean>(false);
  const [showSettingsModal, setShowSettingsModal] = useState<boolean>(false);
  const [showTutorialModal, setShowTutorialModal] = useState<boolean>(false);
  const [showFlutterModal, setShowFlutterModal] = useState<boolean>(false);

  // Persistence
  const [settings, setSettings] = useState<GameSettings>(() => storageService.loadSettings());
  const [statistics, setStatistics] = useState<GameStatistics>(() => storageService.loadStatistics());

  const canvasHandleRef = useRef<GameCanvasHandle | null>(null);
  const currentTheme = GAME_THEMES[settings.selectedTheme] || GAME_THEMES.midnightNeon;

  // Sync audio mute state
  useEffect(() => {
    soundService.setMuted(!settings.soundEnabled);
  }, [settings.soundEnabled]);

  // Update Settings
  const handleUpdateSettings = (updated: GameSettings) => {
    setSettings(updated);
    storageService.saveSettings(updated);
    canvasHandleRef.current?.updateAudioHaptics(
      updated.soundEnabled,
      updated.hapticsEnabled,
      updated.reducedMotion
    );
  };

  // Select Theme
  const handleSelectTheme = (themeId: ThemeId) => {
    const updated = { ...settings, selectedTheme: themeId };
    handleUpdateSettings(updated);
    const newTheme = GAME_THEMES[themeId];
    if (newTheme) {
      canvasHandleRef.current?.updateTheme(newTheme);
    }
  };

  // Start New Game
  const handleStartGame = useCallback(() => {
    soundService.playUiClick();
    setScreenState('PLAYING');
    setCurrentScore(0);
    setCurrentStreak(0);
    setStreakBadge(null);
    setIsNewBest(false);
    canvasHandleRef.current?.startNewGame();
  }, []);

  // Pause
  const handlePause = useCallback(() => {
    if (screenState === 'PLAYING') {
      soundService.playUiClick();
      canvasHandleRef.current?.pause();
      setScreenState('PAUSED');
    }
  }, [screenState]);

  // Resume
  const handleResume = useCallback(() => {
    if (screenState === 'PAUSED') {
      soundService.playUiClick();
      canvasHandleRef.current?.resume();
      setScreenState('PLAYING');
    }
  }, [screenState]);

  // Restart
  const handleRestart = useCallback(() => {
    handleStartGame();
  }, [handleStartGame]);

  // Home
  const handleHome = useCallback(() => {
    soundService.playUiClick();
    setScreenState('TITLE');
  }, []);

  // Toggle Sound in HUD
  const handleToggleSound = () => {
    handleUpdateSettings({ ...settings, soundEnabled: !settings.soundEnabled });
  };

  // Reset Stats
  const handleResetStats = () => {
    const cleanStats: GameStatistics = {
      bestScore: 0,
      bestStreak: 0,
      totalGamesPlayed: 0,
      totalBlocksPlaced: 0,
      totalPerfectPlacements: 0,
    };
    setStatistics(cleanStats);
    storageService.saveStatistics(cleanStats);
    setShowSettingsModal(false);
  };

  // Game Callbacks from isolated Engine
  const callbacks = useRef({
    onScoreUpdate: (score: number, streak: number, badge: string | null) => {
      setCurrentScore(score);
      setCurrentStreak(streak);
      setStreakBadge(badge);
    },
    onGameOver: (score: number, bestStreak: number) => {
      const isRecord = score > statistics.bestScore;
      const updatedStats: GameStatistics = {
        bestScore: isRecord ? score : statistics.bestScore,
        bestStreak: Math.max(bestStreak, statistics.bestStreak),
        totalGamesPlayed: statistics.totalGamesPlayed + 1,
        totalBlocksPlaced: statistics.totalBlocksPlaced + score,
        totalPerfectPlacements: statistics.totalPerfectPlacements + bestStreak,
      };

      setStatistics(updatedStats);
      storageService.saveStatistics(updatedStats);

      setFinalScore(score);
      setBestStreakInRun(bestStreak);
      setIsNewBest(isRecord);
      setScreenState('GAME_OVER');
    },
    onStateChange: (_state: 'MOVING' | 'PLACING' | 'PAUSED' | 'GAME_OVER') => {
      // Internal engine state transitions
    },
  }).current;

  // Keyboard shortcut listener
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) {
        return;
      }

      // Space or Enter
      if (e.code === 'Space' || e.code === 'Enter') {
        e.preventDefault();
        if (screenState === 'TITLE') {
          handleStartGame();
        } else if (screenState === 'PLAYING') {
          canvasHandleRef.current?.handleTap();
        } else if (screenState === 'GAME_OVER') {
          handleRestart();
        }
      }

      // Escape key for Pause / Resume
      if (e.code === 'Escape') {
        e.preventDefault();
        if (screenState === 'PLAYING') {
          handlePause();
        } else if (screenState === 'PAUSED') {
          handleResume();
        } else if (showThemesModal) {
          setShowThemesModal(false);
        } else if (showSettingsModal) {
          setShowSettingsModal(false);
        } else if (showTutorialModal) {
          setShowTutorialModal(false);
        } else if (showFlutterModal) {
          setShowFlutterModal(false);
        }
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [
    screenState,
    handleStartGame,
    handlePause,
    handleResume,
    handleRestart,
    showThemesModal,
    showSettingsModal,
    showTutorialModal,
    showFlutterModal,
  ]);

  return (
    <div
      className="fixed inset-0 w-screen h-screen overflow-hidden flex items-center justify-center select-none"
      style={{ backgroundColor: currentTheme.background }}
    >
      {/* Container: either Full Viewport or Simulated Android Portrait Chassis */}
      <div
        className={`relative w-full h-full flex flex-col overflow-hidden transition-all duration-300 ${
          settings.deviceFrame
            ? 'max-w-[420px] max-h-[880px] rounded-[44px] shadow-[0_0_60px_rgba(0,0,0,0.8)] border-[10px] border-slate-800'
            : ''
        }`}
        style={{ backgroundColor: currentTheme.background }}
      >
        {/* Android Device Frame Camera Notch / Speaker Bar (when frame mode enabled) */}
        {settings.deviceFrame && (
          <div className="absolute top-2 left-1/2 -translate-x-1/2 w-28 h-4 rounded-full bg-black/60 z-50 flex items-center justify-center pointer-events-none">
            <div className="w-10 h-1 rounded-full bg-white/20" />
            <div className="w-2.5 h-2.5 rounded-full bg-black ml-3 border border-white/10" />
          </div>
        )}

        {/* 60fps Isolated Canvas Layer */}
        <div className="absolute inset-0 w-full h-full z-0">
          <GameCanvas
            ref={canvasHandleRef}
            theme={currentTheme}
            soundEnabled={settings.soundEnabled}
            hapticsEnabled={settings.hapticsEnabled}
            reducedMotion={settings.reducedMotion}
            callbacks={callbacks}
          />
        </div>

        {/* Title Screen Overlay */}
        {screenState === 'TITLE' && (
          <HomeScreen
            theme={currentTheme}
            statistics={statistics}
            onPlay={handleStartGame}
            onThemes={() => setShowThemesModal(true)}
            onSettings={() => setShowSettingsModal(true)}
            onTutorial={() => setShowTutorialModal(true)}
            onFlutterHub={() => setShowFlutterModal(true)}
          />
        )}

        {/* Playing HUD Overlay */}
        {screenState === 'PLAYING' && (
          <GameHud
            score={currentScore}
            bestScore={statistics.bestScore}
            streakBadge={streakBadge}
            theme={currentTheme}
            soundEnabled={settings.soundEnabled}
            onToggleSound={handleToggleSound}
            onPause={handlePause}
          />
        )}

        {/* Pause Modal */}
        {screenState === 'PAUSED' && (
          <PauseModal
            theme={currentTheme}
            onResume={handleResume}
            onRestart={handleRestart}
            onSettings={() => setShowSettingsModal(true)}
            onHome={handleHome}
          />
        )}

        {/* Game Over Modal */}
        {screenState === 'GAME_OVER' && (
          <GameOverModal
            score={finalScore}
            bestScore={statistics.bestScore}
            bestStreak={bestStreakInRun}
            isNewBest={isNewBest}
            theme={currentTheme}
            onRetry={handleRestart}
            onHome={handleHome}
          />
        )}

        {/* Themes Selector Modal */}
        {showThemesModal && (
          <ThemesModal
            currentTheme={currentTheme}
            bestScore={statistics.bestScore}
            onSelectTheme={handleSelectTheme}
            onClose={() => setShowThemesModal(false)}
          />
        )}

        {/* Settings Modal */}
        {showSettingsModal && (
          <SettingsModal
            theme={currentTheme}
            settings={settings}
            onUpdateSettings={handleUpdateSettings}
            onResetStats={handleResetStats}
            onClose={() => setShowSettingsModal(false)}
          />
        )}

        {/* Tutorial / How to Play Modal */}
        {showTutorialModal && (
          <TutorialModal
            theme={currentTheme}
            onClose={() => setShowTutorialModal(false)}
          />
        )}

        {/* Flutter + Flame Project Explorer Modal */}
        {showFlutterModal && (
          <FlutterProjectModal
            theme={currentTheme}
            onClose={() => setShowFlutterModal(false)}
          />
        )}
      </div>
    </div>
  );
}
