import 'package:flutter_test/flutter_test.dart';
import 'package:musca/models/calculation.dart';

// Test the fractional unit conversion logic from home_screen.dart
Map<String, dynamic> getCorrectionsForUnit(String unit, Calculation calculation) {
  switch (unit) {
    case 'MRAD':
      return {
        'drift': calculation.driftMrad ?? 0.0,
        'drop': calculation.dropMrad ?? 0.0,
        'unit': 'MRAD'
      };
    case '1/20 MRAD':
      final driftClicks = ((calculation.driftMrad ?? 0.0) / 0.05).round();
      final dropClicks = ((calculation.dropMrad ?? 0.0) / 0.05).round();
      return {
        'drift': driftClicks.toDouble(),
        'drop': dropClicks.toDouble(),
        'unit': '1/20 MRAD'
      };
    case 'MOA':
      return {
        'drift': calculation.driftMoa ?? 0.0,
        'drop': calculation.dropMoa ?? 0.0,
        'unit': 'MOA'
      };
    case '1/2 MOA':
      final driftClicks = ((calculation.driftMoa ?? 0.0) / 0.5).round();
      final dropClicks = ((calculation.dropMoa ?? 0.0) / 0.5).round();
      return {
        'drift': driftClicks.toDouble(),
        'drop': dropClicks.toDouble(),
        'unit': '1/2 MOA'
      };
    case '1/4 MOA':
      final driftClicks = ((calculation.driftMoa ?? 0.0) / 0.25).round();
      final dropClicks = ((calculation.dropMoa ?? 0.0) / 0.25).round();
      return {
        'drift': driftClicks.toDouble(),
        'drop': dropClicks.toDouble(),
        'unit': '1/4 MOA'
      };
    default:
      return {
        'drift': 0.0,
        'drop': 0.0,
        'unit': unit
      };
  }
}

void main() {
  group('Fractional Unit Conversions - Home Screen', () {
    late Calculation testCalculation;

    setUp(() {
      testCalculation = Calculation(
        timestamp: DateTime.now(),
        distance: 300.0,
        angle: 15.0,
        windSpeed: 10.0,
        windDirection: 90.0,
        driftHorizontal: 0.05, // 5 cm drift
        dropVertical: -0.15, // 15 cm drop
        driftMrad: 0.167, // ~0.167 MRAD drift
        dropMrad: -0.5, // -0.5 MRAD drop
        driftMoa: 0.573, // ~0.573 MOA drift  
        dropMoa: -1.719, // ~-1.719 MOA drop
      );
    });

    test('MRAD shows decimal values', () {
      final result = getCorrectionsForUnit('MRAD', testCalculation);
      
      expect(result['drift'], 0.167);
      expect(result['drop'], -0.5);
      expect(result['unit'], 'MRAD');
    });

    test('1/20 MRAD shows click values (multiples of 20)', () {
      final result = getCorrectionsForUnit('1/20 MRAD', testCalculation);
      
      // 0.167 MRAD / 0.05 = 3.34, rounds to 3 clicks
      expect(result['drift'], 3.0);
      // -0.5 MRAD / 0.05 = -10, rounds to -10 clicks
      expect(result['drop'], -10.0);
      expect(result['unit'], '1/20 MRAD');
    });

    test('MOA shows decimal values', () {
      final result = getCorrectionsForUnit('MOA', testCalculation);
      
      expect(result['drift'], 0.573);
      expect(result['drop'], -1.719);
      expect(result['unit'], 'MOA');
    });

    test('1/2 MOA shows click values (multiples of 2)', () {
      final result = getCorrectionsForUnit('1/2 MOA', testCalculation);
      
      // 0.573 MOA / 0.5 = 1.146, rounds to 1 click
      expect(result['drift'], 1.0);
      // -1.719 MOA / 0.5 = -3.438, rounds to -3 clicks
      expect(result['drop'], -3.0);
      expect(result['unit'], '1/2 MOA');
    });

    test('1/4 MOA shows click values (multiples of 4)', () {
      final result = getCorrectionsForUnit('1/4 MOA', testCalculation);
      
      // 0.573 MOA / 0.25 = 2.292, rounds to 2 clicks
      expect(result['drift'], 2.0);
      // -1.719 MOA / 0.25 = -6.876, rounds to -7 clicks
      expect(result['drop'], -7.0);
      expect(result['unit'], '1/4 MOA');
    });

    test('Fractional units properly convert small values', () {
      // Test with smaller values
      final smallCalculation = Calculation(
        timestamp: DateTime.now(),
        distance: 100.0,
        angle: 0.0,
        windSpeed: 5.0,
        windDirection: 90.0,
        driftMrad: 0.03, // Very small drift
        dropMrad: -0.02, // Very small drop
        driftMoa: 0.103,
        dropMoa: -0.069,
      );

      // 1/20 MRAD: 0.03 / 0.05 = 0.6, rounds to 1 click
      final mradResult = getCorrectionsForUnit('1/20 MRAD', smallCalculation);
      expect(mradResult['drift'], 1.0);
      expect(mradResult['drop'], 0.0); // -0.02 / 0.05 = -0.4, rounds to 0

      // 1/4 MOA: 0.103 / 0.25 = 0.412, rounds to 0 clicks
      final moaResult = getCorrectionsForUnit('1/4 MOA', smallCalculation);
      expect(moaResult['drift'], 0.0);
      expect(moaResult['drop'], 0.0); // -0.069 / 0.25 = -0.276, rounds to 0
    });
  });
}
