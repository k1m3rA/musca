// Test script to verify G7 ballistic coefficient table
// Run with: dart run test_g7_ballistics.dart

import 'lib/services/ballistics_calculator.dart';
import 'lib/models/gun_model.dart';
import 'lib/models/cartridge_model.dart';
import 'lib/models/scope_model.dart';

void main() async {
  print('=== G7 BALLISTICS COEFFICIENT TABLE TEST ===\n');
  
  // Create test profiles
  final testGun = Gun(
    id: 'test-gun',
    name: 'Test Rifle',
    twistRate: 12.0,
    twistDirection: 1,
    muzzleVelocity: 800.0,
    zeroRange: 100.0,
  );
  
  // Create G1 cartridge for comparison
  final g1Cartridge = Cartridge(
    id: 'test-g1-cartridge',
    name: 'Test G1 Cartridge',
    diameter: '.308',
    bulletWeight: 175.0,
    bulletLength: 0.0,
    ballisticCoefficient: 0.475,
    bcModelType: 0, // G1
  );
  
  // Create G7 cartridge with same BC value for comparison
  final g7Cartridge = Cartridge(
    id: 'test-g7-cartridge',
    name: 'Test G7 Cartridge',
    diameter: '.308',
    bulletWeight: 175.0,
    bulletLength: 0.0,
    ballisticCoefficient: 0.475,
    bcModelType: 1, // G7
  );
  
  final testScope = Scope(
    id: 'test-scope',
    name: 'Test Scope',
    sightHeight: 1.5,
    units: 0,
  );
  
  // Test conditions
  const double distance = 500.0;
  const double windSpeed = 5.0;
  const double windDirection = 90.0;
  const double temperature = 15.0;
  const double pressure = 1013.25;
  const double humidity = 50.0;
  
  print('TEST CONDITIONS:');
  print('Distance: ${distance}m');
  print('Wind: ${windSpeed}m/s at ${windDirection}°');
  print('Environmental: ${temperature}°C, ${pressure}mbar, ${humidity}% humidity');
  print('');
  
  // Calculate with G1 cartridge
  print('CALCULATION WITH G1 BALLISTIC COEFFICIENT:');
  final g1Result = BallisticsCalculator.calculateWithProfiles(
    distance,
    windSpeed,
    windDirection,
    testGun,
    g1Cartridge,
    testScope,
    temperature: temperature,
    pressure: pressure,
    humidity: humidity,
  );
  
  print('Drift: ${g1Result.driftMrad.toStringAsFixed(2)} MRAD, Drop: ${g1Result.dropMrad.toStringAsFixed(2)} MRAD');
  print('');
  
  // Calculate with G7 cartridge
  print('CALCULATION WITH G7 BALLISTIC COEFFICIENT:');
  final g7Result = BallisticsCalculator.calculateWithProfiles(
    distance,
    windSpeed,
    windDirection,
    testGun,
    g7Cartridge,
    testScope,
    temperature: temperature,
    pressure: pressure,
    humidity: humidity,
  );
  
  print('Drift: ${g7Result.driftMrad.toStringAsFixed(2)} MRAD, Drop: ${g7Result.dropMrad.toStringAsFixed(2)} MRAD');
  print('');
  
  // Compare results
  final driftDifference = (g1Result.driftMrad - g7Result.driftMrad).abs();
  final dropDifference = (g1Result.dropMrad - g7Result.dropMrad).abs();
  
  print('COMPARISON:');
  print('Drift difference: ${driftDifference.toStringAsFixed(3)} MRAD');
  print('Drop difference: ${dropDifference.toStringAsFixed(3)} MRAD');
  print('');
  
  // Test different Mach numbers to verify table lookup
  print('TESTING G7 COEFFICIENT TABLE VALUES:');
  final testMachNumbers = [0.5, 0.9, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0];
  
  for (double mach in testMachNumbers) {
    final g7Coeff = BallisticsCalculator.g7BallisticCoefficient(mach);
    print('Mach ${mach.toStringAsFixed(1)}: G7 coefficient = ${g7Coeff.toStringAsFixed(4)}');
  }
  
  print('\n✅ G7 ballistics coefficient implementation test completed!');
}
