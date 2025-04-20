import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cartridge_model.dart';

class CartridgeStorage {
  static const String _cartridgesKey = 'saved_cartridges';
  static const String _selectedCartridgeKey = 'selected_cartridge';

  // Save all cartridges
  static Future<void> saveCartridges(List<Cartridge> cartridges) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = cartridges.map((cartridge) => cartridge.toJson()).toList();
    await prefs.setString(_cartridgesKey, jsonEncode(jsonList));
  }
  
  // Get all saved cartridges
  static Future<List<Cartridge>> getCartridges() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cartridgesKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Cartridge.fromJson(json)).toList();
    } catch (e) {
      print('Error loading cartridges: $e');
      return [];
    }
  }
  
  // Save a single cartridge (adds or updates)
  static Future<void> saveCartridge(Cartridge cartridge) async {
    List<Cartridge> cartridges = await getCartridges();
    
    // Find and update existing cartridge or add new one
    final index = cartridges.indexWhere((c) => c.id == cartridge.id);
    if (index >= 0) {
      cartridges[index] = cartridge;
    } else {
      cartridges.add(cartridge);  // Fixed missing closing parenthesis
    }
    
    await saveCartridges(cartridges);
  }
  
  // Delete a cartridge by ID
  static Future<bool> deleteCartridge(String cartridgeId) async {
    List<Cartridge> cartridges = await getCartridges();
    
    final initialCount = cartridges.length;
    cartridges.removeWhere((cartridge) => cartridge.id == cartridgeId);
    
    if (cartridges.length == initialCount) {
      return false; // Nothing was deleted
    }
    
    await saveCartridges(cartridges);
    return true;
  }
  
  // Clear all saved cartridges
  static Future<void> clearAllCartridges() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cartridgesKey, '');
  }

  // Save selected cartridge ID
  static Future<void> saveSelectedCartridgeId(String? cartridgeId) async {
    final prefs = await SharedPreferences.getInstance();
    if (cartridgeId == null) {
      await prefs.remove(_selectedCartridgeKey);
    } else {
      await prefs.setString(_selectedCartridgeKey, cartridgeId);
    }
  }
  
  // Get selected cartridge ID
  static Future<String?> getSelectedCartridgeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedCartridgeKey);
  }
  
  // Get selected cartridge object
  static Future<Cartridge?> getSelectedCartridge() async {
    final selectedId = await getSelectedCartridgeId();
    if (selectedId == null) {
      return null;
    }
    
    final cartridges = await getCartridges();
    try {
      return cartridges.firstWhere(
        (cartridge) => cartridge.id == selectedId,
      );
    } catch (e) {
      // If no cartridge matches the ID, return null
      return null;
    }
  }
}
