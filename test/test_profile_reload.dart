// Test script to demonstrate profile reload functionality
// Run with: dart run test_profile_reload.dart

import '../lib/services/ballistics_calculator.dart';
import '../lib/models/gun_model.dart';
import '../lib/models/cartridge_model.dart';
import '../lib/models/scope_model.dart';

void main() {
  print('=== PROFILE RELOAD TEST ===\n');
  
  // Create initial profiles (simulating user changing muzzle velocity)
  final gun1 = Gun(
    id: 'test-gun',
    name: 'Test Rifle',
    twistRate: 12.0,
    twistDirection: 1,
    muzzleVelocity: 800.0, // Initial velocity
    zeroRange: 200.0,
  );
  
  final gun2 = Gun(
    id: 'test-gun',
    name: 'Test Rifle',
    twistRate: 12.0,
    twistDirection: 1,
    muzzleVelocity: 850.0, // Changed velocity
    zeroRange: 200.0,
  );
  
  final cartridge = Cartridge(
    id: 'test-cartridge',
    name: 'Test .308 Load',
    diameter: '.308',
    bulletWeight: 175.0,
    bulletLength: 0.0,
    ballisticCoefficient: 0.475,
    bcModelType: 0,
  );
  
  final scope = Scope(
    id: 'test-scope',
    name: 'Test Scope',
    sightHeight: 1.5,
    units: 0,
  );
  
  // Test conditions
  const double distance = 500.0;
  const double windSpeed = 5.0;
  const double windDirection = 90.0;
  
  print('TEST CONDITIONS:');
  print('Distance: ${distance}m');
  print('Wind: ${windSpeed}m/s at ${windDirection}°');
  print('');
    // Calculate with original gun profile
  print('CALCULATION WITH ORIGINAL PROFILE (800 m/s):');
  final result1 = BallisticsCalculator.calculateWithProfiles(
    distance,
    windSpeed,
    windDirection,
    gun1,
    cartridge,
    scope,
    temperature: 20.0,
    pressure: 1013.0,
    humidity: 50.0,
  );
  print('Drift: ${result1.driftMrad.toStringAsFixed(2)} MRAD');
  print('Drop: ${result1.dropMrad.toStringAsFixed(2)} MRAD');
  print('');
  
  // Calculate with updated gun profile
  print('CALCULATION WITH UPDATED PROFILE (850 m/s):');
  final result2 = BallisticsCalculator.calculateWithProfiles(
    distance,
    windSpeed,
    windDirection,
    gun2,
    cartridge,
    scope,
    temperature: 20.0,
    pressure: 1013.0,
    humidity: 50.0,
  );
  print('Drift: ${result2.driftMrad.toStringAsFixed(2)} MRAD');
  print('Drop: ${result2.dropMrad.toStringAsFixed(2)} MRAD');
  print('');
  
  // Show the difference
  final driftDiff = result2.driftMrad - result1.driftMrad;
  final dropDiff = result2.dropMrad - result1.dropMrad;
  
  print('DIFFERENCE (850 m/s - 800 m/s):');
  print('Drift change: ${driftDiff.toStringAsFixed(3)} MRAD');
  print('Drop change: ${dropDiff.toStringAsFixed(3)} MRAD');
  print('');
  
  print('EXPECTED BEHAVIOR:');
  print('• Higher muzzle velocity should reduce drop (negative drop change)');
  print('• Drift should change slightly due to different flight time');
  print('• Both values should be different, confirming profile data is being used');
  print('');
  
  if (dropDiff.abs() > 0.01) {
    print('✅ PASS: Profile changes are affecting ballistics calculations');
  } else {
    print('❌ FAIL: Profile changes are not affecting ballistics calculations');
  }
}
