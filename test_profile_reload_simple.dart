// Test script to verify profile reloading functionality
// Run with: dart run test_profile_reload_simple.dart

import 'lib/services/gun_storage.dart';
import 'lib/services/cartridge_storage.dart';
import 'lib/services/scope_storage.dart';
import 'lib/services/ballistics_calculator.dart';
import 'lib/models/gun_model.dart';
import 'lib/models/cartridge_model.dart';
import 'lib/models/scope_model.dart';

void main() async {
  print('=== TESTING PROFILE RELOAD FUNCTIONALITY ===\n');
  
  // Create test profiles with different values
  print('1. Creating test profiles...');
  
  final testGun1 = Gun(
    id: 'test-gun-1',
    name: 'Test Rifle (Low Velocity)',
    twistRate: 12.0,
    twistDirection: 1,
    muzzleVelocity: 750.0, // Lower velocity
    zeroRange: 100.0,
  );
  
  final testGun2 = Gun(
    id: 'test-gun-2', 
    name: 'Test Rifle (High Velocity)',
    twistRate: 12.0,
    twistDirection: 1,
    muzzleVelocity: 900.0, // Higher velocity
    zeroRange: 100.0,
  );
  
  final testCartridge = Cartridge(
    id: 'test-cartridge',
    name: 'Test .308',
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
  
  // Save first gun and test ballistics
  print('2. Testing with low velocity gun (750 m/s)...');
  await GunStorage.saveGun(testGun1);
  await GunStorage.saveSelectedGunId(testGun1.id);
  await CartridgeStorage.saveCartridge(testCartridge);
  await CartridgeStorage.saveSelectedCartridgeId(testCartridge.id);
  await ScopeStorage.saveScope(testScope);
  await ScopeStorage.saveSelectedScopeId(testScope.id);
  
  // Test ballistics calculation
  const distance = 300.0;
  const windSpeed = 5.0;
  const windDirection = 90.0;
  
  final result1 = BallisticsCalculator.calculateWithProfiles(
    distance,
    windSpeed, 
    windDirection,
    testGun1,
    testCartridge,
    testScope,
  );
  
  print('   Drop: ${result1.dropMrad.toStringAsFixed(3)} MRAD');
  print('   Drift: ${result1.driftMrad.toStringAsFixed(3)} MRAD');
  
  // Switch to second gun and test again
  print('\n3. Testing with high velocity gun (900 m/s)...');
  await GunStorage.saveGun(testGun2);
  await GunStorage.saveSelectedGunId(testGun2.id);
  
  final result2 = BallisticsCalculator.calculateWithProfiles(
    distance,
    windSpeed,
    windDirection, 
    testGun2,
    testCartridge,
    testScope,
  );
  
  print('   Drop: ${result2.dropMrad.toStringAsFixed(3)} MRAD');
  print('   Drift: ${result2.driftMrad.toStringAsFixed(3)} MRAD');
  
  // Compare results
  print('\n4. Comparison:');
  final dropDifference = result1.dropMrad - result2.dropMrad;
  final driftDifference = result1.driftMrad - result2.driftMrad;
  
  print('   Drop difference: ${dropDifference.toStringAsFixed(3)} MRAD');
  print('   Drift difference: ${driftDifference.toStringAsFixed(3)} MRAD');
  
  if (dropDifference > 0.1) {
    print('   ✅ PASS: Higher velocity shows less drop (as expected)');
  } else {
    print('   ❌ FAIL: Velocity change not affecting ballistics properly');
  }
  
  if (driftDifference.abs() < 0.5) {
    print('   ✅ PASS: Similar drift for same cartridge (as expected)');
  } else {
    print('   ❌ FAIL: Unexpected drift difference');
  }
  
  // Test profile loading
  print('\n5. Testing profile loading...');
  final loadedGun = await GunStorage.getSelectedGun();
  final loadedCartridge = await CartridgeStorage.getSelectedCartridge();
  final loadedScope = await ScopeStorage.getSelectedScope();
  
  if (loadedGun?.id == testGun2.id) {
    print('   ✅ PASS: Correct gun loaded');
  } else {
    print('   ❌ FAIL: Wrong gun loaded');
  }
  
  if (loadedCartridge?.id == testCartridge.id) {
    print('   ✅ PASS: Correct cartridge loaded');
  } else {
    print('   ❌ FAIL: Wrong cartridge loaded');
  }
  
  if (loadedScope?.id == testScope.id) {
    print('   ✅ PASS: Correct scope loaded');
  } else {
    print('   ❌ FAIL: Wrong scope loaded');
  }
  
  print('\n=== TEST COMPLETE ===');
  print('The profile system should now properly affect ballistics calculations.');
  print('When you change gun settings in the app, calculations should update.');
}
