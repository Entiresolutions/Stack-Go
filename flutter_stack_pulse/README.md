# STACK PULSE — Flutter + Flame Mobile Game

**Stack Pulse** is a complete, polished, 2D minimalist precision block-stacking arcade mobile game built with **Flutter** and the **Flame Engine**.

## Features
- **Clean 2D Precision Gameplay**: Horizontal interval intersection cutting without physics jitter.
- **Snapping & Perfect Combos**: Snaps near-perfect alignments (`tolerance = clamp(width * 0.025, 2, 5)`).
- **Combo Feedback**: Rewarding visual & auditory combo system: *NICE!*, *GREAT!*, *AMAZING!*, *LEGENDARY!*.
- **Smooth Easing Camera**: Vertical tracking maintaining headroom above the moving block.
- **4 Procedural Themes**: Midnight Neon (default), Aurora (Score 10+), Sunset Pulse (Score 25+), Arctic Glow (Score 50+).
- **Local Persistence**: Stores best score, streaks, and gameplay stats via `shared_preferences`.
- **Zero Ads & Zero Internet Required**: Pure, distraction-free arcade feel.

---

## Requirements
- Flutter SDK `>=3.10.0`
- Dart SDK `>=3.0.0 <4.0.0`
- Android Studio or VS Code with Flutter extensions
- Android device or emulator running API 21+

---

## Project Structure
```
flutter_stack_pulse/
├── pubspec.yaml
├── README.md
├── android/
│   └── app/src/main/AndroidManifest.xml
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
│   │   └── feedback_service.dart
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
    └── unit/
        ├── placement_engine_test.dart
        └── difficulty_controller_test.dart
```

---

## Local Development Commands

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

### 4. Run in Debug Mode (Connected Device / Emulator)
```bash
flutter run
```

---

## Building Production Releases

### Build Release APK
```bash
flutter build apk --release
```
The output file will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`

### Build Release Android App Bundle (AAB for Google Play)
```bash
flutter build appbundle --release
```
The output bundle will be generated at:
`build/app/outputs/bundle/release/app-release.aab`
