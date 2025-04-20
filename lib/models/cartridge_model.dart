import 'package:uuid/uuid.dart';

class Cartridge {
  final String id;
  final String name;
  final String diameter;
  final double bulletWeight; // in grains
  final double bulletLength; // in fps
  final double ballisticCoefficient;
  final int? bcModelType; // Add bcModelType field (0 for G1, 1 for G7)

  Cartridge({
    required this.id,
    required this.name,
    required this.diameter,
    required this.bulletWeight,
    required this.bulletLength,
    required this.ballisticCoefficient,
    this.bcModelType, // Add to constructor (optional with default null)
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
  }) {
    return Cartridge(
      id: id ?? this.id,
      name: name ?? this.name,
      diameter: diameter ?? this.diameter,
      bulletWeight: bulletWeight ?? this.bulletWeight,
      bulletLength: bulletLength ?? this.bulletLength,
      ballisticCoefficient: ballisticCoefficient ?? this.ballisticCoefficient,
      bcModelType: bcModelType ?? this.bcModelType, // Use the new field in copyWith
    );
  }
}
