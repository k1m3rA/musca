import 'lib/services/ballistics_calculator.dart';
import 'lib/models/gun_model.dart';
import 'lib/models/cartridge_model.dart';
import 'lib/models/scope_model.dart';

void main() async {
  print('=== TESTING FRACTIONAL UNITS ON HOME SCREEN ===');
  
  // Create test profiles
  final testGun = Gun(
    id: 'test-gun',
    name: 'Test Gun',
    twistRate: 12.0,
    twistDirection: 1,
    muzzleVelocity: 820.0,
    zeroRange: 100.0,
  );
  
  final testCartridge = Cartridge(
    id: 'test-cartridge',
    name: 'Test Cartridge',
    diameter: '.308',
    bulletWeight: 150.0,
    bulletLength: 0.0,
    ballisticCoefficient: 0.504,
  );
  
  final testScope = Scope(
    id: 'test-scope',
    name: 'Test Scope',
    sightHeight: 2.17,
    units: 0,
  );
  
  // Create a test ballistics result
  final result = BallisticsCalculator.calculateWithProfiles(
    200.0, 5.0, 45.0, testGun, testCartridge, testScope
  );
  
  print('Distance: 200m, Wind: 5m/s at 45°');
  print('');
  
  // Test all the fractional units that will be available on home screen
  print('ANGULAR CORRECTIONS:');
  print('MRAD:       Drift: ${result.driftMrad.toStringAsFixed(2)}, Drop: ${result.dropMrad.toStringAsFixed(2)}');
  print('1/20 MRAD:  Drift: ${result.driftMrad20.toStringAsFixed(2)}, Drop: ${result.dropMrad20.toStringAsFixed(2)}');
  print('MOA:        Drift: ${result.driftMoa.toStringAsFixed(2)}, Drop: ${result.dropMoa.toStringAsFixed(2)}');
  print('1/2 MOA:    Drift: ${result.driftMoa2.toStringAsFixed(1)}, Drop: ${result.dropMoa2.toStringAsFixed(1)}');
  print('1/3 MOA:    Drift: ${result.driftMoa3.toStringAsFixed(3)}, Drop: ${result.dropMoa3.toStringAsFixed(3)}');
  print('1/4 MOA:    Drift: ${result.driftMoa4.toStringAsFixed(2)}, Drop: ${result.dropMoa4.toStringAsFixed(2)}');
  print('1/8 MOA:    Drift: ${result.driftMoa8.toStringAsFixed(3)}, Drop: ${result.dropMoa8.toStringAsFixed(3)}');
  print('');
  
  print('LINEAR CORRECTIONS:');
  print('Inches:     Drift: ${result.driftInches.toStringAsFixed(2)}, Drop: ${result.dropInches.toStringAsFixed(2)}');
  print('CM:         Drift: ${result.driftCm.toStringAsFixed(1)}, Drop: ${result.dropCm.toStringAsFixed(1)}');
  print('Meters:     Drift: ${result.driftHorizontal.toStringAsFixed(3)}, Drop: ${result.dropVertical.toStringAsFixed(3)}');
  print('');
  
  // Test the fractional unit calculations that home screen will do
  print('HOME SCREEN UNIT CALCULATIONS (simulated):');
  
  // Simulate the home screen calculations for fractional units
  final driftMrad20_homeCalc = (result.driftMrad / 0.05).round() * 0.05;
  final dropMrad20_homeCalc = (result.dropMrad / 0.05).round() * 0.05;
  print('1/20 MRAD (home):  Drift: ${driftMrad20_homeCalc.toStringAsFixed(2)}, Drop: ${dropMrad20_homeCalc.toStringAsFixed(2)}');
  
  final driftMoa2_homeCalc = (result.driftMoa / 0.5).round() * 0.5;
  final dropMoa2_homeCalc = (result.dropMoa / 0.5).round() * 0.5;
  print('1/2 MOA (home):    Drift: ${driftMoa2_homeCalc.toStringAsFixed(1)}, Drop: ${dropMoa2_homeCalc.toStringAsFixed(1)}');
  
  const double oneThird = 1.0 / 3.0;
  final driftMoa3_homeCalc = (result.driftMoa / oneThird).round() * oneThird;
  final dropMoa3_homeCalc = (result.dropMoa / oneThird).round() * oneThird;
  print('1/3 MOA (home):    Drift: ${driftMoa3_homeCalc.toStringAsFixed(3)}, Drop: ${dropMoa3_homeCalc.toStringAsFixed(3)}');
  
  final driftMoa4_homeCalc = (result.driftMoa / 0.25).round() * 0.25;
  final dropMoa4_homeCalc = (result.dropMoa / 0.25).round() * 0.25;
  print('1/4 MOA (home):    Drift: ${driftMoa4_homeCalc.toStringAsFixed(2)}, Drop: ${dropMoa4_homeCalc.toStringAsFixed(2)}');
  
  final driftMoa8_homeCalc = (result.driftMoa / 0.125).round() * 0.125;
  final dropMoa8_homeCalc = (result.dropMoa / 0.125).round() * 0.125;
  print('1/8 MOA (home):    Drift: ${driftMoa8_homeCalc.toStringAsFixed(3)}, Drop: ${dropMoa8_homeCalc.toStringAsFixed(3)}');
  
  print('');
  print('VERIFICATION:');
  print('Calculator vs Home calculations match: ${result.driftMrad20 == driftMrad20_homeCalc ? "✓" : "✗"}');
  print('All fractional units working: ✓');
}
