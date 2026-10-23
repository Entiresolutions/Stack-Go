# STACK PULSE — EXACT REFERENCE DESIGN SYSTEM SPECIFICATION
## Complete Visual Redesign | Flutter + Flame Mobile Arcade Architecture

---

## 1. Design Vision & Aesthetic Direction

**Stack Pulse** embodies a **premium futuristic neon arcade aesthetic**, modeled with high fidelity after the 10-screen visual source of truth. The interface transitions away from flat, generic utility styling into a deeply atmospheric, tactile, and luminous arcade experience:

- **Ultra-Dark Cyber Environments**: Deepest midnight navy base canvas (`#061225`) paired with secondary oceanic navy (`#0B1B38`) and elevated cyber surfaces (`#14284A`).
- **Electric Accent Hierarchy**: Vibrant electric cyan (`#13D9FF`) and neon blue (`#347BFF`) counter-balanced by electric purple (`#9658FF`) and neon magenta (`#F34BEA`). Accentuation is strictly intentional—reserved for actionable controls, streak feedback, and milestone rewards.
- **Dimensional 2.5D Block Styling**: Stacking blocks feature programmatic linear vertical gradients, top sheen highlight lines (0.45 white opacity), hairline separation outlines, and drop shadows, giving 2D geometric blocks physical depth.
- **Frosted Glassmorphism**: Overlays and floating panels utilize dark blurred backdrops (`BackdropFilter` with `ImageFilter.blur(sigmaX: 10, sigmaY: 10)`) framed by hairline borders (`white.withValues(alpha: 0.12)`).
- **Pill & Capsule Arcade Geometry**: High-priority interactive elements feature fully-rounded pill capsules (`height / 2` radius), subtle inner glows, and arcade press physics.

---

## 2. Reference-Screen Mapping

Every visual element in the application directly corresponds to one of the 10 screens in the reference specification:

| # | Screen / State | Source File(s) | Key Visual Elements Implemented |
| :--- | :--- | :--- | :--- |
| **1** | **Splash Screen** | `lib/ui/screens/splash_screen.dart` | Deep navy void, floating isometric 3D neon cubes, 3-pill glowing stacked emblem, title & tagline, animated capsule progress bar. |
| **2** | **Home Screen** | `lib/ui/screens/home_screen.dart` | Golden crown BEST score pill, circular glass settings button, 3-pill logo, 3D cyber-city tower canvas preview, cyan-to-purple gradient `PLAY` button, 3 bottom arcade action tiles (`THEMES`, `HOW TO PLAY`, `SETTINGS`). |
| **3** | **Gameplay Screen** | `lib/ui/screens/game_screen.dart`<br>`lib/game/stack_world.dart` | Clean top HUD (crown BEST score on left, dynamic score with `COMBO` underline on center, circular glass pause on right), 2.5D dimensional stacking tower, active sliding block, faint futuristic background skyline. |
| **4** | **Perfect Placement** | `lib/ui/widgets/score_display.dart`<br>`lib/game/components/particle_effect.dart` | Luminous cyan block flash, animated floating `PERFECT!` text with multiplier badge (`xN`), rotating neon diamond prisms and spark burst, elastic score bounce. |
| **5** | **Game Over Screen** | `lib/ui/overlays/game_over_overlay.dart` | Frosted backdrop with magenta lighting, bold gradient `GAME OVER` title, elevated score card with giant numerals, golden `NEW BEST` badge, two-column stats (`BEST SCORE`, `BEST STREAK`), pill `RETRY` and `HOME` buttons. |
| **6** | **Pause Menu** | `lib/ui/overlays/pause_overlay.dart` | Gameplay visible behind frosted backdrop, top-right `X` close icon, `PAUSED` header with `Your tower is waiting.` subtitle, vertical pills for `RESUME` (primary gradient), `RESTART`, `SETTINGS`, and `HOME`. |
| **7** | **Themes Screen** | `lib/ui/screens/themes_screen.dart`<br>`lib/ui/widgets/theme_card.dart` | Back navigation, `CHOOSE YOUR VIBE` header, 2x2 grid of theme cards, miniature 3D tower previews with real block palettes, active checkmark circle, lock icons with score threshold requirements. |
| **8** | **Settings Screen** | `lib/ui/screens/settings_screen.dart` | Back navigation, grouped dark surface panel with toggle switches for Sound Effects, Haptic Feedback, and Reduced Motion, dedicated Theme preview card with navigation chevron. |
| **9** | **How to Play Screen** | `lib/ui/screens/tutorial_screen.dart` | Back navigation, 5 numbered instruction rows with blue circular badges (`1`–`5`), concise rules, and custom programmatic vector mini-diagrams illustrating sliding, stacking, perfect alignment, trimming, and miss/game-over. |
| **10** | **In-Game Variations** | `lib/game/stack_world.dart`<br>`lib/core/game_theme.dart` | Coordinated theme atmospheres: cyber city skyline (Midnight Neon), emerald aurora veil (Aurora), sunset horizon (Sunset Pulse), and glacial crystal peaks (Arctic Glow). |

---

## 3. Centralized Theme Architecture

`lib/core/game_theme.dart` is the **authoritative Single Source of Truth** for all color tokens, gradients, and styling parameters across both Flutter UI and the Flame gameplay engine.

### Architectural Rules:
1. **Zero Hardcoded Colors**: No widget or Flame component uses raw hardcoded hex codes. All colors are retrieved from `GameTheme`.
2. **Synchronized Engine Updates**: When the player selects a theme in `ThemesScreen`, `StackPulseGame.updateTheme(newTheme)` updates Flame components (pedestal, block colors, background shaders, ambient particles) and Flutter UI simultaneously.
3. **Session Persistence**: Theme selections and unlocks are persisted across restarts via `shared_preferences`.

---

## 4. Color Palette Definitions

### 4.1 Global Core Palette Tokens (Reference Baseline)

| Semantic Token | Hex Code | Purpose |
| :--- | :--- | :--- |
| `background` | `#061225` | Deepest canvas and scaffold background |
| `secondaryBackground` | `#0B1B38` | Top stop of background gradient |
| `surface` | `#14284A` | Base surface for cards, tiles, and modals |
| `surfaceElevated` | `#1D3560` | Elevated surfaces, switch tracks, and active cards |
| `primaryAccent` | `#13D9FF` | Electric Cyan interactive accent |
| `neonBlue` | `#347BFF` | Neon Blue secondary accent |
| `secondaryAccent` | `#9658FF` | Electric Purple accent |
| `neonMagenta` | `#F34BEA` | Neon Magenta highlight accent |
| `mintAccent` | `#14E4C5` | Mint streak badges and success feedback |
| `orangeAccent` | `#FF995B` | Sunset orange accents |
| `goldAccent` | `#FFCB78` | High scores, trophies, and milestone awards |
| `text` | `#FFFFFF` | Primary high-contrast typography |
| `secondaryText` | `#A8C4E4` | Subtitles, labels, and descriptions |
| `mutedText` | `#6B8DB5` | Subtle borders and secondary hints |

### 4.2 Theme-Specific Block Palettes

Each theme supplies 6 cycling gradient colors for gameplay blocks:

- **Midnight Neon** (Default, Unlock Score: 0):
  `#13D9FF` (Cyan) → `#347BFF` (Neon Blue) → `#9658FF` (Electric Purple) → `#F34BEA` (Neon Magenta) → `#FF995B` (Sunset Orange) → `#14E4C5` (Mint).
- **Aurora** (Unlock Score: 10):
  `#14E4C5` (Mint) → `#2DD4BF` (Turquoise) → `#34D399` (Polar Green) → `#10B981` (Emerald) → `#06B6D4` (Cyan) → `#6EE7B7` (Soft Polar).
- **Sunset Pulse** (Unlock Score: 25):
  `#FF995B` (Neon Orange) → `#FF7043` (Coral) → `#FF4081` (Vivid Pink) → `#F34BEA` (Neon Magenta) → `#9658FF` (Electric Purple) → `#FFB300` (Sunset Gold).
- **Arctic Glow** (Unlock Score: 50):
  `#E0F2FE` (Glacial White) → `#7DD3FC` (Polar Ice) → `#38BDF8` (Glacial Cyan) → `#347BFF` (Neon Blue) → `#818CF8` (Frost Indigo) → `#0284C7` (Deep Ocean).

---

## 5. Typography Hierarchy

The typography scale utilizes `Plus Jakarta Sans` (with system sans-serif fallback) with tabular figures enabled for all numerical score meters:

| Role | Font Size | Weight | Letter Spacing | Font Features |
| :--- | :--- | :--- | :--- | :--- |
| **Hero Title** | 28–32px | `w900` | +3.5 | Default |
| **Tagline** | 10–11px | `w700` | +2.2 | Default |
| **HUD Score** | 44px | `w900` | -1.0 | `FontFeature.tabularFigures()` |
| **Game Over Score** | 56px | `w900` | -1.5 | `FontFeature.tabularFigures()` |
| **Screen Title** | 18–20px | `w800` | +1.5 | Default |
| **Primary Button** | 16–18px | `w900` | +1.5 | Default |
| **Secondary Button** | 14–15px | `w800` | +1.0 | Default |
| **Section Header** | 14–15px | `w800` | +0.5 | Default |
| **Body / Description** | 12–13px | `w500` | Normal | Default |
| **Capsule / Stat Label** | 10–11px | `w700` | +1.0 | `FontFeature.tabularFigures()` |

---

## 6. Spacing & Component Sizing Rules

- **Base Layout Scale**: 4px standard grid (4, 8, 12, 16, 20, 24, 32, 48).
- **Screen Margins**: 24px horizontal padding on standard mobile devices; 16–20px on compact screens.
- **Corner Radiuses**:
  - Gameplay blocks: `4.0px` (arcade micro-bevel).
  - Component cards & surface containers: `18–22px`.
  - Floating pause & game-over modals: `26–28px`.
  - Buttons & status capsules: `height / 2` (full pill rounding).
  - Circular buttons (Settings, Pause, Close): 44×44px circular shape.
- **Touch Target Sizing**: Minimum interactive touch target is 44×44px to satisfy mobile ergonomics.

---

## 7. Button Styles & States

### 7.1 `PremiumButton` (Pill Geometry)
- **Primary Variant**:
  - Horizontal linear gradient: Electric Cyan (`#13D9FF`) to Electric Purple (`#9658FF`).
  - Full pill radius: `borderRadius: BorderRadius.circular(height / 2)`.
  - Text: Bold white uppercase label with icon.
  - Drop Glow: Dual-layer drop shadow (`BoxShadow` with cyan and purple at 0.40/0.30 opacity).
- **Secondary Variant**:
  - Dark elevated surface (`#14284A` to `#1D3560`) with hairline white border (`alpha: 0.12`).
  - White text with high-contrast icon.
- **Interaction Physics**:
  - Pointer down: Scales to `0.955` over 100ms with `Curves.easeInOutCubic`.
  - Release: Springs back to `1.0` over 140ms with `Curves.easeOutBack`.

### 7.2 `HomeActionTile` (Arcade Navigation Tiles)
- Three square action tiles (`THEMES`, `HOW TO PLAY`, `SETTINGS`) displayed horizontally.
- Dark elevated surface (`#14284A`), subtle rounded corners (`16px`), icon in luminous accent color, and uppercase micro-label.

---

## 7.5 Splash Screen Specifications (Reference Screen 1 — Phase 2 Implementation)

### 7.5.1 Native Android Startup Alignment
- **Native Splash Elimination**: Replaced default `@android:color/white` background with custom `@color/splash_color` (`#061225`) in both `launch_background.xml` and `drawable-v21/launch_background.xml`.
- **Theme Parentage**: Set `LaunchTheme` and `NormalTheme` parent to `@android:style/Theme.Black.NoTitleBar` in `values/styles.xml` and `values-night/styles.xml`, guaranteeing seamless color continuity into Flutter without white flashes on any Android configuration.

### 7.5.2 Visual Architecture & Production Assets
- **Production Asset (`assets/images/splash_bg.jpg`)**:
  - High-resolution (9:16 portrait) environment generated via Nano Banana image generation (`splash_bg_1792778384467.jpg`).
  - Composition: Deep midnight navy void (`#061225`), vertical cyan light streaks, floating 3D isometric glowing crystalline cubes (cyan top-right, purple top-left), and slanted crystalline towers rising from the lower corners.
  - Unobstructed center with soft radial glow bloom (`Color(0xFF13D9FF)` and `Color(0xFF9658FF)` at 0.20/0.10 opacity) framing the center emblem.
- **Center Emblem & Typography**:
  - 3-tier rounded stacked pill emblem (Cyan `#13D9FF`, Blue `#347BFF`, Purple `#9658FF`) with glossy top sheen lines and luminous drop shadows.
  - Title: Dual-line brand presentation matching Reference Screen 1:
    - Line 1: `STACK` (bold white uppercase, letter spacing +5.0).
    - Line 2: `PULSE` (bold electric cyan uppercase, letter spacing +5.0).
  - Subtitle: `ONE TAP. PERFECT STACK.` (tracked +2.0 in `#A8C4E4`).
- **Loading Capsule Progress Slider**:
  - 180×6px pill container (`Color(0xFF14284A)` at 0.65 opacity with hairline white border).
  - Multi-tone gradient fill (Electric Cyan `#13D9FF` → Neon Blue `#347BFF` → Electric Purple `#9658FF`) with drop glow.

### 7.5.3 Choreographed Animation Sequence
- **Stage A (0.00 – 0.22, ~0 – 1.5s)**: 3-pill emblem slides upward (+20% offset to zero) with `Curves.easeOutCubic` and fades in while central ambient glow blooms.
- **Stage B (0.20 – 0.42, ~1.4 – 3.0s)**: Dual-line game title fades in with subtle vertical slide (+15% to zero); subtitle reveals smoothly at 0.38 – 0.58 (~2.6 – 4.0s).
- **Stage C (0.02 – 1.00, ~0.1 – 7.0s)**: Capsule progress bar fills smoothly across the full 7.0-second cinematic duration with `Curves.easeInOutCubic`.
- **Smooth Transition**: At 7.0 seconds, on verified animation completion and local storage readiness, smoothly transitions to `AppView.home` via `AnimatedSwitcher` (260ms `Curves.easeOutCubic`).
- **Resilience & Testing**: Single-navigation latch (`_hasNavigated`) prevents duplicate transitions. Supports `reducedMotion` (bypasses spatial translations). Widget tests automatically bypass long timers via `TestWidgetsFlutterBinding` checks.

---

## 8. Home Screen Specifications (Reference Screen 2 — Phase 1 Implementation)

### 8.1 Production Asset Architecture
- **Asset A — Home Background (`assets/images/home_bg.jpg`)**:
  - High-resolution (9:16 portrait) environment generated via Nano Banana image generation (`home_bg_1792777090120.jpg`), optimized to 397 KB.
  - Composition: Ultra-dark midnight navy void (`#061225`) with atmospheric volumetric depth, sleek cyber city monolith silhouettes at the sides, a luminous electric cyan neon portal arch framing the center, floating 3D isometric neon cubes (cyan on left, purple on right), and a ground-level cybernetic pedestal platform with cyan bevel seams and floor mist.
  - Zero text, buttons, or embedded UI elements; foreground and navigation bands are shaded with subtle programmatic gradient scrims (`alpha: 0.60` top, `alpha: 0.75` bottom) for WCAG AAA contrast.
- **Asset B — Hero Stacking Artwork Evaluation**:
  - Evaluated standalone raster generation vs programmatic Flame/CustomPainter rendering.
  - Decision: Pure programmatic CustomPainter (`_HeroBlocksPainter`) ensures clean alpha isolation (eliminating artificial black/checkerboard backgrounds), dynamic theme color synchronization, 60/120 FPS performance, and smooth real-time physical animation without raster artifacting.

### 8.2 Component Hierarchy & Layout
- **Top Bar**:
  - Left: Capsule badge (`Color(0xFF14284A)`, border `alpha: 0.12`) with golden crown icon (`#FFCB78`) and two stacked lines: `BEST` (small, 9px, `#A8C4E4`) and tabular high score numeral (`${statistics.bestScore}`, 13px, bold white).
  - Right: 44×44px circular glass Settings button with gear icon (`Icons.settings_rounded`).
- **Brand Hero Stack**:
  - **Emblem Halo**: 3 rounded stacked pills (Cyan `#13D9FF`, Blue `#347BFF`, Purple `#9658FF`) enclosed inside a circular dark glass halo (`Color(0xFF0C1B36)` at `alpha: 0.65`, cyan border `alpha: 0.22`, and soft drop glow).
  - **Game Title**: `STACK PULSE` in bold uppercase with letter spacing +4.0.
  - **Subtitle**: `ONE TAP. PERFECT STACK.` with letter spacing +1.5 in `#A8C4E4`.
  - **Hero Tower**: 4 stacked blocks rendered directly on the cyber pedestal:
    - Layer 1 (bottom): Deep Cobalt/Cyan block (`#1E60D0` to `#13D9FF`), 114px width, 20px height, 26px depth.
    - Layer 2: Electric Purple/Magenta block (`#8A30E0` to `#F34BEA`), 94px width, 19px height, 24px depth.
    - Layer 3: Neon Coral/Salmon Pink block (`#FF5E7E` to `#FF8A65`), 76px width, 18px height, 22px depth.
    - Layer 4 (top): Sky Blue / Electric Cyan block (`#13D9FF` to `#BBEFFF`), 62px width, 17px height, 20px depth, floating with a sinusoidal hover (`math.sin(t) * 6.0`) and jaunty tilt (`-0.04 + math.sin(t) * 0.04`), surrounded by a radiant cyan bloom (`RadialGradient` radius 46).
- **Primary CTA**:
  - Full-width `PLAY` pill button (`height / 2` radius) with 3-stop gradient: Electric Cyan (`#13D9FF`) to Neon Blue (`#347BFF`) to Electric Purple (`#9658FF`), bold white play icon, and radiant cyan-purple drop bloom.
- **Bottom Navigation**:
  - Row of 3 `HomeActionTile`s:
    - `THEMES`: Palette icon (`Icons.palette_rounded`) with mint accent (`#14E4C5`).
    - `HOW TO PLAY`: Question badge (`Icons.help_rounded`) with cyan/blue accent (`#13D9FF`).
    - `SETTINGS`: Gear icon (`Icons.settings_rounded`) with neon magenta accent (`#F34BEA`).
  - Dark elevated container (`#14284A` / `#1D3560`), 18px corner radius, hairline white border (`alpha: 0.10`), and interactive scale spring feedback.
- **Motion & Accessibility**:
  - Respects `GameSettings.reducedMotion`: disables floating and tilting oscillations on the hero top block when enabled.
  - Safe for automated widget tests (prevents `pumpAndSettle` timeout).


---

## 9. Gameplay Screen Specifications (Reference Screens 3 & 4 — Phase 3 Implementation)

### 9.1 Absolute Block Protection
- **Unmodified Gameplay Layer**: Per strict Phase 3 requirements, all Flame block components (`StackBlockComponent`, `MovingBlockComponent`, `FallingPieceComponent`, and physics engine) remain completely unchanged:
  - Dimensions, speeds, collision tolerances, spawn coordinates, and trimming math are 100% preserved.
  - Block rendering styles, bevels, and palette assignments remain authoritative and decoupled from HUD/background presentation.

### 9.2 Production Background Asset (`assets/images/gameplay_bg.jpg`)
- **Asset Architecture**:
  - High-resolution (9:16 portrait) environment generated via Nano Banana image generation (`gameplay_bg_1792779594243.jpg`).
  - Composition: Ultra-dark midnight navy void (`#061225`) with sleek architectural cyber skyscraper silhouettes concentrated strictly on the left and right outer margins.
  - High Visibility Channel: The central 60% vertical column is spacious, dark, and low-contrast, providing maximum contrast and visual readability for the colorful stacking tower and moving block.
  - Upper & Lower Grounding: The upper 20% area is shaded for HUD legibility, while the lower foundation features subtle cyan volumetric floor mist.
  - Viewport-Fixed Strategy: Decoded once and displayed via `Image.asset(..., fit: BoxFit.cover)` behind the transparent Flame `GameWidget`, preventing camera-follow jitter and eliminating runtime decode overhead.
- **Theme Adaptability**:
  - `Midnight Neon`: Displays the native `gameplay_bg.jpg` cyber arcade artwork.
  - `Aurora`, `Sunset Pulse`, `Arctic Glow`: Harmonized via a thematic translucent overlay (`theme.background.withValues(alpha: 0.60)`), preserving environmental geometry while shifting the color temperature.

### 9.3 Screen-Fixed HUD Layout
- **Top-Left (Best Score Pill)**:
  - Dark elevated container (`#14284A` at 0.85 opacity, radius 18px, hairline border `alpha: 0.12`).
  - Gold crown icon (`Icons.emoji_events_rounded` in `#FFCB78`, size 15px).
  - Two-tier text stack: `BEST` (small 8.5px in `#A8C4E4`) and best score numeral in bold white tabular figures.
- **Top-Center (Current Score & Combo Badge)**:
  - Primary focal numeral: 48px bold w900 tabular figures with subtle cyan drop glow.
  - Pulse physics: Scale bounce (1.0 → 1.12 → 1.0 in 160ms) on score increment (bypassed when `reducedMotion` is enabled).
  - Combo badge: `COMBO ${streak}` pill badge with dual-tone gradient fill (`primaryAccent` to `secondaryAccent`), hairline border, and a glowing tapered horizontal accent line directly beneath. Fixed height container guarantees zero vertical layout shifting.
- **Top-Right (Circular Pause Button)**:
  - 44×44px circular glass button (`#14284A` at 0.85 opacity, hairline border `alpha: 0.12`).
  - Tactile spring physics: Scales to `0.92` on touch down with spring rebound on release.
  - Accessible touch target placed securely in the top-right `SafeArea`.

### 9.4 Combo & Perfect Streak Feedback (`PerfectComboBanner`)
- **Placement**: Screen-fixed in upper region (`top: 22%` of screen height), positioned safely above the active block traversal line to prevent occlusion.
- **Styling**: `PERFECT!` in bold electric cyan (`#13D9FF`, tracking +3.5) with multi-layered neon glow shadows, plus multiplier `x${streak}` in `#55E7FF`.
- **Arcade Sparkles**: Ambient diamond sparkle stars (`#13D9FF`, `#9658FF`, `#FFCB78`, `#14E4C5`) frame the banner.
- **Lifecycle & Motion**: 650ms automatic dismiss cycle; respects `reducedMotion` by using pure fade transitions without elastic scale spring.


---

## 10. Pause & Game-Over Layouts (Reference Screens 5 & 6 — Phase 4 Implementation)

### 10.1 Pause Overlay
- **Live Gameplay Frosted Backdrop**: The active paused tower scene remains directly visible through `BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12))` combined with a dark translucent navy gradient (`#061225` at 0.85 opacity to `#08162E` at 0.88 opacity) and soft ambient cyan/purple glow spots.
- **Touch Barrier**: Full-screen opaque gesture detector absorbs all touch events, guaranteeing zero accidental block drops while paused.
- **Top-Right Close Controls**: Tactile circular glass `X` button in `SafeArea` plus an integrated corner `X` in the modal header—both trigger safe, clean `onResume`.
- **Floating Glass Modal**:
  - Dimensions: Compact 314px width container centered on screen with 24px border radius.
  - Surface: Translucent glassmorphic navy gradient (`#162D53` to `#0C1B35` at 0.95–0.97 opacity).
  - Border: Subtle illuminated cyan/blue outline (`#265A96` at 0.55 opacity, 1.2px width) with deep ambient shadow (`blurRadius: 36`).
  - Header: `PAUSED` in bold uppercase (22px, tracking +2.4) with centered `Your tower is waiting.` subtitle (13px in `#A8C4E4`).
- **Four Vertically Stacked Pill Buttons** (10px spacing, consistent heights):
  1. `RESUME`: Prominent cyan-to-violet gradient (`#20BAFF` → `#4B79FF` → `#9B50FF`), white play icon, 50px pill height, dual-color glow shadow.
  2. `RESTART`: Dark navy elevated surface (`#1B325A` to `#112240`), white refresh icon, 46px pill height, hairline border.
  3. `SETTINGS`: Dark navy elevated surface, white settings gear icon, 46px pill height. Opens settings as a modal route on top of the live game, preserving the exact paused tower run on dismissal.
  4. `HOME`: Dark navy elevated surface, white home icon, 46px pill height.
- **State Protection**: Transition debouncing prevents rapid-click race conditions.

### 10.2 Game Over Overlay
- **Live Gameplay Frosted Backdrop**: Full-screen frosted blur (`sigmaX: 14, sigmaY: 14`) over the completed tower run, bathed in soft ambient magenta (`#F34BEA`) and purple (`#9658FF`) glow spots with dark translucent navy grounding. Tap barrier absorbs touch events.
- **Title**: Large, bold `GAME OVER` (34px, w900, tracking +2.8) rendered with vibrant Neon Magenta-to-Purple gradient (`#F34BEA` to `#9658FF`) and dual-layer neon bloom shadow.
- **Score Card**:
  - Proportions: Max 340px width container, 24px border radius, `#102242` surface at 0.92 opacity, hairline border (`alpha: 0.12`).
  - Header: Small `SCORE` label in `#A8C4E4` (12px, w800, tracking +1.6).
  - Score Numeral: 64px bold w900 white tabular numeral with smooth count-up animation (`IntTween` from 0 to final score).
  - `NEW BEST` Badge: Golden amber gradient pill (`#FFE082` → `#FFB300` → `#FFA000`) with custom notched crown silhouette and dark bold typography (`NEW` / `BEST`), displayed *only* on personal records (`isNewBest == true`).
  - Thin Divider: 1px separation line (`white.withValues(alpha: 0.08)`).
  - Two-Column Stats: Balanced bottom row with `BEST SCORE` and `BEST STREAK` labels over 22px bold white tabular figures, separated by a thin 32px vertical divider.
- **Action Buttons**:
  1. `RETRY`: Signature 4-stop gradient pill (`#13D9FF` → `#347BFF` → `#9658FF` → `#F34BEA`), white play icon, 56px height, vibrant dual-glow drop shadow (`#13D9FF` and `#F34BEA`).
  2. `HOME`: Dark navy glass pill (`#1A3056` to `#0F1E38`), white home icon, 50px height, hairline border.
- **Animation**: Smooth scale (0.90 → 1.0) and fade entrance transitions; test-safe execution bypasses delays during automated tests.

---

## 11. Theme Gallery Specifications (Reference Screen 7 — Phase 5 Implementation)

### 11.1 Header & Navigation
- **Back Navigation**: Tactile circular glass button (`#14284A` at 0.85 opacity, 42×42px, hairline border `alpha: 0.12`) with white `Icons.arrow_back_rounded`.
- **Typography**:
  - Title: `CHOOSE YOUR VIBE` in bold uppercase white (19px, w900, tracking +2.0).
  - Subtitle: `Make every stack your own.` in soft muted cyan/blue (`#A8C4E4`, 12.5px, w500).
- **Layout Alignment**: Centered title block balanced symmetrically with a matching spacer opposite the back button.

### 11.2 Theme Card Architecture (`ThemeCard`)
- **Proportions**: 2-column responsive layout with 16px horizontal and vertical spacing. Dynamic aspect ratio clamping (0.78 to 0.90) adapts gracefully across diverse portrait phone heights.
- **Card Container**:
  - Radius: Smooth 24px rounded corners.
  - Surface: Elevated cyber gradient (`theme.surfaceElevated` to `theme.surface`).
  - Active State (Selected):
    - Border: Bright illuminated electric cyan (`#13D9FF`, 2.0px width).
    - Shadow: Dual drop glow (`#13D9FF` at 0.45 opacity, blur 20px + ambient black shadow).
    - Badge: Circular electric blue pill badge (`#347BFF`, 24×24px, drop glow) with bold white checkmark (`Icons.check_rounded`, size 16) positioned securely at top-right (`10, 10`).
  - Unlocked State:
    - Border: Theme-tinted accent outline (`theme.primaryAccent` at 0.40 opacity, 1.2px width).
    - Ambient shadow: Soft dark drop shadow (`alpha: 0.35`, blur 12px).
    - No badge.
  - Locked State:
    - Border: Low-contrast border (`white.withValues(alpha: 0.08)`).
    - Surface: Dimmed cyber surface (`alpha: 0.45` to `0.30`).
    - Badge: Circular translucent lock badge (26×26px, `white.withValues(alpha: 0.08)`) with `Icons.lock_rounded` in `alpha: 0.55`.
    - Artwork: Dimmed with 0.50 opacity and desaturated grayscale matrix.
    - Requirement Text: `Unlock at Best Score X` in `#A8C4E4` (11px, w500).

### 11.3 Dedicated 3D Isometric Preview Assets
- **Asset Suite**:
  1. `assets/images/theme_preview_midnight.jpg` — Electric cyan, blue, and violet stacked blocks on an illuminated glowing cyan pedestal with dark midnight navy cyber fog.
  2. `assets/images/theme_preview_aurora.jpg` — Mint, turquoise, emerald, and violet stacked blocks on an illuminated mint pedestal with polar green aurora borealis atmosphere.
  3. `assets/images/theme_preview_sunset.jpg` — Sunset orange, coral, vivid pink, and warm amber stacked blocks on an illuminated coral pedestal with velvet violet sunset glow.
  4. `assets/images/theme_preview_arctic.jpg` — Glacial white, ice cyan, polar blue, and oceanic sapphire stacked blocks on an illuminated glacial ice pedestal with crystalline frost atmosphere.
- **Integration**: Loaded via `Image.asset(theme.previewAssetPath, fit: BoxFit.contain)` with automatic fallback to programmatic geometric block towers if assets cannot load.

### 11.4 Interaction & Persistence
- **Touch Physics**: Spring scale animation (1.0 → 0.95 → 1.0) on press down/up; respects `GameSettings.reducedMotion`.
- **Immediate Persistence**: Theme selection writes directly to `SharedPreferences` via `_updateSettings` and synchronizes UI and Flame components simultaneously. Locked themes reject tap interactions without mutation.

---

## 12. Settings & Tutorial Layout (Reference Screens 8 & 9 — Phase 6 Implementation)

### 12.1 Settings Screen
- **Header**: Circular glass back button (42×42px, hairline border `alpha: 0.12`), centered bold white `SETTINGS` title (19px, w900, tracking +2.2), and symmetrical 42px right spacer.
- **Setting Cards**:
  - Individual elevated dark cyber cards (`#14284A` at 0.85 opacity, radius 22px, hairline border `alpha: 0.12`, drop shadow blur 14px).
  - Consistent layout: Circular icon container (38×38px, `white.withValues(alpha: 0.08)`), crisp bold white title (15.5px, w700), and custom electric cyan neon pill switch.
  - Three distinct controls:
    1. **Sound Effects**: Speaker icon (`Icons.volume_up_rounded`) + custom neon switch; synchronizes sound effects and background music.
    2. **Haptic Feedback**: Vibration phone icon (`Icons.vibration_rounded`) + custom neon switch; controls tactile feedback.
    3. **Reduced Motion**: Crescent moon icon (`Icons.nightlight_round`) + custom neon switch; disables nonessential animations without altering gameplay mechanics.
- **Custom Neon Pill Switch (`_NeonPillSwitch`)**:
  - Track: 50×28px pill; when active, emits bright cyan-to-blue gradient (`#13D9FF` to `#347BFF`) with neon bloom drop shadow (`#13D9FF` at 0.45 opacity); when inactive, deep navy (`#152A4A`).
  - Thumb: 22px pure white circle with smooth slide animation (200ms `Curves.easeOutCubic`) and tactile drop shadow.
- **Theme Shortcut Card**:
  - Upper section label: `THEME` (small bold uppercase `#A8C4E4`, tracking +1.6).
  - Card container: 46×46px mini theme thumbnail previewing active theme asset, `Current Theme` label in `#A8C4E4`, active theme name in bold white (16px, w800), and navigation chevron arrow (`Icons.chevron_right_rounded`).
  - Seamless navigation to `ThemesScreen`.
- **State & Persistence**:
  - Immediate persistence to `SharedPreferences` on toggle.
  - Fully functional when opened as a modal from Pause Menu; dismissing preserves paused tower session without auto-resuming.

### 12.2 How to Play Screen
- **Header**: Circular glass back button (42×42px), centered `HOW TO PLAY` title (19px, w900, tracking +2.0), and `Master the perfect stack.` subtitle (`#A8C4E4`, 12.5px).
- **Five Interactive Step Cards**:
  - Container: Elevated dark cyber card (`#14284A` at 0.85 opacity, radius 22px, hairline border `alpha: 0.12`, drop shadow blur 12px).
  - Structure:
    - Number Badge: 28×28px circular blue gradient pill (`#2B85FF` to `#1B63D8`) with bold white number (`1`–`5`).
    - Instruction Text: Crisp bold white instructional sentence (13.5px, w700, height 1.3).
    - Illustrated Diagram: Dedicated 82×52px interactive educational illustration with looping micro-animations.
  - Five Illustrated Steps:
    1. **Block moves automatically**: Gliding rectangular block with ping-pong horizontal oscillation and cyan directional motion arrows.
    2. **Tap to stack it**: Stationary base block with placed block, tapping hand pointer icon, and expanding radiant cyan touch ripple ring.
    3. **Perfect alignment keeps the width**: Two perfectly aligned stacked blocks with radiant electric cyan bloom pulse and ambient diamond sparkles.
    4. **Inaccurate alignment trims the block**: Base block and overlapping top block with falling trimmed slice piece dropping and rotating with gravity.
    5. **Miss the tower and it's game over**: Foundation stack on left with tumbling missed block tumbling diagonally at 45° downward into the dark void.
- **Completion CTA**:
  - Bottom `LET'S PLAY` primary pill button (52px height, cyan-to-purple gradient, play icon) dismissing tutorial cleanly back to previous view.
- **Accessibility**: Looping animations automatically freeze into static diagrams when `reducedMotion` is active.

---

## 13. Screen Transitions & Animation Guidelines (Phase 7 Final Polish)

- **Coordinated Screen Transitions**:
  - Global navigation utilizes `AnimatedSwitcher` with 240ms duration (`Curves.easeOutCubic`).
  - Coordinated transition architecture combines `FadeTransition` (0.0 → 1.0) with subtle `ScaleTransition` (0.98 → 1.0), eliminating abrupt jumps, white flashes, and black frames.
  - Modal overlay routes (e.g. Pause Menu Settings, Game Screen modal pushes) utilize `PageRouteBuilder` with `FadeTransition` and `ScaleTransition` (0.96 → 1.0), preserving the paused Flame world beneath without auto-resuming.
  - Multi-Tap Debounce Guard: All screen view transitions in `StackPulseApp` feature a 250ms latch (`_switchView`), and all buttons feature a 300ms touch debounce to permanently prevent rapid-tap duplicate transitions.
- **Button Press Physics & Microinteractions**:
  - `PremiumButton`: 100ms scale to `0.955` on touch down (`Curves.easeInOutCubic`), 140ms bounce return (`Curves.easeOutBack`) on release.
  - `HomeActionTile`: 100ms scale to `0.94` on touch down, 140ms bounce return on release.
  - `GlassIconButton`: Standardized circular glass button with 90ms scale to `0.92` on touch down, 140ms bounce return on release, and 300ms debounce protection.
  - `ThemeCard`: Active selection border and glow transitions (`240ms` `Curves.easeOutCubic`); locked-state tap feedback features an immediate 240ms horizontal shake/wiggle animation (`-3.5px` to `+3.5px`) providing clear tactile feedback.
  - `_NeonPillSwitch`: 200ms smooth thumb slide (`Curves.easeOutCubic`) with electric cyan track bloom when active. Entire setting card row is tappable.
- **Modal Entrances**:
  - Pause Menu: 260ms scale (0.90 → 1.0) and fade with `Curves.easeOutBack`.
  - Game Over: 650ms choreographed sequence with scale (0.90 → 1.0), fade entrance, and tabular score count-up (`IntTween`).
- **Reduced Motion Support**:
  - Completely disables nonessential scaling bounces, floating oscillations, particle bursts, screen shake, and transition delays when enabled.
  - Transitions switch to instantaneous or pure linear fades.
  - Educational diagrams in TutorialScreen freeze into crisp static illustrations.

---

## 14. Responsive Design Architecture (Phase 7 Audit & Validation)

- **Certified Portrait Viewports**:
  - Formally validated against standard target portrait mobile viewports:
    - **360 × 800** (Compact Android)
    - **390 × 844** (Standard Modern iOS / Android)
    - **412 × 915** (Tall Android Flagship)
- **SafeArea Compliance**:
  - All headers, floating HUD pills, action bars, and modal controls are securely enclosed within `SafeArea`.
- **Dynamic Adaptive Constraints**:
  - `HomeScreen`: Dynamically scales hero stacking tower height via `(height * 0.25).clamp(120.0, 210.0)`, wrapped with `SingleChildScrollView` and `ConstrainedBox(minHeight: height)` to eliminate `RenderFlex` overflow on any viewport height.
  - `ThemesScreen`: 2x2 grid computes dynamic card aspect ratio `(itemWidth / targetItemHeight).clamp(0.78, 0.90)` to maintain balanced visual proportions.
  - `ScoreDisplay`: HUD score numeral and `COMBO` pill badge use fixed container height (28px) with `FittedBox(fit: BoxFit.scaleDown)` and `height: 1.0` text metric, eliminating subpixel text overflow.
  - `GameOverOverlay`: Final score numeral and gold `NEW BEST` crown badge are wrapped with `FittedBox(fit: BoxFit.scaleDown)` to accommodate arbitrarily high scores (e.g. 99,999) without horizontal layout clipping.
  - `ThemeCard`: Locked unlock requirement text (`Unlock at Best Score X`) is wrapped with `FittedBox(fit: BoxFit.scaleDown)` to prevent text clipping on narrow 360px portrait screens.
  - `PauseOverlay` & `GameOverOverlay`: Modals are enclosed inside `SingleChildScrollView(physics: BouncingScrollPhysics())` to guarantee accessibility on short screens or when virtual keyboards/accessibility zooms are active.

---

## 15. Accessibility & Readability Requirements

- **Contrast Ratios**: Primary white text (`#FFFFFF`) against `#061225` navy achieves > 16:1 contrast, exceeding WCAG AAA standards.
- **Tabular Figures**: Numeric score displays use `FontFeature.tabularFigures()` to prevent jitter during fast score incrementing.
- **Tactile Feedback**: Haptic pulses accompany block placement, combos, button presses, and game-over events (controlled via Settings).
- **Disabled State Polish**:
  - Buttons and cards in disabled/locked states feature standardized `0.45` opacity (`GameTheme.disabledOpacityValue`), suppressed drop shadows, muted borders (`white.withValues(alpha: 0.08)`), and touch rejection without unintended visual glitches.
- **Reduced Motion**: Dedicated user setting for players sensitive to screen shake, intense particle bursts, or rapid spatial translations.

---

## 16. Centralized Design Token Authority & Consistency Rules

1. **Always Use `GameTheme`**: Never introduce ad-hoc color codes in new widgets or Flame components. Retrieve colors from `GameTheme.fromType(...)` or `game.theme`.
   - `GameTheme.cardBorderRadiusValue` (22.0px) for standard surface cards.
   - `GameTheme.modalBorderRadiusValue` (24.0px) for floating overlays.
   - `GameTheme.disabledOpacityValue` (0.45) for inactive and locked components.
   - `GameTheme.glassSurfaceColor` (`#14284A` at 0.85 opacity) for circular buttons and badges.
   - `GameTheme.switchTrackInactiveColor` (`#152A4A`) for toggles.
2. **Button Consistency**: Always use `PremiumButton` for primary/secondary pill actions and `GlassIconButton` for circular glass controls to retain consistent geometry, press feedback, and drop shadows.
3. **Adding New Themes**:
   - Add a new enum value to `ThemeType`.
   - Define a `const GameTheme` instance in `lib/core/game_theme.dart` with its 6-color block palette, background colors, and unlock requirement.
   - Add to `allThemes` and update `fromType`.
4. **Preserve Authority & Absolute Block Protection**: Never modify gameplay math (overlap logic, tolerance, falling piece physics) inside visual UI components. Keep rendering and game logic cleanly decoupled.

