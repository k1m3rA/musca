import 'dart:math';
import '../models/gun_model.dart';
import '../models/cartridge_model.dart';
import '../models/scope_model.dart';

class BallisticsResult {
  // Raw displacement values
  final double driftHorizontal; // meters
  final double dropVertical; // meters
  
  // MRAD corrections
  final double driftMrad; // milliradians
  final double dropMrad; // milliradians
  final double driftMrad20; // 1/20 MRAD (0.05 MRAD increments)
  final double dropMrad20; // 1/20 MRAD (0.05 MRAD increments)
  
  // MOA corrections
  final double driftMoa; // minutes of angle
  final double dropMoa; // minutes of angle
  final double driftMoa2; // 1/2 MOA (0.5 MOA increments)
  final double dropMoa2; // 1/2 MOA (0.5 MOA increments)
  final double driftMoa3; // 1/3 MOA (0.333... MOA increments)
  final double dropMoa3; // 1/3 MOA (0.333... MOA increments)
  final double driftMoa4; // 1/4 MOA (0.25 MOA increments)
  final double dropMoa4; // 1/4 MOA (0.25 MOA increments)
  final double driftMoa8; // 1/8 MOA (0.125 MOA increments)
  final double dropMoa8; // 1/8 MOA (0.125 MOA increments)
  
  // Linear distance corrections
  final double driftInches; // inches
  final double dropInches; // inches
  final double driftCm; // centimeters
  final double dropCm; // centimeters

  BallisticsResult({
    required this.driftHorizontal,
    required this.dropVertical,
    required this.driftMrad,
    required this.dropMrad,
    required this.driftMrad20,
    required this.dropMrad20,
    required this.driftMoa,
    required this.dropMoa,
    required this.driftMoa2,
    required this.dropMoa2,
    required this.driftMoa3,
    required this.dropMoa3,
    required this.driftMoa4,
    required this.dropMoa4,
    required this.driftMoa8,
    required this.dropMoa8,
    required this.driftInches,
    required this.dropInches,
    required this.driftCm,
    required this.dropCm,
  });
}

class BallisticsCalculator {
  // Fixed simulation parameters
  static const double dt = 0.0001; // s
  static const double omega = 7.292115e-5; // rad/s (Earth rotation)

  static double speedOfSound(double tC) {
    return 20.05 * sqrt(tC + 273.15);
  }
  static double g1DragCoefficient(double mach) {
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

  static double g7DragCoefficient(double mach) {
    final machValues = [
      0.00, 0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40, 0.45,
      0.50, 0.55, 0.60, 0.65, 0.70, 0.725, 0.75, 0.775, 0.80, 0.825,
      0.85, 0.875, 0.90, 0.925, 0.95, 0.975, 1.00, 1.025, 1.05, 1.075,
      1.10, 1.125, 1.15, 1.20, 1.25, 1.30, 1.35, 1.40, 1.50, 1.55,
      1.60, 1.65, 1.70, 1.75, 1.80, 1.85, 1.90, 1.95, 2.00, 2.05,
      2.10, 2.15, 2.20, 2.25, 2.30, 2.35, 2.40, 2.45, 2.50, 2.55,
      2.60, 2.65, 2.70, 2.75, 2.80, 2.85, 2.90, 2.95, 3.00, 3.10,
      3.20, 3.30, 3.40, 3.50, 3.60, 3.70, 3.80, 3.90, 4.00, 4.20,
      4.40, 4.60, 4.80, 5.00
    ];
    
    final g7DragCoeffValues = [
      0.1198, 0.1197, 0.1196, 0.1194, 0.1193, 0.1194, 0.1194, 0.1194, 0.1193, 0.1193,
      0.1194, 0.1193, 0.1194, 0.1197, 0.1202, 0.1207, 0.1215, 0.1226, 0.1242, 0.1266,
      0.1306, 0.1368, 0.1464, 0.1660, 0.2054, 0.2993, 0.3803, 0.4015, 0.4043, 0.4034,
      0.4014, 0.3987, 0.3955, 0.3884, 0.3810, 0.3732, 0.3657, 0.3580, 0.3440, 0.3376,
      0.3315, 0.3260, 0.3209, 0.3160, 0.3117, 0.3078, 0.3042, 0.3010, 0.2980, 0.2951,
      0.2922, 0.2892, 0.2864, 0.2835, 0.2807, 0.2779, 0.2752, 0.2725, 0.2697, 0.2670,
      0.2643, 0.2615, 0.2588, 0.2561, 0.2533, 0.2506, 0.2479, 0.2451, 0.2424, 0.2368,
      0.2313, 0.2258, 0.2205, 0.2154, 0.2106, 0.2060, 0.2017, 0.1975, 0.1935, 0.1861,
      0.1793, 0.1730, 0.1672, 0.1618
    ];
    
    // Linear interpolation
    for (int i = 0; i < machValues.length - 1; i++) {
      if (mach >= machValues[i] && mach <= machValues[i + 1]) {
        final t = (mach - machValues[i]) / (machValues[i + 1] - machValues[i]);
        return g7DragCoeffValues[i] + t * (g7DragCoeffValues[i + 1] - g7DragCoeffValues[i]);
      }
    }
    
    return g7DragCoeffValues.last;
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
    
    // Corrected gravity anomaly calculation: 1 mGal = 1e-5 m/s², not 1e-3
    final double deltaGA = (0.874 - 9.9e-5 * altM + 3.56e-9 * altM * altM) * 1e-5; // Convert mGal to m/s²

    final double g = gamma * pow(Re / (Re + altM), 2) + deltaGA;
    return g;
  }

  /// Converts pressure from various units to Pascals
  /// Accepts pressure in mbar (millibar) or Pa (Pascal)
  /// Values between 800-1200 are assumed to be mbar
  /// Values above 10000 are assumed to be Pa
  /// Values below 800 or between 1200-10000 may be ambiguous
  static double _convertPressureToPa(double pressure) {
    // More intelligent pressure unit detection
    if (pressure >= 800 && pressure <= 1200) {
      // Typical atmospheric pressure range in mbar (800-1200 mbar)
      return pressure * 100; // Convert mbar to Pa
    } else if (pressure >= 80000) {
      // Clearly in Pa range (80000+ Pa = 800+ mbar)
      return pressure;
    } else if (pressure < 800) {
      // Ambiguous range - assume mbar for values that could be low pressure
      return pressure * 100;
    } else {
      // Range 1200-80000 is ambiguous, but more likely to be Pa
      // Log a warning in debug mode if possible
      return pressure;
    }
  }

  static double calculateAirDensity(double tempC, double pressurePa, double humidityPercent) {
    // Calculate air density using the ideal gas law with humidity correction
    final double tempK = tempC + 273.15;
    final double humidityFraction = humidityPercent / 100.0;
    
    // Saturation vapor pressure (Tetens formula)
    final double satVaporPressure = 610.78 * exp(17.27 * tempC / (tempC + 237.3));
    final double vaporPressure = humidityFraction * satVaporPressure;
    final double dryAirPressure = pressurePa - vaporPressure;
    
    // Air density calculation
    const double dryAirConstant = 287.058; // J/(kg·K)
    const double waterVaporConstant = 461.495; // J/(kg·K)
    
    final double dryAirDensity = dryAirPressure / (dryAirConstant * tempK);
    final double waterVaporDensity = vaporPressure / (waterVaporConstant * tempK);
    
    return dryAirDensity + waterVaporDensity;
  }  static double _getDiameterFromCartridge(Cartridge cartridge) {
    // Diameter is provided by user in centimeters, convert to meters
    final double diameterCm = double.parse(cartridge.diameter);
    return diameterCm * 0.01; // Convert centimeters to meters
  }static BallisticsResult calculate(double distance, double windSpeed, double windDirection) {
    // Legacy method for backward compatibility - uses default test profiles
    // For production use, always use calculateWithProfiles with actual user profiles
    
    // Create default test profiles (similar to old hardcoded constants)
    final defaultGun = Gun(
      id: 'default-test-gun',
      name: 'Default Test Rifle',
      twistRate: 12.0, // 1:12 twist
      twistDirection: 1, // Right twist
      muzzleVelocity: 820.0, // m/s
      zeroRange: 100.0, // 100m zero
    );
      final defaultCartridge = Cartridge(
      id: 'default-test-cartridge',
      name: 'Default Test .308',
      diameter: '0.782', // .308" in centimeters
      bulletWeight: 150.0, // grains
      bulletLength: 0.0,
      ballisticCoefficient: 0.504, // G1
      bcModelType: 0,
    );
    
    final defaultScope = Scope(
      id: 'default-test-scope',
      name: 'Default Test Scope',
      sightHeight: 2.17, // inches
      units: 0, // inches
    );
    
    // Use default environmental conditions (15°C, 1013 mbar, 50% humidity)
    return calculateWithProfiles(
      distance,
      windSpeed,
      windDirection,
      defaultGun,
      defaultCartridge,
      defaultScope,
      temperature: 15.0,
      pressure: 1013.25,
      humidity: 50.0,
    );
  }  /// Calculate ballistics with user profiles
  /// 
  /// Parameters:
  /// - distance: target distance in meters
  /// - windSpeed: wind speed in m/s (meters per second)
  /// - windDirection: wind direction in degrees (0° = North, clockwise)
  /// - gun: gun profile with muzzle velocity, twist rate, etc.
  /// - cartridge: cartridge profile with bullet data
  /// - scope: scope profile with sight height
  /// - temperature: air temperature in Celsius
  /// - pressure: air pressure in mbar or Pa (auto-detected)
  /// - humidity: relative humidity as percentage (0-100)
  /// - elevationAngle: elevation angle in degrees (-90 to +90)
  /// - azimuthAngle: azimuth angle in degrees (0-360)
  /// - slopeAngle: terrain slope angle in degrees (-90 to +90, positive = uphill)
  /// - latitude: latitude in degrees (positive = North, negative = South)
  static BallisticsResult calculateWithProfiles(
    double distance, 
    double windSpeed,
    double windDirection,
    Gun? gun,
    Cartridge? cartridge,
    Scope? scope, {
    required double temperature,
    required double pressure,     
    required double humidity,
    double elevationAngle = 0.0,
    double azimuthAngle = 0.0,
    double slopeAngle = 0.0,
    double latitude = 0.0,
  }) {
    // Strict validation - no fallbacks allowed
    if (gun == null) {
      throw ArgumentError('Gun profile is required for ballistics calculation');
    }
    if (cartridge == null) {
      throw ArgumentError('Cartridge profile is required for ballistics calculation');
    }
    if (scope == null) {
      throw ArgumentError('Scope profile is required for ballistics calculation');
    }
    
    if (distance <= 0) {
      throw ArgumentError('Distance must be greater than 0');
    }
    
    // Validate elevation angle range
    if (elevationAngle < -90.0 || elevationAngle > 90.0) {
      throw ArgumentError('Elevation angle must be between -90 and 90 degrees');
    }
    
    // Validate slope angle range
    if (slopeAngle < -90.0 || slopeAngle > 90.0) {
      throw ArgumentError('Slope angle must be between -90 and 90 degrees');
    }
    
    // Use strictly the provided environmental data from calculator screen
    final double envTemperature = temperature;
    final double envPressure = pressure;
    final double envHumidity = humidity;
    
    // Convert pressure to Pa using intelligent detection
    final double pressurePa = _convertPressureToPa(envPressure);
    
    // Calculate air density based on environmental conditions
    final double rhoAir = calculateAirDensity(envTemperature, pressurePa, envHumidity);
    
    // Extract ballistics data from profiles
    final double bulletWeightGrains = cartridge.bulletWeight;
    final double mass = bulletWeightGrains * 0.0000648;
    final double ballisticCoefficient = cartridge.ballisticCoefficient;
    final double diameter = _getDiameterFromCartridge(cartridge);
      
    // Gun properties
    final double muzzleVelocity = gun.muzzleVelocity;
    final double calibrationDistance = gun.zeroRange;
    final double twistRate = gun.twistRate; // calibres/rev
    final int twistDirection = gun.twistDirection; // 1 for right, -1 for left
    
    // Calculate initial spin rate
    final double p0 = 2 * pi * muzzleVelocity / (twistRate * diameter);
    final double spinRate = twistDirection * p0; // Apply twist direction
    
    // Scope properties
    final double sightHeightValue = scope.sightHeight;
    final int sightHeightUnits = scope.units;
    final double visorHeight = sightHeightUnits == 0 
        ? sightHeightValue * 0.0254
        : sightHeightValue * 0.01;

    // Convert angles from degrees to radians
    final double elevationAngleRad = elevationAngle * pi / 180;
    final double slopeAngleRad = slopeAngle * pi / 180;
    
    // --- Wind in the shooting system coordinates ---
    final double windAngle = (windDirection - azimuthAngle) * pi / 180;
    final double windSide = windSpeed * sin(windAngle);  // lateral component
    final double windHead = -windSpeed * cos(windAngle);  // headwind(+) or tailwind(-)
    final List<double> windVectorLocal = [windHead, windSide, 0.0];
    
    // Store crossWind value for windage jump calculation
    final double crossWind = windSide;    // Convert wind to vector (modified to respect shooting azimuth)
    // windX and windY variables removed as they are not used in current implementation
    
    // Calculate initial velocity components in shooting plane coordinates
    // x' = along shooting plane (inclined line of sight)
    // y' = lateral (wind drift direction)  
    // z' = perpendicular to shooting plane
    final double vxPrime = muzzleVelocity * cos(elevationAngleRad);
    final double vzPrime = muzzleVelocity * sin(elevationAngleRad);
    
    // Initial state [x', y', z', vx', vy', vz', p] in shooting plane coordinates
    List<double> state = [
      0.0, 0.0, 0.0,
      vxPrime, 
      0.0, 
      vzPrime,
      spinRate
    ];
    
    // Calculate windage-jump with proper parameters
    final double Rs = diameter * 0.5;          // d/2
    final double fL = 1.25; // NATO standard lift factor
    final double qm = 1.15; // NATO standard Magnus factor
    
    // Correct wind jump calculation
    final double deltaVy0 = -0.625 * diameter / Rs * fL * qm * crossWind;
    double vyJump = deltaVy0; // This will decay over time
    
    print('Applied initial windage-jump: ${deltaVy0.toStringAsFixed(3)} m/s from crosswind ${crossWind.toStringAsFixed(3)} m/s');
      double? driftH;
    double? dropZ;
    double timeOfFlight = 0.0; // Track time of flight
    
    // Variables to capture bullet height at zero range
    double zAtZero = 0.0;
    bool gotZero = false;
    
    // Area for drag calculation
    final double A = pi * (diameter / 2) * (diameter / 2);
    
    // Correct damping constant per STANAG 4355
    const double dYaw = 35.0; // s⁻¹ (updated from 5.0)

    // RK4 Integration loop
    for (int step = 0; step < (30.0 / dt).round(); step++) {
      // Add the current windage jump to lateral velocity
      state[4] += vyJump;
      
      // Exponentially decay the jump for next step
      vyJump *= exp(-dYaw * dt);
      
      // Store previous state for interpolation
      final double xPrev = state[0];
      final double zPrev = state[2];
      
      // RK4 step
      final int bcModelType = cartridge.bcModelType ?? 0;
      final List<double> k1 = _calculateDerivatives(state, windVectorLocal, envTemperature, rhoAir, A, mass, ballisticCoefficient, bcModelType, diameter, slopeAngleRad, latitude);
      
      final List<double> state2 = List.generate(7, (i) => state[i] + k1[i] * dt * 0.5);
      final List<double> k2 = _calculateDerivatives(state2, windVectorLocal, envTemperature, rhoAir, A, mass, ballisticCoefficient, bcModelType, diameter, slopeAngleRad, latitude);
      
      final List<double> state3 = List.generate(7, (i) => state[i] + k2[i] * dt * 0.5);
      final List<double> k3 = _calculateDerivatives(state3, windVectorLocal, envTemperature, rhoAir, A, mass, ballisticCoefficient, bcModelType, diameter, slopeAngleRad, latitude);
      
      final List<double> state4 = List.generate(7, (i) => state[i] + k3[i] * dt);
      final List<double> k4 = _calculateDerivatives(state4, windVectorLocal, envTemperature, rhoAir, A, mass, ballisticCoefficient, bcModelType, diameter, slopeAngleRad, latitude);
      
      // Update state using RK4 formula
      for (int i = 0; i < 7; i++) {
        state[i] += dt / 6.0 * (k1[i] + 2 * k2[i] + 2 * k3[i] + k4[i]);
      }
      
      // Add advection effects - bullet moves with the air mass
      state[0] += windHead * dt;   // advection in x′
      state[1] += windSide * dt;   // advection in y′
      
      // Update time of flight
      timeOfFlight += dt;
      
      final double xNew = state[0];
      final double zNew = state[2];
      
      // Improved zero range interpolation with better validation
      if (!gotZero && calibrationDistance > 0 && xNew >= calibrationDistance) {
        if (xPrev < calibrationDistance && xNew > xPrev) {
          // Ensure interpolation factor is within [0,1] bounds
          final double denominator = xNew - xPrev;
          if (denominator > 0) {
            final double t = (calibrationDistance - xPrev) / denominator;
            // Clamp t to [0,1] to prevent extrapolation errors
            final double clampedT = t.clamp(0.0, 1.0);
            zAtZero = zPrev + clampedT * (zNew - zPrev);
            gotZero = true;
            
            // Debug output for zero range capture
            print('Zero range captured at ${calibrationDistance}m: bullet height = ${zAtZero.toStringAsFixed(4)}m, interpolation factor = ${clampedT.toStringAsFixed(3)}');
          }
        } else if (xPrev <= calibrationDistance) {
          // Direct capture if we're exactly at zero range
          zAtZero = zNew;
          gotZero = true;
          print('Zero range captured directly at ${calibrationDistance}m: bullet height = ${zAtZero.toStringAsFixed(4)}m');
        }
      }
        // Check if we've reached target distance along shooting plane
      if (state[0] >= distance) {
        driftH = state[1];
        dropZ = state[2];
        break;
      }
    }

    // Calculate corrections based on line of sight vs trajectory difference
    final double trajZ = dropZ ?? 0.0;
    final double trajY = driftH ?? 0.0;
    final double D = distance;
    
    // Enhanced line of sight calculation with multiple fallback mechanisms
    double losHeightAtTarget;
    
    if (calibrationDistance == 0.0) {
      // No zero range - horizontal line of sight from scope height
      losHeightAtTarget = visorHeight;
      print('Zero range = 0: Using horizontal line of sight at scope height ${visorHeight.toStringAsFixed(4)}m');
    } else if (!gotZero) {
      // Failed to capture zero height - use ballistic approximation as fallback
      print('Warning: Failed to capture bullet height at zero range ${calibrationDistance}m, using ballistic approximation');
      
      // Fallback calculation using simple ballistics
      final double timeOfFlightToZero = calibrationDistance / muzzleVelocity;
      final double estimatedDropAtZero = 0.5 * 9.81 * timeOfFlightToZero * timeOfFlightToZero;
      
      // Estimate bullet height at zero (positive = above bore)
      zAtZero = estimatedDropAtZero; // Simple drop calculation
      
      // Calculate line of sight slope and height at target
      final double losSlope = (zAtZero - visorHeight) / calibrationDistance;
      losHeightAtTarget = visorHeight + losSlope * D;
      
      print('Fallback: Estimated bullet height at zero = ${zAtZero.toStringAsFixed(4)}m, LOS slope = ${losSlope.toStringAsFixed(6)}');
    } else {
      // Successfully captured zero height - calculate proper line of sight
      final double losSlope = (zAtZero - visorHeight) / calibrationDistance;
      losHeightAtTarget = visorHeight + losSlope * D;
      
      print('Normal calculation: Zero height = ${zAtZero.toStringAsFixed(4)}m, scope height = ${visorHeight.toStringAsFixed(4)}m, LOS slope = ${losSlope.toStringAsFixed(6)}');
    }
    
    // Calculate differences between trajectory and line of sight
    double heightDifference = trajZ - losHeightAtTarget; // Positive = bullet above LOS
    final double lateralDifference = trajY; // Horizontal drift from centerline
    
    // Apply Time of Flight (ToF) correction factor to height difference
    // Get ToF polynomial coefficients from cartridge (with defaults if not set)
    final double a0 = cartridge.tofA0 ?? 1.0;
    final double a1 = cartridge.tofA1 ?? 0.0;
    final double a2 = cartridge.tofA2 ?? 0.0;
    final double a3 = cartridge.tofA3 ?? 0.0;
    
    // Calculate adjusted time of flight using polynomial correction
    final double rawTof = timeOfFlight;
    final double adjTof = a0 + a1 * rawTof + a2 * pow(rawTof, 2) + a3 * pow(rawTof, 3);
    
    // Apply ToF correction factor only if polynomial is meaningful (not default values)
    if (a1 != 0.0 || a2 != 0.0 || a3 != 0.0) {
      final double tofFactor = adjTof / rawTof;
      heightDifference *= tofFactor;
      
      print('ToF correction applied: raw=${rawTof.toStringAsFixed(4)}s, adj=${adjTof.toStringAsFixed(4)}s, factor=${tofFactor.toStringAsFixed(4)}');
    }
    
    // Convert differences to angular corrections (mrad)
    // Positive correction = bullet above LOS, scope needs DOWN adjustment
    // Negative correction = bullet below LOS, scope needs UP adjustment
    final double correctedDropMrad = heightDifference / distance * 1000;
    final double correctedDriftMrad = lateralDifference / distance * 1000;
    
    // Debug output for final calculations
    print('Final calculations at ${distance}m:');
    print('  Time of flight: ${timeOfFlight.toStringAsFixed(4)}s');
    print('  Trajectory height: ${trajZ.toStringAsFixed(4)}m');
    print('  Line of sight height: ${losHeightAtTarget.toStringAsFixed(4)}m');
    print('  Height difference (after ToF): ${heightDifference.toStringAsFixed(4)}m');
    print('  Drop correction: ${correctedDropMrad.toStringAsFixed(3)} MRAD');
    
    // Calculate all unit variations
    // MRAD units
    final double driftMrad20 = (correctedDriftMrad / 0.05).round() * 0.05; // 1/20 MRAD increments
    final double dropMrad20 = (correctedDropMrad / 0.05).round() * 0.05;
    
    // MOA conversions (1 MOA = 0.290888 mrad approximately)
    const double mradToMoa = 1.0 / 0.290888;
    final double correctedDriftMoa = correctedDriftMrad * mradToMoa;
    final double correctedDropMoa = correctedDropMrad * mradToMoa;
    
    // MOA fractions
    final double driftMoa2 = (correctedDriftMoa / 0.5).round() * 0.5; // 1/2 MOA increments
    final double dropMoa2 = (correctedDropMoa / 0.5).round() * 0.5;
    final double driftMoa3 = (correctedDriftMoa / (1.0/3.0)).round() * (1.0/3.0); // 1/3 MOA increments
    final double dropMoa3 = (correctedDropMoa / (1.0/3.0)).round() * (1.0/3.0);
    final double driftMoa4 = (correctedDriftMoa / 0.25).round() * 0.25; // 1/4 MOA increments
    final double dropMoa4 = (correctedDropMoa / 0.25).round() * 0.25;
    final double driftMoa8 = (correctedDriftMoa / 0.125).round() * 0.125; // 1/8 MOA increments
    final double dropMoa8 = (correctedDropMoa / 0.125).round() * 0.125;
    
    // Linear distance corrections at target distance
    final double driftInches = (driftH ?? 0) * 39.3701; // meters to inches
    final double dropInches = (dropZ ?? 0) * 39.3701; // meters to inches
    final double driftCm = (driftH ?? 0) * 100; // meters to centimeters
    final double dropCm = (dropZ ?? 0) * 100; // meters to centimeters
    
    return BallisticsResult(
      driftHorizontal: driftH ?? 0,
      dropVertical: dropZ ?? 0,
      driftMrad: correctedDriftMrad,
      dropMrad: correctedDropMrad,
      driftMrad20: driftMrad20,
      dropMrad20: dropMrad20,
      driftMoa: correctedDriftMoa,
      dropMoa: correctedDropMoa,
      driftMoa2: driftMoa2,
      dropMoa2: dropMoa2,
      driftMoa3: driftMoa3,
      dropMoa3: dropMoa3,
      driftMoa4: driftMoa4,
      dropMoa4: dropMoa4,
      driftMoa8: driftMoa8,
      dropMoa8: dropMoa8,
      driftInches: driftInches,
      dropInches: dropInches,
      driftCm: driftCm,
      dropCm: dropCm,
    );
  }
  /// Calculate derivatives for RK4 integration with slope support
  /// Returns [dx'/dt, dy'/dt, dz'/dt, dvx'/dt, dvy'/dt, dvz'/dt, dp/dt]
  static List<double> _calculateDerivatives(
    List<double> state,
    List<double> windVector,
    double envTemperature,
    double rhoAir,
    double A,
    double mass,
    double ballisticCoefficient,
    int bcModelType,
    double diameter,
    double slopeAngleRad,
    double latitude,
  ) {
    final double z = state[2];
    final double vx = state[3];
    final double vy = state[4];
    final double vz = state[5];
    final double p = state[6]; // spin rate
    
    // Local conditions
    final double tLoc = envTemperature - 0.0065 * z;
    final double a = speedOfSound(tLoc);
    final double gLoc = gravity(latitude, z); // Use the passed latitude
    
    // Decompose gravity into shooting plane components
    final double gxPrime = gLoc * sin(slopeAngleRad); // Component along shooting plane
    final double gzPrime = gLoc * cos(slopeAngleRad); // Component perpendicular to shooting plane
    
    // Relative velocity to air
    final double vRelX = vx - windVector[0];
    final double vRelY = vy - windVector[1];
    final double vRelZ = vz - windVector[2];
    
    final double vMagnitude = sqrt(vRelX * vRelX + vRelY * vRelY + vRelZ * vRelZ);
    final double mach = vMagnitude / a;
    
    // Drag coefficient from model (G1 or G7)
    final double cdModel = bcModelType == 1 
        ? g7DragCoefficient(mach)
        : g1DragCoefficient(mach);
    
    // Calculate sectional density (SD) in lb/in²
    // mass is in kg, diameter is in meters
    final double massGrains = mass * 15432.3583529; // kg to grains
    final double diameterInches = diameter * 39.37; // cm to inches
    final double sectionalDensity = massGrains / 7000 / (diameterInches * diameterInches); // lb/in²
    
    // Form factor: i = SD/BC
    final double formFactor = sectionalDensity / ballisticCoefficient;
    
    // Apply form factor to scale the drag coefficient: Cd = i * Cd_model
    final double cd = formFactor * cdModel;
    
    // Drag force magnitude with corrected formula
    final double dragMagnitude = 0.5 * rhoAir * A * cd * vMagnitude * vMagnitude;
    
    // Unit vector in direction of relative velocity
    final double vRelMag = vMagnitude;
    final double dragFx = vRelMag > 0 ? -dragMagnitude * (vRelX / vRelMag) : 0.0;
    final double dragFy = vRelMag > 0 ? -dragMagnitude * (vRelY / vRelMag) : 0.0;
    final double dragFz = vRelMag > 0 ? -dragMagnitude * (vRelZ / vRelMag) : 0.0;
    
    // Magnus force calculation with proper v² scaling
    // Magnus coefficient (empirical, depends on bullet shape)
    final double cm = 0.3; // Typical value for spitzer bullets
    final double qm = 1.15; // NATO standard value
    
    // Updated: Bullet axis now aligns with current velocity vector
    final double axisX = vRelMag > 0 ? vRelX / vRelMag : 1.0;
    final double axisY = vRelMag > 0 ? vRelY / vRelMag : 0.0;
    final double axisZ = vRelMag > 0 ? vRelZ / vRelMag : 0.0;
    
    // Spin vector (aligned with bullet axis)
    final double spinMagnitude = p.abs();
    final double spinX = spinMagnitude * axisX;
    final double spinY = spinMagnitude * axisY;
    final double spinZ = spinMagnitude * axisZ;
    
    // Cross product: spin × velocity
    final double magnusX = (spinY * vRelZ - spinZ * vRelY);
    final double magnusY = (spinZ * vRelX - spinX * vRelZ);
    final double magnusZ = (spinX * vRelY - spinY * vRelX);
    
    // Magnus force magnitude with STANAG adjustment factor and proper v² scaling
    final double magnusMagnitude = 0.5 * rhoAir * A * qm * cm * vMagnitude * vMagnitude;
    
    // Magnus forces
    final double magFx = magnusMagnitude * magnusX;
    final double magFy = magnusMagnitude * magnusY;
    final double magFz = magnusMagnitude * magnusZ;
    
    // Cross product of bullet axis and velocity for lift direction
    final double liftDirX = (axisY * vRelZ - axisZ * vRelY);
    final double liftDirY = (axisZ * vRelX - axisX * vRelZ);
    final double liftDirZ = (axisX * vRelY - axisY * vRelX);
    
    // Normalize lift direction
    final double liftDirMag = sqrt(liftDirX * liftDirX + liftDirY * liftDirY + liftDirZ * liftDirZ);
    
    // Updated: Calculate angle of attack using improved formula
    final double alpha = vRelMag > 0 ? asin(liftDirMag / vRelMag) : 0.0;
    
    // Apply linear small-angle model for lift coefficient with NATO standard factor
    final double cLa = 2 * pi;          // Theoretical slope for subsonic/transonic
    final double fL = 1.25;              // NATO standard value (table A-1, STANAG)
    final double cL = fL * cLa * alpha;
    
    // Lift force magnitude - now properly based on angle of attack
    final double liftMagnitude = 0.5 * rhoAir * A * cL * vMagnitude * vMagnitude;
    
    // Lift forces
    final double liftFx = liftDirMag > 0 ? liftMagnitude * (liftDirX / liftDirMag) : 0.0;
    final double liftFy = liftDirMag > 0 ? liftMagnitude * (liftDirY / liftDirMag) : 0.0;
    final double liftFz = liftDirMag > 0 ? liftMagnitude * (liftDirZ / liftDirMag) : 0.0;
      // Basic yaw-of-repose calculation (simplified)
    // This adds a small bias to the angle of attack, which creates realistic drift
    final double yawOfRepose = (spinMagnitude / (2*pi)) * gLoc * diameter / 
        (8 * vMagnitude * vMagnitude);
    
    // Apply yaw lift without the 0.5 factor
    final double yawLiftFx = yawOfRepose * liftFx;
    final double yawLiftFy = yawOfRepose * liftFy;
    final double yawLiftFz = yawOfRepose * liftFz;
    
    // Coriolis effect calculation
    final double latRad = latitude * pi / 180; // Use the passed latitude
    final double omegaX = 0.0; // No rotation about local X-axis
    final double omegaY = omega * cos(latRad); // East component
    final double omegaZ = omega * sin(latRad); // Up component
    
    // Coriolis acceleration: -2 * Ω × v
    final double coriolisX = -2.0 * (omegaY * vz - omegaZ * vy);
    final double coriolisY = -2.0 * (omegaZ * vx - omegaX * vz);
    final double coriolisZ = -2.0 * (omegaX * vy - omegaY * vx);
    
    // Convert Coriolis acceleration to forces
    final double coriolisFx = mass * coriolisX;
    final double coriolisFy = mass * coriolisY;
    final double coriolisFz = mass * coriolisZ;
    
    // Total accelerations (all forces combined + gravity components)
    final double ax = (dragFx + magFx + liftFx + yawLiftFx + coriolisFx) / mass - gxPrime;
    final double ay = (dragFy + magFy + liftFy + yawLiftFy + coriolisFy) / mass;
    final double az = (dragFz + magFz + liftFz + yawLiftFz + coriolisFz) / mass - gzPrime;
    
    // Spin decay (due to air resistance)
    final double spinDecay = -0.001 * spinMagnitude; // Empirical spin decay rate
    
    return [vx, vy, vz, ax, ay, az, spinDecay];
  }

  /// Generate a ballistic table using the same calculation engine as the main calculator
  /// 
  /// Parameters:
  /// - startDistance: starting distance in meters
  /// - endDistance: ending distance in meters
  /// - interval: distance interval in meters
  /// - windSpeed: wind speed in m/s
  /// - windDirection: wind direction in degrees
  /// - gun: gun profile
  /// - cartridge: cartridge profile
  /// - scope: scope profile
  /// - temperature: air temperature in Celsius
  /// - pressure: air pressure in mbar or Pa (auto-detected)
  /// - humidity: relative humidity as percentage (0-100)
  /// - elevationAngle: elevation angle in degrees
  /// - azimuthAngle: azimuth angle in degrees
  /// - slopeAngle: terrain slope angle in degrees
  static List<BallisticsResult> generateBallisticTable(
    double startDistance,
    double endDistance,
    double interval,
    double windSpeed,
    double windDirection,
    Gun gun,
    Cartridge cartridge,
    Scope scope, {
    required double temperature,
    required double pressure,
    required double humidity,
    double elevationAngle = 0.0,
    double azimuthAngle = 0.0,
    double slopeAngle = 0.0,
    double latitude = 0.0, // Add latitude parameter
  }) {
    final List<BallisticsResult> results = [];
    
    // Validate input parameters
    if (startDistance <= 0 || endDistance <= startDistance || interval <= 0) {
      throw ArgumentError('Invalid distance parameters for table generation');
    }
    
    // Generate results for each distance point using the same calculation engine
    for (double distance = startDistance; distance <= endDistance; distance += interval) {
      try {
        final result = calculateWithProfiles(
          distance,
          windSpeed,
          windDirection,
          gun,
          cartridge,
          scope,
          temperature: temperature,
          pressure: pressure,
          humidity: humidity,
          elevationAngle: elevationAngle,
          azimuthAngle: azimuthAngle,
          slopeAngle: slopeAngle,
          latitude: latitude, // Pass the latitude
        );
        results.add(result);
      } catch (e) {
        // If calculation fails for a specific distance, skip it
        print('Error calculating ballistics at distance ${distance}m: $e');
        continue;
      }
    }
    
    return results;
  }

  /// Generate a ballistic table with legacy method (for backward compatibility)
  static List<BallisticsResult> generateBallisticTableLegacy(
    double startDistance,
    double endDistance,
    double interval,
    double windSpeed,
    double windDirection,
  ) {
    final List<BallisticsResult> results = [];
    
    for (double distance = startDistance; distance <= endDistance; distance += interval) {
      try {
        final result = calculate(distance, windSpeed, windDirection);
        results.add(result);
      } catch (e) {
        // If calculation fails for a specific distance, skip it
        print('Error calculating legacy ballistics at distance ${distance}m: $e');
        continue;
      }
    }
    
    return results;
  }
}
