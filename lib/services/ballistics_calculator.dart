import 'dart:math';

class BallisticsResult {
  final double driftHorizontal; // meters
  final double dropVertical; // meters
  final double driftMrad; // milliradians
  final double dropMrad; // milliradians
  final double driftMoa; // minutes of angle
  final double dropMoa; // minutes of angle

  BallisticsResult({
    required this.driftHorizontal,
    required this.dropVertical,
    required this.driftMrad,
    required this.dropMrad,
    required this.driftMoa,
    required this.dropMoa,
  });
}

class BallisticsCalculator {
  // Projectile .308 Winchester constants
  static const double mass = 0.00972; // kg (150 grains)
  static const double diameter = 0.00782; // m
  static const double length = 0.02032; // m (800 grains)
  static const double ballisticCoefficient = 0.504; // G1
  
  // Environment constants
  static const double temperature = 15.0; // °C at sea level
  static const double rhoAir = 1.225; // kg/m³
  static const double humidity = 0.5; // fraction (50%)
  static const double pressure = 101325.0; // Pa (sea level)
  
  // Rifle constants
  static const double twistRate = 1 / 0.3048; // rev/m (1 turn in 12")
  static const int twistDirection = 1; // 1: clockwise (right), -1: counterclockwise (left)
  static const double elevationAngle = 0.0; // rad
  static const double azimuthAngle = 0.0; // rad
  
  // Simulation parameters
  static const double dt = 0.001; // s
  static const double omega = 7.292115e-5; // rad/s (Earth rotation)
  static const double latitude = 0.0; // degrees North

  static double speedOfSound(double tC) {
    return 20.05 * sqrt(tC + 273.15);
  }

  static double g1BallisticCoefficient(double mach) {
    final machValues = [
      0.00, 0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40, 0.45,
      0.50, 0.55, 0.60, 0.70, 0.725, 0.75, 0.775, 0.80, 0.825, 0.85,
      0.875, 0.90, 0.925, 0.95, 0.975, 1.0, 1.025, 1.05, 1.075, 1.10,
      1.125, 1.15, 1.20, 1.25, 1.30, 1.35, 1.40, 1.45, 1.50, 1.55,
      1.60, 1.65, 1.70, 1.75, 1.80, 1.85, 1.90, 1.95, 2.00, 2.05,
      2.10, 2.15, 2.20, 2.25, 2.30, 2.35, 2.40, 2.45, 2.50, 2.60,
      2.70, 2.80, 2.90, 3.00, 3.10, 3.20, 3.30, 3.40, 3.50, 3.60,
      3.70, 3.80, 3.90, 4.00, 4.20, 4.40, 4.60, 4.80, 5.00
    ];
    
    final g1DragCoeffValues = [
      0.2629, 0.2558, 0.2487, 0.2413, 0.2344, 0.2278, 0.2214, 0.2155, 0.2104, 0.2061,
      0.2032, 0.2020, 0.2034, 0.2165, 0.2230, 0.2313, 0.2417, 0.2546, 0.2706, 0.2901,
      0.3136, 0.3415, 0.3734, 0.4084, 0.4448, 0.4805, 0.5136, 0.5427, 0.5677, 0.5883,
      0.6053, 0.6191, 0.6393, 0.6518, 0.6589, 0.6621, 0.6625, 0.6607, 0.6573, 0.6528,
      0.6474, 0.6413, 0.6347, 0.6280, 0.6210, 0.6141, 0.6072, 0.6003, 0.5934, 0.5867,
      0.5804, 0.5743, 0.5685, 0.5630, 0.5577, 0.5527, 0.5481, 0.5438, 0.5397, 0.5325,
      0.5264, 0.5211, 0.5168, 0.5133, 0.5105, 0.5084, 0.5067, 0.5054, 0.5040, 0.5030,
      0.5022, 0.5016, 0.5010, 0.5006, 0.4998, 0.4995, 0.4992, 0.4990, 0.4988
    ];
    
    // Linear interpolation
    for (int i = 0; i < machValues.length - 1; i++) {
      if (mach >= machValues[i] && mach <= machValues[i + 1]) {
        final t = (mach - machValues[i]) / (machValues[i + 1] - machValues[i]);
        return g1DragCoeffValues[i] + t * (g1DragCoeffValues[i + 1] - g1DragCoeffValues[i]);
      }
    }
    
    return g1DragCoeffValues.last;
  }

  static double gravity(double latDeg, double altM) {
    const double Re = 6378137.0; // m
    final double phi = latDeg * pi / 180;
    final double sinPhi = sin(phi);
    final double sin2Phi = sinPhi * sinPhi;
    final double sin4Phi = sin2Phi * sin2Phi;
    final double sin6Phi = sin2Phi * sin2Phi * sin2Phi;
    final double sin8Phi = sin2Phi * sin2Phi * sin2Phi * sin2Phi;

    final double gamma = 9.7803267715 * (1 + 0.0052790414 * sin2Phi + 0.0000232718 * sin4Phi + 0.0000001262 * sin6Phi + 0.0000000007 * sin8Phi);
    
    double deltaGA = 0.874 - 9.9e-5 * altM + 3.56e-9 * altM * altM;
    deltaGA /= 1000.0; // mGal to m/s²

    final double g = gamma * pow(Re / (Re + altM), 2) + deltaGA;
    return g;
  }

  static BallisticsResult calculate(double distance, double windSpeed, double windDirection) {
    // Convert wind direction to wind vector (simplified)
    final double windX = windSpeed * cos(windDirection * pi / 180);
    final double windY = windSpeed * sin(windDirection * pi / 180);
    final List<double> windVector = [windX, windY, 0.0];
    
    // Initial state
    List<double> pos = [0.0, 0.0, 0.0];
    const double speed = 820.0; // m/s
    List<double> vel = [speed * cos(elevationAngle), 0.0, speed * sin(elevationAngle)];
    
    double? driftH;
    double? dropZ;
    
    // Area
    const double A = pi * (diameter / 2) * (diameter / 2);
    
    for (int step = 0; step < (30.0 / dt).round(); step++) {
      // Local conditions
      final double tLoc = temperature - 0.0065 * pos[2];
      final double a = speedOfSound(tLoc);
      final double gLoc = gravity(latitude, pos[2]);
      
      // Relative velocity to air
      final List<double> vRel = [
        vel[0] - windVector[0],
        vel[1] - windVector[1],
        vel[2] - windVector[2]
      ];
      
      final double vMagnitude = sqrt(vRel[0] * vRel[0] + vRel[1] * vRel[1] + vRel[2] * vRel[2]);
      final double mach = vMagnitude / a;
      
      // Updated coefficients
      final double CD = g1BallisticCoefficient(mach) * ballisticCoefficient;
      
      // Drag force
      final double dragMagnitude = 0.5 * rhoAir * A * CD * vMagnitude * vMagnitude;
      final List<double> dragForce = [
        -dragMagnitude * (vRel[0] / vMagnitude),
        -dragMagnitude * (vRel[1] / vMagnitude),
        -dragMagnitude * (vRel[2] / vMagnitude)
      ];
      
      // Gravity force
      final List<double> gravityForce = [0.0, 0.0, -mass * gLoc];
      
      // Total force (simplified - only drag and gravity for basic calculation)
      final List<double> totalForce = [
        gravityForce[0] + dragForce[0],
        gravityForce[1] + dragForce[1],
        gravityForce[2] + dragForce[2]
      ];
      
      // Euler integration
      final List<double> acc = [
        totalForce[0] / mass,
        totalForce[1] / mass,
        totalForce[2] / mass
      ];
      
      vel[0] += acc[0] * dt;
      vel[1] += acc[1] * dt;
      vel[2] += acc[2] * dt;
      
      pos[0] += vel[0] * dt;
      pos[1] += vel[1] * dt;
      pos[2] += vel[2] * dt;
      
      if (pos[0] >= distance) {
        driftH = pos[1];
        dropZ = pos[2];
        break;
      }
    }
    
    // Calculate adjustments
    final double driftMrad = (driftH ?? 0) / distance * 1000;
    final double dropMrad = (dropZ ?? 0) / distance * 1000;
    
    // Convert to MOA (1 MOA = 1/3.438 mrad approximately)
    final double driftMoa = driftMrad / 0.290888;
    final double dropMoa = dropMrad / 0.290888;
    
    return BallisticsResult(
      driftHorizontal: driftH ?? 0,
      dropVertical: dropZ ?? 0,
      driftMrad: driftMrad,
      dropMrad: dropMrad,
      driftMoa: driftMoa,
      dropMoa: dropMoa,
    );
  }
}
