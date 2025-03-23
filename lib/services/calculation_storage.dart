import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculation.dart';

class CalculationStorage {
  static const String _storageKey = 'saved_calculations';

  // Save a calculation to storage
  static Future<void> saveCalculation(Calculation calculation) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing calculations
    List<Calculation> calculations = await getCalculations();
    
    // Add new calculation
    calculations.add(calculation);
    
    // Convert to list of JSON objects
    final jsonList = calculations.map((calc) => calc.toJson()).toList();
    
    // Save as JSON string
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  // Get all saved calculations
  static Future<List<Calculation>> getCalculations() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get JSON string
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    // Parse JSON and convert to calculations
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Calculation.fromJson(json)).toList();
    } catch (e) {
      print('Error parsing saved calculations: $e');
      return [];
    }
  }

  // Clear all saved calculations
  static Future<void> clearAllCalculations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, '');
  }

  // Delete a specific calculation by matching properties
  static Future<bool> deleteCalculation(Calculation calculationToDelete) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing calculations
    List<Calculation> calculations = await getCalculations();
    
    // Find and remove the calculation
    final initialCount = calculations.length;
    calculations.removeWhere((calc) => 
      calc.distance == calculationToDelete.distance &&
      calc.angle == calculationToDelete.angle &&
      calc.windSpeed == calculationToDelete.windSpeed &&
      calc.windDirection == calculationToDelete.windDirection &&
      calc.timestamp.isAtSameMomentAs(calculationToDelete.timestamp)
    );
    
    // Check if we removed anything
    if (calculations.length == initialCount) {
      return false; // Nothing was deleted
    }
    
    // Convert to list of JSON objects
    final jsonList = calculations.map((calc) => calc.toJson()).toList();
    
    // Save the updated list
    await prefs.setString(_storageKey, jsonEncode(jsonList));
    return true; // Successfully deleted
  }
}
