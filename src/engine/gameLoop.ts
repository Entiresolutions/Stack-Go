import { GameTheme, PlacementResult } from '../types/game';
import { PlacementEngine } from './placementEngine';
import { soundService } from '../services/audio';
import { storageService } from '../services/storage';

export interface GameCallbacks {
  onScoreUpdate: (score: number, streak: number, badge: string | null) => void;
  onGameOver: (finalScore: number, bestStreak: number) => void;
  onStateChange: (state: 'MOVING' | 'PLACING' | 'PAUSED' | 'GAME_OVER') => void;
}

interface PlacedBlock {
  left: number;
  width: number;
  y: number; // in world coordinates (0 = ground, goes upward)
  color: string;
}

interface FallingPiece {
  x: number;
  y: number;
  width: number;
  height: number;
  vy: number;
  angle: number;
  vRot: number;
  opacity: number;
  color: string;
}

interface Particle {
  x: number;
  y: number;
  vx: number;
  vy: number;
  size: number;
  life: number;
  maxLife: number;
  color: string;
}

export class GameEngine {
  private canvas: HTMLCanvasElement;
  private ctx: CanvasRenderingContext2D;
  private callbacks: GameCallbacks;

  // Viewport & Scale
  public readonly logicalWidth = 360;
  public readonly logicalHeight = 640;
  private scale = 1;
  private dpr = 1;

  // Game Configuration
  private readonly baseWidth = 210;
  private readonly blockHeight = 26;
  private readonly basePositionY = 120;
  private readonly boundaryPadding = 12;

  // Gameplay State
  private running = false;
  private isPaused = false;
  private isGameOver = false;
  private score = 0;
  private streak = 0;
  private bestStreakInRun = 0;

  // Active theme & settings
  public theme: GameTheme;
  public soundEnabled = true;
  public hapticsEnabled = true;
  public reducedMotion = false;

  // World objects
  private placedBlocks: PlacedBlock[] = [];
  private fallingPieces: FallingPiece[] = [];
  private particles: Particle[] = [];

  // Active moving block
  private movingX = 0;
  private movingWidth = 210;
  private movingY = 0;
  private movingSpeed = 160;
  private movingDirection = 1; // 1 = right, -1 = left
  private nextDirection = 1;
  private activeBlockColor = '';

  // Camera
  private cameraOffsetY = 0;
  private targetCameraOffsetY = 0;

  // Visual effects
  private cameraShake = 0;
  private perfectFlashOpacity = 0;

  // Loop tracking
  private lastTimestamp = 0;
  private animFrameId: number | null = null;

  constructor(canvas: HTMLCanvasElement, theme: GameTheme, callbacks: GameCallbacks) {
    this.canvas = canvas;
    const context = canvas.getContext('2d');
    if (!context) throw new Error('2D context not supported');
    this.ctx = context;
    this.theme = theme;
    this.callbacks = callbacks;

    this.resize();
    window.addEventListener('resize', this.handleResize);
    window.addEventListener('blur', this.handleBlur);
  }

  private handleResize = () => {
    this.resize();
  };

  private handleBlur = () => {
    if (this.running && !this.isPaused && !this.isGameOver) {
      this.pause();
    }
  };

  public resize() {
    const parent = this.canvas.parentElement;
    if (!parent) return;

    const rect = parent.getBoundingClientRect();
    this.dpr = Math.min(window.devicePixelRatio || 1, 3);

    // Calculate best fit maintaining 360:640 aspect ratio
    const targetRatio = this.logicalWidth / this.logicalHeight;
    const parentRatio = rect.width / rect.height;

    let displayWidth: number;
    let displayHeight: number;

    if (parentRatio > targetRatio) {
      displayHeight = rect.height;
      displayWidth = rect.height * targetRatio;
    } else {
      displayWidth = rect.width;
      displayHeight = rect.width / targetRatio;
    }

    this.scale = displayWidth / this.logicalWidth;

    this.canvas.width = Math.round(displayWidth * this.dpr);
    this.canvas.height = Math.round(displayHeight * this.dpr);

    this.canvas.style.width = `${displayWidth}px`;
    this.canvas.style.height = `${displayHeight}px`;
  }

  public startNewGame() {
    this.running = true;
    this.isPaused = false;
    this.isGameOver = false;
    this.score = 0;
    this.streak = 0;
    this.bestStreakInRun = 0;
    this.cameraOffsetY = 0;
    this.targetCameraOffsetY = 0;
    this.cameraShake = 0;
    this.perfectFlashOpacity = 0;
    this.fallingPieces = [];
    this.particles = [];
    this.nextDirection = 1;

    // Reset tower to base platform
    const startLeft = (this.logicalWidth - this.baseWidth) / 2;
    this.placedBlocks = [
      {
        left: startLeft,
        width: this.baseWidth,
        y: this.basePositionY,
        color: this.theme.blockPalette[0],
      },
    ];

    this.spawnMovingBlock();
    this.callbacks.onStateChange('MOVING');
    this.callbacks.onScoreUpdate(0, 0, null);

    this.lastTimestamp = performance.now();
    if (this.animFrameId) cancelAnimationFrame(this.animFrameId);
    this.animFrameId = requestAnimationFrame(this.loop);
  }

  private spawnMovingBlock() {
    const lastBlock = this.placedBlocks[this.placedBlocks.length - 1];
    this.movingWidth = lastBlock.width;
    this.movingY = lastBlock.y + this.blockHeight;
    this.movingSpeed = PlacementEngine.calculateSpeed(this.score);

    this.movingDirection = this.nextDirection;
    this.nextDirection = -this.nextDirection;

    // Position block at side boundary
    if (this.movingDirection === 1) {
      this.movingX = this.boundaryPadding;
    } else {
      this.movingX = this.logicalWidth - this.movingWidth - this.boundaryPadding;
    }

    const colorIdx = this.placedBlocks.length % this.theme.blockPalette.length;
    this.activeBlockColor = this.theme.blockPalette[colorIdx];

    this.callbacks.onStateChange('MOVING');
  }

  public handleTap(): boolean {
    if (!this.running || this.isPaused || this.isGameOver) return false;

    // Lock placement input immediately
    this.callbacks.onStateChange('PLACING');

    const lastBlock = this.placedBlocks[this.placedBlocks.length - 1];
    const result: PlacementResult = PlacementEngine.calculatePlacement(
      lastBlock.left,
      lastBlock.width,
      this.movingX,
      this.movingWidth
    );

    if (result.type === 'miss') {
      this.handleMiss();
    } else {
      this.handleSuccess(result);
    }

    return true;
  }

  private handleSuccess(result: PlacementResult) {
    const isPerfect = result.type === 'perfect';
    this.score++;

    let badge: string | null = null;
    if (isPerfect) {
      this.streak++;
      if (this.streak > this.bestStreakInRun) {
        this.bestStreakInRun = this.streak;
      }
      badge = PlacementEngine.getStreakBadge(this.streak);

      // Trigger audio & haptics
      if (this.soundEnabled) {
        soundService.playPerfectPlacement(this.score, this.streak);
      }
      if (this.hapticsEnabled) {
        storageService.triggerHaptic(this.streak >= 5 ? 'heavy' : 'medium', true);
      }

      // Visual glow & particles scaling with streak intensity
      this.perfectFlashOpacity = Math.min(1.0, 0.7 + this.streak * 0.05);
      if (!this.reducedMotion) {
        const particleCount = Math.min(48, 20 + this.streak * 4);
        this.emitParticles(
          result.retainedLeft + result.retainedWidth / 2,
          this.movingY + this.blockHeight / 2,
          this.theme.primaryAccent,
          particleCount
        );
      }
    } else {
      this.streak = 0;
      if (this.soundEnabled) {
        soundService.playNormalPlacement(this.score);
      }
      if (this.hapticsEnabled) {
        storageService.triggerHaptic('light', true);
      }
    }

    // Add placed block to stack
    this.placedBlocks.push({
      left: result.retainedLeft,
      width: result.retainedWidth,
      y: this.movingY,
      color: this.activeBlockColor,
    });

    // Spawn falling piece for excess overhang
    if (result.type === 'partial' && result.excessLeft !== undefined && result.excessWidth !== undefined) {
      this.fallingPieces.push({
        x: result.excessLeft,
        y: this.movingY,
        width: result.excessWidth,
        height: this.blockHeight,
        vy: 30,
        angle: 0,
        vRot: result.isExcessOnRight ? 0.08 : -0.08,
        opacity: 0.9,
        color: this.activeBlockColor,
      });
    }

    // Camera target update: keep moving block around Y=320 in logical screen
    if (this.movingY > 300) {
      this.targetCameraOffsetY = this.movingY - 300;
    }

    this.callbacks.onScoreUpdate(this.score, this.streak, badge);

    // Spawn next block
    this.spawnMovingBlock();
  }

  private handleMiss() {
    this.isGameOver = true;
    this.callbacks.onStateChange('GAME_OVER');

    if (this.soundEnabled) {
      soundService.playGameOver();
    }
    if (this.hapticsEnabled) {
      storageService.triggerHaptic('heavy', true);
    }
    if (!this.reducedMotion) {
      this.cameraShake = 12;
    }

    // Missed piece drops away
    this.fallingPieces.push({
      x: this.movingX,
      y: this.movingY,
      width: this.movingWidth,
      height: this.blockHeight,
      vy: 40,
      angle: 0,
      vRot: this.movingDirection * 0.1,
      opacity: 1,
      color: this.activeBlockColor,
    });

    this.callbacks.onGameOver(this.score, this.bestStreakInRun);
  }

  private emitParticles(x: number, y: number, color: string, count: number) {
    for (let i = 0; i < count; i++) {
      const angle = (Math.PI * 2 * i) / count + (Math.random() - 0.5) * 0.5;
      const speed = 70 + Math.random() * 120;
      this.particles.push({
        x,
        y,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed,
        size: 2.5 + Math.random() * 3,
        life: 0,
        maxLife: 0.5 + Math.random() * 0.3,
        color,
      });
    }
  }

  public pause() {
    if (this.running && !this.isGameOver) {
      this.isPaused = true;
      this.callbacks.onStateChange('PAUSED');
    }
  }

  public resume() {
    if (this.running && this.isPaused) {
      this.isPaused = false;
      this.lastTimestamp = performance.now();
      this.callbacks.onStateChange('MOVING');
    }
  }

  public updateTheme(newTheme: GameTheme) {
    this.theme = newTheme;
  }

  private loop = (timestamp: number) => {
    const rawDt = (timestamp - this.lastTimestamp) / 1000;
    this.lastTimestamp = timestamp;

    // Clamp frame delta to protect against tab suspension or frame drops
    const dt = Math.min(rawDt, 0.05);

    if (this.running && !this.isPaused) {
      this.update(dt);
    }

    this.render();

    this.animFrameId = requestAnimationFrame(this.loop);
  };

  private update(dt: number) {
    // 1. Moving Block
    if (!this.isGameOver) {
      this.movingX += this.movingSpeed * this.movingDirection * dt;

      // Bounce at boundary
      const minX = this.boundaryPadding;
      const maxX = this.logicalWidth - this.movingWidth - this.boundaryPadding;

      if (this.movingX <= minX) {
        this.movingX = minX;
        this.movingDirection = 1;
      } else if (this.movingX >= maxX) {
        this.movingX = maxX;
        this.movingDirection = -1;
      }
    }

    // 2. Camera smooth easing
    const diff = this.targetCameraOffsetY - this.cameraOffsetY;
    this.cameraOffsetY += diff * (5.5 * dt);

    // 3. Camera shake decay
    if (this.cameraShake > 0) {
      this.cameraShake = Math.max(0, this.cameraShake - 30 * dt);
    }

    // 4. Perfect flash decay
    if (this.perfectFlashOpacity > 0) {
      this.perfectFlashOpacity = Math.max(0, this.perfectFlashOpacity - 2.8 * dt);
    }

    // 5. Falling pieces physics
    const gravity = 800;
    for (let i = this.fallingPieces.length - 1; i >= 0; i--) {
      const piece = this.fallingPieces[i];
      piece.vy += gravity * dt;
      piece.y -= piece.vy * dt; // world y decreases as it falls
      piece.angle += piece.vRot;

      if (piece.y < this.cameraOffsetY - 200) {
        piece.opacity -= dt * 2;
      }

      if (piece.opacity <= 0 || piece.y < this.cameraOffsetY - 350) {
        this.fallingPieces.splice(i, 1);
      }
    }

    // 6. Particles
    for (let i = this.particles.length - 1; i >= 0; i--) {
      const p = this.particles[i];
      p.life += dt;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy -= 120 * dt; // gentle drift

      if (p.life >= p.maxLife) {
        this.particles.splice(i, 1);
      }
    }
  }

  private render() {
    const ctx = this.ctx;
    const width = this.canvas.width;
    const height = this.canvas.height;

    ctx.save();
    ctx.scale(this.scale * this.dpr, this.scale * this.dpr);

    // Camera shake offset
    let shakeX = 0;
    let shakeY = 0;
    if (this.cameraShake > 0) {
      shakeX = (Math.random() - 0.5) * this.cameraShake;
      shakeY = (Math.random() - 0.5) * this.cameraShake;
    }

    // Background fill
    ctx.fillStyle = this.theme.background;
    ctx.fillRect(0, 0, this.logicalWidth, this.logicalHeight);

    // Subtle atmospheric vertical gradient & grid
    const bgGrad = ctx.createLinearGradient(0, 0, 0, this.logicalHeight);
    bgGrad.addColorStop(0, this.theme.secondaryBackground);
    bgGrad.addColorStop(1, this.theme.background);
    ctx.fillStyle = bgGrad;
    ctx.fillRect(0, 0, this.logicalWidth, this.logicalHeight);

    // Subtle guide grid lines
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.025)';
    ctx.lineWidth = 1;
    for (let x = 36; x < this.logicalWidth; x += 36) {
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x, this.logicalHeight);
      ctx.stroke();
    }

    // Apply camera transform: Invert Y so 0 is at bottom
    ctx.save();
    ctx.translate(shakeX, shakeY);

    // World to screen transform: ScreenY = logicalHeight - (WorldY - cameraOffsetY)
    const toScreenY = (worldY: number) => this.logicalHeight - (worldY - this.cameraOffsetY);

    // Render Base Platform
    const baseGroundY = toScreenY(this.basePositionY - 6);
    ctx.fillStyle = this.theme.surface;
    ctx.beginPath();
    ctx.roundRect(this.boundaryPadding, baseGroundY, this.logicalWidth - this.boundaryPadding * 2, 8, 4);
    ctx.fill();

    // 1. Render Placed Blocks
    for (let i = 0; i < this.placedBlocks.length; i++) {
      const b = this.placedBlocks[i];
      const sy = toScreenY(b.y + this.blockHeight);

      // Cull offscreen blocks below viewport
      if (sy > this.logicalHeight + 50) continue;

      this.drawBlock(ctx, b.left, sy, b.width, this.blockHeight, b.color);
    }

    // 2. Render Active Moving Block
    if (!this.isGameOver && this.running) {
      const activeSy = toScreenY(this.movingY + this.blockHeight);
      this.drawBlock(ctx, this.movingX, activeSy, this.movingWidth, this.blockHeight, this.activeBlockColor, true);
    }

    // 3. Render Falling Pieces
    for (const piece of this.fallingPieces) {
      ctx.save();
      const psx = piece.x + piece.width / 2;
      const psy = toScreenY(piece.y + piece.height / 2);
      ctx.translate(psx, psy);
      ctx.rotate(piece.angle);
      ctx.globalAlpha = Math.max(0, Math.min(1, piece.opacity));

      this.drawBlock(ctx, -piece.width / 2, -piece.height / 2, piece.width, piece.height, piece.color);
      ctx.restore();
    }

    // 4. Render Particle Bursts
    for (const p of this.particles) {
      const progress = p.life / p.maxLife;
      const alpha = 1 - progress;
      const psy = toScreenY(p.y);

      ctx.save();
      ctx.globalAlpha = Math.max(0, alpha);
      ctx.fillStyle = p.color;
      ctx.beginPath();
      ctx.arc(p.x, psy, p.size * (1 - progress * 0.4), 0, Math.PI * 2);
      ctx.fill();
      ctx.restore();
    }

    // 5. Perfect Placement Glow Flash
    if (this.perfectFlashOpacity > 0) {
      ctx.save();
      ctx.fillStyle = this.theme.primaryAccent;
      ctx.globalAlpha = this.perfectFlashOpacity * 0.15;
      ctx.fillRect(0, 0, this.logicalWidth, this.logicalHeight);
      ctx.restore();
    }

    ctx.restore(); // restore camera transform
    ctx.restore(); // restore scale transform
  }

  private drawBlock(
    ctx: CanvasRenderingContext2D,
    x: number,
    y: number,
    width: number,
    height: number,
    color: string,
    isActive = false
  ) {
    if (width <= 0) return;

    ctx.save();

    // Subtle drop shadow for depth
    ctx.shadowColor = 'rgba(0, 0, 0, 0.35)';
    ctx.shadowBlur = 6;
    ctx.shadowOffsetY = 3;

    // Block body
    ctx.fillStyle = color;
    ctx.beginPath();
    ctx.roundRect(x, y, width, height, 4);
    ctx.fill();

    // Reset shadow for sheen & outline
    ctx.shadowColor = 'transparent';

    // Top sheen highlight
    ctx.fillStyle = 'rgba(255, 255, 255, 0.32)';
    ctx.beginPath();
    ctx.roundRect(x + 2, y + 2, Math.max(0, width - 4), 3, 2);
    ctx.fill();

    // Outer hairline border
    ctx.strokeStyle = isActive ? 'rgba(255, 255, 255, 0.4)' : 'rgba(255, 255, 255, 0.14)';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.roundRect(x, y, width, height, 4);
    ctx.stroke();

    ctx.restore();
  }

  public destroy() {
    this.running = false;
    if (this.animFrameId) cancelAnimationFrame(this.animFrameId);
    window.removeEventListener('resize', this.handleResize);
    window.removeEventListener('blur', this.handleBlur);
  }
}
