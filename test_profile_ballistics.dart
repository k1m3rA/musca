// Test script to verify profile-based ballistics calculations
// Run with: dart run test_profile_ballistics.dart

import 'lib/services/ballistics_calculator.dart';
import 'lib/models/gun_model.dart';
import 'lib/models/cartridge_model.dart';
import 'lib/models/scope_model.dart';

void main() {
  print('=== PROFILE-BASED BALLISTICS CALCULATOR TEST ===\n');
  
  // Create test profiles
  final testGun = Gun(
    id: 'test-gun',
    name: 'Test Rifle',
    twistRate: 12.0, // 1:12 twist
    twistDirection: 1, // Right twist
    muzzleVelocity: 800.0, // m/s
    zeroRange: 200.0, // 200m zero
  );
  
  final testCartridge = Cartridge(
    id: 'test-cartridge',
    name: 'Test .308 Load',
    diameter: '.308',
    bulletWeight: 175.0, // grains
    bulletLength: 0.0, // Not used in ballistics calculation
    ballisticCoefficient: 0.475, // G1 BC
  );
  
  final testScope = Scope(
    id: 'test-scope',
    name: 'Test Scope',
    sightHeight: 1.5, // inches
    units: 0, // inches
  );
  
  // Test scenarios
  final scenarios = [
    {'distance': 300.0, 'windSpeed': 0.0, 'windDirection': 0.0, 'name': '300m - No Wind'},
    {'distance': 500.0, 'windSpeed': 5.0, 'windDirection': 90.0, 'name': '500m - 5m/s Crosswind'},
  ];
  
  for (final scenario in scenarios) {
    final distance = scenario['distance'] as double;
    final windSpeed = scenario['windSpeed'] as double;
    final windDirection = scenario['windDirection'] as double;
    final name = scenario['name'] as String;
    
    print('SCENARIO: $name');
    print('Distance: ${distance}m, Wind: ${windSpeed}m/s @ ${windDirection}°');
    print('');
    
    // Test with hardcoded constants (original method)
    final resultOriginal = BallisticsCalculator.calculate(
      distance,
      windSpeed,
      windDirection,
    );
    
    // Test with profiles
    final resultWithProfiles = BallisticsCalculator.calculateWithProfiles(
      distance,
      windSpeed,
      windDirection,
      testGun,
      testCartridge,
      testScope,
    );
    
    print('ORIGINAL METHOD (hardcoded .308 150gr):');
    print('Drift: ${resultOriginal.driftMrad.toStringAsFixed(2)} MRAD, Drop: ${resultOriginal.dropMrad.toStringAsFixed(2)} MRAD');
    print('Drift: ${resultOriginal.driftMoa.toStringAsFixed(2)} MOA, Drop: ${resultOriginal.dropMoa.toStringAsFixed(2)} MOA');
    print('');
    
    print('PROFILE-BASED METHOD (.308 175gr):');
    print('Drift: ${resultWithProfiles.driftMrad.toStringAsFixed(2)} MRAD, Drop: ${resultWithProfiles.dropMrad.toStringAsFixed(2)} MRAD');
    print('Drift: ${resultWithProfiles.driftMoa.toStringAsFixed(2)} MOA, Drop: ${resultWithProfiles.dropMoa.toStringAsFixed(2)} MOA');
    print('');
    
    print('DIFFERENCES:');
    final driftDiff = resultWithProfiles.driftMrad - resultOriginal.driftMrad;
    final dropDiff = resultWithProfiles.dropMrad - resultOriginal.dropMrad;
    print('Drift: ${driftDiff.toStringAsFixed(3)} MRAD');
    print('Drop: ${dropDiff.toStringAsFixed(3)} MRAD');
    print('');
    print('=' * 50);
    print('');
  }
  
  print('NOTES:');
  print('• Original method uses hardcoded .308 Winchester 150gr, 820 m/s');
  print('• Profile method uses custom .308 175gr, 800 m/s, 200m zero');
  print('• Differences show impact of using user-configured profiles');
  print('• Heavier bullet (175gr vs 150gr) and lower velocity should show more drop');
}
