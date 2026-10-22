import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../core/game_config.dart';
import '../core/game_theme.dart';

class StackWorld extends World {
  GameTheme theme;

  StackWorld({required this.theme});

  void updateTheme(GameTheme newTheme) {
    theme = newTheme;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }
}
