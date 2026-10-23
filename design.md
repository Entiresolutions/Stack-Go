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

## 9. Gameplay HUD & Block Styling (Reference Screens 3 & 4)

- **Top HUD**:
  - Left: Golden crown BEST score pill.
  - Center: Large tabular score with glowing `COMBO X` underline badge.
  - Right: Circular glass pause button (44×44px) with pause bars icon.
- **Stack Blocks**:
  - Dimension: Dynamic width × 32px height.
  - Rendering: 2.5D vertical gradient, top sheen highlight line (1.5px height at 0.45 white opacity), hairline separation border (0.25 opacity), and subtle floor drop shadow.
- **Active Moving Block**:
  - Luminous gradient face, distinct outline, and smooth linear traversal.
- **Background Atmosphere**:
  - Dark gradient void with faint vertical architectural guidelines and theme-specific silhouetted background elements.

---

## 10. Pause & Game-Over Layouts (Reference Screens 5 & 6)

### 10.1 Pause Overlay
- Full-screen blurred backdrop (`sigmaX: 10, sigmaY: 10`) with `0xCC061225` dark tint.
- Floating modal container (`#14284A`) with subtle border and rounded corners (`26px`).
- Top-right `X` close icon button.
- Header: `PAUSED` in bold uppercase, accompanied by `Your tower is waiting.` subtitle.
- Action Stack: Vertical pill buttons for `RESUME` (Primary gradient), `RESTART`, `SETTINGS`, and `HOME`.

### 10.2 Game Over Overlay
- Magenta-accented ambient backdrop.
- Title: `GAME OVER` in bold gradient text.
- Score Card: Elevated container with `SCORE` label and giant tabular score numeral (56px).
- `NEW BEST` badge: Golden pill with star icon when personal record is broken.
- Stats Grid: Two-column layout displaying `BEST SCORE` and `BEST STREAK`.
- Action Stack: Prominent `RETRY` gradient pill button and secondary `HOME` dark pill button.

---

## 11. Theme Gallery Specifications (Reference Screen 7)

- **Header**: Back arrow icon button, `CHOOSE YOUR VIBE` title, and `Make every stack your own.` subtitle.
- **Grid Layout**: 2-column responsive card grid (`GridView`).
- **Theme Card**:
  - Dark elevated container with active/inactive border.
  - Real 3D miniature stacked tower preview rendered on a miniature pedestal using the theme's actual block colors.
  - Active State: Cyan circular checkmark badge (`Icons.check`) on top-right, glowing active border, and theme name.
  - Locked State: Top-right lock icon, semi-translucent overlay, and `Unlock at Best Score X` indicator.
  - Tap interaction: Selects unlocked themes immediately and updates game settings.

---

## 12. Settings & Tutorial Layout (Reference Screens 8 & 9)

### 12.1 Settings Screen
- Back navigation header with `SETTINGS` title.
- Elevated surface container grouping three interactive toggle rows:
  - **Sound Effects**: Speaker icon, readable label, cyan switch toggle.
  - **Haptic Feedback**: Vibration phone icon, readable label, cyan switch toggle.
  - **Reduced Motion**: Moon/calm icon, readable label, cyan switch toggle.
- Theme Selection Card: Displays mini 3-pill logo, `Current Theme` label, current theme name, and navigation chevron pointing to Themes screen.

### 12.2 How to Play Screen
- Back navigation header with `HOW TO PLAY` title.
- 5 vertical instructional step rows:
  1. `Block moves automatically` (with sliding block and directional arrows).
  2. `Tap to stack it` (with stacked blocks and tapping hand pointer).
  3. `Perfect alignment keeps the width` (with glowing perfect block and sparkle badge).
  4. `Inaccurate alignment trims the block` (with trimmed slice falling away).
  5. `Miss the tower and it's game over` (with missed block falling past tower foundation).

---

## 13. Animation Guidelines

- **Screen Transitions**: `AnimatedSwitcher` using `Curves.easeOutCubic` (240ms duration).
- **Button Press Physics**: 100ms scale to `0.955` on press, 140ms bounce return with `Curves.easeOutBack`.
- **Modal Entrances**: 260ms scale and fade with `Curves.easeOutBack`.
- **Hero Tower Motion**: Sinusoidal floating block animation on Home screen (3200ms cycle). Test-safe: automatically bypasses infinite loops during automated widget testing to prevent `pumpAndSettle` timeout.
- **Particle System**: Flame-managed rotating diamond prisms and glowing spark bursts on perfect placement.
- **Reduced Motion Support**: Completely disables particle bursts and camera shake when enabled by the user.

---

## 14. Responsive Design Guidelines

- **Orientation**: Strictly locked to portrait mode (`DeviceOrientation.portraitUp`, `DeviceOrientation.portraitDown`).
- **SafeArea Compliance**: All headers, HUD elements, and bottom action rows are wrapped within `SafeArea`.
- **Adaptive Layout**: Uses `LayoutBuilder`, `SingleChildScrollView`, and flex ratios so layouts gracefully adapt from small phones (600px height) to modern tall displays (900px+ height) without clipping or overflow.

---

## 15. Accessibility & Readability Requirements

- **Contrast Ratios**: Primary white text (`#FFFFFF`) against `#061225` navy achieves > 16:1 contrast, exceeding WCAG AAA standards.
- **Tabular Figures**: Numeric score displays use `FontFeature.tabularFigures()` to prevent jitter during fast score incrementing.
- **Tactile Feedback**: Haptic pulses accompany block placement, combos, button presses, and game-over events.
- **Reduced Motion**: Dedicated user setting for players sensitive to screen shake or intense particle bursts.

---

## 16. Instructions for Maintaining Consistency

1. **Always Use `GameTheme`**: Never introduce ad-hoc color codes in new widgets or Flame components. Retrieve colors from `GameTheme.fromType(...)` or `game.theme`.
2. **Button Consistency**: Always use `PremiumButton` for primary/secondary actions to retain consistent pill geometry, press feedback, and drop shadows.
3. **Adding New Themes**:
   - Add a new enum value to `ThemeType`.
   - Define a `const GameTheme` instance in `lib/core/game_theme.dart` with its 6-color block palette, background colors, and unlock requirement.
   - Add to `allThemes` and update `fromType`.
4. **Preserve Authority**: Never modify gameplay math (overlap logic, tolerance, falling piece physics) inside visual UI components. Keep rendering and game logic cleanly decoupled.
