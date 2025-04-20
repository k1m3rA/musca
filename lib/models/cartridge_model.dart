import 'package:uuid/uuid.dart';

class Cartridge {
  final String id;
  final String name;
  final String caliber;
  final double bulletWeight; // in grains
  final double muzzleVelocity; // in fps
  final double ballisticCoefficient;
  
  Cartridge({
    required this.id,
    required this.name,
    required this.caliber,
    required this.bulletWeight,
    required this.muzzleVelocity,
    required this.ballisticCoefficient,
  });
  
  String getDescription() {
    return '$caliber - ${bulletWeight}gr - ${muzzleVelocity}fps';
  }
  
  // Factory constructor for creating from JSON
  factory Cartridge.fromJson(Map<String, dynamic> json) {
    return Cartridge(
      id: json['id'] ?? Uuid().v4(),
      name: json['name'] ?? '',
      caliber: json['caliber'] ?? '',
      bulletWeight: json['bulletWeight']?.toDouble() ?? 0.0,
      muzzleVelocity: json['muzzleVelocity']?.toDouble() ?? 0.0,
      ballisticCoefficient: json['ballisticCoefficient']?.toDouble() ?? 0.0,
    );
  }
  
  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'caliber': caliber,
      'bulletWeight': bulletWeight,
      'muzzleVelocity': muzzleVelocity,
      'ballisticCoefficient': ballisticCoefficient,
    };
  }
}
