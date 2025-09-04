import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';
import 'api_key_service.dart';
import 'weather_api_exceptions.dart';

class WeatherData {
  final double temperature;
  final double pressure;
  final int humidity;

  WeatherData({
    required this.temperature,
    required this.pressure,
    required this.humidity,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: json['current']['temp_c'].toDouble(),
      pressure: json['current']['pressure_mb'].toDouble(),
      humidity: json['current']['humidity'].toInt(),
    );
  }
}

class WeatherService {
  /// Get weather data for the given coordinates
  static Future<WeatherData> getWeatherData(double latitude, double longitude) async {
    // First, try to get API key from app settings
    String? apiKey = await ApiKeyService.getWeatherApiKey();
    
    // If no API key in settings, fall back to config file
    if (apiKey == null || apiKey.isEmpty) {
      apiKey = ApiKeys.weatherApi;
      
      // Check if config file also has empty/default key
      if (apiKey.isEmpty || apiKey == 'YOUR_API_KEY_HERE') {
        throw WeatherApiException(
          WeatherApiError.noApiKey,
          'No Weather API key configured'
        );
      }
    }

    try {
      final response = await http.get(
        Uri.parse('http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$latitude,$longitude&aqi=no'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherData.fromJson(data);
      } else {
        // Handle specific HTTP error codes
        switch (response.statusCode) {
          case 401:
            throw WeatherApiException(
              WeatherApiError.invalidApiKey,
              'Invalid or expired API key',
              statusCode: response.statusCode
            );
          case 400:
            throw WeatherApiException(
              WeatherApiError.locationError,
              'Invalid location coordinates',
              statusCode: response.statusCode
            );
          case 403:
            throw WeatherApiException(
              WeatherApiError.invalidApiKey,
              'API key access denied or quota exceeded',
              statusCode: response.statusCode
            );
          case 429:
            throw WeatherApiException(
              WeatherApiError.serverError,
              'API rate limit exceeded. Please try again later.',
              statusCode: response.statusCode
            );
          case 500:
          case 502:
          case 503:
            throw WeatherApiException(
              WeatherApiError.serverError,
              'Weather service temporarily unavailable',
              statusCode: response.statusCode
            );
          default:
            throw WeatherApiException(
              WeatherApiError.unknown,
              'HTTP ${response.statusCode}: ${response.reasonPhrase}',
              statusCode: response.statusCode
            );
        }
      }
    } on WeatherApiException {
      rethrow; // Re-throw our custom exceptions
    } catch (e) {
      // Handle network and other errors
      if (e.toString().contains('TimeoutException') || 
          e.toString().contains('SocketException') ||
          e.toString().contains('HandshakeException')) {
        throw WeatherApiException(
          WeatherApiError.networkError,
          'Failed to connect to weather service'
        );
      } else {
        throw WeatherApiException(
          WeatherApiError.unknown,
          e.toString()
        );
      }
    }
  }

  /// Check if weather API is properly configured
  static Future<bool> isApiConfigured() async {
    final settingsApiKey = await ApiKeyService.getWeatherApiKey();
    final configApiKey = ApiKeys.weatherApi;
    
    return (settingsApiKey != null && settingsApiKey.isNotEmpty) || 
           (configApiKey.isNotEmpty && configApiKey != 'YOUR_API_KEY_HERE');
  }

  /// Get the current API key being used (prioritizes settings over config)
  static Future<String?> getCurrentApiKey() async {
    final settingsApiKey = await ApiKeyService.getWeatherApiKey();
    if (settingsApiKey != null && settingsApiKey.isNotEmpty) {
      return settingsApiKey;
    }
    
    final configApiKey = ApiKeys.weatherApi;
    if (configApiKey.isNotEmpty && configApiKey != 'YOUR_API_KEY_HERE') {
      return configApiKey;
    }
    
    return null;
  }
}
