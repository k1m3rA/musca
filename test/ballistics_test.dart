import 'package:flutter_test/flutter_test.dart';
import 'package:musca/services/ballistics_calculator.dart';

void main() {
  group('Ballistics Calculator Tests', () {
    test('Calculate ballistics with zero wind', () {
      final result = BallisticsCalculator.calculate(100.0, 0.0, 0.0);
      
      // With no wind, horizontal drift should be minimal (close to zero)
      expect(result.driftHorizontal.abs(), lessThan(1.0));
        // There should be some vertical drop at 100m
      expect(result.dropVertical, lessThan(0.0)); // Negative means below line of sight
      
      // Results should have proper conversions
      expect(result.driftMrad, isNotNull);
      expect(result.dropMrad, isNotNull);
      expect(result.driftMoa, isNotNull);
      expect(result.dropMoa, isNotNull);
    });

    test('Calculate ballistics with wind', () {
      final result = BallisticsCalculator.calculate(200.0, 10.0, 90.0); // 10 m/s crosswind
      
      // With crosswind, there should be significant horizontal drift
      expect(result.driftHorizontal.abs(), greaterThan(0.1));
        // There should be vertical drop at 200m
      expect(result.dropVertical, lessThan(0.0));
      
      // Conversions should be consistent
      final driftMradFromMeters = result.driftHorizontal / 200.0 * 1000;
      expect((result.driftMrad - driftMradFromMeters).abs(), lessThan(0.1));
    });

    test('Calculate ballistics at different distances', () {
      final result100 = BallisticsCalculator.calculate(100.0, 5.0, 90.0);
      final result200 = BallisticsCalculator.calculate(200.0, 5.0, 90.0);
      
      // At greater distance, effects should be more pronounced
      expect(result200.driftHorizontal.abs(), greaterThan(result100.driftHorizontal.abs()));
      expect(result200.dropVertical.abs(), greaterThan(result100.dropVertical.abs()));
    });
  });
}
