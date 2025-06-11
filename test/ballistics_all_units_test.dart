import 'package:flutter_test/flutter_test.dart';
import 'package:musca/services/ballistics_calculator.dart';

void main() {
  group('Ballistics Calculator All Units Tests', () {
    test('Calculate ballistics corrections in all units', () {
      // Test parameters
      const double distance = 300.0; // meters
      const double windSpeed = 5.0; // m/s
      const double windDirection = 90.0; // degrees (crosswind from right)

      // Calculate ballistics
      final result = BallisticsCalculator.calculate(distance, windSpeed, windDirection);

      // Print all results
      print('\n=== BALLISTICS CALCULATOR RESULTS ===');
      print('Distance: ${distance}m');
      print('Wind: ${windSpeed}m/s at ${windDirection}°');
      print('\n--- ANGULAR CORRECTIONS ---');
      print('MRAD:      Drift: ${result.driftMrad.toStringAsFixed(2)}, Drop: ${result.dropMrad.toStringAsFixed(2)}');
      print('1/20 MRAD: Drift: ${result.driftMrad20.toStringAsFixed(2)}, Drop: ${result.dropMrad20.toStringAsFixed(2)}');
      print('MOA:       Drift: ${result.driftMoa.toStringAsFixed(2)}, Drop: ${result.dropMoa.toStringAsFixed(2)}');
      print('1/2 MOA:   Drift: ${result.driftMoa2.toStringAsFixed(1)}, Drop: ${result.dropMoa2.toStringAsFixed(1)}');
      print('1/3 MOA:   Drift: ${result.driftMoa3.toStringAsFixed(3)}, Drop: ${result.dropMoa3.toStringAsFixed(3)}');
      print('1/4 MOA:   Drift: ${result.driftMoa4.toStringAsFixed(2)}, Drop: ${result.dropMoa4.toStringAsFixed(2)}');
      print('1/8 MOA:   Drift: ${result.driftMoa8.toStringAsFixed(3)}, Drop: ${result.dropMoa8.toStringAsFixed(3)}');
      
      print('\n--- LINEAR CORRECTIONS ---');
      print('Inches: Drift: ${result.driftInches.toStringAsFixed(2)}, Drop: ${result.dropInches.toStringAsFixed(2)}');
      print('CM:     Drift: ${result.driftCm.toStringAsFixed(1)}, Drop: ${result.dropCm.toStringAsFixed(1)}');

      // Verify calculations are reasonable
      expect(result.driftMrad, greaterThan(0)); // Wind should cause drift
      expect(result.dropMrad, greaterThan(0)); // Bullet should drop
      expect(result.driftMoa, greaterThan(0)); // MOA should be positive
      expect(result.driftInches, greaterThan(0)); // Linear drift should be positive
      expect(result.dropCm, greaterThan(0)); // Linear drop should be positive

      // Verify unit conversions are consistent
      const double mradToMoa = 1.0 / 0.290888;
      expect(result.driftMoa, closeTo(result.driftMrad * mradToMoa, 0.01));
      expect(result.dropMoa, closeTo(result.dropMrad * mradToMoa, 0.01));

      // Verify fractional MOA calculations
      expect(result.driftMoa2, closeTo((result.driftMoa / 0.5).round() * 0.5, 0.01));
      expect(result.driftMoa4, closeTo((result.driftMoa / 0.25).round() * 0.25, 0.01));
    });

    test('Verify all unit types are available', () {
      const double distance = 100.0;
      const double windSpeed = 3.0;
      const double windDirection = 45.0;

      final result = BallisticsCalculator.calculate(distance, windSpeed, windDirection);

      // Verify all properties exist and are finite numbers
      expect(result.driftMrad.isFinite, true);
      expect(result.dropMrad.isFinite, true);
      expect(result.driftMrad20.isFinite, true);
      expect(result.dropMrad20.isFinite, true);
      expect(result.driftMoa.isFinite, true);
      expect(result.dropMoa.isFinite, true);
      expect(result.driftMoa2.isFinite, true);
      expect(result.dropMoa2.isFinite, true);
      expect(result.driftMoa3.isFinite, true);
      expect(result.dropMoa3.isFinite, true);
      expect(result.driftMoa4.isFinite, true);
      expect(result.dropMoa4.isFinite, true);
      expect(result.driftMoa8.isFinite, true);
      expect(result.dropMoa8.isFinite, true);
      expect(result.driftInches.isFinite, true);
      expect(result.dropInches.isFinite, true);
      expect(result.driftCm.isFinite, true);
      expect(result.dropCm.isFinite, true);
    });

    test('Zero wind conditions', () {
      const double distance = 200.0;
      const double windSpeed = 0.0;
      const double windDirection = 0.0;

      final result = BallisticsCalculator.calculate(distance, windSpeed, windDirection);

      // With no wind, drift should be minimal (near zero)
      expect(result.driftMrad.abs(), lessThan(0.1));
      expect(result.driftMoa.abs(), lessThan(0.5));
      expect(result.driftInches.abs(), lessThan(2.0));
      expect(result.driftCm.abs(), lessThan(5.0));

      // Drop should still be significant due to gravity
      expect(result.dropMrad, greaterThan(0.5));
      expect(result.dropMoa, greaterThan(1.0));
    });
  });
}
