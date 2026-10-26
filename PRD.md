# Product Requirements Document (PRD)

**Project Name:** Stack Go  
**Document Version:** 1.0.0  
**Status:** Approved / In Production  
**Platforms:** Android, Windows Desktop, Web (PWA/CanvasKit)  
**Target Release:** Production v1.0.0+1  

---

## 1. Executive Summary & Vision

### 1.1 Product Vision
**Stack Go** is a hyper-polished, premium minimalist 2D precision block-stacking arcade game built using Flutter and the Flame Engine. Designed with an ultra-clean cyber-neon aesthetic, tactile haptics, and dynamically generated procedural audio, Stack Go delivers an addictive, reflex-testing gaming experience with seamless monetization through non-intrusive AdMob interstitials and user-rewarded revives, paired with an offline-resilient architecture and zero input latency.

### 1.2 Core Value Proposition
- **Pure Skill & Precision:** Clean, deterministic 1D interval slicing that rewards millisecond timing and exact alignment.
- **Hypnotic Audio-Visual Synergy:** Ascending pentatonic scales and harmonic overtones synthesized algorithmically on the fly, paired with streak-driven neon particle fireworks.
- **Instantaneous Playability:** Lightweight cross-platform footprint (<15MB APK, instant Web load), zero load screens, and offline-first architecture.
- **Fair & Player-Centric Monetization:** Reward-based gameplay revives ("Watch and Get a Chance"), contextual interstitial placements with background preloading, automatic audio muting/resumption, and zero banner clutter during active gameplay.

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

### 4.1 Precision Slicing & 3D Isometric Rendering Engine
* **3D Isometric Slabs**:
  * Blocks and sliced overhangs are rendered as 3D isometric slabs with 3 distinct visible faces:
    * **Top Face**: Illuminated diamond surface with soft directional gradient lighting.
    * **Left Face**: Darker shaded shadow face providing realistic depth.
    * **Right Face**: Medium half-tone shade capturing diffuse ambient light.
  * **Material & Texture**: Subtle surface sheen and planar specular highlights with crisp, sharp edge bevels and front vertical ridge highlights.
  * **Color Palette**: Vibrant multi-color spectrum (Electric Cyan, Royal Blue, Purple, Magenta, Coral Pink, Sunset Orange, Gold, Emerald Green, Turquoise, Cerulean Blue, Deep Indigo, Rose Pink) cycling dynamically as blocks stack higher.
  * **Unified Isometric World**: Base foundation pedestal rendered as a wide 3D isometric slab harmonizing with the stack.
* **Interval Intersection**: Cutting logic uses exact 1D horizontal coordinate math rather than rigid body physics colliders, eliminating clipping glitches or physics instability.
* **Smart Tolerance Snapping**:
  * Near-perfect hits snap to 100% alignment: `tolerance = clamp(previousWidth * 0.025, 2.0, 5.0)` pixels.
  * Preserves full block width and awards a combo streak.
* **Overhang Detachment**:
  * Blocks placed outside tolerance are sliced cleanly into retained and excess 3D isometric slabs.
  * Overhanging excess block is spawned as a falling rigid 3D slab that rotates and plunges past the bottom of the screen.

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

### 4.8 Google Mobile Ads (AdMob) Integration & Monetization Specifications

#### 4.8.1 Production AdMob Identifiers
The application utilizes Google Mobile Ads SDK across Android (and iOS) platforms with dedicated ad units for optimal revenue and non-intrusive player progression:

| Identifier Type | Value | Target Format | Implementation Purpose |
|---|---|---|---|
| **AdMob App ID** | `ca-app-pub-3794659976212193~9107617603` | Application Manifest | SDK Initialization & App Verification |
| **App Open / Interstitial** | `ca-app-pub-3794659976212193/3368291483` | Full-Screen Interstitial / App Open | Game Over Exit to Home |
| **Action Interstitial** | `ca-app-pub-3794659976212193/5028771792` | Full-Screen Interstitial | Accessibility Settings Controls, Theme Selection, Pause Actions |
| **Rewarded Video** | `ca-app-pub-3794659976212193/9929744688` | Rewarded Video Ad | "Watch and Get a Chance" Run Revival |

> [!NOTE]
> During development / propagation windows, official Google test ad unit IDs (`ca-app-pub-3940256099942544/...`) act as automated debug fallbacks to guarantee tests and staging builds do not violate AdMob policies or fail silently.

---

#### 4.8.2 Comprehensive Active Ad Placement Matrix
Ads are systematically placed across strategic navigation gates, user preferences, and failure recovery states, while keeping core gameplay triggers 100% ad-free:

| Screen / Overlay | Triggering UI Element / Event | Ad Format & Production Unit ID | Source File & Implementation | Playback Condition & Action |
|---|---|---|---|---|
| **Game Session (Game Over)** | Block Miss / Run Loss Event | Interstitial (`5028771792`) | `lib/ui/screens/game_screen.dart` | Allows 350ms for miss drop animation and audio FX to play, then presents full-screen interstitial ad before transitioning to the final Score Card overlay. |
| **Game Over Overlay** | `HOME` Button Tap | App Open / Interstitial (`3368291483`) | `lib/app.dart` (`_handleGoHome`) | Plays full-screen ad before transitioning the user from the game session back to the Main Menu. |
| **Game Over Overlay** | `WATCH AND GET A CHANCE` Button Tap | Rewarded Video (`9929744688`) | `lib/ui/screens/game_screen.dart` (`_onRevive`) | Plays full-screen rewarded video. Upon verified completion, revives the current run, preserves existing score, clears missed blocks, and spawns the next block. |
| **Pause Menu Overlay** | `RESTART` Button Tap | Interstitial (`5028771792`) | `lib/ui/overlays/pause_overlay.dart` | Plays interstitial before wiping the stack and re-centering the camera for a fresh run. |
| **Pause Menu Overlay** | `SETTINGS` Button Tap | Interstitial (`5028771792`) | `lib/ui/overlays/pause_overlay.dart` | Plays interstitial before navigating from the pause overlay to the Settings screen. |
| **Pause Menu Overlay** | `HOME` Button Tap | Interstitial (`5028771792`) | `lib/ui/overlays/pause_overlay.dart` | Plays interstitial before leaving the paused session and returning to Home. |
| **Settings Screen** | `Haptic Feedback` Switch (Toggle ON/OFF) | Interstitial (`5028771792`) | `lib/ui/screens/settings_screen.dart` | Plays interstitial when the user toggles tactile vibration feedback. |
| **Settings Screen** | `Reduced Motion` Switch (Toggle ON/OFF) | Interstitial (`5028771792`) | `lib/ui/screens/settings_screen.dart` | Plays interstitial when the user toggles camera shake & particle reduction. |
| **Settings Screen** | `Current Theme` Card Tap | Interstitial (`5028771792`) | `lib/ui/screens/settings_screen.dart` | Plays interstitial before navigating from Settings to the Theme Selection Screen. |
| **Themes Screen** | Selecting Any Unlocked Theme Tile | Interstitial (`5028771792`) | `lib/ui/screens/themes_screen.dart` | Plays interstitial upon selecting and applying any unlocked aesthetic theme. |

> [!TIP]
> **Ad-Free Core Experience Policy (Strictly Enforced)**:
> To guarantee zero friction during game entry, mid-session resumes, instant replays, and essential audio adjustments, ads are **strictly removed** from:
> - **Home Screen `PLAY` Button**: Immediate entry into the 3D game arena with zero latency or ad barriers (`_handleStartGame`).
> - **Pause Menu Overlay `RESUME` Button**: Immediate resumption of active gameplay and block oscillation (`onResume`).
> - **Game Over Overlay `RETRY` Button**: Instant restart into a fresh stack run with zero interstitial barrier or interruption (`onRetry`).
> - **Settings Screen `Sound Effects` Switch & Slider**: Immediate toggling and smooth real-time volume adjustment.
> - **Settings Screen `Background Music` Switch & Slider**: Immediate toggling and smooth real-time music level adjustment.

---

#### 4.8.3 Ad Playback Mechanics & Technical Execution Flow
To guarantee smooth 60 FPS gameplay, prevent frame hitching, and avoid black-screen hangs, `AdService` executes ads according to the following lifecycle architecture:

```
+-----------------------------------------------------------------------------------+
|                            1. BACKGROUND PRELOADING                               |
| - App Launch (main.dart): preloadAd(), preloadInterstitialAd(), preloadRewardedAd()|
| - Game Over Trigger: Preloads next run ads in background                          |
| - Post-Ad Dismissal: Automatically caches replacement ad in background            |
+-----------------------------------------------------------------------------------+
                                       |
                                       v
+-----------------------------------------------------------------------------------+
|                             2. RUNTIME AD TRIGGER                                 |
| Player triggers an action (e.g. Button tap, Slider release, Revive tap)           |
+--------------------------------------+--------------------------------------------+
                                       |
               +-----------------------+-----------------------+
               |                                               |
        [Ad In Memory]                                 [Ad Not Cached]
               |                                               |
               v                                               v
+-----------------------------+              +-------------------------------------+
|      3. INSTANT PLAY        |              |       4. QUICK-FETCH TIMEOUT        |
| - MusicService PAUSED       |              | - Interstitial: Max 2.0s timeout    |
| - Full-screen ad presented  |              | - Rewarded Ad: Max 4.0s timeout     |
+--------------+--------------+              +------------------+------------------+
               |                                                |
               |                            +-------------------+-------------------+
               |                            |                                       |
               |                     [Fetch Succeeded]                      [Timeout / Error]
               |                            |                                       |
               |                            v                                       v
               |              +-----------------------------+         +----------------------------+
               +------------> |      5. AD PRESENTATION     |         |  6. SAFE FALLBACK (NO AD)  |
                              | - Audio muted / paused      |         | - Interstitial: Proceed    |
                              | - User views / interacts    |         |   without freezing UI      |
                              +--------------+--------------+         | - Rewarded: STRICT NO REVIVE|
                                              |                        |   Shows English error alert|
                                             v                        +----------------------------+
                              +-----------------------------+
                              |      7. DISMISSAL & RESUME  |
                              | - MusicService RESUMED      |
                              | - Ad disposed from memory   |
                              | - Background preload next ad|
                              | - Execute navigation/reward |
                              +-----------------------------+
```

1. **Intelligent Background Preloading**:
   - Ads are never loaded synchronously on the UI thread when a button is pressed.
   - Upon app startup (`AdService.instance.initialize()`), three distinct background load pipelines run concurrently: `preloadAd()` (App Open/Interstitial), `preloadInterstitialAd()` (Action Interstitial), and `preloadRewardedAd()` (Revive Rewarded).
   - Whenever an ad is closed (`onAdDismissedFullScreenContent`) or fails to show (`onAdFailedToShowFullScreenContent`), the respective preload pipeline is immediately re-invoked so the cache stays hot.
   - Upon encountering a Game Over state, `game_screen.dart` proactively re-checks and warms both interstitial and rewarded caches.

2. **Zero-Lag Cache Hits & Safety Timeouts**:
   - If an ad is ready in memory, playback begins instantly with zero frame drop or buffering lag.
   - If the player taps an action before an ad has finished loading (e.g. during rapid navigation or unstable connectivity):
     - **Interstitials**: A safety timer of **2.0 seconds** is enforced. If the ad cannot load within 2 seconds, the action completes anyway (e.g. game starts or settings toggle completes) to prevent the user from being trapped in an unresponsive black screen.
     - **Rewarded Ads**: A safety timer of **4.0 seconds** is enforced. If the ad cannot load within 4 seconds, the attempt is aborted, NO revive chance is granted, and user feedback is presented.

3. **Background Music & Audio Coordination**:
   - Before any ad is shown (`_showAppOpenAd`, `_showInterstitialAd`, `_displayRewardedAd`), `MusicService.instance.onAppLifecycleStateChanged(AppLifecycleState.paused)` is invoked to cleanly pause background music playback.
   - Once the ad is closed or fails to show, `MusicService.instance.onAppLifecycleStateChanged(AppLifecycleState.resumed)` is immediately invoked to restore background music without requiring manual toggle manipulation.

4. **Strict Rewarded Revive Verification & Offline Safeguards**:
   - **No Watch, No Reward**: Rewarded revives are gated strictly behind the AdMob `onUserEarnedReward` callback.
   - **Premature Close Detection**: If a player dismisses or skips the rewarded ad prior to completion, the reward boolean remains `false`. The game remains in the Game Over state and displays an advisory: *"You closed the ad before earning the chance. Watch the full ad to continue."*
   - **Offline / Failure Handling**: If the device has no internet connection or AdMob returns an error, the game remains on Game Over and surfaces a clear notification in proper English: *"Ad not available. Please check your internet connection and try again."* Under no circumstances can a player bypass ads or obtain an unearned revive chance while offline.

---

## 5. Screen & UI Flow Architecture

```
[ App Launch / Splash ]
         |
         | (Initialize AdService, Preload All Ads)
         v
  [ Home Screen ] <------------------------------------+
   |-- Play Button (Direct / Ad-Free) -----------------+---> [ Active Game Screen ]
   |                                                   |      |-- Heads-Up Display (Score, Streak)
   |-- Best Score & Best Streak Pills                  |      |-- Pause Button
   |-- Stats Modal (Lifetime Metrics)                  |      |     |
   |-- Themes Screen (Select/Unlock) <-------+         |      |     v
   |-- Settings Screen -----------------+    |         |      | [ Pause Overlay ]
   |    |-- SFX Switch & Slider (Ad-Free)|   |         |      |  |-- Resume (Direct / Ad-Free)
   |    |-- BGM Switch & Slider (Ad-Free)|   |         |      |  |-- Restart (Ad: 5028771792)
   |    |-- Haptics & Motion (Ad)        |   |         |      |  |-- Settings (Ad: 5028771792)
   |    +-- Theme Shortcut Card (Ad) ----+   |         |      |  |-- Home (Ad: 5028771792) ------+
   |-- Tutorial Screen                       |         |      |                                   |
                                             |         |      |-- Block Miss / Game Over          |
                                             |         |            |                             |
                                             |         |            v                             |
                                             |         |       [ Interstitial Ad: 5028771792 ]    |
                                             |         |            |                             |
                                             |         |            v                             |
                                             |         |     [ Game Over Overlay (Score Card) ]   |
                                             |         |      |-- Retry (Instant / Ad-Free)       |
                                             |         |      |-- Home (Ad: 3368291483) ----------+
                                             |         |      +-- Watch & Get a Chance            |
                                             |         |           (Rewarded Ad: 9929744688)      |
                                             |         |                |                         |
                                             |         +---------- [ Revive Run ]                 |
                                             |                     (Continue with score)          |
                                             +----------------------------------------------------+
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

