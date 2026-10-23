# Technical Requirements Document (TRD)

**Project Name:** Stack Pulse  
**Document Version:** 1.0.0  
**Status:** Approved / In Production  
**Target Architecture:** Flutter 3.x / Dart 3.x / Flame Engine 1.x  
**Primary Platforms:** Windows Desktop, Web (CanvasKit/WASM), Android  

---

## 1. System Architecture & Tech Stack

### 1.1 Core Technology Stack

| Layer | Technology | Version | Purpose |
|---|---|---|---|
| **Framework** | Flutter SDK | `>=3.10.0` (Dart 3.x) | Cross-platform UI, state bindings, rendering host |
| **Game Engine** | Flame Engine | `^1.20.0` (Flame 1.38+) | 2D Component System, Game Loop, Viewfinder & Camera |
| **Audio Pipeline** | Audioplayers | `^6.8.1` | Low-latency audio playback of in-memory byte sources |
| **Local Storage** | SharedPreferences | `^2.2.3` | Key-value disk persistence for stats and settings |
| **Testing** | Flutter Test / Package Test | SDK | Unit tests and UI widget verification |

### 1.2 Architectural Layering

```
+-------------------------------------------------------------------------+
|                         FLUTTER UI LAYER                                |
|  - StackPulseApp (StatefulWidget root, settings & stats synchronization)|
|  - Screens: HomeScreen, GameScreen, ThemesScreen, SettingsScreen       |
|  - Overlays: PauseOverlay, GameOverOverlay                             |
|  - Custom Widgets: PremiumButton, ScoreDisplay, ThemeCard              |
+------------------------------------+------------------------------------+
                                     |
                                     v
+-------------------------------------------------------------------------+
|                         FLAME GAME ENGINE LAYER                         |
|  - Game Engine: StackPulseGame extends FlameGame<StackWorld>           |
|  - World Container: StackWorld (Component Tree & Background Glow)       |
|  - Game Entities: StackBlockComponent, MovingBlockComponent,           |
|                   FallingPieceComponent, ParticleEffectComponent        |
+------------------------------------+------------------------------------+
                                     |
                                     v
+-------------------------------------------------------------------------+
|                      CORE SYSTEMS & ALGORITHMS                          |
|  - PlacementEngine: Pure 1D interval mathematical cutting & snapping   |
|  - DifficultyController: Speed calculation & streak badge thresholds    |
|  - CameraController: Smooth exponential vertical tracking & shake      |
|  - ScoreController: Run score and combo streak tracking                 |
+------------------------------------+------------------------------------+
                                     |
                                     v
+-------------------------------------------------------------------------+
|                      SERVICES & PERSISTENCE                             |
|  - MusicService: Background loop audio manager with lifecycle awareness|
|  - SoundSynthesizer: In-memory 16-bit PCM WAV procedural generator     |
|  - FeedbackService: Coordinated audio and multi-tier haptics           |
|  - LocalStorageService: JSON serializable storage for Stats & Settings  |
+-------------------------------------------------------------------------+
```

---

## 2. Mathematical Models & Game Engine Algorithms

### 2.1 Pure Interval Slicing (`PlacementEngine`)
Unlike traditional rigid-body physics engines where cutting causes collider jitter and clipping bugs, Stack Pulse evaluates block intersection using deterministic 1D interval projection on the X-axis:

Let the stationary target block be defined by horizontal interval $[P_{\text{left}}, P_{\text{right}}]$ with width $W_P = P_{\text{right}} - P_{\text{left}}$.  
Let the moving block at the instant of player input be defined by $[M_{\text{left}}, M_{\text{right}}]$ with width $W_M = M_{\text{right}} - M_{\text{left}}$.

#### 1. Dynamic Tolerance Snapping
A hit is classified as **Perfect** if the absolute horizontal offset is within the clamped tolerance $\tau$:

$$\tau = \text{clamp}(W_P \cdot 0.025,\, 2.0,\, 5.0) \text{ px}$$

$$\Delta x = |M_{\text{left}} - P_{\text{left}}|$$

$$\text{If } \Delta x \le \tau \implies \begin{cases} \text{Type} = \text{Perfect} \\ R_{\text{left}} = P_{\text{left}} \\ R_{\text{right}} = P_{\text{right}} \\ R_{\text{width}} = W_P \end{cases}$$

#### 2. Partial Slicing & Excess Detachment
If $\Delta x > \tau$, calculate the interval intersection:

$$O_{\text{left}} = \max(P_{\text{left}}, M_{\text{left}})$$

$$O_{\text{right}} = \min(P_{\text{right}}, M_{\text{right}})$$

$$W_{\text{overlap}} = \max(0.0,\, O_{\text{right}} - O_{\text{left}})$$

- **Miss Case**: If $W_{\text{overlap}} \le 0.001$, the block completely missed the target stack. Retained width becomes $0.0$, and the entire moving block drops as an excess piece, triggering `GamePlayState.gameOver`.
- **Partial Case**: If $W_{\text{overlap}} > 0.001$:
  - **Retained Placed Block**: $[O_{\text{left}}, O_{\text{right}}]$ with width $W_{\text{overlap}}$.
  - **Overhang Detachment**:
    - If $M_{\text{left}} > P_{\text{left}}$ (Right overhang): Excess interval is $[O_{\text{right}}, M_{\text{right}}]$ with excess width $W_E = M_{\text{right}} - O_{\text{right}}$, falling with clockwise angular velocity ($+2.5\text{ rad/s}$).
    - If $M_{\text{left}} \le P_{\text{left}}$ (Left overhang): Excess interval is $[M_{\text{left}}, O_{\text{left}}]$ with excess width $W_E = O_{\text{left}} - M_{\text{left}}$, falling with counter-clockwise angular velocity ($-2.5\text{ rad/s}$).

### 2.2 Dynamic Difficulty Scaling (`DifficultyController`)
The linear speed scaling algorithm ensures accessibility for early gameplay while escalating reflexes smoothly:

$$v(s) = \min(v_{\text{max}},\, v_{\text{initial}} + s \cdot \Delta v)$$

Where:
- $v_{\text{initial}} = 160.0 \text{ px/s}$
- $\Delta v = 5.0 \text{ px/s}$ per placed block
- $v_{\text{max}} = 340.0 \text{ px/s}$
- Terminal speed is reached at score $s = 36$.

### 2.3 Camera Tracking & Easing Math (`CameraController`)
To keep the apex of the tower visible without jarring motion, the camera uses an exponential easing tracker:

Let $Y_{\text{top}}$ be the global Y coordinate of the highest placed block. When $Y_{\text{top}} < Y_{\text{threshold}}$ ($300.0\text{ px}$):

$$Y_{\text{target}} = 300.0 - Y_{\text{top}}$$

During frame delta $\Delta t$:

$$Y_{\text{offset}}(t + \Delta t) = Y_{\text{offset}}(t) + \left[ Y_{\text{target}} - Y_{\text{offset}}(t) \right] \cdot \min(1.0,\, \lambda_{\text{camera}} \cdot \Delta t)$$

Where $\lambda_{\text{camera}} = 5.5$.

#### Screen Shake Decay
When a miss occurs, an instantaneous shake impulse $I_0 = 12.0\text{ px}$ is applied, decaying exponentially:

$$I(t + \Delta t) = \max(0.0,\, I(t) - 24.0 \cdot \Delta t)$$

$$\text{Shake Offset}: (\Delta x, \Delta y) = \left( (\text{rand}_{[-0.5, 0.5]}) \cdot I(t),\, (\text{rand}_{[-0.5, 0.5]}) \cdot I(t) \right)$$

---

## 3. In-Memory Procedural Audio Synthesis (`SoundSynthesizer`)

To avoid external asset loading, network fetches, and file I/O latency, all audio is generated synthetically at startup as byte-accurate PCM WAV files in RAM.

### 3.1 PCM WAV Header Specification (44 Bytes)
The synthesizer builds standard RIFF PCM buffers using Dart `ByteData`:

| Byte Offset | Field Name | Value / Type | Purpose |
|---|---|---|---|
| `0x00 - 0x03` | Chunk ID | `"RIFF"` (ASCII) | Identifies RIFF container |
| `0x04 - 0x07` | Chunk Size | `36 + DataSize` (uint32, LE) | Overall stream size minus 8 bytes |
| `0x08 - 0x0B` | Format | `"WAVE"` (ASCII) | Identifies WAV audio format |
| `0x0C - 0x0F` | Subchunk1 ID | `"fmt "` (ASCII) | Header metadata block |
| `0x10 - 0x13` | Subchunk1 Size | `16` (uint32, LE) | Standard uncompressed PCM header |
| `0x14 - 0x15` | Audio Format | `1` (uint16, LE) | PCM Linear quantization |
| `0x16 - 0x17` | Num Channels | `1` (uint16, LE) | Mono audio stream |
| `0x18 - 0x1B` | Sample Rate | `22050` (uint32, LE) | Standard low-latency sample rate |
| `0x1C - 0x1F` | Byte Rate | `44100` (uint32, LE) | `SampleRate * NumChannels * (Bits / 8)` |
| `0x20 - 0x21` | Block Align | `2` (uint16, LE) | `NumChannels * (Bits / 8)` |
| `0x22 - 0x23` | Bits Per Sample | `16` (uint16, LE) | 16-bit signed integer depth |
| `0x24 - 0x27` | Subchunk2 ID | `"data"` (ASCII) | Start of raw sample array |
| `0x28 - 0x2B` | Subchunk2 Size | `DataSize` (uint32, LE) | `TotalSamples * 2` bytes |
| `0x2C - ...`  | Data Samples | `int16` Little Endian | Quantized audio amplitudes |

### 3.2 Acoustic Waveform Mathematics

#### Standard Notes (Exponential Decay Sine)
For sample index $i \in [0, N-1]$ at sample rate $f_s = 22050\text{ Hz}$, $t = i / f_s$:

$$A(t) = \sin(2\pi \cdot f \cdot t) \cdot e^{-\delta t} \cdot V_{\text{vol}}$$

Quantized to 16-bit signed integer:

$$S(i) = \text{round}\left( \text{clamp}(A(t), -1.0, 1.0) \cdot 32767 \right)$$

#### Streak Harmonized Notes (Dual Frequency Synthesis)
To produce crystalline chimes during combos, a second harmonic voice is layered over the fundamental:

$$A_{\text{streak}}(t) = \left[ \sin(2\pi f t) \cdot V_1 + \sin(2\pi f_{\text{harm}} t) \cdot V_2 \right] \cdot e^{-\delta t}$$

Where $f_{\text{harm}} = 1.5f$ (perfect fifth) for streaks $1\text{–}4$, and $f_{\text{harm}} = 2.0f$ (octave overtone) for streaks $\ge 5$.

#### Game Over Pitch Descent
Generates a low percussive impact whose fundamental frequency sweeps downwards over $450\text{ ms}$:

$$f(t) = 140.0 - 85.0 \cdot \left(\frac{t}{0.45}\right) \text{ Hz}$$

### 3.3 Round-Robin Polyphony Pool
To prevent sample clipping and audio queue bottlenecks when the user taps rapidly:
- 4 dedicated `AudioPlayer` instances are pre-initialized in `PlayerMode.lowLatency`.
- Sounds are routed sequentially using `_playerIndex = (_playerIndex + 1) % 4`.
- Sources are passed via zero-copy `BytesSource(uint8List)`.

### 3.4 Ambient Background Music Architecture (`MusicService`)
- Dedicated `AudioPlayer` instance playing `AssetSource('music/stackpulse_background_music.mp3')` in `ReleaseMode.loop`.
- **Decoupled Volume Control**: Master music volume attenuated to $0.4$ to maintain dynamic audio headroom for high-frequency perfect streak chimes.
- **Lifecycle Integration**: Registered directly with `WidgetsBindingObserver` in `_StackPulseAppState`:
  - `AppLifecycleState.paused` / `inactive` / `hidden` / `detached`: Suspends playback via `_player.pause()` immediately to save device battery and prevent unwanted sound in background.
  - `AppLifecycleState.resumed`: Automatically calls `_player.resume()` if `musicEnabled == true`.
- **User Settings Toggle**: State persisted via `GameSettings.musicEnabled` and directly switchable from the in-game Settings screen.

### 3.5 Monetization & AdMob Integration (`AdService`)
- **SDK**: `google_mobile_ads: ^9.2.0`.
- **Application ID**: `ca-app-pub-3794659976212193~9107617603` (configured in `AndroidManifest.xml`).
- **Interstitial / App Open Ad Unit ID**: `ca-app-pub-3794659976212193/3368291483`.
- **Rewarded Ad Unit ID**: `ca-app-pub-3794659976212193/9929744688`.
- **Preloading & Lifecycle Coordination**:
  - Automatically preloads both interstitial and rewarded ads on app launch and upon entering Game Over state.
  - When user presses 'PLAY' on Home Screen or 'HOME' on Game Over Screen, triggers `AdService.instance.showAd(...)` with background audio muting.
  - When user presses 'WATCH AND GET A CHANCE', triggers `AdService.instance.showRewardedAd(...)`. Upon watching the rewarded ad, `StackPulseGame.reviveGame()` clears miss fragments and resumes the stack run without losing score.
  - Strict verification: If the ad fails to load, device has no internet, or is dismissed early, no revive is awarded. A notification is surfaced to the player: *"Ad not available. Please check your internet connection and try again."*

---

## 4. Entity Lifecycle & Performance Optimization

### 4.1 Component Hierarchy in `FlameGame`

```
StackPulseGame (FlameGame)
 │
 └── StackWorld (World)
      ├── StackBlockComponent (Stationary Tower Blocks)
      ├── MovingBlockComponent (Currently Oscillating Block)
      ├── FallingPieceComponent (Sliced Overhangs & Misses)
      └── ParticleEffectComponent (Streak Bursts)
```

### 4.2 Frame-Budget & Garbage Collection Rules
1. **Delta-Time Clamping**: In `StackPulseGame.update(double dt)`, dt is strictly clamped to `dt.clamp(0.0, 0.05)`. This eliminates numerical divergence, teleporting blocks, or infinite physics steps when the browser tab loses focus or Android resumes from standby.
2. **Falling Piece Pruning**: `FallingPieceComponent` tracks global height and self-disposes via `removeFromParent()` immediately once $Y > \text{topStackY} + 840.0$, preventing unbounded memory consumption.
3. **Particle Recycling**: `ParticleEffectComponent` pre-allocates particle vectors and auto-removes itself when its internal timer reaches $0.65\text{s}$.
4. **Input Locking**: When `handlePlacementTap()` triggers, `currentMovingBlock.removeFromParent()` is invoked synchronously prior to spawning pieces. This eliminates race conditions from multi-finger touch spamming.

### 4.3 3D Isometric Slab Geometry & Material System (`IsometricSlabRenderer`)
- **Isometric Vertex Projection**:
  - Isometric tilt slope ($\text{tiltSlope} = 0.28 \approx 15.6^\circ$) ensures authentic 3D isometric projection across all widths $W \in [0, 210]$.
  - Front vertical ridge $V_{\text{front}} \to V_{\text{front\_bot}}$ separates Left and Right faces.
  - Sits seamlessly on top of preceding blocks and the base isometric pedestal: $\Delta Y_{\text{step}} = H = 26.0\text{ px}$.
- **3-Face Lighting Model**:
  - **Top Face**: Specular directional highlight ($L \approx 85\%$) from top-left with linear gradient fill and soft planar diagonal sheen.
  - **Right Face**: Medium diffuse half-tone shade ($L \approx 65\%$).
  - **Left Face**: Deep ambient shadow face ($L \approx 48\%$) with vertical ambient occlusion gradient.
- **Vibrant Multi-Color Palette**:
  - 12-stage rich, vibrant spectrum (Cyan, Royal Blue, Purple, Magenta, Coral Pink, Sunset Orange, Gold, Emerald, Mint Turquoise, Cerulean, Indigo, Rose Pink) cycling dynamically per block level.
- **Top Center HUD Anchoring**:
  - Dedicated `Positioned(top: 0, left: 0, right: 0)` container anchoring the score at the top center, preventing overlap with the active stacking area.

---

## 5. Data Persistence & Schema

Persistence is mediated by `LocalStorageService` utilizing `SharedPreferences`.

### 5.1 Game Settings Schema (`stack_pulse_settings`)
```json
{
  "soundEnabled": true,
  "musicEnabled": true,
  "hapticsEnabled": true,
  "reducedMotion": false,
  "tutorialCompleted": false,
  "selectedTheme": "midnightNeon"
}
```

### 5.2 Game Statistics Schema (`stack_pulse_statistics`)
```json
{
  "bestScore": 42,
  "bestStreak": 14,
  "totalGamesPlayed": 128,
  "totalBlocksPlaced": 2150,
  "totalPerfectPlacements": 680
}
```

---

## 6. Input Routing & Resolution Scaling

### 6.1 Viewport Anchoring
- Standard logical resolution: **$360 \times 640$ (Aspect Ratio 9:16)**.
- Handled via `CameraComponent.withFixedResolution(width: 360, height: 640)`.
- Automatically letterboxes/pillarboxes across varying display aspect ratios (e.g. 19.5:9 on modern phones, 16:9 on desktop).

### 6.2 Multi-Modal Input Handling
- **Touch / Mouse**: Handled via Flame's `TapCallbacks` on `StackPulseGame.onTapDown`.
- **Hardware Keyboard**: Handled via `KeyboardEvents` on `StackPulseGame.onKeyEvent`. Listens for `LogicalKeyboardKey.space` and `LogicalKeyboardKey.enter` on `KeyDownEvent`.

---

## 7. Verification & Testing Strategy

### 7.1 Unit Tests
Automated verification implemented in `/test/unit/`:
- `placement_engine_test.dart`:
  - Mathematical evaluation of exact alignment (tolerance snapping).
  - Offset calculations for right-side overhangs and left-side overhangs.
  - Complete miss detection when overlap $\le 0$.
- `difficulty_controller_test.dart`:
  - Speed formula progression up to terminal speed cap ($340\text{ px/s}$).
  - Streak badge string mapping across tiers.
- `audio_test.dart`:
  - Validates in-memory WAV byte stream formation (44-byte RIFF/WAVE header verification, sample sizing).

### 7.2 Static Analysis & Quality Gate
- Linter configured via `analysis_options.yaml` targeting standard Flutter lints.
- Verification command:
```bash
flutter analyze
flutter test
```

---

## 8. Target Builds & Deployment

| Platform | Target Output | Key Configuration |
|---|---|---|
| **Android** | Release APK / AAB | Min SDK 21, Target SDK 34, Portrait lock in `AndroidManifest.xml` |
| **Windows** | Win32 x64 Native Executable | Fixed minimal window constraints, CMake runner |
| **Web** | HTML5 / CanvasKit PWA | Web manifest configured, CanvasKit hardware accelerated rendering |

