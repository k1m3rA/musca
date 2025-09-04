enum WeatherApiError {
  noApiKey,
  invalidApiKey,
  networkError,
  serverError,
  locationError,
  unknown
}

class WeatherApiException implements Exception {
  final WeatherApiError type;
  final String message;
  final int? statusCode;

  WeatherApiException(this.type, this.message, {this.statusCode});

  @override
  String toString() {
    switch (type) {
      case WeatherApiError.noApiKey:
        return 'No API key configured. Please configure your Weather API key in Settings.';
      case WeatherApiError.invalidApiKey:
        return 'Invalid API key. Please check your Weather API key in Settings.';
      case WeatherApiError.networkError:
        return 'Network error. Please check your internet connection.';
      case WeatherApiError.serverError:
        return 'Weather service unavailable. Please try again later.';
      case WeatherApiError.locationError:
        return 'Location not found. Please check your location permissions.';
      case WeatherApiError.unknown:
        return 'Unknown error: $message';
    }
  }
}
