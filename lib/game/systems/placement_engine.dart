import 'dart:math';
import '../../core/game_config.dart';
import '../../core/game_state.dart';

class PlacementEngine {
  /// Pure mathematical horizontal interval intersection
  static PlacementResult calculatePlacement({
    required double previousLeft,
    required double previousWidth,
    required double movingLeft,
    required double movingWidth,
    double? customTolerance,
  }) {
    final previousRight = previousLeft + previousWidth;
    final movingRight = movingLeft + movingWidth;

    // Calculate tolerance: clamp(previousBlockWidth * 0.025, 2, 5)
    final tolerance = customTolerance ??
        (previousWidth * GameConfig.toleranceRatio)
            .clamp(GameConfig.minTolerance, GameConfig.maxTolerance);

    final offset = (movingLeft - previousLeft).abs();

    // Check perfect placement
    if (offset <= tolerance) {
      return PlacementResult(
        type: PlacementResultType.perfect,
        retainedLeft: previousLeft,
        retainedRight: previousRight,
        retainedWidth: previousWidth,
      );
    }

    // Calculate overlap
    final overlapLeft = max(previousLeft, movingLeft);
    final overlapRight = min(previousRight, movingRight);
    final overlapWidth = max(0.0, overlapRight - overlapLeft);

    // If no positive overlap, it's a miss
    if (overlapWidth <= 0.001) {
      return PlacementResult(
        type: PlacementResultType.miss,
        retainedLeft: movingLeft,
        retainedRight: movingRight,
        retainedWidth: 0.0,
        excessLeft: movingLeft,
        excessRight: movingRight,
        excessWidth: movingWidth,
        isExcessOnRight: movingLeft > previousLeft,
      );
    }

    // Partial placement with excess piece
    double? excessLeft;
    double? excessRight;
    double? excessWidth;
    bool isExcessOnRight = true;

    if (movingLeft > previousLeft) {
      // Overhang is on the right
      isExcessOnRight = true;
      excessLeft = overlapRight;
      excessRight = movingRight;
      excessWidth = movingRight - overlapRight;
    } else {
      // Overhang is on the left
      isExcessOnRight = false;
      excessLeft = movingLeft;
      excessRight = overlapLeft;
      excessWidth = overlapLeft - movingLeft;
    }

    return PlacementResult(
      type: PlacementResultType.partial,
      retainedLeft: overlapLeft,
      retainedRight: overlapRight,
      retainedWidth: overlapWidth,
      excessLeft: excessLeft,
      excessRight: excessRight,
      excessWidth: excessWidth,
      isExcessOnRight: isExcessOnRight,
    );
  }
}
