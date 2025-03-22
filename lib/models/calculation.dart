
class Calculation {
  final double distance;
  final double angle;
  final double windSpeed;
  final double windDirection;
  final DateTime timestamp;

  Calculation({
    required this.distance,
    required this.angle,
    required this.windSpeed,
    required this.windDirection,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'distance': distance,
      'angle': angle,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'timestamp': timestamp.toIso8601String(),
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
    );
  }
}
