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

  static double g7BallisticCoefficient(double mach) {
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
    
    double deltaGA = 0.874 - 9.9e-5 * altM + 3.56e-9 * altM * altM;
    deltaGA /= 1000.0; // mGal to m/s²

    final double g = gamma * pow(Re / (Re + altM), 2) + deltaGA;
    return g;
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
    // The diameter is collected in centimeters in the UI
    try {
      final double diameterCm = double.parse(cartridge.diameter);
      return diameterCm * 0.01; // Convert centimeters to meters
    } catch (e) {
      // If parsing fails, try to handle common caliber formats like ".308", "7.62", etc.
      String cleanDiameter = cartridge.diameter.replaceAll(RegExp(r'[^\d.]'), '');
      final double parsedValue = double.parse(cleanDiameter);
      
      // If value is less than 1, assume it's in inches (like .308) and convert to meters
      if (parsedValue < 1.0) {
        return parsedValue * 0.0254; // Convert inches to meters
      } else {
        // Otherwise assume it's in centimeters
        return parsedValue * 0.01; // Convert centimeters to meters
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
  }  static BallisticsResult calculateWithProfiles(
    double distance, 
    double windSpeed, 
    double windDirection,
    Gun? gun,
    Cartridge? cartridge,
    Scope? scope, {
    required double temperature,  // Made required
    required double pressure,     // Made required  
    required double humidity,     // Made required
    double elevationAngle = 0.0,  // Elevation angle in degrees
    double azimuthAngle = 0.0,    // Azimuth angle in degrees
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
    final double envTemperature = temperature; // °C - strictly from screen
    final double envPressure = pressure; // mbar - strictly from screen
    final double envHumidity = humidity; // % - strictly from screen
    
    // Convert pressure from mbar to Pa if needed
    final double pressurePa = envPressure < 10000 ? envPressure * 100 : envPressure;
    
    // Calculate air density based on environmental conditions
    final double rhoAir = calculateAirDensity(envTemperature, pressurePa, envHumidity);
    
    // Extract ballistics data from profiles
      // Projectile properties from cartridge
    final double bulletWeightGrains = cartridge.bulletWeight; // grains
    final double mass = bulletWeightGrains * 0.0000648; // Convert grains to kg
    final double ballisticCoefficient = cartridge.ballisticCoefficient; // G1 or G7
    final double diameter = _getDiameterFromCartridge(cartridge); // m
      
    // Gun properties
    final double muzzleVelocity = gun.muzzleVelocity; // m/s
    final double calibrationDistance = gun.zeroRange; // m
    
    // Scope properties
    final double sightHeightValue = scope.sightHeight; // value in units specified
    final int sightHeightUnits = scope.units; // 0: inches, 1: cm
    final double visorHeight = sightHeightUnits == 0 
        ? sightHeightValue * 0.0254 // Convert inches to meters
        : sightHeightValue * 0.01; // Convert cm to meters    // Convert wind direction to wind vector (simplified)
    final double windX = windSpeed * cos(windDirection * pi / 180);
    final double windY = windSpeed * sin(windDirection * pi / 180);
    final List<double> windVector = [windX, windY, 0.0];
    
    // Convert elevation angle from degrees to radians
    final double elevationAngleRad = elevationAngle * pi / 180;
    
    // Initial state
    List<double> pos = [0.0, 0.0, 0.0];
    List<double> vel = [muzzleVelocity * cos(elevationAngleRad), 0.0, muzzleVelocity * sin(elevationAngleRad)];
    
    double? driftH;
    double? dropZ;
    
    // Area
    final double A = pi * (diameter / 2) * (diameter / 2);
      for (int step = 0; step < (30.0 / dt).round(); step++) {
      // Local conditions (use dynamic temperature instead of constant)
      final double tLoc = envTemperature - 0.0065 * pos[2];
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
      final double CD = cartridge.bcModelType == 1 
          ? g7BallisticCoefficient(mach)
          : g1BallisticCoefficient(mach);
      
      // Drag force (use calculated air density and correct BC application)
      final double dragMagnitude = 0.5 * rhoAir * A * CD * vMagnitude * vMagnitude / ballisticCoefficient;
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
      }    }
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
}
