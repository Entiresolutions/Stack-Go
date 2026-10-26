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

### 4.2 Complete 10-Theme Specifications & Block Palettes

Stack Pulse organizes its 10 interactive themes into 3 distinct priority progression tiers. Each theme supplies 6 cycling gradient colors for gameplay blocks alongside dedicated ambient and reactive visual environments:

#### Priority 1 — Core Environments (Themes 1–4)
- **1. Midnight Neon (Cyber Dimension)**
  - Tier: `ThemeTier.core`
  - Unlock Requirement: Unlocked by default (Best Score 0)
  - Visual Identity: Deep navy futuristic architecture, cyan & violet lighting, subtle cyber grid elements.
  - Assets: `assets/images/gameplay_bg_1792779594243.jpg`, `assets/images/theme_preview_neon.jpg`
  - Block Palette: `#13D9FF` (Cyan) → `#347BFF` (Neon Blue) → `#9658FF` (Electric Purple) → `#F34BEA` (Neon Magenta) → `#FF995B` (Sunset Orange) → `#14E4C5` (Mint).
  - Ambient Animation: Slow edge vertical light beams, moving cyber diamond particles, subtle floor mist breathing.
  - Reactive Feedback: Electric cyan shockwave expanding outward on perfect placement; streak multiplier intensifies cyber beam glow.

- **2. Aurora (Living Lights)**
  - Tier: `ThemeTier.core`
  - Unlock Requirement: Best Score 10
  - Visual Identity: Deep emerald & turquoise northern lights, soft atmospheric depth, flowing ethereal ribbons.
  - Assets: `assets/images/gameplay_bg_aurora.jpg`, `assets/images/theme_preview_aurora.jpg`
  - Block Palette: `#14E4C5` (Mint) → `#2DD4BF` (Turquoise) → `#34D399` (Polar Green) → `#10B981` (Emerald) → `#06B6D4` (Cyan) → `#6EE7B7` (Soft Polar).
  - Ambient Animation: Flowing dual-layer upper aurora wave ribbons, floating luminous spirit particles.
  - Reactive Feedback: Shimmer wave sweep horizontally across northern lights on perfect placement; streaks temporarily boost aurora brightness.

- **3. Sunset Pulse (Golden Horizon)**
  - Tier: `ThemeTier.core`
  - Unlock Requirement: Best Score 25
  - Visual Identity: Coral & orange twilight, deep violet horizon, warm atmospheric breathing.
  - Assets: `assets/images/gameplay_bg_sunset.jpg`, `assets/images/theme_preview_sunset.jpg`
  - Block Palette: `#FF995B` (Neon Orange) → `#FF7043` (Coral) → `#FF4081` (Vivid Pink) → `#F34BEA` (Neon Magenta) → `#9658FF` (Electric Purple) → `#FFB300` (Sunset Gold).
  - Ambient Animation: Slow horizon glow breathing, glowing boundary horizon line, drifting golden dust motes.
  - Reactive Feedback: Radiant golden sweep radiating along horizon on perfect placement; streaks brighten sunset horizon glow.

- **4. Arctic Glow (Frozen Dimension)**
  - Tier: `ThemeTier.core`
  - Unlock Requirement: Best Score 50
  - Visual Identity: Deep icy blue environment, cold cyan lighting, distant crystalline spires.
  - Assets: `assets/images/gameplay_bg_arctic.jpg`, `assets/images/theme_preview_arctic.jpg`
  - Block Palette: `#E0F2FE` (Glacial White) → `#7DD3FC` (Polar Ice) → `#38BDF8` (Glacial Cyan) → `#347BFF` (Neon Blue) → `#818CF8` (Frost Indigo) → `#0284C7` (Deep Ocean).
  - Ambient Animation: Gentle crystalline snow drift, floor frost mist breathing, twinkling crystal spire glints.
  - Reactive Feedback: Sharp icy sparkle flash with expanding frost ring on perfect placement; streaks add crystalline sparkle highlights.

#### Priority 2 — Advanced Environments (Themes 5–7)
- **5. Sakura Drift (Cherry Blossom Sanctuary)**
  - Tier: `ThemeTier.advanced`
  - Unlock Requirement: 100 Lifetime Placements
  - Visual Identity: Serene nighttime Japanese garden sanctuary, deep indigo & muted violet atmosphere, soft warm lantern lighting, layered silhouette edges.
  - Assets: `assets/images/gameplay_bg_sakura.jpg`, `assets/images/theme_preview_sakura.jpg`
  - Block Palette: `#FF85A2` (Blossom Pink) → `#FFAAC0` (Soft Petal) → `#FF6384` (Deep Sakura) → `#D070FF` (Orchid Violet) → `#FF94B8` (Radiant Pink) → `#F8E8EE` (Cherry White).
  - Ambient Animation: Diagonally fluttering cherry blossom petals drifting with natural sway, soft lantern breathing illumination in outer lower corners.
  - Reactive Feedback: Delicate blossom burst radiating 6 petal sparkles outward on perfect placement; streaks create soft pink ambient shimmer.

- **6. Abyssal Depths (Bioluminescent Ocean)**
  - Tier: `ThemeTier.advanced`
  - Unlock Requirement: 250 Lifetime Placements
  - Visual Identity: Deep oceanic abyss, dark ocean blue & turquoise, volumetric caustic light shafts, bioluminescent environmental detailing.
  - Assets: `assets/images/gameplay_bg_abyssal.jpg`, `assets/images/theme_preview_abyssal.jpg`
  - Block Palette: `#00E5FF` (Bioluminescent Cyan) → `#00FFD1` (Marine Mint) → `#00B0FF` (Deep Turquoise) → `#1DE9B6` (Aqua Teal) → `#0091EA` (Abyss Blue) → `#80D8FF` (Surface Shimmer).
  - Ambient Animation: Slowly rising underwater bubbles with specular highlights, atmospheric angled caustic light shafts descending in outer margins.
  - Reactive Feedback: Concentric circular underwater sonar ripple on perfect placement; streaks increase bioluminescent light shaft radiance.

- **7. Retro Grid (Digital Synthwave)**
  - Tier: `ThemeTier.advanced`
  - Unlock Requirement: 450 Lifetime Placements
  - Visual Identity: 80s digital synthwave cyber world, deep purple and midnight blue, magenta horizon, perspective wireframe grid, minimal glowing geometric silhouettes.
  - Assets: `assets/images/gameplay_bg_retro.jpg`, `assets/images/theme_preview_retro.jpg`
  - Block Palette: `#FF007F` (Neon Magenta) → `#FF2E93` (Synth Pink) → `#9D00FF` (Cyber Violet) → `#00E5FF` (Laser Cyan) → `#7928CA` (Retro Purple) → `#2BFBFF` (Electric Aqua).
  - Ambient Animation: Receding perspective wireframe grid scrolling smoothly at the bottom, horizon magenta glow, horizontal laser scan line sweeping vertically, digital square/diamond bits in edge margins.
  - Reactive Feedback: High-energy synthwave pulse wave traveling horizontally across the grid line + vibrant magenta shockwave on perfect placement; streaks brighten the digital grid and horizon.

#### Priority 3 — Prestige Environments (Themes 8–10)
- **8. Ember Core (Volcanic Chamber)**
  - Tier: `ThemeTier.prestige`
  - Unlock Requirement: 700 Lifetime Placements
  - Visual Identity: Dark volcanic obsidian chamber, molten rock fissures, glowing lava formations in edge columns, cinematic contrast.
  - Assets: `assets/images/gameplay_bg_ember.jpg`, `assets/images/theme_preview_ember.jpg`
  - Block Palette: `#FF6600` (Molten Orange) → `#FF8800` (Fiery Amber) → `#FFCC00` (Blazing Gold) → `#FF3300` (Crimson Magma) → `#FFAE00` (Sun Gold) → `#FF5722` (Obsidian Core).
  - Ambient Animation: Slowly rising glowing embers, breathing volcanic floor heat shimmer, molten edge fissure flares.
  - Reactive Feedback: Blazing magma shockwave with double fire rings and central ember spark on perfect placement; streaks amplify molten fissure illumination.

- **9. Celestial Observatory (Golden Constellations)**
  - Tier: `ThemeTier.prestige`
  - Unlock Requirement: 1,000 Lifetime Placements
  - Visual Identity: Rare midnight-blue celestial sky, elegant golden architectural silhouettes, fine constellation geometry, pure refined luxury.
  - Assets: `assets/images/gameplay_bg_celestial.jpg`, `assets/images/theme_preview_celestial.jpg`
  - Block Palette: `#FFD700` (Celestial Gold) → `#FFE57F` (Astral Yellow) → `#BF80FF` (Cosmic Violet) → `#FFF080` (Starlight) → `#9D65FF` (Deep Nebula) → `#FFFDE7` (Golden White).
  - Ambient Animation: Star clusters connected with fine glowing constellation lines in upper corners, periodic faint shooting star streak, golden 4-pointed sparkle stars.
  - Reactive Feedback: Starburst constellation flash with 8-pointed golden celestial sparkle at center on perfect placement; streaks illuminate constellation connections.

- **10. Prism Rift (Dimensional Fracture)**
  - Tier: `ThemeTier.prestige`
  - Unlock Requirement: 1,500 Lifetime Placements
  - Visual Identity: Dimensional fracture in deep space, dark violet and black void, prismatic cyan, magenta, and indigo reflections, crystalline dimensional facets.
  - Assets: `assets/images/gameplay_bg_prism.jpg`, `assets/images/theme_preview_prism.jpg`
  - Block Palette: `#00F0FF` (Prismatic Cyan) → `#50F7FF` (Refracted Aqua) → `#FF00CC` (Prismatic Magenta) → `#B026FF` (Prismatic Indigo) → `#FF40DF` (Neon Fuchsia) → `#FFFFFF` (Pure Spectrum).
  - Ambient Animation: Shifting angular dimensional refracted light facets, drifting faceted diamond crystal shards along outer margins.
  - Reactive Feedback: Multi-spectral chromatic dispersion ripple (cyan outer ring, magenta inner ring) + crystalline refractive flash on perfect placement; streaks illuminate distant crystalline dimensional fractures.

---

### 4.3 Environmental Rendering Architecture & Performance Guarantees

1. **Layered Structure**:
   - **Layer 1 (Background Artwork)**: High-resolution 9:16 portrait artwork locally bundled in `assets/images/` rendered via `Image.asset(fit: BoxFit.cover)` with smooth crossfade `AnimatedSwitcher`.
   - **Layer 2 (Procedural Ambient Graphics)**: Lightweight, GPU-accelerated procedural movement (petals, bubbles, grid scanlines, embers, stars, refractive facets) rendered via `CustomPainter`.
   - **Layer 3 (Reactive Placement Feedback)**: Decoupled listeners responding to perfect placement and streak milestones with non-blocking decorative visual pulses.
   - **Layer 4 (Atmospheric Scrim)**: Guaranteed legibility gradient scrim ensuring HUD score numbers and active gameplay stacking blocks maintain maximum contrast regardless of background scenery.
2. **Strict Playfield Protection**:
   - The central **55–65%** stacking column is strictly unobstructed across all 10 themes.
   - All ambient particles, silhouettes, light shafts, and fissures are anchored to outer edge columns (`x < 0.22` or `x > 0.78`) or top/bottom horizons.
3. **Performance & Energy Efficiency**:
   - **Single Active Environment**: Only the currently selected theme animates during gameplay. Inactive environments consume zero GPU or CPU resources.
   - **Zero Per-Frame Allocations**: All particle models are static constant structures with precomputed phases and speeds; `CustomPaint` reuses drawing structures without heap thrashing.
   - **Pause & Reduced Motion Lifecycle**: Ambient and reactive animation controllers immediately stop when the game is paused, inactive, or when the user activates `Reduced Motion`.
4. **Decoupled Game Engine Isolation**:
   - All environmental rendering is isolated in Flutter widget tree and background layers.
   - Stacking block components, movement, trimming, overlap calculations, difficulty speeds, collision logic, and scoring are 100% untouched and preserved.

---

### 4.4 Theme-Specific Center Corridor Blend Specification

The central gameplay stacking region strictly avoids flat, dead black vertical rectangles. Instead, each theme features an **organic, theme-aware gameplay-safe corridor**:

1. **Dark Central Gradient**:
   - Rather than pitch black, the center employs a deep, rich atmospheric extension of the active theme (`theme.corridorBaseColor` and `theme.corridorCenterColor`).
   - Maintains ideal contrast for 2.5D stacking blocks while feeling intrinsically connected to the surrounding environment.
2. **Soft Feather Blending from Both Side Environments**:
   - Multi-stop horizontal gradient (`stops: [0.0, 0.18, 0.32, 0.50, 0.68, 0.82, 1.0]`).
   - Outer edges (0.0–0.18 and 0.82–1.0) are completely transparent, allowing environmental scenery, spires, and trees to be admired unimpeded.
   - Transitions feather smoothly between 0.18 and 0.32, avoiding any visible seams, borders, or cuts.
3. **Subtle Lower Fog / Atmospheric Continuation**:
   - A breathing atmospheric mist (`RadialGradient` centered at bottom) using `theme.corridorLowerFogColor` with gentle ambient wave oscillation (`math.sin(waveTime * 1.2)`).
   - Visually links the left environment, base pedestal, and right environment across the bottom floor.
4. **Very Restrained Ambient Particles**:
   - Dedicated subtle motes (1.3–1.8px radius, low 0.16–0.22 alpha) drifting quietly through the central corridor (`x: 0.34 .. 0.66`).
   - Adds life and spatial depth to the corridor without distracting the player during precision block alignment.
5. **Theme-Specific Reactive Visual Accents**:
   - Landing a perfect placement triggers a soft, delicate corridor bloom (`RadialGradient` with `theme.reactivePulseColor` at 0.15 alpha) that illuminates the central corridor mist.
   - High streak milestones boost corridor fog luminescence.

#### Theme Corridor Color Palette Mapping:
- **Midnight Neon**: Deep navy (`#061226` / `#091934`) with cyan/violet atmospheric diffusion (`#0D254C`).
- **Aurora**: Dark emerald/teal atmospheric blend (`#041917` / `#062320` / `#0A332E`) with polar mint mist.
- **Sunset Pulse**: Deep plum / magenta-shadow blend (`#1C091B` / `#280E27` / `#381436`) with warm sunset orange glow.
- **Arctic Glow**: Icy deep blue / cyan-shadow blend (`#061628` / `#0A2038` / `#0F2E4F`) with frosty cyan glints.
- **Sakura Drift**: Dark indigo / blossom-pink haze (`#110B22` / `#1A1032` / `#281648`) with soft sakura haze.
- **Abyssal Depths**: Deep ocean abyss / aqua haze (`#031220` / `#051B2E` / `#082740`) with bioluminescent marine mist.
- **Retro Grid**: Dark synth purple / magenta-cyan blend (`#130826` / `#1D0D38` / `#2C1252`) with neon magenta dusk.
- **Ember Core**: Deep obsidian / ember-orange shadow glow (`#180A06` / `#240E08` / `#35150C`) with volcanic floor warmth.
- **Celestial Observatory**: Midnight blue / elegant gold haze (`#070E24` / `#0B1736` / `#10214C`) with astral starlight diffusion.
- **Prism Rift**: Dark violet / prismatic atmosphere (`#100720` / `#180B30` / `#261048`) with multi-spectral cyan-magenta dispersion.

---

### 4.5 Living Animated Environments & Layered Motion Specifications

Stack Pulse features an interactive living environmental animation system across all 10 gameplay themes. Rather than simply zooming or scaling a static canvas, the architecture separates environmental presentation into 4 GPU-optimized decoupled layers:

#### Layer 1: Static High-Fidelity Thematic Artwork
- High-resolution 9:16 portrait environments rendered via `Image.asset(fit: BoxFit.cover)` with smooth crossfade `AnimatedSwitcher`.

#### Layer 2: Theme-Specific Animated Environmental Elements (Multi-Depth & Parallax)
Each theme executes its own dedicated procedural rendering engine with independent velocity, trigonometric oscillation, and depth layers:

1. **Midnight Neon (Cyber Dimension)**:
   - **Holographic Light Beams**: Smoothly swaying vertical light columns in outer margins with soft linear falloff.
   - **Architectural Neon Conduits**: Angled travelling neon pulses running vertically along outer silhouettes.
   - **Cyber Dust & Data Glyphs**: Multi-layer geometric diamond particles and micro-pixels ascending with sinusoidal sway.
   - **Reactive**: Electric cyan shockwave expanding on perfect hits; 5x/10x streaks intensify conduit pulse frequency and beam luminance.

2. **Aurora (Living Lights)**:
   - **Multi-Curtain Aurora Ribbons**: 3 smoothly flowing, undulating ribbon curtains driven by multi-frequency harmonic sine waves (`sin(x * 3.2 + t * 1.5) + cos(x * 6.5 + t * 0.9)`).
   - **Curtain Striations**: Vertical radiant light bands hanging beneath the crests with shifting alpha.
   - **Luminous Spirit Motes**: Glowing emerald and turquoise motes drifting upwards with shimmering halos.
   - **Reactive**: Horizontal aurora shimmer wave sweeping across the northern lights on perfect placement; streaks swell ribbon height and wave amplitude.

3. **Sunset Pulse (Golden Horizon)**:
   - **Layered Drifting Clouds**: High-altitude thin wisps (`speed = 0.015`) and midground cumulus lobes with warm gradient shading moving with organic parallax.
   - **Crepuscular Sunlight Rays**: Radial sunlight beams originating from the horizon sun point, shifting angle slowly over time.
   - **Horizon Warm Glow**: Breathing amber/coral gradient along the bottom horizon with glowing boundary line.
   - **Floating Warm Dust**: Golden dust motes caught in the sunlight.
   - **Reactive**: Golden sweep radiating along horizon on perfect placement; streaks expand sun ray reach and sky warmth.

4. **Arctic Glow (Frozen Dimension)**:
   - **3-Depth Parallax Snowfall**:
     - *Layer 0 (Deep Background)*: Dense micro-snow dust (`r = 1.4-1.6px`) with slow descent (`speedY = 0.04`).
     - *Layer 1 (Midground)*: Medium flakes (`r = 2.4-2.8px`) with gentle sinusoidal wind sway.
     - *Layer 2 (Foreground)*: Faceted crystalline flakes (`r = 3.8-4.5px`) with faster descent (`speedY = 0.11`) and specular glints.
   - **Ground Frost Mist**: Breathing cold cyan fog creeping along the base pedestal.
   - **Crystalline Spire Glints**: Distant ice peaks twinkling with sharp 4-pointed sparkle stars.
   - **Reactive**: Sharp icy sparkle flash with radial frost shockwave ring; streaks illuminate ice spires.

5. **Sakura Drift (Cherry Blossom Sanctuary)**:
   - **Tumbling 3D Cherry Blossom Petals**: Diagonally fluttering petals with simulated 3D tumbling (modulating 2D rotation angle alongside orthogonal aspect ratio `scaleX = cos(flutterPhase)`).
   - **Natural Wind Gusts**: Periodic wind acceleration waves carrying petals horizontally across the screen margins.
   - **Swaying Hanging Lanterns**: Outer lower lanterns swaying like pendulums (`sin(t * 1.2) * 0.08`) with flickering warm radial light pools.
   - **Reactive**: Blossom burst radiating 8 fluttering petals outward on perfect placement; streaks induce a gentle blossom wind gust.

6. **Abyssal Depths (Bioluminescent Ocean)**:
   - **Multi-Speed Rising Bubbles**: Bubbles rising with organic sinusoidal horizontal wobble, translucent aqua bodies, and specular highlight dots.
   - **Swaying Aquatic Kelp Silhouettes**: Organic fronds rising from bottom-left and bottom-right edges with multi-joint quadratic bezier kinematics.
   - **Volumetric Caustic Shafts**: Shimmering angled light shafts projecting downward from the surface.
   - **Reactive**: Concentric circular sonar ripple expanding outward on perfect placement; streaks brighten bioluminescent shafts.

7. **Retro Grid (Digital Synthwave)**:
   - **Continuous 3D Perspective Grid**: Infinite scrolling horizontal lines with quadratic depth compression (`((i + frac) / N)^2.2`) converging at the horizon vanishing point.
   - **Segmented Synthwave Sun**: Half-disc neon sun with horizontal scanline blinds pulsing at the horizon.
   - **Digital Laser Scanline**: Horizontal laser beam sweeping smoothly up and down the upper screen with gradient trail.
   - **Reactive**: High-energy synthwave pulse shockwave radiating from the vanishing point; streaks accelerate grid scroll and brighten wireframes.

8. **Ember Core (Volcanic Chamber)**:
   - **Boiling Magma Reservoir**: Viscous lava pool at bottom pulsing with deep crimson and blazing gold.
   - **Buoyant Turbulent Embers**: Thermal upward acceleration with turbulent horizontal currents; incandescent color shift from white/gold core to orange body and cooling red crust.
   - **Heat Shimmer Waves**: Rising atmospheric convection bands along the outer walls.
   - **Reactive**: Molten magma shockwave ring with central exploding ember spark on perfect placement; streaks flare lateral volcanic fissures.

9. **Celestial Observatory (Golden Constellations)**:
   - **Multi-Phase Twinkling Star Dust**: Multi-frequency twinkling stars (`sin(t * rate + phase)^4`) with 4-point diamond sparkle stars.
   - **Revolving Constellation Geometry**: Geometric starlight lines connecting star nodes, slowly revolving around celestial poles in the sky margins.
   - **Periodic Shooting Stars**: Incandescent shooting stars streaking diagonally across the upper heavens with fading gradient tails.
   - **Reactive**: Golden starburst constellation flash on perfect placement; streaks trigger golden starfall.

10. **Prism Rift (Dimensional Fracture)**:
    - **Drifting 3D Faceted Crystal Shards**: Drifting polygonal shards with slow rotation, planar facet shading, and specular edge gleams.
    - **Refractive Chromatic Dispersion Beams**: Angled light beams radiating from the rift with split cyan and magenta color fringes.
    - **Reactive**: Chromatic dispersion ripple (dual cyan and magenta concentric shockwave rings expanding with slight radius offset) on perfect placement; streaks illuminate distant crystalline dimensional fractures.

#### Layer 3: Theme-Aware Gameplay-Safe Corridor Blend
- Central column (30% to 70% width) is strictly protected with a horizontal feather gradient (`stops: [0.0, 0.22, 0.50, 0.78, 1.0]`).
- Dark theme-aware atmospheric tone ensures 2.5D stacking blocks and perfect alignment calculations are 100% visible and distraction-free.
- Lower fog continuation seamlessly bridges the left and right scenery across the base pedestal.

#### Layer 4: Cosmetic Gameplay-Reactive Feedback
- **Normal Placement**: Gentle subtle atmospheric breathe (`normalReactiveAnimation`, 320ms `easeOutQuad`).
- **Perfect Placement**: Theme-specific visual shockwave / burst (`reactiveAnimation`, 700ms `easeOutCubic`).
- **Streak Milestones (5x, 10x)**: Smooth multiplier boosts particle velocity, illumination intensity, and atmospheric depth.
- **Game Paused**: Ambient AnimationController freezes cleanly without abrupt jumps.
- **Reduced Motion**: Disables CustomPaint layer entirely, preserving battery and honoring accessibility settings.

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

### 7.5.4 Ambient Background Animation System (Enhanced VFX)
- **Layer 1 — Static Production Background**: `assets/images/splash_bg.jpg` maintained as base layer with ambient dark contrast gradient scrim.
- **Layer 2 — Animated Aurora Lighting**: Smooth, slow-moving ambient cyan (`#13D9FF`), blue (`#347BFF`), and violet (`#9658FF`) light pools drifting along outer decorative quadrants with subtle sinusoidal breathing opacity (`0.08` to `0.18`), keeping the central logo readable.
- **Layer 3 — Initial Light Sweep**: Single-run diagonal luminous anamorphic light band sweeping smoothly across the atmospheric background during entrance (`0.02` to `0.14` progress, ~840ms), featuring soft cyan/blue gradients without harsh flashes.
- **Layer 4 — Ambient Energy Rings**: Expanding dual concentric circular wave outlines (radii 55px to 150px) radiating softly behind the central 3-pill emblem over 2.4s wave cycles with fading luminous edges.
- **Layer 5 — Floating Geometric Light Particles**: 18 persistent `const` light points (13 circular motes, 5 geometric diamond prisms) drifting upward with horizontal sway, edge fade-out, and staggered entrance.
- **Performance & Reduced Motion**: Isolated with `RepaintBoundary`, zero per-frame heap allocations, repaints driven by `_controller`. When `reducedMotion` is true, procedural painter is completely bypassed.

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

### 9.2 Dynamic Theme-Based Gameplay Environments & 10 Animated Video Backgrounds (`ThemeGameplayBackground`)
- **Complete 10-Theme Living Video Architecture**:
  - Every theme in Stack Pulse possesses its own high-resolution (9:16 portrait) animated video background sampled directly from its approved artwork and encoded into seamless, mobile-optimized H.264 MP4 assets in `assets/videos/`:
    1. **Midnight Neon**: `assets/videos/gameplay_bg_midnight.mp4` (733.5 KB) — Rapidly coursing vertical neon building energy pulses (+65V), sweeping volumetric holographic sky searchlights, wet reflective street ripple waves, and floating digital cyber glyphs.
    2. **Aurora**: `assets/videos/gameplay_bg_aurora.mp4` (445.1 KB) — Undulating northern lights ribbon flow, breathing emerald/turquoise illumination shifts, and drifting valley mist.
    3. **Sunset Pulse**: `assets/videos/gameplay_bg_sunset.mp4` (582.7 KB) — Rock-solid cyber monoliths & spires, radiant golden-amber sunset horizon breathing, flowing twilight magenta/violet atmospheric sky vistas, neon energy runners racing along architectural edges, solar rim sparkle glints, drifting floor mist, and 45 floating twilight embers.
    4. **Arctic Glow**: `assets/videos/gameplay_bg_arctic.mp4` (608.4 KB) — Shifting crystal reflections across frozen glacial spires, icy valley mist, and 60 naturally falling polar snowflakes with periodic loop wrap.
    5. **Sakura Drift**: `assets/videos/gameplay_bg_sakura.mp4` (580.7 KB) — Gentle atmospheric tree canopy swaying, soft lantern illumination breathing, and 45 drifting cherry blossom petals.
    6. **Abyssal Depths**: `assets/videos/gameplay_bg_abyssal.mp4` (1,264.6 KB) — Fluid underwater refractive wave distortion, moving oceanic caustic light shafts, 35 rising bubbles, and pulsing bioluminescence.
    7. **Retro Grid**: `assets/videos/gameplay_bg_retro.mp4` (649.7 KB) — Active forward-moving perspective wireframe grid streaming toward player, concentric synthwave sun pulse rings, and horizon laser scanline.
    8. **Ember Core**: `assets/videos/gameplay_bg_ember.mp4` (876.3 KB) — Molten lava fluid flow displacement, glowing volcanic magma breathing, heat haze, and 40 rising volcanic sparks/embers.
    9. **Celestial Observatory**: `assets/videos/gameplay_bg_celestial.mp4` (1,379.0 KB) — Rock-solid stationary observatory architecture (zero camera wobble), rich flowing cosmic nebula currents, volumetric starlight god rays streaming from dome, traveling golden armillary ring gleams, 75 sparkling constellation star cross-flares, two shooting stars/meteors, and 50+ floating golden stardust motes.
    10. **Prism Rift**: `assets/videos/gameplay_bg_prism.mp4` (1,851.1 KB) — Floating crystal shard levitation, vivid spectral rainbow chromatic refraction cycling through facets, and dimensional fracture gleams.
  - **Total Bundle Footprint**: Just **8.81 MB** for all 10 high-fidelity video environments combined.
  - **Video Encoding Standards**: Portrait 9:16, 720 × 1280 resolution, 24 FPS, 144 frames (6.0s duration), H.264 video codec (`libx264`, `yuv420p`), MP4 container with `+faststart` moov atom header, and zero audio tracks.
  - **Seamless Loop Precision**: Every temporal function is parameterized on pure harmonic terms of $\theta = 2\pi t / 144$, yielding near-zero boundary pixel difference with zero visible frame jumps or motion resets.
- **Four-Tier Environmental Layering**:
  - **Layer 1 — Static Artwork Fallback**: The original static image (`assets/images/gameplay_bg_*.jpg`) is decoded and rendered underneath with `AnimatedSwitcher(380ms, Curves.easeOut)`, guaranteeing zero black flash during theme switching and instantaneous fallback if video decoding is unavailable.
  - **Layer 1B — Video Player Layer**: Single active `VideoPlayerController.asset` rendered via `FittedBox(fit: BoxFit.cover, clipBehavior: Clip.hardEdge)` across all device aspect ratios. Bypassed when `reducedMotion` is enabled.
  - **Layer 2 — Living Environmental Accents & Reactive Feedback**:
    - *Corridor Safety*: Theme-aware central gradient (`corridorBaseColor` and `corridorCenterColor`) ensures the center 56% column remains quiet and high-contrast for block tracking.
    - *Reactive Placement*: Themed pulse/shimmer sweeps across the background on perfect placement (`r > 0.0`); streak multipliers scale environmental luminescence.
    - *Adaptive Blending*: Procedural ambient curves are dynamically softened when video is active, letting the authentic video scenery shine as the focal environment while retaining reactive placement feedback.
  - **Layer 3 — Atmospheric Contrast Scrim**: Upper/lower vertical gradient guaranteeing WCAG AAA contrast for HUD indicators and stacked blocks.
- **Audio Protection & Zero Audio Interference**:
  - All video files contain strictly zero audio streams.
  - `_videoController.setVolume(0.0)` is explicitly invoked upon controller initialization.
  - Flutter/Flame audio players for Background Music (`BGM`) and Sound Effects (`SFX`) remain 100% independent and undisturbed, with zero audio focus disruption.
- **Lifecycle & Resource Management**:
  - Single active controller: Only the currently selected theme consumes video decoding and memory resources.
  - `WidgetsBindingObserver` automatically pauses video playback during app backgrounding (`AppLifecycleState.paused`/`inactive`/`hidden`) and resumes on `resumed`.
  - Game pause immediately pauses the video controller; resume restores playback.
  - Controllers are cleanly disposed when switching themes or leaving the screen to prevent memory leaks.
  - `reducedMotion` completely disables video playback and procedural particles, displaying the rock-solid static artwork.
  - Video surfaces are wrapped in `IgnorePointer(ignoring: true)` to prevent any touch event interception.

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

