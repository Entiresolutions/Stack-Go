import '../../core/game_config.dart';

class CameraController {
  double _targetOffsetY = 0.0;
  double _currentOffsetY = 0.0;

  double get currentOffsetY => _currentOffsetY;

  void reset() {
    _targetOffsetY = 0.0;
    _currentOffsetY = 0.0;
  }

  void updateTarget(double topBlockCenterY) {
    if (topBlockCenterY > GameConfig.cameraFollowThresholdY) {
      _targetOffsetY = topBlockCenterY - GameConfig.cameraFollowThresholdY;
    } else {
      _targetOffsetY = 0.0;
    }
  }

  void update(double dt) {
    final diff = _targetOffsetY - _currentOffsetY;
    _currentOffsetY += diff * (GameConfig.cameraEasingSpeed * dt);
  }
}
