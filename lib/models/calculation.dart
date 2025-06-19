class Calculation {
  final double distance;
  final double angle;
  final double windSpeed;
  final double windDirection;
  final DateTime timestamp;  final double temperature;
  final double pressure;
  final double humidity;
  final double latitude; // Add latitude field

  // Add ballistics results
  final double? driftHorizontal;
  final double? dropVertical;
  final double? driftMrad;
  final double? dropMrad;
  final double? driftMoa;
  final double? dropMoa;
  Calculation({
    required this.distance,
    required this.angle,
    required this.windSpeed,
    required this.windDirection,
    DateTime? timestamp,
    this.temperature = 20.0,  // Default values for environmental data
    this.pressure = 1013.0,
    this.humidity = 50.0,
    this.latitude = 0.0, // Default latitude
    this.driftHorizontal,
    this.dropVertical,
    this.driftMrad,
    this.dropMrad,
    this.driftMoa,
    this.dropMoa,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'distance': distance,
      'angle': angle,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'timestamp': timestamp.toIso8601String(),      'temperature': temperature,
      'pressure': pressure,
      'humidity': humidity,
      'latitude': latitude, // Add latitude to JSON
      'driftHorizontal': driftHorizontal,
      'dropVertical': dropVertical,
      'driftMrad': driftMrad,
      'dropMrad': dropMrad,
      'driftMoa': driftMoa,
      'dropMoa': dropMoa,
    };
  }

  // Create from JSON data
  factory Calculation.fromJson(Map<String, dynamic> json) {
    return Calculation(
      distance: json['distance'],
      angle: json['angle'],
      windSpeed: json['windSpeed'],
      windDirection: json['windDirection'],
      timestamp: DateTime.parse(json['timestamp']),      temperature: json['temperature'] ?? 20.0,
      pressure: json['pressure'] ?? 1013.0,
      humidity: json['humidity'] ?? 50.0,
      latitude: json['latitude'] ?? 0.0, // Add latitude from JSON with default
      driftHorizontal: json['driftHorizontal']?.toDouble(),
      dropVertical: json['dropVertical']?.toDouble(),
      driftMrad: json['driftMrad']?.toDouble(),
      dropMrad: json['dropMrad']?.toDouble(),
      driftMoa: json['driftMoa']?.toDouble(),
      dropMoa: json['dropMoa']?.toDouble(),
    );
  }
  Calculation copyWith({
    double? distance,
    double? angle,
    double? windSpeed,
    double? windDirection,
    DateTime? timestamp,
    double? temperature,
    double? pressure,
    double? humidity,
    double? latitude, // Add latitude parameter
    double? driftHorizontal,
    double? dropVertical,
    double? driftMrad,
    double? dropMrad,
    double? driftMoa,
    double? dropMoa,
  }) {
    return Calculation(
      distance: distance ?? this.distance,
      angle: angle ?? this.angle,
      windSpeed: windSpeed ?? this.windSpeed,
      windDirection: windDirection ?? this.windDirection,
      timestamp: timestamp ?? this.timestamp,
      temperature: temperature ?? this.temperature,
      pressure: pressure ?? this.pressure,
      humidity: humidity ?? this.humidity,
      latitude: latitude ?? this.latitude, // Add latitude field
      driftHorizontal: driftHorizontal ?? this.driftHorizontal,
      dropVertical: dropVertical ?? this.dropVertical,
      driftMrad: driftMrad ?? this.driftMrad,
      dropMrad: dropMrad ?? this.dropMrad,
      driftMoa: driftMoa ?? this.driftMoa,
      dropMoa: dropMoa ?? this.dropMoa,
    );
  }
}
