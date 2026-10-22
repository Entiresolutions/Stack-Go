import { PlacementResult } from '../types/game';

export const PlacementEngine = {
  calculatePlacement(
    previousLeft: number,
    previousWidth: number,
    movingLeft: number,
    movingWidth: number,
    customTolerance?: number
  ): PlacementResult {
    const previousRight = previousLeft + previousWidth;
    const movingRight = movingLeft + movingWidth;

    // Tolerance formula: clamp(previousBlockWidth * 0.025, 2, 5)
    const tolerance = customTolerance ?? Math.min(5, Math.max(2, previousWidth * 0.025));

    const offset = Math.abs(movingLeft - previousLeft);

    // 1. Perfect placement test
    if (offset <= tolerance) {
      return {
        type: 'perfect',
        retainedLeft: previousLeft,
        retainedRight: previousRight,
        retainedWidth: previousWidth,
        isExcessOnRight: false,
      };
    }

    // 2. Overlap interval intersection
    const overlapLeft = Math.max(previousLeft, movingLeft);
    const overlapRight = Math.min(previousRight, movingRight);
    const overlapWidth = Math.max(0, overlapRight - overlapLeft);

    // 3. Failed placement (miss)
    if (overlapWidth <= 0.001) {
      return {
        type: 'miss',
        retainedLeft: movingLeft,
        retainedRight: movingRight,
        retainedWidth: 0,
        excessLeft: movingLeft,
        excessRight: movingRight,
        excessWidth: movingWidth,
        isExcessOnRight: movingLeft > previousLeft,
      };
    }

    // 4. Partial placement
    let excessLeft: number;
    let excessRight: number;
    let excessWidth: number;
    let isExcessOnRight = true;

    if (movingLeft > previousLeft) {
      // Overhang on the right
      isExcessOnRight = true;
      excessLeft = overlapRight;
      excessRight = movingRight;
      excessWidth = movingRight - overlapRight;
    } else {
      // Overhang on the left
      isExcessOnRight = false;
      excessLeft = movingLeft;
      excessRight = overlapLeft;
      excessWidth = overlapLeft - movingLeft;
    }

    return {
      type: 'partial',
      retainedLeft: overlapLeft,
      retainedRight: overlapRight,
      retainedWidth: overlapWidth,
      excessLeft,
      excessRight,
      excessWidth,
      isExcessOnRight,
    };
  },

  calculateSpeed(score: number): number {
    // Formula: min(340, 160 + score * 5)
    return Math.min(340, 160 + score * 5);
  },

  getStreakBadge(streak: number): string {
    if (streak >= 10) return 'LEGENDARY!';
    if (streak >= 5) return 'AMAZING!';
    if (streak >= 3) return 'GREAT!';
    if (streak >= 2) return 'NICE!';
    if (streak === 1) return 'PERFECT!';
    return '';
  },
};
