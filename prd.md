# STACK PULSE — Product Requirements Document (PRD)

**Product Name:** STACK PULSE  
**Tagline:** One Tap. Perfect Stack.  
**Platform Target:** Cross-Platform (Mobile Android via Flutter + Flame Engine; Instant Web Canvas SPA via React 19 + TypeScript)  
**Monetization / Ads:** Zero ads, zero tracking, zero in-app purchases, completely offline-first.  
**Version:** 1.0.0  

---

## 1. Executive Summary & Vision

**Stack Pulse** is a premium, minimalist 2D precision block-stacking arcade game. Inspired by classic arcade timing games, it elevates the genre through pristine geometric aesthetics, zero-latency deterministic mechanics, dynamic neon theme progression, and an escalating procedural audio-visual combo reward system.

### Core Design Pillars
1. **Purity of Input**: Playable with a single finger or single keypress (`Space` / `Enter` / Screen Tap). Immediate, deterministic response without input lag.
2. **Deterministic Fairness**: Overlap is computed using pure mathematical interval intersections rather than volatile physics colliders. Every trim or snap is mathematically exact.
3. **Ascending Audio-Tactile Feedback**: Consecutive perfect placements reward the player with dynamically rising musical pitches (C5 through C7), harmonic overtones, and scaling particle bursts.
4. **Zero Dark Patterns**: No ads, no energy timers, no pay-to-revive mechanics, no forced connectivity. Everything persists locally on the player's device.

---

## 2. Target Audience & Play Context
- **Casual & Arcade Gamers**: Seeking fast, highly satisfying micro-sessions (30 to 90 seconds) with deep skill ceilings.
- **Rhythm & Timing Enthusiasts**: Players motivated by musical harmony and rhythm-like precision stacking.
- **Commuters & Offline Users**: Zero internet requirement ensures instant availability anywhere.

---

## 3. Core Gameplay Loop

```
┌─────────────────────────────────────────────────────────────────┐
│                           GAME START                            │
│           (Base block placed on lower playfield)                │
└────────────────────────────────┬────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                         MOVING STATE                            │
│     (Active block slides horizontally with speed = f(score))    │
└────────────────────────────────┬────────────────────────────────┘
                                 │
                                 ▼ [Player Tap / Space]
┌─────────────────────────────────────────────────────────────────┐
│                        PLACEMENT CHECK                          │
│     Calculate horizontal offset from previous stacked block     │
└───────────────┬───────────────────────────────┬─────────────────┘
                │                               │
       [Offset <= Tolerance]            [0 < Overlap]
                │                               │
                ▼                               ▼
    ┌───────────────────────┐       ┌───────────────────────┐
    │     PERFECT SNAP      │       │     PARTIAL TRIM      │
    │ • Full width retained │       │ • Overlap retained    │
    │ • Streak increments   │       │ • Streak reset to 0   │
    │ • Ascending chime     │       │ • Overhang falls      │
    │ • Particle burst      │       │ • Standard click tone │
    │ • Camera eases up     │       │ • Camera eases up     │
    └───────────┬───────────┘       └───────────┬───────────┘
                │                               │
                └───────────────┬───────────────┘
                                │
                                ▼
                    [Next Block Spawns Above]
                                │
                 (Miss: Overlap <= 0)
                                │
                                ▼
    ┌───────────────────────────────────────────────────────────┐
    │                        GAME OVER                          │
    │ • Missed block drops with gravity & rotation              │
    │ • Low resonant sound & haptic alert                       │
    │ • High-score evaluation & celebration sparks              │
    │ • Immediate 1-tap retry                                   │
    └───────────────────────────────────────────────────────────┘
```

---

## 4. Detailed Feature Requirements

### 4.1 Playfield & Block Mechanics
- **Playfield Dimension**: Internal coordinate system of 360 x 640 logical units, auto-scaled to preserve aspect ratio across mobile screens and desktop viewports.
- **Base Block**: Initial width of 210 units, height of 26 units, positioned horizontally centered at Y = 120.
- **Active Block Movement**: Frame-rate independent translation along the X axis. Bounces cleanly upon reaching the side boundary margins (`padding = 12 units`).
- **Alternating Direction**: Successive blocks spawn alternating between left-to-right and right-to-left.

### 4.2 Placement Precision & Tolerance
- **Tolerance Formula**: `tolerance = clamp(previousWidth * 0.025, 2.0, 5.0)` units.
- **Perfect Snap**: When offset $\le$ tolerance:
  - Snap X position to exactly match previous block.
  - Maintain 100% of previous block width.
  - Increment score by 1; increment consecutive streak by 1.
  - Trigger unique ascending pitch Web Audio tone based on streak.
- **Partial Placement**: When offset > tolerance but positive overlap exists:
  - Retain only intersection: `[max(pLeft, mLeft), min(pRight, mRight)]`.
  - Slice excess material into a detached debris piece.
  - Debris falls downward with gravity (`800 px/s²`) and rotation.
  - Reset consecutive streak to 0.
- **Failed Placement (Miss)**: When overlap is zero or negative:
  - Disallow further input.
  - Animate entire block falling off the screen.
  - Transition to Game Over screen.

### 4.3 Difficulty Progression
- **Speed Curve**: `speed = min(340, 160 + score * 5)` logical units/sec.
- **Fairness Guarantee**: No artificial random glitches or unpredictable jumps. The game naturally becomes harder through narrower platforms and higher sliding speeds.

### 4.4 Combo & Streak Reward System
- **Streak 1**: Base harmonic root tone (C5).
- **Streak 2**: Major step pitch (D5) + dual ping.
- **Streak 3 ("NICE!")**: E5 pitch + sparkling overtone + 3-note arpeggio.
- **Streak 4**: G5 pitch + octave harmonic.
- **Streak 5 ("AMAZING!")**: A5 pitch + 4-note ascending chord.
- **Streak 10+ ("LEGENDARY!")**: C7 apex crystalline bell + 5-note cascading arpeggio.

### 4.5 Visual Theme Unlock Progression
Visual themes require no microtransactions or tokens; they unlock automatically as the player sets personal best records:
1. **Midnight Neon**: Unlocked by default (Score 0). Deep navy `#0B1020`, cyan, purple, teal.
2. **Aurora**: Unlocks at Best Score $\ge 10$. Ethereal polar emerald `#071B19`, turquoise, mint.
3. **Sunset Pulse**: Unlocks at Best Score $\ge 25$. Warm violet `#1C0D1E`, amber, coral, magenta.
4. **Arctic Glow**: Unlocks at Best Score $\ge 50$. Glacial navy `#061325`, ice cyan, diamond white.

### 4.6 Infinite Tower Camera
- The world origin remains stable.
- When tower height exceeds mid-screen threshold ($Y > 300$), a vertical camera tracks the top of the stack using smooth exponential easing (`speed = 5.5`).
- Maintains ample clear headroom ($> 280$ logical units) so the moving block is fully visible without visual occlusion.

### 4.7 Local Settings & Persistence
- Automatically persists to local storage:
  - `bestScore`, `bestStreak`, `totalGamesPlayed`, `totalBlocksPlaced`, `totalPerfectPlacements`.
  - `soundEnabled` (true/false), `hapticsEnabled` (true/false), `reducedMotion` (true/false), `deviceFrame` (true/false), `selectedTheme`.

---

## 5. Non-Functional Requirements & Performance
- **Target Frame Rate**: Smooth 60 FPS across both Web (HTML5 Canvas) and Android Flutter (Flame Engine).
- **Input Responsiveness**: Input processing latency $< 16\text{ms}$.
- **Zero Asset Dependencies**: All visuals drawn procedurally via canvas primitives and Flutter CustomPainter/Flame components. Zero external sprite downloads.
- **Accessibility**:
  - High-contrast text exceeding WCAG AA standards.
  - Reduced Motion toggle disables screen shake and particle bursts while preserving deterministic gameplay timing.
  - Sound Mute toggle available directly in the top HUD.

---

## 6. Definition of Done (DoD)
- [x] Mathematical interval intersection with exact snapping and trimming.
- [x] Ascending streak pitch Web Audio synthesis.
- [x] 4 neon themes with local record unlock rules.
- [x] Full-viewport game shell (Title $\rightarrow$ Playing $\rightarrow$ Pause $\rightarrow$ Game Over).
- [x] Complete, compilable Flutter + Flame codebase in `/flutter_stack_pulse`.
- [x] Built-in Flutter Project Explorer for code inspection and export.
- [x] Clean unit test coverage for collision and difficulty curves.
