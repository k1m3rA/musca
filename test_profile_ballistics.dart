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
    
    print('SCENARIO: $name');    print('Distance: ${distance}m, Wind: ${windSpeed}m/s @ ${windDirection}°');
    print('');
    
    // Create default profiles for comparison (similar to old hardcoded constants)
    final defaultGun = Gun(
      id: 'default-gun',
      name: 'Default .308',
      twistRate: 12.0, // 1:12 twist (default)
      twistDirection: 1, // Right twist
      muzzleVelocity: 820.0, // m/s (old hardcoded value)
      zeroRange: 100.0, // 100m zero (old hardcoded value)
    );
    
    final defaultCartridge = Cartridge(
      id: 'default-cartridge',
      name: 'Default .308 150gr',
      diameter: '.308',
      bulletWeight: 150.0, // grains (old hardcoded value)
      bulletLength: 0.0,
      ballisticCoefficient: 0.504, // G1 (old hardcoded value)
    );
    
    final defaultScope = Scope(
      id: 'default-scope',
      name: 'Default Scope',
      sightHeight: 2.17, // inches (old hardcoded value)
      units: 0, // inches
    );
    
    // Test with default profiles (equivalent to old hardcoded constants)
    final resultDefault = BallisticsCalculator.calculateWithProfiles(
      distance,
      windSpeed,
      windDirection,
      defaultGun,
      defaultCartridge,
      defaultScope,
    );
    
    // Test with custom profiles
    final resultWithProfiles = BallisticsCalculator.calculateWithProfiles(
      distance,
      windSpeed,
      windDirection,
      testGun,
      testCartridge,
      testScope,
    );
    
    print('DEFAULT PROFILES (equivalent to old hardcoded .308 150gr):');    print('Drift: ${resultDefault.driftMrad.toStringAsFixed(2)} MRAD, Drop: ${resultDefault.dropMrad.toStringAsFixed(2)} MRAD');
    print('Drift: ${resultDefault.driftMoa.toStringAsFixed(2)} MOA, Drop: ${resultDefault.dropMoa.toStringAsFixed(2)} MOA');
    print('');
    
    print('CUSTOM PROFILE-BASED METHOD (.308 175gr):');
    print('Drift: ${resultWithProfiles.driftMrad.toStringAsFixed(2)} MRAD, Drop: ${resultWithProfiles.dropMrad.toStringAsFixed(2)} MRAD');
    print('Drift: ${resultWithProfiles.driftMoa.toStringAsFixed(2)} MOA, Drop: ${resultWithProfiles.dropMoa.toStringAsFixed(2)} MOA');
    print('');
    
    print('DIFFERENCES:');
    final driftDiff = resultWithProfiles.driftMrad - resultDefault.driftMrad;
    final dropDiff = resultWithProfiles.dropMrad - resultDefault.dropMrad;
    print('Drift: ${driftDiff.toStringAsFixed(3)} MRAD');
    print('Drop: ${dropDiff.toStringAsFixed(3)} MRAD');
    print('');
    print('=' * 50);
    print('');
  }
    print('NOTES:');
  print('• Default profiles use equivalent values to old hardcoded .308 Winchester 150gr, 820 m/s');
  print('• Custom profile method uses custom .308 175gr, 800 m/s, 200m zero');
  print('• Differences show impact of using user-configured profiles');
  print('• Heavier bullet (175gr vs 150gr) and lower velocity should show more drop');
}
