// Test to verify BC model type switching
// Run with: dart run test_bc_model_switching.dart

import 'lib/services/ballistics_calculator.dart';
import 'lib/models/gun_model.dart';
import 'lib/models/cartridge_model.dart';
import 'lib/models/scope_model.dart';

void main() async {
  print('=== BALLISTIC COEFFICIENT MODEL SWITCHING TEST ===\n');
  
  final testGun = Gun(
    id: 'test-gun',
    name: 'Test Rifle',
    twistRate: 12.0,
    twistDirection: 1,
    muzzleVelocity: 800.0,
    zeroRange: 100.0,
  );
  
  final testScope = Scope(
    id: 'test-scope',
    name: 'Test Scope',
    sightHeight: 1.5,
    units: 0,
  );
  
  // Test with null bcModelType (should default to G1)
  final cartridgeNullBC = Cartridge(
    id: 'test-null-cartridge',
    name: 'Test Null BC Model',
    diameter: '.308',
    bulletWeight: 175.0,
    bulletLength: 0.0,
    ballisticCoefficient: 0.475,
    bcModelType: null, // null should default to G1
  );
  
  // Test with explicit G1
  final cartridgeG1 = Cartridge(
    id: 'test-g1-cartridge',
    name: 'Test G1 Cartridge',
    diameter: '.308',
    bulletWeight: 175.0,
    bulletLength: 0.0,
    ballisticCoefficient: 0.475,
    bcModelType: 0, // explicit G1
  );
  
  // Test with G7
  final cartridgeG7 = Cartridge(
    id: 'test-g7-cartridge',
    name: 'Test G7 Cartridge',
    diameter: '.308',
    bulletWeight: 175.0,
    bulletLength: 0.0,
    ballisticCoefficient: 0.475,
    bcModelType: 1, // G7
  );
  
  const distance = 300.0;
  const windSpeed = 10.0;
  const windDirection = 90.0;
  
  print('TEST CONDITIONS: ${distance}m, ${windSpeed}m/s wind');
  print('');
  
  // Test calculations
  final resultNull = BallisticsCalculator.calculateWithProfiles(
    distance, windSpeed, windDirection,
    testGun, cartridgeNullBC, testScope,
    temperature: 15.0, pressure: 1013.25, humidity: 50.0,
  );
  
  final resultG1 = BallisticsCalculator.calculateWithProfiles(
    distance, windSpeed, windDirection,
    testGun, cartridgeG1, testScope,
    temperature: 15.0, pressure: 1013.25, humidity: 50.0,
  );
  
  final resultG7 = BallisticsCalculator.calculateWithProfiles(
    distance, windSpeed, windDirection,
    testGun, cartridgeG7, testScope,
    temperature: 15.0, pressure: 1013.25, humidity: 50.0,
  );
  
  print('NULL BC MODEL TYPE (should use G1): Drift=${resultNull.driftMrad.toStringAsFixed(2)}, Drop=${resultNull.dropMrad.toStringAsFixed(2)}');
  print('EXPLICIT G1 BC MODEL: Drift=${resultG1.driftMrad.toStringAsFixed(2)}, Drop=${resultG1.dropMrad.toStringAsFixed(2)}');
  print('EXPLICIT G7 BC MODEL: Drift=${resultG7.driftMrad.toStringAsFixed(2)}, Drop=${resultG7.dropMrad.toStringAsFixed(2)}');
  print('');
  
  // Verify null and G1 results are identical
  final nullG1DriftDiff = (resultNull.driftMrad - resultG1.driftMrad).abs();
  final nullG1DropDiff = (resultNull.dropMrad - resultG1.dropMrad).abs();
  
  if (nullG1DriftDiff < 0.001 && nullG1DropDiff < 0.001) {
    print('✅ PASS: Null BC model type correctly defaults to G1');
  } else {
    print('❌ FAIL: Null BC model type does not match G1');
  }
  
  // Verify G1 and G7 results are different
  final g1G7DriftDiff = (resultG1.driftMrad - resultG7.driftMrad).abs();
  final g1G7DropDiff = (resultG1.dropMrad - resultG7.dropMrad).abs();
  
  if (g1G7DriftDiff > 0.1 || g1G7DropDiff > 0.1) {
    print('✅ PASS: G1 and G7 models produce different results (as expected)');
  } else {
    print('❌ FAIL: G1 and G7 models produce too similar results');
  }
  
  print('\n=== TEST COMPLETED ===');
}
