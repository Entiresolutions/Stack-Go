# STACK PULSE — Technical Requirements Document (TRD)

**Document Version:** 1.0.0  
**Target Systems:**  
1. Web Production: HTML5 Canvas 2D + React 19 + TypeScript (Vite bundler)  
2. Native Mobile: Flutter 3.10+ / Dart 3.0+ / Flame Engine ^1.20.0 (Android target)  

---

## 1. System Architecture & Dual Implementation Strategy

Stack Pulse utilizes a dual-target architecture:
- **Web Runtime**: High-throughput 60fps HTML5 Canvas engine managed via an isolated React wrapper (`GameCanvas.tsx`). React state updates are isolated outside the active `requestAnimationFrame` loop to guarantee zero frame stutter.
- **Flutter / Flame Runtime**: Fully modular Android application in `/flutter_stack_pulse` with Flame `World` and `CameraComponent`, pure Dart systems (`PlacementEngine`, `DifficultyController`, `CameraController`, `ScoreController`), and `shared_preferences` persistence.

```
                             STACK PULSE ARCHITECTURE
 ┌──────────────────────────────────────────────────────────────────────────────────┐
 │                               PRESENTATION LAYER                                 │
 │  ┌─────────────────────────────────┐   ┌──────────────────────────────────────┐  │
 │  │      Web Shell (React 19)       │   │       Flutter Widgets & Overlays     │  │
 │  │  • HomeScreen   • GameHud       │   │  • HomeScreen    • GameScreen        │  │
 │  │  • PauseModal   • GameOverModal │   │  • PauseOverlay  • GameOverOverlay   │  │
 │  │  • ThemesModal  • SettingsModal │   │  • ThemesScreen  • SettingsScreen    │  │
 │  └────────────────┬────────────────┘   └──────────────────┬───────────────────┘  │
 └───────────────────┼───────────────────────────────────────┼──────────────────────┘
                     │                                       │
 ┌───────────────────▼───────────────────────────────────────▼──────────────────────┐
 │                              GAME ENGINE LAYER                                   │
 │  ┌─────────────────────────────────┐   ┌──────────────────────────────────────┐  │
 │  │   HTML5 Canvas Engine (Web)     │   │     Flame Engine 1.20 (Flutter)      │  │
 │  │  • GameEngine.ts (60fps rAF)    │   │  • StackPulseGame with TapDetector   │  │
 │  │  • Viewport Scaling & Culling   │   │  • StackWorld & CameraComponent      │  │
 │  │  • Particle Pooling & Physics   │   │  • Component Tree (Stack, Moving,    │  │
 │  │  • Web Audio Synthesizer        │   │    FallingPiece, ParticleEffect)     │  │
 │  └────────────────┬────────────────┘   └──────────────────┬───────────────────┘  │
 └───────────────────┼───────────────────────────────────────┼──────────────────────┘
                     │                                       │
 ┌───────────────────▼───────────────────────────────────────▼──────────────────────┐
 │                     DETERMINISTIC MATHEMATICS & LOGIC                            │
 │  • PlacementEngine: Mathematical 1D Interval Intersection & Tolerance Snapping   │
 │  • DifficultyController: Linear Speed Ramp & Streak Milestones                   │
 │  • CameraController: Smooth Easing (Exponential Decay tracking)                  │
 │  • SoundSynthesizer / FeedbackService: Multi-Tier Pitch Escalation               │
 └──────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Mathematical Placement Engine Specification

Placement calculation is pure, deterministic, and free of physics collider noise.

### 2.1 Coordinate Invariants
- Let the previous stationary block have horizontal span $[L_p, R_p]$ with width $W_p = R_p - L_p$.
- Let the active moving block have horizontal span $[L_m, R_m]$ with width $W_m = R_m - L_m$ (where $W_m \equiv W_p$).

### 2.2 Alignment Tolerance
$$\text{Tolerance } T = \text{clamp}(W_p \times 0.025,\, 2.0,\, 5.0) \text{ units}$$

### 2.3 Evaluation Pipeline

```typescript
// Offset from perfect alignment
const offset = Math.abs(L_m - L_p);

// 1. Perfect Snap Check
if (offset <= T) {
  return {
    type: 'perfect',
    retainedLeft: L_p,
    retainedRight: R_p,
    retainedWidth: W_p,
    isExcessOnRight: false
  };
}

// 2. Interval Intersection
const overlapLeft = Math.max(L_p, L_m);
const overlapRight = Math.min(R_p, R_m);
const overlapWidth = Math.max(0.0, overlapRight - overlapLeft);

// 3. Failed Placement (Miss)
if (overlapWidth <= 0.001) {
  return {
    type: 'miss',
    retainedWidth: 0,
    isExcessOnRight: L_m > L_p
  };
}

// 4. Partial Placement (Trimming)
const isRightOverhang = L_m > L_p;
const excessLeft = isRightOverhang ? overlapRight : L_m;
const excessRight = isRightOverhang ? R_m : overlapLeft;
const excessWidth = excessRight - excessLeft;

return {
  type: 'partial',
  retainedLeft: overlapLeft,
  retainedRight: overlapRight,
  retainedWidth: overlapWidth,
  excessLeft,
  excessRight,
  excessWidth,
  isExcessOnRight: isRightOverhang
};
```

---

## 3. Motion & Difficulty Equations

### 3.1 Sliding Translation
$$\Delta x = v \cdot d \cdot \Delta t$$
Where:
- $v$ is horizontal speed (units/sec).
- $d \in \{-1, +1\}$ is translation direction vector.
- $\Delta t$ is delta time clamped to $\min(\Delta t_{\text{raw}}, 0.05)$ to prevent teleportation after browser suspension.

### 3.2 Speed Scaling
$$v(s) = \min(340,\, 160 + 5s) \quad \text{where } s = \text{score}$$

### 3.3 Debris Physics Simulation
$$\begin{aligned}
v_y(t + \Delta t) &= v_y(t) + g \cdot \Delta t \quad (g = 800\text{ units/s}^2) \\
y(t + \Delta t) &= y(t) - v_y \cdot \Delta t \\
\theta(t + \Delta t) &= \theta(t) + \omega \cdot \Delta t \quad (\omega \in [-0.15, +0.15]\text{ rad/tick})
\end{aligned}$$

---

## 4. Procedural Audio Synthesis Engine

The Web Audio API synthesizer constructs tones dynamically in memory without external audio assets.

### 4.1 Frequency Tables
- **Pentatonic Base**: $C_4$ (261.63 Hz) through $A_7$ (3520.00 Hz).
- **Ascending Streak Scale**:
  $$\text{STREAK\_SCALE} = [523.25, 587.33, 659.25, 783.99, 880.00, 1046.50, 1174.66, 1318.51, 1567.98, 2093.00]\text{ Hz}$$

### 4.2 ADSR & Harmonic Envelope Formulation
For consecutive streak $k \ge 1$:
1. **Primary Carrier**: Sine wave at $f_0 = \text{STREAK\_SCALE}[\min(k-1, 9)]$.
2. **Frequency Attack**: $f(t) = f_0 \times 1.02$ at $t_0 + 30\text{ms}$, ramping to $f_0$ at $t_0 + 100\text{ms}$.
3. **Harmonic Overtone**:
   $$f_{\text{harmonic}} = \begin{cases} 
   f_0 \times 1.5 & k < 4 \\
   f_0 \times 2.0 & k \ge 4 
   \end{cases}$$
4. **Gain Envelope**:
   $$A(t) = A_{\max} \cdot e^{-\alpha(t - t_0)} \quad \text{where } A_{\max} = \min(0.28, 0.18 + 0.015k)$$
5. **Milestone Chime Cascades**:
   - $k = 3$: 3-note ascending arpeggio $[f_0, 1.25f_0, 1.5f_0]$ with $40\text{ms}$ stagger.
   - $k \ge 5$: 4-note ascending chord $[C_5, E_5, G_5, C_6]$ with $35\text{ms}$ stagger.
   - $k \ge 10$: 5-note crystalline cascade $[E_5, G_5, C_6, E_6, C_7]$ with $30\text{ms}$ stagger.

---

## 5. Camera Transformation & Viewport Projection

### 5.1 World to Viewport Coordinate Mapping
$$\begin{aligned}
Y_{\text{screen}} &= H_{\text{logical}} - (Y_{\text{world}} - Y_{\text{camera}}) \\
X_{\text{screen}} &= X_{\text{world}} + X_{\text{shake}}
\end{aligned}$$

### 5.2 Smooth Camera Tracking
$$Y_{\text{target}} = \begin{cases}
Y_{\text{top}} - 300 & Y_{\text{top}} > 300 \\
0 & Y_{\text{top}} \le 300
\end{cases}$$
$$\frac{dY_{\text{camera}}}{dt} = 5.5 \cdot (Y_{\text{target}} - Y_{\text{camera}})$$

---

## 6. Finite State Machine (FSM)

```
        ┌─────────────┐
        │    TITLE    │
        └──────┬──────┘
               │ (Start Game)
               ▼
        ┌─────────────┐   (Pause)   ┌─────────────┐
        │   MOVING    │ ──────────> │   PAUSED    │
        └──────┬──────┘ <────────── └─────────────┘
               │          (Resume)
         (Tap) │
               ▼
        ┌─────────────┐
        │   PLACING   │
        └──────┬──────┘
               │
        ┌──────┴──────┐
(Success)│             │ (Miss)
        ▼             ▼
   [Next Block]   ┌─────────────┐
        │         │  GAME_OVER  │
        │         └──────┬──────┘
        │                │ (Play Again)
        └────────────────┘
```

---

## 7. Persistence Schema

### Web LocalStorage (`stack_pulse_web_stats` & `stack_pulse_web_settings`)
```json
{
  "bestScore": 42,
  "bestStreak": 7,
  "totalGamesPlayed": 18,
  "totalBlocksPlaced": 384,
  "totalPerfectPlacements": 92
}
```

### Flutter SharedPreferences Keys
- `stack_pulse_statistics`: JSON stringified `GameStatistics`.
- `stack_pulse_settings`: JSON stringified `GameSettings`.

---

## 8. Automated Unit Test Matrix

| Test Suite | Function Under Test | Input Condition | Expected Output | Status |
|:---|:---|:---|:---|:---|
| **PlacementEngine** | `calculatePlacement` | $offset \le \text{tolerance}$ | `type == 'perfect'`, full width preserved | PASS |
| **PlacementEngine** | `calculatePlacement` | $L_m = 95, L_p = 75, W = 200$ | `type == 'partial'`, $W_{\text{retained}} = 180$, $W_{\text{excess}} = 20$ | PASS |
| **PlacementEngine** | `calculatePlacement` | $L_m = 70, L_p = 100, W = 200$ | `type == 'partial'`, $W_{\text{retained}} = 170$, left excess | PASS |
| **PlacementEngine** | `calculatePlacement` | Zero overlap ($L_m = 200, R_p = 175$) | `type == 'miss'`, $W_{\text{retained}} = 0$ | PASS |
| **PlacementEngine** | `calculatePlacement` | Edge contact ($L_m = R_p$) | `type == 'miss'`, $W_{\text{retained}} = 0$ | PASS |
| **DifficultyController** | `calculateSpeed` | Score = 0 | $160\text{ units/s}$ | PASS |
| **DifficultyController** | `calculateSpeed` | Score = 20 | $260\text{ units/s}$ | PASS |
| **DifficultyController** | `calculateSpeed` | Score = 200 | $340\text{ units/s}$ (capped) | PASS |
| **DifficultyController** | `getStreakBadge` | Streak = 1, 3, 5, 10 | 'PERFECT!', 'GREAT!', 'AMAZING!', 'LEGENDARY!' | PASS |
