# Product Requirements Document (PRD)

**Project Name:** Stack Pulse  
**Document Version:** 1.0.0  
**Status:** Approved / In Production  
**Platforms:** Android, Windows Desktop, Web (PWA/CanvasKit)  
**Target Release:** Production v1.0.0+1  

---

## 1. Executive Summary & Vision

### 1.1 Product Vision
**Stack Pulse** is a hyper-polished, premium minimalist 2D precision block-stacking arcade game built using Flutter and the Flame Engine. Designed with an ultra-clean cyber-neon aesthetic, tactile haptics, and dynamically generated procedural audio, Stack Pulse delivers an addictive, reflex-testing gaming experience with zero ads, zero internet dependencies, and zero latency.

### 1.2 Core Value Proposition
- **Pure Skill & Precision:** Clean, deterministic 1D interval slicing that rewards millisecond timing and exact alignment.
- **Hypnotic Audio-Visual Synergy:** Ascending pentatonic scales and harmonic overtones synthesized algorithmically on the fly, paired with streak-driven neon particle fireworks.
- **Instantaneous Playability:** Lightweight cross-platform footprint (<15MB APK, instant Web load), zero load screens, and offline-first architecture.
- **Distraction-Free Experience:** No pay-to-win mechanics, no intrusive banner/interstitial advertisements, and no user tracking.

---

## 2. Target Audience & User Personas

| Persona | Demographics | Motivation | Pain Points Addressed |
|---|---|---|---|
| **The Commuter / Casual Gamer** | Age 16–45, Mobile / Web users | Quick 2-3 minute dopamine hits during breaks or transit | No mandatory internet connection required; immediate startup with no loading screens. |
| **The Reflex Perfectionist** | Age 14–30, Arcade / Rhythm fans | Mastering high scores, chasing streak combos, audio-visual feedback | Tight, responsive input handling without physics jitter or frame drops. |
| **The Desktop Multitasker** | Age 18–40, Windows Desktop users | Quick focus breaks while working on PC | Native keyboard support (`Space` / `Enter`), responsive fixed-ratio scaling, lightweight CPU footprint. |

---

## 3. Core Gameplay Loop

```
+-------------------------------------------------------+
|                   1. Block Spawns                    |
|    - Alternating spawn direction (Left / Right)       |
|    - Speed determined by current score                |
+---------------------------+---------------------------+
                            |
                            v
+-------------------------------------------------------+
|               2. Block Oscillates Horizontally        |
|    - Bounces smoothly between boundary margins         |
+---------------------------+---------------------------+
                            |
                            v
+-------------------------------------------------------+
|              3. Player Tap / Space / Enter            |
|    - Mathematical overlap evaluated via PlacementEngine|
+---------------------------+---------------------------+
                            |
            +---------------+---------------+
            |                               |
    [Within Tolerance]             [Partial Overlap]            [No Overlap]
            |                               |                        |
            v                               v                        v
+-----------------------+       +-----------------------+    +----------------+
|  PERFECT PLACEMENT    |       |   PARTIAL PLACEMENT   |    |    GAME OVER   |
| - Block snaps         |       | - Overhang sliced off |    | - Block falls  |
| - Width preserved     |       | - Excess drops down   |    | - Screen shake |
| - Streak count +1     |       | - Stack width shrinks |    | - Low thud     |
| - Harmonic Audio      |       | - Streak resets to 0  |    | - Score screen |
| - Particle Fireworks  |       | - Normal note audio   |    +----------------+
| - Screen Flash        |       +-----------+-----------+
+-----------+-----------+                   |
            |                               |
            +---------------+---------------+
                            |
                            v
+-------------------------------------------------------+
|            4. Camera Smoothly Centers Stack           |
|    - Vertical viewport eased upwards to track peak    |
+---------------------------+---------------------------+
                            |
                            v
+-------------------------------------------------------+
|         5. Next Block Spawns (Loop Continues)         |
+-------------------------------------------------------+
```

---

## 4. Feature Specifications

### 4.1 Precision Slicing & Perfect Snapping Engine
* **Interval Intersection**: Cutting logic uses exact 1D horizontal coordinate math rather than rigid body physics colliders, eliminating clipping glitches or physics instability.
* **Smart Tolerance Snapping**:
  * Near-perfect hits snap to 100% alignment: `tolerance = clamp(previousWidth * 0.025, 2.0, 5.0)` pixels.
  * Preserves full block width and awards a combo streak.
* **Overhang Detachment**:
  * Blocks placed outside tolerance are sliced cleanly.
  * Overhanging excess block is spawned as a falling rigid entity that rotates and plunges past the bottom of the screen.

### 4.2 Streak & Combo Escalation System
* Consecutive perfect placements trigger cascading audiovisual rewards:
  * **Streak 1**: `PERFECT!` (C5 note)
  * **Streak 2**: `NICE!` (D5 note)
  * **Streak 3–4**: `GREAT!` (E5, G5 notes)
  * **Streak 5–9**: `AMAZING!` (A5, C6, D6, E6, G6 notes + dual-voice harmonic overtones)
  * **Streak 10+**: `LEGENDARY!` (C7 high-resonance note + maximal particle burst)
* Dropping a non-perfect slice resets streak count to zero while retaining the base score.

### 4.3 Audio System & Procedural Sound FX
* **Continuous Ambient Background Music**:
  * Original electronic soundtrack (`stackpulse_background_music.mp3`) bundled in `assets/music/`.
  * Loops seamlessly in the background with dedicated volume attenuation ($0.4$).
  * **Lifecycle Awareness**: Automatically pauses when the game is sent to the mobile background / minimized, and automatically resumes when the app returns to the foreground.
  * **User Control**: Dedicated toggle switch in Settings allowing players to toggle background music independently from sound effects.
* **On-the-fly Procedural WAV FX Generation**:
  * Real-time synthesis in memory as 16-bit mono 22.05kHz PCM WAV byte streams.
  * Normal placements ascend through a rich 20-note pentatonic scale ($C_4$ to $A_7$).
  * Combo streaks trigger rising major tones with resonant harmonics.
  * Game Over generates an exponential frequency slide downwards ($140\text{ Hz} \to 55\text{ Hz}$).
* **Polyphonic Concurrency**: Employs an internal 4-player round-robin sound pool for zero clipping or latency during rapid taps.

### 4.4 Theme Progression & Customization
Players unlock visual themes by reaching score milestones in a single run:

| Theme | Unlock Requirement | Visual Palette & Mood |
|---|---|---|
| **Midnight Neon** | Default (0 pts) | Deep navy background, cyan and purple electric blocks, violet glow. |
| **Aurora** | Score $\ge 10$ | Deep spruce dark teal, emerald and mint green shimmering gradients. |
| **Sunset Pulse** | Score $\ge 25$ | Deep twilight plum, vivid amber, hot coral, and radiant magenta. |
| **Arctic Glow** | Score $\ge 50$ | Glacial charcoal blue, frosty azure, icy white, and diamond sparkles. |

### 4.5 Tactile Haptics & Visual Feedback
* **Haptics**: 
  * Light impact on standard block placement.
  * Medium impact on combo milestones ($\ge 3$ streak).
  * Heavy vibration burst on Game Over.
* **Screen Effects**:
  * Smooth exponential camera tracking to keep the active block centered in the upper third of the viewport.
  * Full-screen subtle flash on perfect streaks.
  * Multi-directional camera shake on Game Over.

### 4.6 Offline Persistence & Lifetime Statistics
Using `shared_preferences`, the application records and updates:
- **Best Score** (All-time highest blocks stacked).
- **Best Streak** (Longest consecutive perfect placement run).
- **Total Games Played**.
- **Total Blocks Placed** across all sessions.
- **Total Perfect Placements**.
- **User Settings**: Sound FX on/off, Haptic feedback on/off, Reduced Motion toggle, Selected Theme, and Tutorial Completion flag.

### 4.7 Accessibility & User Comfort
* **Reduced Motion Mode**: Disables camera shake and high-count particle bursts for users prone to motion discomfort.
* **Interactive Tutorial Screen**: Step-by-step interactive demonstration explaining snapping, combo ladders, and slicing mechanics.
* **Ergonomic Controls**:
  * Mobile: Single finger touch anywhere on screen.
  * Desktop: Mouse left-click, `Spacebar`, or `Enter` keys.

---

## 5. Screen & UI Flow Architecture

```
[ App Launch / Splash ]
         |
         v
  [ Home Screen ] <-----------------------------+
   |-- Play Button                              |
   |-- Best Score & Best Streak Pills           |
   |-- Stats Modal (Lifetime Metrics)           |
   |-- Themes Screen (Select/Unlock)            |
   |-- Settings Screen (Toggles & Reset)        |
   |-- Tutorial Screen                          |
         |                                      |
         v                                      |
  [ Game Screen ]                               |
   |-- In-Game Heads-Up Display (Score, Streak) |
   |-- Pause Button -> [ Pause Modal ] ---------+
   |-- Game Over Event -> [ Game Over Modal ] --+
                            |-- Restart Button
                            |-- Home Button
                            |-- Share / Best Banner
```

---

## 6. Non-Functional Requirements (NFR)

1. **Performance**: Consistent 60 FPS on mid-range Android devices; 120 FPS on high-refresh-rate displays and Desktop platforms.
2. **Audio Latency**: Sub-50ms audio latency between user tap and synthesized WAV sound output via `PlayerMode.lowLatency`.
3. **Storage Footprint**: Total disk footprint under 20 MB; zero runtime asset downloads.
4. **Memory Footprint**: Average RAM usage $< 80\text{ MB}$ under prolonged gameplay sessions.
5. **Cold Start Time**: Launch to interactive Home screen in $< 1.2\text{ seconds}$.
6. **Cross-Platform Compatibility**: Full parity across Android (API 21+), Windows (10/11 x64), and modern web browsers (Chrome, Edge, Firefox, Safari).

---

## 7. Future Roadmap & Enhancements

* **v1.1**: Global asynchronous leaderboards via lightweight Firebase or Supabase backend.
* **v1.2**: Dynamic color gradient transitions that shift continuously as the tower climbs higher within a single run.
* **v1.3**: Daily Challenge mode with randomized movement speeds and reverse gravity physics.
* **v1.4**: Custom haptic waveform patterns using modern Android 12+ / iOS CoreHaptics.

