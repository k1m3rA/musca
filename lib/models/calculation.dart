class Calculation {
  final double distance;
  final double angle;
  final double windSpeed;
  final double windDirection;
  final DateTime timestamp;
  final double temperature;
  final double pressure;
  final double humidity;

  Calculation({
    required this.distance,
    required this.angle,
    required this.windSpeed,
    required this.windDirection,
    DateTime? timestamp,
    this.temperature = 20.0,  // Default values for environmental data
    this.pressure = 1013.0,
    this.humidity = 50.0,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'distance': distance,
      'angle': angle,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'timestamp': timestamp.toIso8601String(),
      'temperature': temperature,
      'pressure': pressure,
      'humidity': humidity,
    };
  }

  // Create from JSON data
  factory Calculation.fromJson(Map<String, dynamic> json) {
    return Calculation(
      distance: json['distance'],
      angle: json['angle'],
      windSpeed: json['windSpeed'],
      windDirection: json['windDirection'],
      timestamp: DateTime.parse(json['timestamp']),
      temperature: json['temperature'] ?? 20.0,
      pressure: json['pressure'] ?? 1013.0,
      humidity: json['humidity'] ?? 50.0,
    );
  }
}
