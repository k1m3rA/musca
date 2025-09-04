import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyService {
  static const String _weatherApiKeyKey = 'weather_api_key';
  
  /// Get the stored weather API key
  static Future<String?> getWeatherApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_weatherApiKeyKey);
  }
  
  /// Save the weather API key
  static Future<bool> saveWeatherApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_weatherApiKeyKey, apiKey);
  }
  
  /// Remove the stored weather API key
  static Future<bool> removeWeatherApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_weatherApiKeyKey);
  }
  
  /// Check if weather API key is configured
  static Future<bool> hasWeatherApiKey() async {
    final apiKey = await getWeatherApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }
}
