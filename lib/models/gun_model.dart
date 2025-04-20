import 'dart:convert';

class Gun {
  final String id;
  final String name;
  final double twistRate;
  final int twistDirection; // 0 = left, 1 = right
  final double muzzleVelocity;
  final double zeroRange;
  
  // Constructor
  Gun({
    required this.id,
    required this.name,
    required this.twistRate,
    required this.twistDirection,
    required this.muzzleVelocity,
    required this.zeroRange,
  });

  // Create a Gun from a Map
  factory Gun.fromMap(Map<String, dynamic> map) {
    return Gun(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['name'] ?? 'My Gun',
      twistRate: map['twistRate']?.toDouble() ?? 10.0,
      twistDirection: map['twistDirection'] ?? 1,
      muzzleVelocity: map['muzzleVelocity']?.toDouble() ?? 800.0,
      zeroRange: map['zeroRange']?.toDouble() ?? 100.0,
    );
  }

  // Convert a Gun to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'twistRate': twistRate,
      'twistDirection': twistDirection,
      'muzzleVelocity': muzzleVelocity,
      'zeroRange': zeroRange,
    };
  }

  // For serialization
  String toJson() => json.encode(toMap());
  factory Gun.fromJson(String source) => Gun.fromMap(json.decode(source));

  // Create a copy of a Gun with some properties changed
  Gun copyWith({
    String? id,
    String? name,
    double? twistRate,
    int? twistDirection,
    double? muzzleVelocity,
    double? zeroRange,
  }) {
    return Gun(
      id: id ?? this.id,
      name: name ?? this.name,
      twistRate: twistRate ?? this.twistRate,
      twistDirection: twistDirection ?? this.twistDirection,
      muzzleVelocity: muzzleVelocity ?? this.muzzleVelocity,
      zeroRange: zeroRange ?? this.zeroRange,
    );
  }

  // Generate a description string for display purposes
  String getDescription() {
    final twistDirectionText = twistDirection == 0 ? 'Left' : 'Right';
    return '$twistDirectionText Twist Rate: 1:${twistRate.toStringAsFixed(1)}", '
           'MV: ${muzzleVelocity.toStringAsFixed(0)} m/s, '
           'Zero: ${zeroRange.toStringAsFixed(0)} m';
  }
}
