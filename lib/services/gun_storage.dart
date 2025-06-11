import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gun_model.dart';

class GunStorage {
  static const String _gunsKey = 'saved_guns';
  static const String _selectedGunKey = 'selected_gun';

  // Save all guns
  static Future<void> saveGuns(List<Gun> guns) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = guns.map((gun) => gun.toJson()).toList();
    await prefs.setString(_gunsKey, jsonEncode(jsonList));
  }
  
  // Get all saved guns
  static Future<List<Gun>> getGuns() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_gunsKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Gun.fromJson(json)).toList();
    } catch (e) {
      print('Error loading guns: $e');
      return [];
    }
  }
  
  // Save a single gun (adds or updates)
  static Future<void> saveGun(Gun gun) async {
    List<Gun> guns = await getGuns();
    
    // Find and update existing gun or add new one
    final index = guns.indexWhere((g) => g.id == gun.id);
    if (index >= 0) {
      guns[index] = gun;
    } else {
      guns.add(gun);
    }
    
    await saveGuns(guns);
  }
  
  // Delete a gun by ID
  static Future<bool> deleteGun(String gunId) async {
    List<Gun> guns = await getGuns();
    
    final initialCount = guns.length;
    guns.removeWhere((gun) => gun.id == gunId);
    
    if (guns.length == initialCount) {
      return false; // Nothing was deleted
    }
    
    await saveGuns(guns);
    return true;
  }
  
  // Clear all saved guns
  static Future<void> clearAllGuns() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gunsKey, '');
  }

  // Save selected gun ID
  static Future<void> saveSelectedGunId(String? gunId) async {
    final prefs = await SharedPreferences.getInstance();
    if (gunId == null) {
      await prefs.remove(_selectedGunKey);
    } else {
      await prefs.setString(_selectedGunKey, gunId);
    }
  }
  
  // Get selected gun ID
  static Future<String?> getSelectedGunId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedGunKey);
  }
  
  // Get selected gun object
  static Future<Gun?> getSelectedGun() async {
    final selectedId = await getSelectedGunId();
    if (selectedId == null) {
      return null;
    }
    
    final guns = await getGuns();
    try {
      return guns.firstWhere(
        (gun) => gun.id == selectedId,
      );
    } catch (e) {
      // If no gun matches the ID, return null
      return null;
    }
  }
}
