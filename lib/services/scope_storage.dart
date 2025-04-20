import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scope_model.dart';

class ScopeStorage {
  static const String _scopesKey = 'saved_scopes';
  static const String _selectedScopeKey = 'selected_scope';

  // Save all scopes
  static Future<void> saveScopes(List<Scope> scopes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = scopes.map((scope) => scope.toJson()).toList();
    await prefs.setString(_scopesKey, jsonEncode(jsonList));
  }
  
  // Get all saved scopes
  static Future<List<Scope>> getScopes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_scopesKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Scope.fromJson(json)).toList();
    } catch (e) {
      print('Error loading scopes: $e');
      return [];
    }
  }
  
  // Save a single scope (adds or updates)
  static Future<void> saveScope(Scope scope) async {
    List<Scope> scopes = await getScopes();
    
    // Find and update existing scope or add new one
    final index = scopes.indexWhere((c) => c.id == scope.id);
    if (index >= 0) {
      scopes[index] = scope;
    } else {
      scopes.add(scope);
    }
    
    await saveScopes(scopes);
  }
  
  // Delete a scope by ID
  static Future<bool> deleteScope(String scopeId) async {
    List<Scope> scopes = await getScopes();
    
    final initialCount = scopes.length;
    scopes.removeWhere((scope) => scope.id == scopeId);
    
    if (scopes.length == initialCount) {
      return false; // Nothing was deleted
    }
    
    await saveScopes(scopes);
    return true;
  }
  
  // Clear all saved scopes
  static Future<void> clearAllScopes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scopesKey, '');
  }

  // Save selected scope ID
  static Future<void> saveSelectedScopeId(String? scopeId) async {
    final prefs = await SharedPreferences.getInstance();
    if (scopeId == null) {
      await prefs.remove(_selectedScopeKey);
    } else {
      await prefs.setString(_selectedScopeKey, scopeId);
    }
  }
  
  // Get selected scope ID
  static Future<String?> getSelectedScopeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedScopeKey);
  }
  
  // Get selected scope object
  static Future<Scope?> getSelectedScope() async {
    final selectedId = await getSelectedScopeId();
    if (selectedId == null) {
      return null;
    }
    
    final scopes = await getScopes();
    try {
      return scopes.firstWhere(
        (scope) => scope.id == selectedId,
      );
    } catch (e) {
      // If no scope matches the ID, return null
      return null;
    }
  }
}
