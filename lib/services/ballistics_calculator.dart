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
  static const double dt = 0.001; // s
  static const double omega = 7.292115e-5; // rad/s (Earth rotation)
  static const double latitude = 0.0; // degrees North

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
    // Parse the diameter from user input
    // The diameter is collected in millimeters in the UI
    try {
      final double diameterMm = double.parse(cartridge.diameter);
      return diameterMm * 0.001; // Convert millimeters to meters
    } catch (e) {
      // If parsing fails, try to handle common caliber formats like ".308", "7.62", etc.
      String cleanDiameter = cartridge.diameter.replaceAll(RegExp(r'[^\d.]'), '');
      final double parsedValue = double.parse(cleanDiameter);
      
      // If value is less than 1, assume it's in inches (like .308) and convert to meters
      if (parsedValue < 1.0) {
        return parsedValue * 0.0254; // Convert inches to meters
      } else if (parsedValue < 50.0) {
        // Values between 1-50 are likely millimeters (common rifle calibers)
        return parsedValue * 0.001; // Convert millimeters to meters
      } else {
        // Larger values might be in hundredths of millimeters or other units
        return parsedValue * 0.001; // Default to millimeters
      }
    }
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
      diameter: '0.782', // .308" converted to centimeters
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
  static BallisticsResult calculateWithProfiles(
    double distance, 
    double windSpeed, // Wind speed in m/s
    double windDirection,
    Gun? gun,
    Cartridge? cartridge,
    Scope? scope, {
    required double temperature,
    required double pressure,     
    required double humidity,
    double elevationAngle = 0.0,
    double azimuthAngle = 0.0,
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

    // Convert wind direction to wind vector
    final double windX = windSpeed * cos(windDirection * pi / 180);
    final double windY = windSpeed * sin(windDirection * pi / 180);
    final List<double> windVector = [windX, windY, 0.0];
    
    // Convert elevation angle from degrees to radians
    final double elevationAngleRad = elevationAngle * pi / 180;
    
    // Initial state [x, y, z, vx, vy, vz, p] - added spin rate p
    List<double> state = [
      0.0, 0.0, 0.0,
      muzzleVelocity * cos(elevationAngleRad), 
      0.0, 
      muzzleVelocity * sin(elevationAngleRad),
      spinRate
    ];
    
    double? driftH;
    double? dropZ;
    
    // Area for drag calculation
    final double A = pi * (diameter / 2) * (diameter / 2);

    // RK4 Integration loop
    for (int step = 0; step < (30.0 / dt).round(); step++) {
      // RK4 step
      final int bcModelType = cartridge.bcModelType ?? 0;
      final List<double> k1 = _calculateDerivatives(state, windVector, envTemperature, rhoAir, A, mass, ballisticCoefficient, bcModelType, diameter);
      
      final List<double> state2 = List.generate(7, (i) => state[i] + k1[i] * dt * 0.5);
      final List<double> k2 = _calculateDerivatives(state2, windVector, envTemperature, rhoAir, A, mass, ballisticCoefficient, bcModelType, diameter);
      
      final List<double> state3 = List.generate(7, (i) => state[i] + k2[i] * dt * 0.5);
      final List<double> k3 = _calculateDerivatives(state3, windVector, envTemperature, rhoAir, A, mass, ballisticCoefficient, bcModelType, diameter);
      
      final List<double> state4 = List.generate(7, (i) => state[i] + k3[i] * dt);
      final List<double> k4 = _calculateDerivatives(state4, windVector, envTemperature, rhoAir, A, mass, ballisticCoefficient, bcModelType, diameter);
      
      // Update state using RK4 formula
      for (int i = 0; i < 7; i++) {
        state[i] += dt / 6.0 * (k1[i] + 2 * k2[i] + 2 * k3[i] + k4[i]);
      }
      
      // Check if we've reached target distance
      if (state[0] >= distance) {
        driftH = state[1];
        dropZ = state[2];
        break;
      }
    }

    // Calculate raw corrections (referred to bore axis)
    final double rawDriftMrad = (driftH ?? 0) / distance * 1000;
    final double rawDropMrad = -(dropZ ?? 0) / distance * 1000; // Negative for upward correction
    
    // Calculate scope height correction angle
    final double scopeHeightCorrectionMrad = atan(visorHeight / calibrationDistance) * 1000;
    
    // Apply corrections considering scope height and calibration distance
    final double correctedDriftMrad = rawDriftMrad; // Drift is not affected by scope height
    final double correctedDropMrad = rawDropMrad - scopeHeightCorrectionMrad;
    
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
    final double dropInches = -(dropZ ?? 0) * 39.3701; // meters to inches (negative for upward)
    final double driftCm = (driftH ?? 0) * 100; // meters to centimeters
    final double dropCm = -(dropZ ?? 0) * 100; // meters to centimeters (negative for upward)
    
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

  /// Calculate derivatives for RK4 integration
  /// Returns [dx/dt, dy/dt, dz/dt, dvx/dt, dvy/dt, dvz/dt, dp/dt]
  static List<double> _calculateDerivatives(
    List<double> state,
    List<double> windVector,
    double envTemperature,
    double rhoAir,
    double A,
    double mass,
    double ballisticCoefficient,
    int bcModelType,
    double diameter
  ) {
    final double x = state[0];
    final double y = state[1];
    final double z = state[2];
    final double vx = state[3];
    final double vy = state[4];
    final double vz = state[5];
    final double p = state[6]; // spin rate
    
    // Local conditions
    final double tLoc = envTemperature - 0.0065 * z;
    final double a = speedOfSound(tLoc);
    final double gLoc = gravity(latitude, z);
    
    // Relative velocity to air
    final double vRelX = vx - windVector[0];
    final double vRelY = vy - windVector[1];
    final double vRelZ = vz - windVector[2];
    
    final double vMagnitude = sqrt(vRelX * vRelX + vRelY * vRelY + vRelZ * vRelZ);
    final double mach = vMagnitude / a;
    
    // Drag coefficient
    final double CD = bcModelType == 1 
        ? g7DragCoefficient(mach)
        : g1DragCoefficient(mach);
    
    // Drag force magnitude
    final double dragMagnitude = 0.5 * rhoAir * A * (CD / ballisticCoefficient) * vMagnitude * vMagnitude;
    
    // Unit vector in direction of relative velocity
    final double vRelMag = vMagnitude;
    final double dragFx = vRelMag > 0 ? -dragMagnitude * (vRelX / vRelMag) : 0.0;
    final double dragFy = vRelMag > 0 ? -dragMagnitude * (vRelY / vRelMag) : 0.0;
    final double dragFz = vRelMag > 0 ? -dragMagnitude * (vRelZ / vRelMag) : 0.0;
    
    // Magnus force calculation
    // Magnus coefficient (empirical, depends on bullet shape)
    final double CM = 0.3; // Typical value for spitzer bullets
    
    // Spin vector (aligned with bullet axis, approximately with velocity)
    final double spinMagnitude = p.abs();
    final double spinX = vRelMag > 0 ? spinMagnitude * (vRelX / vRelMag) : 0.0;
    final double spinY = vRelMag > 0 ? spinMagnitude * (vRelY / vRelMag) : 0.0;
    final double spinZ = vRelMag > 0 ? spinMagnitude * (vRelZ / vRelMag) : 0.0;
    
    // Cross product: spin × velocity
    final double magnusX = (spinY * vRelZ - spinZ * vRelY);
    final double magnusY = (spinZ * vRelX - spinX * vRelZ);
    final double magnusZ = (spinX * vRelY - spinY * vRelX);
    
    // Magnus force magnitude
    final double magnusMagnitude = 0.5 * rhoAir * A * CM * vMagnitude;
    
    // Magnus forces
    final double magFx = magnusMagnitude * magnusX;
    final double magFy = magnusMagnitude * magnusY;
    final double magFz = magnusMagnitude * magnusZ;
    
    // Lift force calculation
    // Lift coefficient (empirical, depends on bullet shape and angle of attack)
    final double CL = 0.1; // Typical value for pointed bullets
    
    // Calculate angle of attack (angle between velocity vector and bullet axis)
    // For simplicity, assume bullet axis is aligned with initial velocity direction
    final double initialVx = state[3]; // Could be stored separately for more accuracy
    final double initialVy = state[4];
    final double initialVz = state[5];
    final double initialVMag = sqrt(initialVx * initialVx + initialVy * initialVy + initialVz * initialVz);
    
    // Normalized bullet axis (approximated as initial velocity direction)
    final double axisX = initialVMag > 0 ? initialVx / initialVMag : 1.0;
    final double axisY = initialVMag > 0 ? initialVy / initialVMag : 0.0;
    final double axisZ = initialVMag > 0 ? initialVz / initialVMag : 0.0;
    
    // Cross product of bullet axis and velocity for lift direction
    final double liftDirX = (axisY * vRelZ - axisZ * vRelY);
    final double liftDirY = (axisZ * vRelX - axisX * vRelZ);
    final double liftDirZ = (axisX * vRelY - axisY * vRelX);
    
    // Normalize lift direction
    final double liftDirMag = sqrt(liftDirX * liftDirX + liftDirY * liftDirY + liftDirZ * liftDirZ);
    
    // Lift force magnitude
    final double liftMagnitude = 0.5 * rhoAir * A * CL * vMagnitude * vMagnitude;
    
    // Lift forces
    final double liftFx = liftDirMag > 0 ? liftMagnitude * (liftDirX / liftDirMag) : 0.0;
    final double liftFy = liftDirMag > 0 ? liftMagnitude * (liftDirY / liftDirMag) : 0.0;
    final double liftFz = liftDirMag > 0 ? liftMagnitude * (liftDirZ / liftDirMag) : 0.0;
    
    // Coriolis effect calculation
    // Earth's angular velocity vector in Earth-fixed coordinates
    final double latRad = latitude * pi / 180;
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
    
    // Sail force calculation (wind pressure on bullet surface)
    final double CF = 1.0; // sail coefficient (≈1 for smooth cylinder)
    final double sailFx = 0.5 * rhoAir * A * CF * windVector[0] * windVector[0] * (windVector[0] > 0 ? 1 : -1);
    final double sailFy = 0.5 * rhoAir * A * CF * windVector[1] * windVector[1] * (windVector[1] > 0 ? 1 : -1);
    final double sailFz = 0.0; // No vertical sail force from horizontal wind
    
    // Total accelerations (drag + Magnus + lift + Coriolis + sail + gravity)
    final double ax = (dragFx + magFx + liftFx + coriolisFx) / mass + sailFx / mass;
    final double ay = (dragFy + magFy + liftFy + coriolisFy) / mass + sailFy / mass;
    final double az = (dragFz + magFz + liftFz + coriolisFz) / mass - gLoc;
    
    // Spin decay (due to air resistance)
    final double spinDecay = -0.001 * spinMagnitude; // Empirical spin decay rate
    
    return [vx, vy, vz, ax, ay, az, spinDecay];
  }
}
