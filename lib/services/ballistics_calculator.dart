import '../models/gun_model.dart';
import '../models/cartridge_model.dart';
import '../models/scope_model.dart';
import 'ballistics_v5.dart' as v5;
import 'package:musca/utils/decimal_input.dart';

/// Resultado de un cálculo balístico.
///
/// Convenciones (modelo v5):
/// - [dropVertical]/[dropMrad]/... positivos = la bala queda POR ENCIMA de la
///   línea de mira (corrección a aplicar: bajar).
/// - [driftHorizontal]/[driftMrad]/... positivos = deriva a la DERECHA.
/// - Los valores lineales (drop/drift en m, cm, in) están referidos a la línea
///   de mira, igual que los angulares (antes los lineales iban referidos al
///   ánima: inconsistencia eliminada).
class BallisticsResult {
  // Desplazamientos respecto a la línea de mira
  final double driftHorizontal; // metros
  final double dropVertical; // metros

  // Correcciones MRAD
  final double driftMrad;
  final double dropMrad;
  final double driftMrad20; // incrementos de 0.05 MRAD
  final double dropMrad20;

  // Correcciones MOA
  final double driftMoa;
  final double dropMoa;
  final double driftMoa2; // 1/2 MOA
  final double dropMoa2;
  final double driftMoa3; // 1/3 MOA
  final double dropMoa3;
  final double driftMoa4; // 1/4 MOA
  final double dropMoa4;
  final double driftMoa8; // 1/8 MOA
  final double dropMoa8;

  // Correcciones lineales
  final double driftInches;
  final double dropInches;
  final double driftCm;
  final double dropCm;

  // Novedades del modelo v5
  final double timeS; // tiempo de vuelo [s]
  final double speedMs; // velocidad restante [m/s]
  final double energyJ; // energía restante [J]
  final double mach; // Mach relativo al aire
  final double spinDriftM; // deriva por giro [m] (NaN si Sg<1: desconocida)
  final bool spinUnstable; // true si Sg<1 (spinDriftM no es fiable)
  final List<String> warnings; // avisos del modelo (tabla Mach, Sg, ...)

  /// Trayectoria completa de la simulación, para gráficas y tablas sin
  /// volver a integrar.
  final v5.Trajectory trajectory;

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
    required this.timeS,
    required this.speedMs,
    required this.energyJ,
    required this.mach,
    required this.spinDriftM,
    required this.spinUnstable,
    required this.warnings,
    required this.trajectory,
  });
}

class BallisticsCalculator {
  static const double _grainKg = 6.479891e-5;
  static const double _mradToMoa = 1.0 / 0.290888;

  /// Conversión de presión a Pascales.
  /// 800-1200 (o < 800) se interpreta como mbar; >= 80000 como Pa.
  /// IMPORTANTE: la presión debe ser de ESTACIÓN (absoluta, medida a la altitud
  /// del tirador), no reducida a nivel del mar.
  static double convertPressureToPa(double pressure) {
    if (pressure >= 800 && pressure <= 1200) {
      return pressure * 100;
    } else if (pressure >= 80000) {
      return pressure;
    } else if (pressure < 800) {
      return pressure * 100;
    } else {
      return pressure;
    }
  }

  static double _diameterFromCartridge(Cartridge cartridge) {
    // El usuario introduce el diámetro en centímetros
    return parseDecimal(cartridge.diameter) * 0.01;
  }

  static v5.Projectile _projectileFrom(Gun gun, Cartridge cartridge) {
    // La UI define la estría como "1:X" con X en pulgadas/vuelta
    final double twistM = gun.twistRate * 0.0254;
    // La UI define la longitud de bala en centímetros (0 = desconocida)
    final double? lengthM =
        cartridge.bulletLength > 0 ? cartridge.bulletLength / 100.0 : null;
    return v5.Projectile(
      mass: cartridge.bulletWeight * _grainKg,
      diameter: _diameterFromCartridge(cartridge),
      bc: cartridge.ballisticCoefficient,
      dragModel: (cartridge.bcModelType ?? 0) == 1 ? 'G7' : 'G1',
      length: lengthM,
      twist: twistM,
      twistRight: gun.twistDirection != 0,
    );
  }

  static v5.Atmosphere _atmosphereFrom({
    required double temperatureC,
    required double pressureRaw,
    required double humidityPercent,
    double altitude = 0.0,
  }) {
    return v5.Atmosphere(
      stationAltitude: altitude,
      temperature: temperatureC + 273.15,
      pressure: convertPressureToPa(pressureRaw),
      relHumidity: (humidityPercent / 100.0).clamp(0.0, 1.0),
    );
  }

  static double _sightHeightM(Scope scope) {
    return scope.units == 0
        ? scope.sightHeight * 0.0254
        : scope.sightHeight * 0.01;
  }

  /// Dirección del viento de la UI (0 = de cara, 90 = de la izquierda,
  /// 180 = de cola, 270 = de la derecha) al ángulo "desde" del modelo v5
  /// (0 = de cara, 90 = de la derecha, horario visto desde arriba).
  static double _windFromAngle(double uiDirection) {
    return (360.0 - uiDirection) % 360.0;
  }

  /// Método legacy con perfiles de prueba por defecto.
  static BallisticsResult calculate(
    double distance,
    double windSpeed,
    double windDirection,
  ) {
    final defaultGun = Gun(
      id: 'default-test-gun',
      name: 'Default Test Rifle',
      twistRate: 12.0, // 1:12"
      twistDirection: 1,
      muzzleVelocity: 820.0,
      zeroRange: 100.0,
    );
    final defaultCartridge = Cartridge(
      id: 'default-test-cartridge',
      name: 'Default Test .308',
      diameter: '0.782',
      bulletWeight: 150.0,
      bulletLength: 0.0,
      ballisticCoefficient: 0.504,
      bcModelType: 0,
    );
    final defaultScope = Scope(
      id: 'default-test-scope',
      name: 'Default Test Scope',
      sightHeight: 2.17,
      units: 0,
    );
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
  }

  /// Cálculo balístico con perfiles de usuario (modelo v5).
  ///
  /// - [distance]: distancia al blanco [m].
  /// - [windSpeed] [m/s], [windDirection]: 0 = de cara, 90 = de la izquierda.
  /// - [elevationAngle]: ángulo del tiro respecto a la horizontal [grados].
  /// - [azimuthAngle]: acimut del disparo [grados] (afecta al Coriolis).
  /// - [slopeAngle]: pendiente del terreno [grados]; se suma al ángulo de tiro.
  /// - [latitude]: latitud [grados] (Coriolis).
  /// - [altitude]: altitud de la boca del arma sobre el nivel del mar [m].
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
    double altitude = 0.0,
    double? fixedLosSlope, // ignorado: la LOS se deriva del cero del arma
  }) {
    if (gun == null) {
      throw ArgumentError('Gun profile is required for ballistics calculation');
    }
    if (cartridge == null) {
      throw ArgumentError(
        'Cartridge profile is required for ballistics calculation',
      );
    }
    if (scope == null) {
      throw ArgumentError(
        'Scope profile is required for ballistics calculation',
      );
    }
    if (distance <= 0) {
      throw ArgumentError('Distance must be greater than 0');
    }
    if (elevationAngle < -90.0 || elevationAngle > 90.0) {
      throw ArgumentError('Elevation angle must be between -90 and 90 degrees');
    }
    if (slopeAngle < -90.0 || slopeAngle > 90.0) {
      throw ArgumentError('Slope angle must be between -90 and 90 degrees');
    }

    final proj = _projectileFrom(gun, cartridge);
    final atm = _atmosphereFrom(
      temperatureC: temperature,
      pressureRaw: pressure,
      humidityPercent: humidity,
      altitude: altitude,
    );
    final sightHeight = _sightHeightM(scope);
    final shotAngleDeg = elevationAngle + slopeAngle;

    // Elevación del ánima: la del cero del arma (resuelta con tiro horizontal)
    // más el ángulo del tiro actual.
    double zeroElDeg = 0.0;
    if (gun.zeroRange > 0.0) {
      zeroElDeg = v5.solveElevation(
        proj,
        gun.muzzleVelocity,
        gun.zeroRange,
        sightHeight: sightHeight,
        atmosphere: atm,
      );
    }
    final boreElDeg = zeroElDeg + shotAngleDeg;

    final wind = v5.windVector(windSpeed, _windFromAngle(windDirection));
    final trajectory = v5.simulate(
      proj,
      gun.muzzleVelocity,
      boreElDeg,
      azimuthDeg: azimuthAngle,
      latitudeDeg: latitude,
      wind: wind,
      atmosphere: atm,
      groundLevel: null,
      maxRange: distance * 1.05 + 1.0,
    );
    final sample = trajectory.atRange(
      distance,
      sightHeight: sightHeight,
      losAngleDeg: shotAngleDeg,
    );

    return _resultFromSample(sample, trajectory, distance);
  }

  /// Construye el resultado en todas las unidades a partir de una muestra de
  /// trayectoria (referida a la línea de mira).
  static BallisticsResult _resultFromSample(
    v5.RangeSample sample,
    v5.Trajectory trajectory,
    double distance,
  ) {
    final heightDifference = sample.dropM;
    final lateralDifference = sample.driftTotalM;

    final correctedDropMrad = heightDifference / distance * 1000.0;
    final correctedDriftMrad = lateralDifference / distance * 1000.0;

    final driftMrad20 = (correctedDriftMrad / 0.05).round() * 0.05;
    final dropMrad20 = (correctedDropMrad / 0.05).round() * 0.05;

    final correctedDriftMoa = correctedDriftMrad * _mradToMoa;
    final correctedDropMoa = correctedDropMrad * _mradToMoa;
    final driftMoa2 = (correctedDriftMoa / 0.5).round() * 0.5;
    final dropMoa2 = (correctedDropMoa / 0.5).round() * 0.5;
    final driftMoa3 = (correctedDriftMoa / (1.0 / 3.0)).round() * (1.0 / 3.0);
    final dropMoa3 = (correctedDropMoa / (1.0 / 3.0)).round() * (1.0 / 3.0);
    final driftMoa4 = (correctedDriftMoa / 0.25).round() * 0.25;
    final dropMoa4 = (correctedDropMoa / 0.25).round() * 0.25;
    final driftMoa8 = (correctedDriftMoa / 0.125).round() * 0.125;
    final dropMoa8 = (correctedDropMoa / 0.125).round() * 0.125;

    return BallisticsResult(
      driftHorizontal: lateralDifference,
      dropVertical: heightDifference,
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
      driftInches: lateralDifference * 39.3701,
      dropInches: heightDifference * 39.3701,
      driftCm: lateralDifference * 100.0,
      dropCm: heightDifference * 100.0,
      timeS: sample.timeS,
      speedMs: sample.speedMs,
      energyJ: sample.energyJ,
      mach: sample.mach,
      spinDriftM: sample.spinDriftM,
      spinUnstable: sample.spinUnstable,
      warnings: trajectory.warnings,
      trajectory: trajectory,
    );
  }

  /// Alias de compatibilidad: en el modelo v5 la línea de mira SIEMPRE se
  /// deriva del cero del arma (el comportamiento "fixed LOS" es el nativo).
  static BallisticsResult calculateWithFixedLos(
    double distance,
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
    double latitude = 0.0,
    double altitude = 0.0,
  }) {
    return calculateWithProfiles(
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
      latitude: latitude,
      altitude: altitude,
    );
  }

  /// Tabla balística reutilizando UNA sola simulación.
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
    double latitude = 0.0,
    double altitude = 0.0,
  }) {
    if (interval <= 0) {
      throw ArgumentError('Interval must be greater than 0');
    }
    // Una simulación hasta la distancia máxima; cada fila se interpola.
    final probe = calculateWithProfiles(
      endDistance,
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
      latitude: latitude,
      altitude: altitude,
    );
    final sightHeight = _sightHeightM(scope);
    final shotAngleDeg = elevationAngle + slopeAngle;
    final results = <BallisticsResult>[];
    double d = startDistance;
    while (d <= endDistance + 1e-9) {
      results.add(
        d == endDistance
            ? probe
            : _resultFromSample(
              probe.trajectory.atRange(
                d,
                sightHeight: sightHeight,
                losAngleDeg: shotAngleDeg,
              ),
              probe.trajectory,
              d,
            ),
      );
      d += interval;
    }
    return results;
  }
}
