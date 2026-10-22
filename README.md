# STACK PULSE — Flutter + Flame Cross-Platform Game

**Stack Pulse** is a complete, polished, 2D minimalist precision block-stacking arcade game built with **Flutter** and the **Flame Engine**. Playable seamlessly across **Android, Windows Desktop, and Web**.

## Features
- **Clean 2D Precision Gameplay**: Frame-rate independent horizontal interval intersection cutting without physics collider jitter.
- **Snapping & Perfect Combos**: Snaps near-perfect alignments (`tolerance = clamp(width * 0.025, 2, 5)`).
- **Ascending Procedural Audio**: In-memory procedural WAV synthesis with rising pentatonic scales (C4 to A6) and dedicated combo scale (C5 to C7) with harmonic overtones.
- **Haptic Feedback**: Three-tiered tactile feedback (light, medium, heavy) on placements and combo milestones.
- **Dynamic Particle Fireworks**: Burst effects scaling in count and velocity with consecutive perfect streak count.
- **Smooth Easing Camera & Screen Shake**: Vertical easing tracking keeping the active block centered, with impact shake on game over.
- **Keyboard & Touch Controls**: Play with single tap, mouse click, or `Space` / `Enter` keyboard keys.
- **4 Procedural Themes**: Midnight Neon (default), Aurora (Score 10+), Sunset Pulse (Score 25+), Arctic Glow (Score 50+).
- **Local Offline Persistence**: Stores high scores, combo records, and gameplay statistics via `shared_preferences`.
- **Zero Ads & Zero Internet Required**: Pure, distraction-free arcade feel.

---

## Requirements
- Flutter SDK `>=3.10.0` (Verified on Flutter 3.47+ / Dart 3.13+)
- Flame Engine `^1.20.0` (Flame 1.38+)
- Audioplayers `^6.8.1`

---

## Project Structure
```
flutter_stack_pulse/
├── pubspec.yaml
├── README.md
├── android/
├── web/
├── windows/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── game_config.dart
│   │   ├── game_theme.dart
│   │   └── game_state.dart
│   ├── models/
│   │   ├── game_statistics.dart
│   │   └── game_settings.dart
│   ├── services/
│   │   ├── local_storage_service.dart
│   │   ├── feedback_service.dart
│   │   └── sound_synthesizer.dart
│   ├── game/
│   │   ├── stack_pulse_game.dart
│   │   ├── stack_world.dart
│   │   ├── components/
│   │   │   ├── stack_block.dart
│   │   │   ├── moving_block.dart
│   │   │   ├── falling_piece.dart
│   │   │   └── particle_effect.dart
│   │   └── systems/
│   │       ├── placement_engine.dart
│   │       ├── difficulty_controller.dart
│   │       ├── camera_controller.dart
│   │       └── score_controller.dart
│   └── ui/
│       ├── screens/
│       │   ├── home_screen.dart
│       │   ├── game_screen.dart
│       │   ├── themes_screen.dart
│       │   ├── settings_screen.dart
│       │   └── tutorial_screen.dart
│       ├── overlays/
│       │   ├── pause_overlay.dart
│       │   └── game_over_overlay.dart
│       └── widgets/
│           ├── premium_button.dart
│           ├── score_display.dart
│           └── theme_card.dart
└── test/
    ├── widget_test.dart
    └── unit/
        ├── audio_test.dart
        ├── difficulty_controller_test.dart
        └── placement_engine_test.dart
```

---

## Commands

### 1. Install Dependencies
```bash
cd flutter_stack_pulse
flutter pub get
```

### 2. Run Tests
```bash
flutter test
```

### 3. Analyze Code
```bash
flutter analyze
```

### 4. Run Game
```bash
# Run on Windows Desktop
flutter run -d windows

# Run on Chrome Web
flutter run -d chrome

# Run on connected Android device / emulator
flutter run
```

### 5. Build for Production
```bash
# Web Build
flutter build web

# Android APK
flutter build apk --release

# Windows Executable
flutter build windows
```
