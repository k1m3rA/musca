import 'package:uuid/uuid.dart';

class Scope {
  final String id;
  final String name;
  final double sightHeight; // in inches or cm
  final int units; // 0 for inches, 1 for cm

  Scope({
    required this.id,
    required this.name,
    required this.sightHeight,
    required this.units,
  });

  String getDescription() {
    final String unitsLabel = units == 0 ? 'in' : 'cm';
    return 'Sight Height: ${sightHeight.toStringAsFixed(2)} $unitsLabel';
  }

  String getUnitsDisplayName() {
    switch(units) {
      case 0: return 'Inches';
      case 1: return 'Centimeters';
      case 2: return 'MOA';
      case 3: return '1/2 MOA';
      case 4: return '1/3 MOA';
      case 5: return '1/4 MOA';
      case 6: return '1/8 MOA';
      case 7: return 'MRAD';
      case 8: return '1/10 MRAD';
      case 9: return '1/20 MRAD';
      default: return 'MOA';
    }
  }

  // Factory constructor for creating from JSON
  factory Scope.fromJson(Map<String, dynamic> json) {
    return Scope(
      id: json['id'] ?? const Uuid().v4(),
      name: json['name'] ?? '',
      sightHeight: json['sightHeight']?.toDouble() ?? 0.0,
      units: json['units'] ?? 2, // Default to MOA (2)
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sightHeight': sightHeight,
      'units': units,
    };
  }

  // Add copyWith method
  Scope copyWith({
    String? id,
    String? name,
    double? sightHeight,
    int? units,
  }) {
    return Scope(
      id: id ?? this.id,
      name: name ?? this.name,
      sightHeight: sightHeight ?? this.sightHeight,
      units: units ?? this.units,
    );
  }
}
