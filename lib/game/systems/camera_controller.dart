import '../../core/game_config.dart';

class CameraController {
  double _targetOffsetY = 0.0;
  double _currentOffsetY = 0.0;
  double shakeIntensity = 0.0;

  double get currentOffsetY => _currentOffsetY;

  void reset() {
    _targetOffsetY = 0.0;
    _currentOffsetY = 0.0;
    shakeIntensity = 0.0;
  }

  void triggerShake(double intensity) {
    shakeIntensity = intensity;
  }

  void updateTarget(double topBlockY) {
    if (topBlockY < GameConfig.cameraFollowThresholdY) {
      _targetOffsetY = topBlockY - GameConfig.cameraFollowThresholdY;
    } else {
      _targetOffsetY = 0.0;
    }
  }

  void update(double dt) {
    final diff = _targetOffsetY - _currentOffsetY;
    _currentOffsetY += diff * (GameConfig.cameraEasingSpeed * dt);

    if (shakeIntensity > 0.0) {
      shakeIntensity = (shakeIntensity - dt * 25.0).clamp(0.0, 50.0);
    }
  }
}
