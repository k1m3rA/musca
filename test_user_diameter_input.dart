// Test script to verify user-input diameter handling
// Run with: dart run test_user_diameter_input.dart

import 'lib/services/ballistics_calculator.dart';
import 'lib/models/gun_model.dart';
import 'lib/models/cartridge_model.dart';
import 'lib/models/scope_model.dart';

void main() async {
  print('=== USER DIAMETER INPUT TEST ===\n');
  
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
  
  // Test with valid diameter inputs
  final testCases = [
    {'diameter': '0.308', 'description': '.308 Winchester'},
    {'diameter': '0.223', 'description': '.223 Remington'},
    {'diameter': '0.243', 'description': '.243 Winchester'},
    {'diameter': '0.270', 'description': '.270 Winchester'},
    {'diameter': '0.300', 'description': '.300 Winchester Magnum'},
  ];
  
  print('TESTING VALID DIAMETER INPUTS:');
  
  for (var testCase in testCases) {
    final cartridge = Cartridge(
      id: 'test-cartridge-${testCase['diameter']}',
      name: 'Test ${testCase['description']}',
      diameter: testCase['diameter']!,
      bulletWeight: 150.0,
      bulletLength: 0.0,
      ballisticCoefficient: 0.450,
      bcModelType: 0,
    );
    
    try {
      final result = BallisticsCalculator.calculateWithProfiles(
        300.0, 5.0, 90.0,
        testGun, cartridge, testScope,
        temperature: 15.0, pressure: 1013.25, humidity: 50.0,
      );
      
      print('✅ ${testCase['description']} (${testCase['diameter']}"): Drift=${result.driftMrad.toStringAsFixed(2)}, Drop=${result.dropMrad.toStringAsFixed(2)}');
    } catch (e) {
      print('❌ ${testCase['description']} (${testCase['diameter']}"): ERROR - $e');
    }
  }
  
  print('\nTESTING INVALID DIAMETER INPUTS:');
  
  // Test with invalid diameter inputs
  final invalidCases = [
    'abc',      // Non-numeric
    '',         // Empty
    '.308',     // With dot prefix (should fail)
    '308',      // Without decimal point (large number)
  ];
  
  for (var invalidDiameter in invalidCases) {
    final cartridge = Cartridge(
      id: 'test-invalid-cartridge',
      name: 'Test Invalid Cartridge',
      diameter: invalidDiameter,
      bulletWeight: 150.0,
      bulletLength: 0.0,
      ballisticCoefficient: 0.450,
      bcModelType: 0,
    );
    
    try {
      final result = BallisticsCalculator.calculateWithProfiles(
        300.0, 5.0, 90.0,
        testGun, cartridge, testScope,
        temperature: 15.0, pressure: 1013.25, humidity: 50.0,
      );
      
      print('❌ Invalid diameter "$invalidDiameter" should have failed but calculated: Drift=${result.driftMrad.toStringAsFixed(2)}');
    } catch (e) {
      print('✅ Invalid diameter "$invalidDiameter" correctly rejected: ${e.toString().split(': ')[1]}');
    }
  }
  
  print('\n=== TEST COMPLETED ===');
  print('Now users must enter correct diameter values in inches (e.g., "0.308")');
  print('The system no longer makes assumptions based on cartridge names.');
}
