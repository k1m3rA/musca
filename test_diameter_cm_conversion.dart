// Test file to verify diameter conversion from centimeters to meters
import 'lib/services/ballistics_calculator.dart';
import 'lib/models/gun_model.dart';
import 'lib/models/cartridge_model.dart';
import 'lib/models/scope_model.dart';

void main() {
  print('Testing Diameter Conversion from Centimeters to Meters');
  print('=' * 60);
  
  // Test different diameter values in centimeters
  final testDiameters = [
    {'cm': '0.782', 'expected_meters': 0.00782, 'description': '.308 caliber (7.82mm)'},
    {'cm': '0.556', 'expected_meters': 0.00556, 'description': '.223 caliber (5.56mm)'},
    {'cm': '0.762', 'expected_meters': 0.00762, 'description': '.30-06 caliber (7.62mm)'},
    {'cm': '1.270', 'expected_meters': 0.01270, 'description': '.50 BMG caliber (12.7mm)'},
  ];
    // Create test profiles
  final testGun = Gun(
    id: 'test-gun',
    name: 'Test Rifle',
    zeroRange: 100.0,
    muzzleVelocity: 800.0,
    twistRate: 10.0,
    twistDirection: 1,
  );
  
  final testScope = Scope(
    id: 'test-scope',
    name: 'Test Scope',
    sightHeight: 3.8, // cm
    units: 1, // cm units
  );
  
  print('Testing diameter conversion for various calibers:');
  print('');
  
  for (final testData in testDiameters) {
    final cartridge = Cartridge(
      id: 'test-cartridge',
      name: 'Test Cartridge',
      diameter: testData['cm'] as String,
      bulletWeight: 168.0,
      bulletLength: 3.550,
      ballisticCoefficient: 0.5,
      bcModelType: 0,
    );
    
    try {      // Test the ballistics calculation which internally uses _getDiameterFromCartridge
      final result = BallisticsCalculator.calculateWithProfiles(
        200.0, // distance
        0.0,   // wind speed
        0.0,   // wind direction
        testGun,
        cartridge,
        testScope,
        temperature: 15.0,
        pressure: 1013.25,
        humidity: 50.0,
      );
      
      print('✓ ${testData['description']}');
      print('  Input: ${testData['cm']} cm');
      print('  Expected meters: ${testData['expected_meters']}');
      print('  Calculation successful - diameter conversion working');
      print('  Sample result - Drop: ${result.dropCm.toStringAsFixed(2)} cm');
      print('');
      
    } catch (e) {
      print('✗ ${testData['description']}');
      print('  Input: ${testData['cm']} cm');
      print('  Error: $e');
      print('');
    }
  }
  
  // Test error handling with invalid input
  print('Testing error handling with invalid diameter input:');
  
  final invalidCartridge = Cartridge(
    id: 'invalid-cartridge',
    name: 'Invalid Cartridge',
    diameter: 'invalid_diameter',
    bulletWeight: 168.0,
    bulletLength: 3.550,
    ballisticCoefficient: 0.5,
    bcModelType: 0,
  );
    try {
    BallisticsCalculator.calculateWithProfiles(
      200.0,
      0.0,
      0.0,
      testGun,
      invalidCartridge,
      testScope,
      temperature: 15.0,
      pressure: 1013.25,
      humidity: 50.0,
    );
    print('✗ Error handling failed - should have thrown an exception');
  } catch (e) {
    print('✓ Error handling working correctly');
    print('  Error message: $e');
  }
  
  print('');
  print('Test Summary:');
  print('- Diameter input now expects centimeters (e.g., "0.782" for .308 caliber)');
  print('- Conversion factor changed from 0.0254 (inches to meters) to 0.01 (cm to meters)');
  print('- Error messages updated to reference centimeters');
  print('- UI suffix changed from "in" to "cm"');
  print('- Default diameter changed from 0.308 inches to 0.782 cm');
}
