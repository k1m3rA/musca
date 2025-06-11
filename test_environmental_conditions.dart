// Test script to verify environmental conditions affect ballistics calculations
// Run with: dart run test_environmental_conditions.dart

import 'lib/services/ballistics_calculator.dart';
import 'lib/models/gun_model.dart';
import 'lib/models/cartridge_model.dart';
import 'lib/models/scope_model.dart';

void main() {
  print('=== ENVIRONMENTAL CONDITIONS BALLISTICS TEST ===\n');
  
  // Create test profiles
  final testGun = Gun(
    id: 'test-gun',
    name: 'Test Rifle',
    twistRate: 12.0,
    twistDirection: 1,
    muzzleVelocity: 800.0,
    zeroRange: 100.0,
  );
  
  final testCartridge = Cartridge(
    id: 'test-cartridge',
    name: 'Test .308 Load',
    diameter: '.308',
    bulletWeight: 175.0,
    bulletLength: 0.0,
    ballisticCoefficient: 0.475,
    bcModelType: 0,
  );
  
  final testScope = Scope(
    id: 'test-scope',
    name: 'Test Scope',
    sightHeight: 1.5,
    units: 0,
  );
  
  // Test conditions
  const double distance = 300.0;
  const double windSpeed = 5.0;
  const double windDirection = 90.0;
  
  print('Test Scenario: ${distance}m with ${windSpeed}m/s crosswind\n');
  
  // Test 1: Standard conditions (15°C, 1013 mbar, 50% humidity)
  print('1. STANDARD CONDITIONS:');
  print('   Temperature: 15°C, Pressure: 1013 mbar, Humidity: 50%');
  final result1 = BallisticsCalculator.calculateWithProfiles(
    distance,
    windSpeed,
    windDirection,
    testGun,
    testCartridge,
    testScope,
    temperature: 15.0,
    pressure: 1013.0,
    humidity: 50.0,
  );
  print('   Drop: ${result1.dropMrad.toStringAsFixed(3)} MRAD');
  print('   Drift: ${result1.driftMrad.toStringAsFixed(3)} MRAD\n');
  
  // Test 2: Hot conditions (35°C, 1000 mbar, 80% humidity)
  print('2. HOT CONDITIONS:');
  print('   Temperature: 35°C, Pressure: 1000 mbar, Humidity: 80%');
  final result2 = BallisticsCalculator.calculateWithProfiles(
    distance,
    windSpeed,
    windDirection,
    testGun,
    testCartridge,
    testScope,
    temperature: 35.0,
    pressure: 1000.0,
    humidity: 80.0,
  );
  print('   Drop: ${result2.dropMrad.toStringAsFixed(3)} MRAD');
  print('   Drift: ${result2.driftMrad.toStringAsFixed(3)} MRAD\n');
  
  // Test 3: Cold conditions (-10°C, 1030 mbar, 20% humidity)
  print('3. COLD CONDITIONS:');
  print('   Temperature: -10°C, Pressure: 1030 mbar, Humidity: 20%');
  final result3 = BallisticsCalculator.calculateWithProfiles(
    distance,
    windSpeed,
    windDirection,
    testGun,
    testCartridge,
    testScope,
    temperature: -10.0,
    pressure: 1030.0,
    humidity: 20.0,
  );
  print('   Drop: ${result3.dropMrad.toStringAsFixed(3)} MRAD');
  print('   Drift: ${result3.driftMrad.toStringAsFixed(3)} MRAD\n');
  
  // Test 4: High altitude conditions (5°C, 850 mbar, 30% humidity)
  print('4. HIGH ALTITUDE CONDITIONS:');
  print('   Temperature: 5°C, Pressure: 850 mbar, Humidity: 30%');
  final result4 = BallisticsCalculator.calculateWithProfiles(
    distance,
    windSpeed,
    windDirection,
    testGun,
    testCartridge,
    testScope,
    temperature: 5.0,
    pressure: 850.0,
    humidity: 30.0,
  );
  print('   Drop: ${result4.dropMrad.toStringAsFixed(3)} MRAD');
  print('   Drift: ${result4.driftMrad.toStringAsFixed(3)} MRAD\n');
  
  // Compare results
  print('ENVIRONMENTAL EFFECTS:');
  
  final hotVsStandard = result2.dropMrad - result1.dropMrad;
  final coldVsStandard = result3.dropMrad - result1.dropMrad;
  final altitudeVsStandard = result4.dropMrad - result1.dropMrad;
  
  print('Drop changes compared to standard conditions:');
  print('   Hot vs Standard: ${hotVsStandard.toStringAsFixed(3)} MRAD');
  print('   Cold vs Standard: ${coldVsStandard.toStringAsFixed(3)} MRAD');
  print('   High altitude vs Standard: ${altitudeVsStandard.toStringAsFixed(3)} MRAD\n');
  
  print('EXPECTED BEHAVIORS:');
  print('• Hot air (lower density) should reduce drop (negative change)');
  print('• Cold air (higher density) should increase drop (positive change)');
  print('• High altitude (lower pressure/density) should reduce drop (negative change)');
  print('• All conditions should show different results, confirming environmental data is being used');
  
  // Validation
  bool allDifferent = (result1.dropMrad != result2.dropMrad) &&
                     (result1.dropMrad != result3.dropMrad) &&
                     (result1.dropMrad != result4.dropMrad);
  
  if (allDifferent) {
    print('\n✅ PASS: Environmental conditions are affecting ballistics calculations');
  } else {
    print('\n❌ FAIL: Environmental conditions are not affecting ballistics calculations');
  }
}
