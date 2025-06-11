// Demo script to showcase the new ballistics calculator with all units
// Run with: dart run demo_ballistics.dart

import 'lib/services/ballistics_calculator.dart';
import 'lib/models/gun_model.dart';
import 'lib/models/cartridge_model.dart';
import 'lib/models/scope_model.dart';

void main() {
  print('=== BALLISTICS CALCULATOR - MULTIPLE UNITS DEMO ===\n');
  
  // Create demo profiles
  final demoGun = Gun(
    id: 'demo-gun',
    name: 'Demo .308 Rifle',
    twistRate: 12.0, // 1:12 twist
    twistDirection: 1, // Right twist
    muzzleVelocity: 820.0, // m/s
    zeroRange: 100.0, // 100m zero
  );
  
  final demoCartridge = Cartridge(
    id: 'demo-cartridge',
    name: 'Demo .308 150gr',
    diameter: '.308',
    bulletWeight: 150.0, // grains
    bulletLength: 0.0,
    ballisticCoefficient: 0.504, // G1
  );
    final demoScope = Scope(
    id: 'demo-scope',
    name: 'Demo Scope',
    sightHeight: 2.17, // inches
    units: 0, // inches
  );

  // Example shooting scenarios
  final scenarios = [
    {'distance': 100.0, 'windSpeed': 0.0, 'windDirection': 0.0, 'name': '100m - No Wind'},
    {'distance': 200.0, 'windSpeed': 5.0, 'windDirection': 90.0, 'name': '200m - 5m/s Crosswind'},
    {'distance': 300.0, 'windSpeed': 10.0, 'windDirection': 45.0, 'name': '300m - 10m/s Quarter Wind'},
    {'distance': 500.0, 'windSpeed': 3.0, 'windDirection': 180.0, 'name': '500m - 3m/s Tailwind'},
  ];

  for (final scenario in scenarios) {
    final distance = scenario['distance'] as double;
    final windSpeed = scenario['windSpeed'] as double;
    final windDirection = scenario['windDirection'] as double;
    final name = scenario['name'] as String;    print('--- $name ---');
    print('Distance: ${distance}m, Wind: ${windSpeed}m/s at ${windDirection}°\n');

    final result = BallisticsCalculator.calculateWithProfiles(
      distance, 
      windSpeed, 
      windDirection,
      demoGun,
      demoCartridge,
      demoScope,
    );

    // Display results in a formatted table
    print('ANGULAR CORRECTIONS:');
    print('┌─────────────┬──────────────┬──────────────┐');
    print('│    Unit     │    Drift     │     Drop     │');
    print('├─────────────┼──────────────┼──────────────┤');
    print('│ MRAD        │ ${result.driftMrad.toStringAsFixed(2).padLeft(10)} │ ${result.dropMrad.toStringAsFixed(2).padLeft(10)} │');
    print('│ 1/20 MRAD   │ ${result.driftMrad20.toStringAsFixed(2).padLeft(10)} │ ${result.dropMrad20.toStringAsFixed(2).padLeft(10)} │');
    print('│ MOA         │ ${result.driftMoa.toStringAsFixed(2).padLeft(10)} │ ${result.dropMoa.toStringAsFixed(2).padLeft(10)} │');
    print('│ 1/2 MOA     │ ${result.driftMoa2.toStringAsFixed(1).padLeft(10)} │ ${result.dropMoa2.toStringAsFixed(1).padLeft(10)} │');
    print('│ 1/3 MOA     │ ${result.driftMoa3.toStringAsFixed(3).padLeft(10)} │ ${result.dropMoa3.toStringAsFixed(3).padLeft(10)} │');
    print('│ 1/4 MOA     │ ${result.driftMoa4.toStringAsFixed(2).padLeft(10)} │ ${result.dropMoa4.toStringAsFixed(2).padLeft(10)} │');
    print('│ 1/8 MOA     │ ${result.driftMoa8.toStringAsFixed(3).padLeft(10)} │ ${result.dropMoa8.toStringAsFixed(3).padLeft(10)} │');
    print('└─────────────┴──────────────┴──────────────┘');

    print('\nLINEAR CORRECTIONS AT TARGET:');
    print('┌─────────────┬──────────────┬──────────────┐');
    print('│    Unit     │    Drift     │     Drop     │');
    print('├─────────────┼──────────────┼──────────────┤');
    print('│ Inches      │ ${result.driftInches.toStringAsFixed(1).padLeft(10)} │ ${result.dropInches.toStringAsFixed(1).padLeft(10)} │');
    print('│ Centimeters │ ${result.driftCm.toStringAsFixed(1).padLeft(10)} │ ${result.dropCm.toStringAsFixed(1).padLeft(10)} │');
    print('└─────────────┴──────────────┴──────────────┘');

    // Scope adjustment estimates (assuming 0.1 MRAD clicks)
    final driftClicks = (result.driftMrad / 0.1).round();
    final dropClicks = (result.dropMrad / 0.1).round();
    print('\nSCOPE ADJUSTMENTS (0.1 MRAD clicks):');
    print('Windage: ${driftClicks.abs()} clicks ${driftClicks > 0 ? "RIGHT" : "LEFT"}');
    print('Elevation: ${dropClicks.abs()} clicks UP');

    print('\n' + '='*50 + '\n');
  }
  print('NOTES:');
  print('• All corrections use .308 Winchester 150gr projectile with demo profiles');
  print('• MRAD = Milliradian, MOA = Minute of Angle');
  print('• Fractional units (1/2, 1/3, etc.) are rounded to nearest increment');
  print('• Linear corrections show actual bullet impact displacement at target');
  print('• Angular corrections can be used directly for scope adjustments');
}
