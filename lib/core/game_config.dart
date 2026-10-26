class GameConfig {
  static const double logicalWidth = 360.0;
  static const double logicalHeight = 640.0;
  static const double baseBlockWidth = 210.0;
  static const double blockHeight = 26.0;
  static const double basePositionY = 500.0;
  static const double initialSpeed = 170.0;
  static const double maxSpeed = 320.0;
  static const int speedStepInterval = 5;
  static const double speedIncrementPerStep = 15.0;
  static const double speedIncrementPerPoint = speedIncrementPerStep / speedStepInterval;
  static const double toleranceRatio = 0.025;
  static const double minTolerance = 2.0;
  static const double maxTolerance = 5.0;
  static const double boundaryPadding = 12.0;
  static const double cameraFollowThresholdY = 300.0;
  static const double cameraEasingSpeed = 5.5;
}
