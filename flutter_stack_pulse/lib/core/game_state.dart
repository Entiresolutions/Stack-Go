enum GamePlayState {
  home,
  initializing,
  moving,
  placing,
  resolving,
  paused,
  gameOver,
}

enum PlacementResultType {
  perfect,
  partial,
  miss,
}

class PlacementResult {
  final PlacementResultType type;
  final double retainedLeft;
  final double retainedRight;
  final double retainedWidth;
  final double? excessLeft;
  final double? excessRight;
  final double? excessWidth;
  final bool isExcessOnRight;

  const PlacementResult({
    required this.type,
    required this.retainedLeft,
    required this.retainedRight,
    required this.retainedWidth,
    this.excessLeft,
    this.excessRight,
    this.excessWidth,
    this.isExcessOnRight = true,
  });

  bool get isSuccessful => type == PlacementResultType.perfect || type == PlacementResultType.partial;
}
