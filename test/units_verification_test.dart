import 'package:flutter_test/flutter_test.dart';
import '../lib/services/ballistics_calculator.dart';

void main() {
  group('All Units Ballistics Calculator', () {
    test('Test all correction units at 300m with crosswind', () {
      // Test scenario: 300m with 5 m/s crosswind from 90° (pure crosswind)
      final result = BallisticsCalculator.calculate(300.0, 5.0, 90.0);

      // Print results in a readable format
      print('\n=== BALLISTICS RESULTS: 300m, 5m/s crosswind ===');
      print('ANGULAR CORRECTIONS:');
      print('MRAD:      Drift: ${result.driftMrad.toStringAsFixed(2)}, Drop: ${result.dropMrad.toStringAsFixed(2)}');
      print('1/20 MRAD: Drift: ${result.driftMrad20.toStringAsFixed(2)}, Drop: ${result.dropMrad20.toStringAsFixed(2)}');
      print('MOA:       Drift: ${result.driftMoa.toStringAsFixed(2)}, Drop: ${result.dropMoa.toStringAsFixed(2)}');
      print('1/2 MOA:   Drift: ${result.driftMoa2.toStringAsFixed(1)}, Drop: ${result.dropMoa2.toStringAsFixed(1)}');
      print('1/3 MOA:   Drift: ${result.driftMoa3.toStringAsFixed(3)}, Drop: ${result.dropMoa3.toStringAsFixed(3)}');
      print('1/4 MOA:   Drift: ${result.driftMoa4.toStringAsFixed(2)}, Drop: ${result.dropMoa4.toStringAsFixed(2)}');
      print('1/8 MOA:   Drift: ${result.driftMoa8.toStringAsFixed(3)}, Drop: ${result.dropMoa8.toStringAsFixed(3)}');
      print('\nLINEAR CORRECTIONS:');
      print('Inches: Drift: ${result.driftInches.toStringAsFixed(2)}, Drop: ${result.dropInches.toStringAsFixed(2)}');
      print('CM:     Drift: ${result.driftCm.toStringAsFixed(1)}, Drop: ${result.dropCm.toStringAsFixed(1)}');

      // Basic validation
      expect(result.driftMrad, isA<double>());
      expect(result.dropMrad, isA<double>());
      expect(result.driftMoa, isA<double>());
      expect(result.dropMoa, isA<double>());
      expect(result.driftInches, isA<double>());
      expect(result.dropInches, isA<double>());
      expect(result.driftCm, isA<double>());
      expect(result.dropCm, isA<double>());

      // Wind should cause drift
      expect(result.driftMrad.abs(), greaterThan(0));
      expect(result.driftMoa.abs(), greaterThan(0));
      
      // Bullet should drop due to gravity
      expect(result.dropMrad, greaterThan(0));
      expect(result.dropMoa, greaterThan(0));
    });

    test('Verify unit conversions are mathematically correct', () {
      final result = BallisticsCalculator.calculate(200.0, 3.0, 45.0);
      
      // Test MRAD to MOA conversion (1 MRAD ≈ 3.4377 MOA)
      const double mradToMoaFactor = 3.437746771;
      expect(result.driftMoa, closeTo(result.driftMrad * mradToMoaFactor, 0.1));
      expect(result.dropMoa, closeTo(result.dropMrad * mradToMoaFactor, 0.1));

      // Test that fractional MOA values are properly rounded
      final expectedMoa2 = (result.driftMoa / 0.5).round() * 0.5;
      expect(result.driftMoa2, closeTo(expectedMoa2, 0.01));

      final expectedMoa4 = (result.driftMoa / 0.25).round() * 0.25;
      expect(result.driftMoa4, closeTo(expectedMoa4, 0.01));

      print('\n=== UNIT CONVERSION VERIFICATION ===');
      print('Original MRAD: ${result.driftMrad.toStringAsFixed(3)}');
      print('Calculated MOA: ${result.driftMoa.toStringAsFixed(3)}');
      print('Expected MOA: ${(result.driftMrad * mradToMoaFactor).toStringAsFixed(3)}');
      print('1/2 MOA rounded: ${result.driftMoa2.toStringAsFixed(1)}');
      print('1/4 MOA rounded: ${result.driftMoa4.toStringAsFixed(2)}');
    });
  });
}
