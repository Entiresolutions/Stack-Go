import 'package:flutter_test/flutter_test.dart';
import 'package:stack_pulse/core/game_state.dart';
import 'package:stack_pulse/game/systems/placement_engine.dart';

void main() {
  group('PlacementEngine Tests', () {
    test('Perfect alignment within tolerance snaps to previous block', () {
      final result = PlacementEngine.calculatePlacement(
        previousLeft: 75.0,
        previousWidth: 210.0,
        movingLeft: 76.5, // 1.5 units offset <= tolerance (clamp: 2.0 to 5.0)
        movingWidth: 210.0,
      );

      expect(result.type, equals(PlacementResultType.perfect));
      expect(result.retainedLeft, equals(75.0));
      expect(result.retainedWidth, equals(210.0));
      expect(result.isSuccessful, isTrue);
    });

    test('Partial overlap on the right trims excess piece', () {
      final result = PlacementEngine.calculatePlacement(
        previousLeft: 75.0,
        previousWidth: 200.0, // bounds: [75, 275]
        movingLeft: 95.0, // bounds: [95, 295], offset = 20 > tolerance
        movingWidth: 200.0,
      );

      expect(result.type, equals(PlacementResultType.partial));
      expect(result.retainedLeft, equals(95.0));
      expect(result.retainedRight, equals(275.0));
      expect(result.retainedWidth, equals(180.0));
      expect(result.excessLeft, equals(275.0));
      expect(result.excessRight, equals(295.0));
      expect(result.excessWidth, equals(20.0));
      expect(result.isExcessOnRight, isTrue);
      expect(result.isSuccessful, isTrue);
    });

    test('Partial overlap on the left trims left overhang piece', () {
      final result = PlacementEngine.calculatePlacement(
        previousLeft: 100.0,
        previousWidth: 200.0, // bounds: [100, 300]
        movingLeft: 70.0, // bounds: [70, 270], offset = 30 > tolerance
        movingWidth: 200.0,
      );

      expect(result.type, equals(PlacementResultType.partial));
      expect(result.retainedLeft, equals(100.0));
      expect(result.retainedRight, equals(270.0));
      expect(result.retainedWidth, equals(170.0));
      expect(result.excessLeft, equals(70.0));
      expect(result.excessRight, equals(100.0));
      expect(result.excessWidth, equals(30.0));
      expect(result.isExcessOnRight, isFalse);
      expect(result.isSuccessful, isTrue);
    });

    test('Zero overlap returns miss and ends run', () {
      final result = PlacementEngine.calculatePlacement(
        previousLeft: 75.0,
        previousWidth: 100.0, // bounds: [75, 175]
        movingLeft: 200.0, // bounds: [200, 300] - completely missed
        movingWidth: 100.0,
      );

      expect(result.type, equals(PlacementResultType.miss));
      expect(result.retainedWidth, equals(0.0));
      expect(result.isSuccessful, isFalse);
    });

    test('Edge contact with zero overlap is treated as a miss', () {
      final result = PlacementEngine.calculatePlacement(
        previousLeft: 50.0,
        previousWidth: 100.0, // bounds: [50, 150]
        movingLeft: 150.0, // bounds: [150, 250], touch point = 150
        movingWidth: 100.0,
      );

      expect(result.type, equals(PlacementResultType.miss));
      expect(result.retainedWidth, equals(0.0));
      expect(result.isSuccessful, isFalse);
    });
  });
}
