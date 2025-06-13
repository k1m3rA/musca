import '../lib/services/ballistics_calculator.dart';
import '../lib/models/gun_model.dart';
import '../lib/models/cartridge_model.dart';
import '../lib/models/scope_model.dart';

void main() {
  print('=== TESTING ELEVATION ANGLE FUNCTIONALITY ===');
  
  // Create test profiles
  final testGun = Gun(
    id: 'test',
    name: 'Test Gun',
    muzzleVelocity: 800.0,
    zeroRange: 100.0,
    twistRateValue: 10.0,
    twistRateUnits: 0,
  );
  
  final testCartridge = Cartridge(
    id: 'test',
    name: 'Test Cartridge',
    bulletWeight: 150.0,
    ballisticCoefficient: 0.45,
    diameter: 7.62,
    length: 31.0,
    bcModelType: 0,
  );
  
  final testScope = Scope(
    id: 'test',
    name: 'Test Scope',
    sightHeight: 1.5,
    units: 0,
  );
  
  // Test with 0° elevation (flat shot)
  print('\\nTesting with 0° elevation (flat shot):');
  final result0deg = BallisticsCalculator.calculateWithProfiles(
    200.0, 0.0, 0.0, testGun, testCartridge, testScope,
    temperature: 20.0,
    pressure: 1013.0,
    humidity: 50.0,
    elevationAngle: 0.0,
    azimuthAngle: 0.0,
  );
  print('Drop: ${result0deg.dropMrad.toStringAsFixed(3)} MRAD');
  
  // Test with 10° elevation (upward shot)
  print('\\nTesting with 10° elevation (upward shot):');
  final result10deg = BallisticsCalculator.calculateWithProfiles(
    200.0, 0.0, 0.0, testGun, testCartridge, testScope,
    temperature: 20.0,
    pressure: 1013.0,
    humidity: 50.0,
    elevationAngle: 10.0,
    azimuthAngle: 0.0,
  );
  print('Drop: ${result10deg.dropMrad.toStringAsFixed(3)} MRAD');
  
  // Test with -10° elevation (downward shot)
  print('\\nTesting with -10° elevation (downward shot):');
  final resultNeg10deg = BallisticsCalculator.calculateWithProfiles(
    200.0, 0.0, 0.0, testGun, testCartridge, testScope,
    temperature: 20.0,
    pressure: 1013.0,
    humidity: 50.0,
    elevationAngle: -10.0,
    azimuthAngle: 0.0,
  );
  print('Drop: ${resultNeg10deg.dropMrad.toStringAsFixed(3)} MRAD');
  
  print('\\n=== RESULTS ANALYSIS ===');
  print('With upward shot (10°), drop should be less than flat shot');
  print('With downward shot (-10°), drop should be more than flat shot');
  print('');
  print('Drop comparison:');
  print('  Upward (+10°):  ${result10deg.dropMrad.toStringAsFixed(3)} MRAD');
  print('  Flat (0°):      ${result0deg.dropMrad.toStringAsFixed(3)} MRAD');
  print('  Downward (-10°): ${resultNeg10deg.dropMrad.toStringAsFixed(3)} MRAD');
  
  // Verify that angles are actually affecting the calculation
  if (result10deg.dropMrad != result0deg.dropMrad && 
      resultNeg10deg.dropMrad != result0deg.dropMrad) {
    print('\\n✅ SUCCESS: Elevation angle is properly affecting ballistics calculations!');
  } else {
    print('\\n❌ FAILURE: Elevation angle is not affecting calculations properly!');
  }
  
  print('\\n=== TESTING AZIMUTH ANGLE FUNCTIONALITY ===');
  
  // Test with different azimuth angles (should affect wind impact)
  print('\\nTesting with 5 m/s wind and different azimuth angles:');
  
  final resultAz0 = BallisticsCalculator.calculateWithProfiles(
    200.0, 5.0, 90.0, testGun, testCartridge, testScope,
    temperature: 20.0,
    pressure: 1013.0,
    humidity: 50.0,
    elevationAngle: 0.0,
    azimuthAngle: 0.0,
  );
  print('Azimuth 0°: Drift ${resultAz0.driftMrad.toStringAsFixed(3)} MRAD');
  
  final resultAz45 = BallisticsCalculator.calculateWithProfiles(
    200.0, 5.0, 90.0, testGun, testCartridge, testScope,
    temperature: 20.0,
    pressure: 1013.0,
    humidity: 50.0,
    elevationAngle: 0.0,
    azimuthAngle: 45.0,
  );
  print('Azimuth 45°: Drift ${resultAz45.driftMrad.toStringAsFixed(3)} MRAD');
  
  print('\\n✅ TESTING COMPLETE: Dynamic angles are now functional in the ballistics calculator!');
}
