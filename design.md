# STACK PULSE — Design Specification Document (Design.md)

**Aesthetic Direction:** Premium Minimal Neon  
**Primary Typography:** Plus Jakarta Sans & JetBrains Mono  
**Design Ratio:** 9:16 Portrait Canvas (360 x 640 logical design units)  
**Accessibility Level:** WCAG 2.1 AA Compliant  

---

## 1. Visual Constitution & Anti-Slop Rules

Stack Pulse adheres strictly to human-crafted, premium minimalist arcade aesthetics.

### 1.1 Anti-Slop Discipline
1. **Zero-Pill Metadata Enclosure**: Informational metadata (scores, timestamps, tags) is rendered as clean unboxed text or paired with subtle typographic separators (`·` or `/`). Never wrap informational text in capsule boxes.
2. **No Mechanical Pseudo-Technical Clutter**: Section headings and modal titles use clean natural Title Case or clean geometric uppercase (`HOW TO PLAY`, `PAUSED`). No code-comment prefixes (`//`, `/* */`), no fake version strings ("v4.2-CORE"), no fake prober status dots (`animate-pulse`).
3. **Low-Occlusion HUD Contract**: At least **85% of the playfield remains completely unobstructed**. Overlays use `pointer-events: none` on outer containers so touch and click inputs pass through without interference.
4. **No Backdrop-Filter Over Active Viewports**: Translucent modal scrims use solid RGBA colors (`rgba(11, 16, 32, 0.85)`) rather than expensive GPU `backdrop-filter` blurs that induce frame drops during active 60fps canvas rendering.

---

## 2. Color System & Palettes

All themes follow the **60-30-10 Color Budget**:
- **60% Neutral Canvas**: Deep oceanic or void navy (`#0B1020`, `#071B19`, etc.)
- **30% Structural Surfaces**: Elevated cards, platforms, hairline borders (`#1D2940`, rgba borders)
- **10% High-Intent Accent**: Concentrated strictly at primary CTAs, active blocks, and perfect streak sparks.

### 2.1 Theme Specifications

| Theme | Unlock Requirement | Background (`60%`) | Surface (`30%`) | Primary Accent (`10%`) | Block Palette Progression |
|:---|:---|:---|:---|:---|:---|
| **Midnight Neon** | Default (Score 0) | `#0B1020` | `#1D2940` | `#55DDFB` (Electric Cyan) | Cyan $\rightarrow$ Blue $\rightarrow$ Indigo $\rightarrow$ Violet $\rightarrow$ Emerald $\rightarrow$ Teal |
| **Aurora** | Best Score $\ge 10$ | `#071B19` | `#143D38` | `#34D399` (Polar Emerald) | Emerald $\rightarrow$ Mint $\rightarrow$ Turquoise $\rightarrow$ Cyan $\rightarrow$ Teal $\rightarrow$ Green |
| **Sunset Pulse** | Best Score $\ge 25$ | `#1C0D1E` | `#3D1B42` | `#F97316` (Radiant Coral) | Coral $\rightarrow$ Orange $\rightarrow$ Rose $\rightarrow$ Magenta $\rightarrow$ Violet $\rightarrow$ Amber |
| **Arctic Glow** | Best Score $\ge 50$ | `#061325` | `#142F54` | `#38BDF8` (Glacial Ice) | Ice Cyan $\rightarrow$ Azure $\rightarrow$ Sky Blue $\rightarrow$ Diamond White $\rightarrow$ Cobalt |

---

## 3. Typography Hierarchy

| Role | Font Family | Size | Weight | Tracking | Usage |
|:---|:---|:---|:---|:---|:---|
| **Hero Title** | Plus Jakarta Sans | 32px | 900 (Black) | +3.5px | Home screen SVG lockup |
| **Score Counter** | Plus Jakarta Sans | 54px–72px | 900 (Black) | -1.5px | Active HUD readout & Game Over result (`tabular-nums`) |
| **Section Heading** | Plus Jakarta Sans | 20px–22px | 800 (ExtraBold) | +1.5px | Modal headers (`SETTINGS`, `THEMES`) |
| **Primary Button** | Plus Jakarta Sans | 16px | 700 (Bold) | +0.5px | Main CTAs (`START GAME`, `PLAY AGAIN`) |
| **Metadata & Subtitles** | Plus Jakarta Sans | 12px–13px | 600 (SemiBold) | +0.8px | Best score tags, description prose |
| **Numbers & Data** | JetBrains Mono | 12px–18px | 700 (Bold) | 0.0 | Tabular numeral data strips |

---

## 4. Component Anatomy & Geometry

### 4.1 Stack Block (Stationary & Moving)
- **Dimensions**: Variable width (initial: 210 units), height: 26 units.
- **Corner Radius**: $4\text{px}$ rounded corner rectangle.
- **Lighting Sheen**: Top highlight strip with height $3\text{px}$, margin $2\text{px}$, white fill at $32\%$ opacity.
- **Hairline Border**: $1\text{px}$ stroke with white fill at $14\%$ opacity (active moving block at $40\%$ opacity).
- **Depth Shadow**: $6\text{px}$ blur, $3\text{px}$ Y offset at $35\%$ black opacity.

### 4.2 Falling Piece (Overhang Debris)
- **Dimensions**: Overhang width ($W_{\text{excess}}$), height: 26 units.
- **Rotation**: Angular velocity $\omega = \pm 0.08\text{ rad/frame}$ based on left/right side.
- **Alpha Decay**: Fades out linearly upon dropping below the active viewport.

### 4.3 Particle Spark Emitter
- **Count**: Dynamically scaled: $20 + \min(\text{streak} \times 4, 28)$ particles.
- **Physics**: Velocity $v \in [70, 190]\text{ units/s}$ radiating outward in an isotropic burst.
- **Lifespan**: $400\text{ms}$–$600\text{ms}$ with linear alpha decay and radius shrinking.

---

## 5. Screen Wireframes & UI Specifications

### 5.1 Title Screen (Home)
- **Top Bar**: Minimalist Best Score indicator with trophy icon; quick settings toggle button.
- **Centerpiece**: Glowing geometric neon stack emblem ($90 \times 90\text{px}$) with bespoke inline SVG title lockup over 35% negative space.
- **Primary CTA**: Prominent $58\text{px}$ tall `START GAME` button with ambient cyan glow.
- **Secondary Actions**: Two-column grid (`THEMES` and `HOW TO PLAY`).
- **Footer**: Single flat control-hint line: `Tap / Space to Stack · Esc Pause`.

### 5.2 Gameplay HUD
- **Top Left**: Real-time score ($48\text{px}$ extra-bold) + subtle Best Score counter.
- **Streak Alert**: Compact floating pill badge that bounces briefly on milestone triggers (`PERFECT!`, `NICE!`, `GREAT!`, `AMAZING!`, `LEGENDARY!`).
- **Top Right**: Quick sound mute toggle + pause button.
- **Playfield Clearance**: $88\%$ of screen area left completely clear of UI elements.

### 5.3 Game Over Modal
- **Card**: Centered elevated surface ($320\text{px}$ width) with $24\text{px}$ corner radius.
- **Score Showcase**: Large $64\text{px}$ final score readout.
- **Record Badge**: Animated glowing badge if a new all-time best is achieved.
- **2-Column Stats Strip**: `ALL-TIME BEST` and `BEST STREAK` in tabular figures.
- **CTAs**: `PLAY AGAIN` (primary) and `HOME` (secondary).

---

## 6. Motion & Audio-Tactile Choreography

| Event | Visual Response | Audio Synthesizer | Haptic Feedback |
|:---|:---|:---|:---|
| **Normal Placement** | Block settles on stack; overhang debris falls with gravity | Soft sine ping on pentatonic scale ($261\text{Hz}$–$880\text{Hz}$) | Light impact ($12\text{ms}$) |
| **Perfect Placement (Streak 1)** | Block snaps to alignment; $0.8$ flash; 24 sparks | Bell chime at $C_5$ ($523.25\text{Hz}$) + $1.5\times$ harmonic | Medium impact ($28\text{ms}$) |
| **Perfect Streak (Streak 3 - NICE)** | $0.85$ flash; 32 sparks; animated HUD badge | Bright chime at $E_5$ ($659\text{Hz}$) + 3-note arpeggio | Medium impact ($28\text{ms}$) |
| **Perfect Streak (Streak 5 - AMAZING)** | $0.95$ flash; 40 sparks; animated HUD badge | Soaring chime at $A_5$ ($880\text{Hz}$) + 4-note ascending chord | Heavy impact ($40\text{ms}$) |
| **Perfect Streak (Streak 10+ - LEGENDARY)** | $1.0$ flash; 48 sparks; glowing combo badge | Apex bell at $C_7$ ($2093\text{Hz}$) + 5-note crystalline cascade | Double heavy impact pulse |
| **Failed Miss (Game Over)** | Block drops away; decaying camera shake ($12\text{px}$) | Descending sawtooth tone ($220\text{Hz} \rightarrow 55\text{Hz}$) | Long alert buzz ($60\text{ms}$) |
