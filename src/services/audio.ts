/**
 * Procedural Web Audio API sound synthesizer
 * Zero external audio files, instant response, musical pentatonic progression.
 */

// Pentatonic scale frequencies across multiple octaves
const PENTATONIC_FREQUENCIES = [
  261.63, 293.66, 329.63, 392.00, 440.00, // C4, D4, E4, G4, A4
  523.25, 587.33, 659.25, 783.99, 880.00, // C5, D5, E5, G5, A5
  1046.50, 1174.66, 1318.51, 1567.98, 1760.00, // C6, D6, E6, G6, A6
  2093.00, 2349.32, 2637.02, 3135.96, 3520.00, // C7, D7, E7, G7, A7
];

class SoundSynthesizer {
  private ctx: AudioContext | null = null;
  private isMuted: boolean = false;

  private getContext(): AudioContext | null {
    if (this.isMuted) return null;
    if (!this.ctx) {
      const AudioCtx = window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
      if (AudioCtx) {
        this.ctx = new AudioCtx();
      }
    }
    if (this.ctx && this.ctx.state === 'suspended') {
      this.ctx.resume().catch(() => {});
    }
    return this.ctx;
  }

  public setMuted(muted: boolean) {
    this.isMuted = muted;
    if (muted && this.ctx && this.ctx.state === 'running') {
      this.ctx.suspend().catch(() => {});
    }
  }

  /**
   * Normal block placement ping.
   * Pitch scales with stack height following a pleasant pentatonic progression.
   */
  public playNormalPlacement(score: number) {
    const ctx = this.getContext();
    if (!ctx) return;

    const freqIndex = score % PENTATONIC_FREQUENCIES.length;
    const baseFreq = PENTATONIC_FREQUENCIES[freqIndex];

    const osc = ctx.createOscillator();
    const gain = ctx.createGain();

    osc.type = 'sine';
    osc.frequency.setValueAtTime(baseFreq, ctx.currentTime);

    gain.gain.setValueAtTime(0.18, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.18);

    osc.connect(gain);
    gain.connect(ctx.destination);

    osc.start();
    osc.stop(ctx.currentTime + 0.19);
  }

  // Dedicated ascending musical scale for consecutive perfect placements
  private static readonly STREAK_SCALE = [
    523.25,  // Streak 1: C5
    587.33,  // Streak 2: D5
    659.25,  // Streak 3: E5 (NICE!)
    783.99,  // Streak 4: G5
    880.00,  // Streak 5: A5 (AMAZING!)
    1046.50, // Streak 6: C6
    1174.66, // Streak 7: D6
    1318.51, // Streak 8: E6
    1567.98, // Streak 9: G6
    2093.00, // Streak 10+: C7 (LEGENDARY!)
  ];

  /**
   * Unique Sound Effect for Perfect Placements with Consecutive Streak Scaling.
   * Higher streak = higher musical pitch, richer shimmering harmonics, and celebratory flourishes!
   */
  public playPerfectPlacement(score: number, streak: number) {
    const ctx = this.getContext();
    if (!ctx) return;

    // Pitch rises with each consecutive perfect placement
    const streakIndex = Math.min(Math.max(0, streak - 1), SoundSynthesizer.STREAK_SCALE.length - 1);
    const baseFreq = SoundSynthesizer.STREAK_SCALE[streakIndex];
    // Rich harmonic: higher streaks get octave (2x) or fifth (1.5x) sparkle
    const harmonicFreq = streak >= 4 ? baseFreq * 2 : baseFreq * 1.5;

    const now = ctx.currentTime;

    // 1. Primary Bell Oscillator
    const osc1 = ctx.createOscillator();
    const gain1 = ctx.createGain();
    osc1.type = 'sine';
    osc1.frequency.setValueAtTime(baseFreq, now);

    // Slight micro-pitch rise for punchy attack
    osc1.frequency.exponentialRampToValueAtTime(baseFreq * 1.02, now + 0.03);
    osc1.frequency.exponentialRampToValueAtTime(baseFreq, now + 0.1);

    const baseVol = Math.min(0.28, 0.18 + streak * 0.015);
    gain1.gain.setValueAtTime(baseVol, now);
    gain1.gain.exponentialRampToValueAtTime(0.001, now + (streak >= 3 ? 0.38 : 0.28));

    osc1.connect(gain1);
    gain1.connect(ctx.destination);
    osc1.start(now);
    osc1.stop(now + 0.4);

    // 2. Crystal Shimmer / Harmonic Over Tone
    const osc2 = ctx.createOscillator();
    const gain2 = ctx.createGain();
    osc2.type = streak >= 5 ? 'triangle' : 'sine';
    osc2.frequency.setValueAtTime(harmonicFreq, now);

    const harmonicVol = Math.min(0.18, 0.08 + streak * 0.012);
    gain2.gain.setValueAtTime(harmonicVol, now + 0.01);
    gain2.gain.exponentialRampToValueAtTime(0.001, now + (streak >= 3 ? 0.42 : 0.25));

    osc2.connect(gain2);
    gain2.connect(ctx.destination);
    osc2.start(now);
    osc2.stop(now + 0.45);

    // 3. Ultra-Streak Resonant Ring (Streak 3+)
    if (streak >= 3) {
      const sparkleOsc = ctx.createOscillator();
      const sparkleGain = ctx.createGain();
      sparkleOsc.type = 'sine';
      // Sparkling overtone 2.5x
      sparkleOsc.frequency.setValueAtTime(baseFreq * 2.5, now + 0.04);

      sparkleGain.gain.setValueAtTime(0.08, now + 0.04);
      sparkleGain.gain.exponentialRampToValueAtTime(0.001, now + 0.35);

      sparkleOsc.connect(sparkleGain);
      sparkleGain.connect(ctx.destination);
      sparkleOsc.start(now + 0.04);
      sparkleOsc.stop(now + 0.36);
    }

    // 4. Milestone Ascending Arpeggio Flourish for big streaks
    if (streak === 2) {
      // Soft quick dual ping
      this.playQuickArpeggio([baseFreq, baseFreq * 1.25], 0.04);
    } else if (streak === 3) {
      // NICE! Milestone
      this.playQuickArpeggio([baseFreq, baseFreq * 1.25, baseFreq * 1.5], 0.04);
    } else if (streak >= 5 && streak < 10) {
      // AMAZING! Milestone
      this.playQuickArpeggio([523.25, 659.25, 783.99, 1046.50], 0.035);
    } else if (streak >= 10) {
      // LEGENDARY! Milestone
      this.playQuickArpeggio([659.25, 783.99, 1046.50, 1318.51, 2093.00], 0.03);
    }
  }

  /**
   * Fast celebratory musical arpeggio
   */
  private playQuickArpeggio(notes: number[], delaySec: number) {
    const ctx = this.getContext();
    if (!ctx) return;

    notes.forEach((freq, i) => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();

      const startTime = ctx.currentTime + 0.06 + i * delaySec;
      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, startTime);

      gain.gain.setValueAtTime(0.12, startTime);
      gain.gain.exponentialRampToValueAtTime(0.001, startTime + 0.22);

      osc.connect(gain);
      gain.connect(ctx.destination);

      osc.start(startTime);
      osc.stop(startTime + 0.23);
    });
  }

  /**
   * Game Over descending resonant tone
   */
  public playGameOver() {
    const ctx = this.getContext();
    if (!ctx) return;

    const osc = ctx.createOscillator();
    const gain = ctx.createGain();

    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(220, ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(55, ctx.currentTime + 0.45);

    gain.gain.setValueAtTime(0.18, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.45);

    osc.connect(gain);
    gain.connect(ctx.destination);

    osc.start();
    osc.stop(ctx.currentTime + 0.46);
  }

  /**
   * UI Click / Tap feedback
   */
  public playUiClick() {
    const ctx = this.getContext();
    if (!ctx) return;

    const osc = ctx.createOscillator();
    const gain = ctx.createGain();

    osc.type = 'sine';
    osc.frequency.setValueAtTime(800, ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(400, ctx.currentTime + 0.04);

    gain.gain.setValueAtTime(0.08, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.04);

    osc.connect(gain);
    gain.connect(ctx.destination);

    osc.start();
    osc.stop(ctx.currentTime + 0.045);
  }
}

export const soundService = new SoundSynthesizer();
