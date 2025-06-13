import 'package:uuid/uuid.dart';

class Cartridge {
  final String id;
  final String name;
  final String diameter;
  final double bulletWeight; // in grains
  final double bulletLength; // in fps
  final double ballisticCoefficient;
  final int? bcModelType; // Add bcModelType field (0 for G1, 1 for G7)

  // Time of Flight (ToF) polynomial correction coefficients
  // ToF_adjusted = a0 + a1*t + a2*t² + a3*t³
  final double? tofA0; // Constant term (typically 1.0)
  final double? tofA1; // Linear coefficient
  final double? tofA2; // Quadratic coefficient
  final double? tofA3; // Cubic coefficient

  Cartridge({
    required this.id,
    required this.name,
    required this.diameter,
    required this.bulletWeight,
    required this.bulletLength,
    required this.ballisticCoefficient,
    this.bcModelType, // Add to constructor (optional with default null)
    this.tofA0, // Default: 1.0 (no correction)
    this.tofA1, // Default: 0.0 (no correction)
    this.tofA2, // Default: 0.0 (no correction)
    this.tofA3, // Default: 0.0 (no correction)
  });

  String getDescription() {
    return '$diameter - ${bulletWeight}gr - ${bulletLength}fps';
  }

  // Factory constructor for creating from JSON
  factory Cartridge.fromJson(Map<String, dynamic> json) {
    return Cartridge(
      id: json['id'] ?? Uuid().v4(),
      name: json['name'] ?? '',
      diameter: json['diameter'] ?? '',
      bulletWeight: json['bulletWeight']?.toDouble() ?? 0.0,
      bulletLength: json['bulletLength'] ?? '',
      ballisticCoefficient: json['ballisticCoefficient']?.toDouble() ?? 0.0,
      bcModelType: json['bcModelType'], // Add field to from JSON conversion
      tofA0: json['tofA0'] != null ? (json['tofA0'] as num).toDouble() : null,
      tofA1: json['tofA1'] != null ? (json['tofA1'] as num).toDouble() : null,
      tofA2: json['tofA2'] != null ? (json['tofA2'] as num).toDouble() : null,
      tofA3: json['tofA3'] != null ? (json['tofA3'] as num).toDouble() : null,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'diameter': diameter,
      'bulletWeight': bulletWeight,
      'bulletLength': bulletLength,
      'ballisticCoefficient': ballisticCoefficient,
      'bcModelType': bcModelType, // Add field to JSON conversion
      'tofA0': tofA0,
      'tofA1': tofA1,
      'tofA2': tofA2,
      'tofA3': tofA3,
    };
  }

  // Add copyWith method
  Cartridge copyWith({
    String? id,
    String? name,
    String? diameter,
    double? bulletWeight,
    double? bulletLength,
    double? ballisticCoefficient,
    int? bcModelType, // Add field to copyWith method
    double? tofA0,
    double? tofA1,
    double? tofA2,
    double? tofA3,
  }) {
    return Cartridge(
      id: id ?? this.id,
      name: name ?? this.name,
      diameter: diameter ?? this.diameter,
      bulletWeight: bulletWeight ?? this.bulletWeight,
      bulletLength: bulletLength ?? this.bulletLength,
      ballisticCoefficient: ballisticCoefficient ?? this.ballisticCoefficient,
      bcModelType: bcModelType ?? this.bcModelType, // Use the new field in copyWith
      tofA0: tofA0 ?? this.tofA0,
      tofA1: tofA1 ?? this.tofA1,
      tofA2: tofA2 ?? this.tofA2,
      tofA3: tofA3 ?? this.tofA3,
    );
  }
}
