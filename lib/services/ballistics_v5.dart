/// MODELO BALÍSTICO EXTERIOR 3D POR COEFICIENTE BALÍSTICO (G1 / G7)
/// =================================================================
/// Port a Dart del modelo Python v5 validado contra tablas públicas
/// (Beck/JBM, Hornady, Federal: caída <0.5" a 500 yd, velocidad <0.06%).
///
/// Sistema de coordenadas (mano derecha), origen en la boca del arma:
///   x = distancia horizontal en la dirección de tiro
///   y = vertical (arriba +)
///   z = lateral (derecha +)
///
/// Modelo físico (masa puntual, 3 grados de libertad):
///   dv/dt = -(pi/8) * rho * Cd(M) * |v_r| * v_r / BC_SI   (arrastre)
///           + g                                          (gravedad, -y)
///           - 2 * Omega x v                              (Coriolis)
///   v_r = v - v_viento;  M = |v_r| / a(T)
///
/// Atmósfera ISA 1976 anclada a las condiciones reales de la estación.
/// Deriva por giro: aproximación empírica de Litz con estabilidad de Miller.
library;

import 'dart:math' as math;

const double kG0 = 9.80665; // m/s^2
const double kRAir = 287.05287; // J/(kg K), aire seco
const double kGamma = 1.4;
const double kOmegaEarth = 7.2921159e-5; // rad/s, rotación terrestre (sidérea)
const double kLbPerIn2ToKgPerM2 = 0.45359237 / (0.0254 * 0.0254); // 703.0696
const double kGrainKg = 6.479891e-5;
const double kFpsToMs = 0.3048;
const double kEpsVapor = 0.62198;
const double kREarth = 6356766.0; // m, radio terrestre de la ISA 1976

// ---------------------------------------------------------------------------
// TABLAS DE ARRASTRE ESTÁNDAR (Mach, Cd) - Ingalls/Mayevski G1; G7 Litz/Krupp
// ---------------------------------------------------------------------------
const List<List<double>> kG1Table = [
  [0.00, 0.2629], [0.05, 0.2558], [0.10, 0.2487], [0.15, 0.2413],
  [0.20, 0.2344], [0.25, 0.2278], [0.30, 0.2214], [0.35, 0.2155],
  [0.40, 0.2104], [0.45, 0.2061], [0.50, 0.2032], [0.55, 0.2020],
  [0.60, 0.2034], [0.70, 0.2165], [0.725, 0.2230], [0.75, 0.2313],
  [0.775, 0.2417], [0.80, 0.2546], [0.825, 0.2706], [0.85, 0.2901],
  [0.875, 0.3136], [0.90, 0.3415], [0.925, 0.3734], [0.95, 0.4084],
  [0.975, 0.4448], [1.00, 0.4805], [1.025, 0.5136], [1.05, 0.5427],
  [1.075, 0.5677], [1.10, 0.5883], [1.125, 0.6053], [1.15, 0.6191],
  [1.20, 0.6393], [1.25, 0.6518], [1.30, 0.6589], [1.35, 0.6621],
  [1.40, 0.6625], [1.45, 0.6607], [1.50, 0.6573], [1.55, 0.6528],
  [1.60, 0.6474], [1.65, 0.6413], [1.70, 0.6347], [1.75, 0.6280],
  [1.80, 0.6210], [1.85, 0.6141], [1.90, 0.6072], [1.95, 0.6003],
  [2.00, 0.5934], [2.05, 0.5867], [2.10, 0.5804], [2.15, 0.5743],
  [2.20, 0.5685], [2.25, 0.5630], [2.30, 0.5577], [2.35, 0.5527],
  [2.40, 0.5481], [2.45, 0.5438], [2.50, 0.5397], [2.60, 0.5325],
  [2.70, 0.5264], [2.80, 0.5211], [2.90, 0.5168], [3.00, 0.5133],
  [3.10, 0.5105], [3.20, 0.5084], [3.30, 0.5067], [3.40, 0.5054],
  [3.50, 0.5040], [3.60, 0.5030], [3.70, 0.5022], [3.80, 0.5016],
  [3.90, 0.5010], [4.00, 0.5006], [4.20, 0.4998], [4.40, 0.4995],
  [4.60, 0.4992], [4.80, 0.4990], [5.00, 0.4988],
];

const List<List<double>> kG7Table = [
  [0.00, 0.1198], [0.05, 0.1197], [0.10, 0.1196], [0.15, 0.1194],
  [0.20, 0.1193], [0.25, 0.1194], [0.30, 0.1194], [0.35, 0.1194],
  [0.40, 0.1193], [0.45, 0.1193], [0.50, 0.1194], [0.55, 0.1193],
  [0.60, 0.1194], [0.65, 0.1197], [0.70, 0.1202], [0.725, 0.1207],
  [0.75, 0.1215], [0.775, 0.1226], [0.80, 0.1242], [0.825, 0.1266],
  [0.85, 0.1306], [0.875, 0.1368], [0.90, 0.1464], [0.925, 0.1660],
  [0.95, 0.2054], [0.975, 0.2993], [1.00, 0.3803], [1.025, 0.4015],
  [1.05, 0.4043], [1.075, 0.4034], [1.10, 0.4014], [1.125, 0.3987],
  [1.15, 0.3955], [1.20, 0.3884], [1.25, 0.3810], [1.30, 0.3732],
  [1.35, 0.3657], [1.40, 0.3580], [1.50, 0.3440], [1.55, 0.3376],
  [1.60, 0.3315], [1.65, 0.3260], [1.70, 0.3209], [1.75, 0.3160],
  [1.80, 0.3117], [1.85, 0.3078], [1.90, 0.3042], [1.95, 0.3010],
  [2.00, 0.2980], [2.05, 0.2951], [2.10, 0.2922], [2.15, 0.2892],
  [2.20, 0.2864], [2.25, 0.2835], [2.30, 0.2807], [2.35, 0.2779],
  [2.40, 0.2752], [2.45, 0.2725], [2.50, 0.2697], [2.55, 0.2670],
  [2.60, 0.2643], [2.65, 0.2615], [2.70, 0.2588], [2.75, 0.2561],
  [2.80, 0.2533], [2.85, 0.2506], [2.90, 0.2479], [2.95, 0.2451],
  [3.00, 0.2424], [3.10, 0.2368], [3.20, 0.2313], [3.30, 0.2258],
  [3.40, 0.2205], [3.50, 0.2154], [3.60, 0.2106], [3.70, 0.2060],
  [3.80, 0.2017], [3.90, 0.1975], [4.00, 0.1935], [4.20, 0.1861],
  [4.40, 0.1793], [4.60, 0.1730], [4.80, 0.1672], [5.00, 0.1618],
];

/// Cd(M) por interpolación PCHIP monótona (Fritsch-Carlson) sobre la tabla,
/// equivalente al PCHIP del modelo Python (sin oscilaciones, Cd nunca negativo).
class DragModel {
  final String name;
  final List<double> _m;
  final List<double> _c;
  late final List<double> _slope; // derivadas PCHIP en los nodos
  bool _warned = false;
  List<String>? warnSink;

  DragModel(this.name, List<List<double>> table)
      : _m = [for (final r in table) r[0]],
        _c = [for (final r in table) r[1]] {
    _slope = _pchipSlopes(_m, _c);
  }

  static List<double> _pchipSlopes(List<double> x, List<double> y) {
    final n = x.length;
    final d = List<double>.filled(n, 0.0);
    final h = List<double>.generate(n - 1, (i) => x[i + 1] - x[i]);
    final delta = List<double>.generate(n - 1, (i) => (y[i + 1] - y[i]) / h[i]);
    // Extremos (esquema no centrado de tres puntos, con limitado)
    double endpoint(double h0, double h1, double d0, double d1) {
      var v = ((2 * h0 + h1) * d0 - h0 * d1) / (h0 + h1);
      if (v.sign != d0.sign) v = 0.0;
      if (d0.sign != d1.sign && v.abs() > 3 * d0.abs()) v = 3 * d0;
      return v;
    }

    d[0] = endpoint(h[0], h[1], delta[0], delta[1]);
    d[n - 1] = endpoint(h[n - 2], h[n - 3], delta[n - 2], delta[n - 3]);
    for (var i = 1; i < n - 1; i++) {
      if (delta[i - 1] == 0.0 || delta[i] == 0.0 || delta[i - 1].sign != delta[i].sign) {
        d[i] = 0.0;
      } else {
        final w1 = 2 * h[i] + h[i - 1];
        final w2 = h[i] + 2 * h[i - 1];
        d[i] = (w1 + w2) / (w1 / delta[i - 1] + w2 / delta[i]);
      }
    }
    return d;
  }

  double get _mmax => _m.last;

  double cd(double mach) {
    if (mach >= _mmax) {
      if (mach > _mmax + 1e-9 && !_warned) {
        _warned = true;
        warnSink?.add(
            'Mach ${mach.toStringAsFixed(2)} > ${_mmax.toStringAsFixed(1)}: fuera de la tabla $name. '
            'Se mantiene Cd constante (asíntota hipersónica, nunca negativo); '
            'G1/G7 no están validadas a esta velocidad.');
      }
      return _c.last; // extrapolación constante
    }
    if (mach <= 0) return _c.first;
    var i = 0;
    // búsqueda binaria del intervalo
    var lo = 0, hi = _m.length - 1;
    while (hi - lo > 1) {
      final mid = (lo + hi) >> 1;
      if (_m[mid] <= mach) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    i = lo;
    final h = _m[i + 1] - _m[i];
    final t = (mach - _m[i]) / h;
    final t2 = t * t, t3 = t2 * t;
    // Hermite cúbico con pendientes PCHIP
    final h00 = 2 * t3 - 3 * t2 + 1;
    final h10 = t3 - 2 * t2 + t;
    final h01 = -2 * t3 + 3 * t2;
    final h11 = t3 - t2;
    return h00 * _c[i] + h10 * h * _slope[i] + h01 * _c[i + 1] + h11 * h * _slope[i + 1];
  }
}

final Map<String, DragModel> kDragModels = {
  'G1': DragModel('G1', kG1Table),
  'G7': DragModel('G7', kG7Table),
};

// ---------------------------------------------------------------------------
// ATMÓSFERA (ISA 1976 con condiciones reales en la estación de tiro)
// ---------------------------------------------------------------------------
// (altitud base geopotencial [m], gradiente [K/m])
const List<List<double>> _isaLayers = [
  [0.0, -0.0065], [11000.0, 0.0], [20000.0, 0.0010],
  [32000.0, 0.0028], [47000.0, 0.0], [51000.0, -0.0028],
  [71000.0, -0.0020],
];

double _geopotential(double h) => kREarth * h / (kREarth + h);

List<double> _layerTop(double tb, double pb, double l, double dh) {
  final t = tb + l * dh;
  final p = l != 0.0
      ? pb * math.pow(t / tb, -kG0 / (kRAir * l)).toDouble()
      : pb * math.exp(-kG0 * dh / (kRAir * tb));
  return [t, p];
}

List<List<double>> _isaBases() {
  final bases = <List<double>>[
    [0.0, 288.15, 101325.0, _isaLayers[0][1]]
  ];
  for (var j = 1; j < _isaLayers.length; j++) {
    final last = bases.last;
    final tb = last[1], pb = last[2], l = last[3];
    final h1 = _isaLayers[j][0];
    final tp = _layerTop(tb, pb, l, h1 - last[0]);
    bases.add([h1, tp[0], tp[1], _isaLayers[j][1]]);
  }
  return bases;
}

final List<List<double>> _kIsaBases = _isaBases();

/// (T [K], P [Pa]) de la ISA 1976 a altitud GEOMÉTRICA h [m].
List<double> isa(double h) {
  final hg = _geopotential(h);
  var base = _kIsaBases[0];
  for (final b in _kIsaBases) {
    if (hg >= b[0]) base = b;
  }
  return _layerTop(base[1], base[2], base[3], hg - base[0]);
}

double _eSat(double tC) {
  /// Presión de vapor de saturación [Pa] (Buck 1996).
  return 611.21 * math.exp((18.678 - tC / 234.5) * tC / (257.14 + tC));
}

class Atmosphere {
  /// Atmósfera por capas anclada a las condiciones medidas en la estación.
  /// [stationAltitude]: altitud ASL de la boca del arma [m].
  /// [temperature]: T real en la estación [K] (null -> ISA).
  /// [pressure]: P real de ESTACIÓN [Pa] (null -> ISA). No reducida al mar.
  /// [relHumidity]: 0..1. Se supone cociente e/P constante con la altura.
  Atmosphere({
    double stationAltitude = 0.0,
    double? temperature,
    double? pressure,
    double relHumidity = 0.0,
  })  : hStation = stationAltitude {
    final isaSt = isa(stationAltitude);
    final tSt = temperature ?? isaSt[0];
    final pSt = pressure ?? isaSt[1];
    tStation = tSt;
    pStation = pSt;
    final hSt = _geopotential(stationAltitude);
    var k = 0;
    for (var i = 0; i < _isaLayers.length; i++) {
      if (hSt >= _isaLayers[i][0]) k = i;
    }
    _layers = [
      [hSt, tSt, pSt, _isaLayers[k][1]]
    ];
    for (var j = k + 1; j < _isaLayers.length; j++) {
      final last = _layers.last;
      final h1 = _isaLayers[j][0];
      final tp = _layerTop(last[1], last[2], last[3], h1 - last[0]);
      _layers.add([h1, tp[0], tp[1], _isaLayers[j][1]]);
    }
    final e = relHumidity * _eSat(tSt - 273.15);
    _r = e / pSt;
  }

  final double hStation;
  late final double tStation;
  late final double pStation;
  late final List<List<double>> _layers;
  late final double _r;

  /// Devuelve (T, P, rho, a) a altitud ASL GEOMÉTRICA h [m].
  List<double> state(double h) {
    final hg = kREarth * h / (kREarth + h);
    var layer = _layers[0];
    for (final lay in _layers) {
      if (hg >= lay[0]) layer = lay;
    }
    final tp = _layerTop(layer[1], layer[2], layer[3], hg - layer[0]);
    final t = tp[0], p = tp[1];
    final tv = t / (1.0 - _r * (1.0 - kEpsVapor)); // temperatura virtual
    final rho = p / (kRAir * tv);
    final a = math.sqrt(kGamma * kRAir * tv);
    return [t, p, rho, a];
  }
}

// ---------------------------------------------------------------------------
// PROYECTIL
// ---------------------------------------------------------------------------
class Projectile {
  /// [mass] kg, [diameter] m, [bc] coeficiente balístico (G1 o G7 según
  /// [dragModel]), [bcUnits] 'imperial' (lb/in^2, el de catálogo) o 'si'.
  /// [length] m y [twist] m/vuelta (opcionales; necesarios para la deriva
  /// por giro). [twistRight]: true = estría a derechas.
  Projectile({
    required this.mass,
    required this.diameter,
    required this.bc,
    this.bcUnits = 'imperial',
    this.dragModel = 'G1',
    this.length,
    this.twist,
    this.twistRight = true,
  }) {
    if (bc <= 0 || mass <= 0 || diameter <= 0) {
      throw ArgumentError('mass, diameter y bc deben ser > 0');
    }
    if (bcUnits != 'imperial' && bcUnits != 'si') {
      throw ArgumentError("bcUnits debe ser 'imperial' o 'si'");
    }
    if (!kDragModels.containsKey(dragModel)) {
      throw ArgumentError("dragModel debe ser 'G1' o 'G7'");
    }
  }

  final double mass;
  final double diameter;
  final double bc;
  final String bcUnits;
  final String dragModel;
  final double? length;
  final double? twist;
  final bool twistRight;

  double get bcSi => bc * (bcUnits == 'imperial' ? kLbPerIn2ToKgPerM2 : 1.0);

  /// m/d^2 [kg/m^2]
  double get sectionalDensity => mass / (diameter * diameter);

  /// i = (m/d^2)/BC. i<1: mejor forma que el proyectil de referencia.
  double get formFactor => sectionalDensity / bcSi;
}

/// Viento (vx, vy, vz) en el sistema de tiro [m/s].
/// [fromAngleDeg]: dirección DE DONDE sopla, horaria desde la dirección de
/// tiro (0 = de cara, 90 = de la derecha / las 3, 180 = de cola, 270 = de la
/// izquierda).
List<double> windVector(double speed, double fromAngleDeg,
    {double vertical = 0.0}) {
  final th = fromAngleDeg * math.pi / 180.0;
  return [-speed * math.cos(th), vertical, -speed * math.sin(th)];
}

// ---------------------------------------------------------------------------
// DERIVA POR GIRO (Miller + Litz)
// ---------------------------------------------------------------------------
/// Factor de estabilidad Sg de Miller (con corrección atmosférica).
double gyroscopicStability(Projectile proj, double v0, double t, double p) {
  final length = proj.length, twist = proj.twist;
  if (length == null || twist == null) {
    throw ArgumentError('Se necesitan length y twist');
  }
  final mGr = proj.mass / kGrainKg;
  final dIn = proj.diameter / 0.0254;
  final lCal = length / proj.diameter;
  final tCal = twist / proj.diameter;
  final tF = t * 9.0 / 5.0 - 459.67;
  final pInHg = p / 3386.389;
  var sg = 30.0 * mGr / (tCal * tCal * dIn * dIn * dIn * lCal * (1.0 + lCal * lCal));
  sg *= math.pow((v0 / kFpsToMs) / 2800.0, 1.0 / 3.0).toDouble();
  sg *= (tF + 460.0) / 519.0 * 29.92 / pInHg;
  return sg;
}

/// Deriva lateral por giro [m] a tiempo de vuelo t (Litz). Válida Sg > 1.
double spinDrift(double t, double sg, {bool right = true}) {
  final sdIn = 1.25 * (sg + 1.2) * math.pow(t, 1.83).toDouble();
  return (right ? 1.0 : -1.0) * sdIn * 0.0254;
}

// ---------------------------------------------------------------------------
// RESULTADOS
// ---------------------------------------------------------------------------
class RangeSample {
  final double rangeM, timeS, yM, sightLineM, dropM, dropMrad;
  final double driftWindCoriolisM, spinDriftM, driftTotalM, driftMrad;
  final double speedMs, mach, energyJ;

  /// true: Sg<1, deriva por giro desconocida y excluida del total.
  final bool spinUnstable;

  const RangeSample({
    required this.rangeM,
    required this.timeS,
    required this.yM,
    required this.sightLineM,
    required this.dropM,
    required this.dropMrad,
    required this.driftWindCoriolisM,
    required this.spinDriftM,
    required this.driftTotalM,
    required this.spinUnstable,
    required this.driftMrad,
    required this.speedMs,
    required this.mach,
    required this.energyJ,
  });
}

class ImpactResult {
  final double rangeM, timeS, speedMs, angleDeg, spinDriftM, driftTotalM;
  final bool spinUnstable, hitGround, hitMaxRange, tMaxReached;

  const ImpactResult({
    required this.rangeM,
    required this.timeS,
    required this.speedMs,
    required this.angleDeg,
    required this.spinDriftM,
    required this.spinUnstable,
    required this.driftTotalM,
    required this.hitGround,
    required this.hitMaxRange,
    required this.tMaxReached,
  });
}

// ---------------------------------------------------------------------------
// TRAYECTORIA (malla integrada + interpolación Hermite)
// ---------------------------------------------------------------------------
class Trajectory {
  final Projectile proj;
  final double v0;
  final double elevationRad;
  final Atmosphere atm;
  final double? groundLevel;
  final double? sg;
  final List<double> wind; // (vx, vy, vz)
  final List<String> warnings;

  // Malla almacenada: tiempos, estados (6) y derivadas (6) por punto.
  final List<double> _ts;
  final List<List<double>> _ys;
  final List<List<double>> _fs;
  final bool _hitGround;
  final bool _hitMaxRange;
  final bool _tMaxReached;

  Trajectory(this.proj, this.v0, this.elevationRad, this.atm, this.groundLevel,
      this.sg, this.wind, this.warnings, this._ts, this._ys, this._fs,
      this._hitGround, this._hitMaxRange)
      : _tMaxReached = !_hitGround && !_hitMaxRange;

  bool get hitGround => _hitGround;
  bool get hitMaxRange => _hitMaxRange;

  /// true si la integración llegó a tMax sin evento terminal: con un plano de
  /// suelo por encima de la trayectoria la bala nunca lo alcanza, y
  /// hitGround=false solo significa "no impactó", no "cayó".
  bool get tMaxReached => _tMaxReached;

  double get tEnd => _ts.last;
  double get xEnd => _ys.last[0];

  /// Deriva por giro [m]: 0 si no hay datos de estría; NaN si el proyectil es
  /// inestable (Sg<1), porque la fórmula de Litz no es válida en ese régimen
  /// y la deriva es desconocida (un 0 se leería como "sin deriva").
  double _spinDrift(double t) {
    final s = sg;
    if (s == null) return 0.0;
    if (s < 1.0) return double.nan;
    return spinDrift(t, s, right: proj.twistRight);
  }

  /// Estado interpolado (Hermite cúbico) a tiempo t.
  List<double> state(double t) {
    if (t <= _ts.first) return List<double>.from(_ys.first);
    if (t >= _ts.last) return List<double>.from(_ys.last);
    var lo = 0, hi = _ts.length - 1;
    while (hi - lo > 1) {
      final mid = (lo + hi) >> 1;
      if (_ts[mid] <= t) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    final h = _ts[hi] - _ts[lo];
    final s = (t - _ts[lo]) / h;
    final s2 = s * s, s3 = s2 * s;
    final h00 = 2 * s3 - 3 * s2 + 1;
    final h10 = s3 - 2 * s2 + s;
    final h01 = -2 * s3 + 3 * s2;
    final h11 = s3 - s2;
    final y0 = _ys[lo], y1 = _ys[hi], f0 = _fs[lo], f1 = _fs[hi];
    return List<double>.generate(
        6, (i) => h00 * y0[i] + h10 * h * f0[i] + h01 * y1[i] + h11 * h * f1[i]);
  }

  /// Tiempo de vuelo alcanzar la distancia horizontal X.
  double timeAtRange(double x) {
    if (x > xEnd + 1e-6 || x < 0) {
      throw ArgumentError('Distancia fuera de la trayectoria');
    }
    x = math.min(x, xEnd);
    // bracket por barrido de la malla
    var idx = 0;
    for (var i = 0; i < _ys.length; i++) {
      if (_ys[i][0] >= x) {
        idx = i;
        break;
      }
    }
    var t = _ts[idx];
    if (idx > 0) {
      final x0 = _ys[idx - 1][0], x1 = _ys[idx][0];
      if (x1 > x0) t = _ts[idx - 1] + (_ts[idx] - _ts[idx - 1]) * (x - x0) / (x1 - x0);
    }
    for (var it = 0; it < 6; it++) {
      final s = state(t);
      if (s[3] == 0) break;
      t -= (s[0] - x) / s[3];
      t = math.min(math.max(t, 0.0), tEnd);
    }
    return t;
  }

  /// Estado a distancia horizontal X.
  ///
  /// Línea de mira (LOS): recta que parte de la mira, a [sightHeight] sobre el
  /// eje del ánima en la boca, con inclinación [losAngleDeg] respecto a la
  /// horizontal (0 = blanco a la altura de la mira, la convención estándar).
  RangeSample atRange(double x, {double sightHeight = 0.0, double losAngleDeg = 0.0}) {
    final t = timeAtRange(x);
    final s = state(t);
    final px = s[0], py = s[1], pz = s[2], vx = s[3], vy = s[4], vz = s[5];
    final a = atm.state(atm.hStation + py)[3];
    final v = math.sqrt(vx * vx + vy * vy + vz * vz); // respecto al suelo
    final wx = wind[0], wy = wind[1], wz = wind[2];
    final vr = math.sqrt((vx - wx) * (vx - wx) + (vy - wy) * (vy - wy) + (vz - wz) * (vz - wz));
    final sd = _spinDrift(t);
    final sdOk = !sd.isNaN;
    final sdUsed = sdOk ? sd : 0.0; // el total excluye el término desconocido
    final yLos = sightHeight + px * math.tan(losAngleDeg * math.pi / 180.0);
    final drop = py - yLos; // respecto a la línea de mira
    return RangeSample(
      rangeM: px,
      timeS: t,
      yM: py,
      sightLineM: yLos,
      dropM: drop,
      dropMrad: px > 0 ? math.atan2(yLos - py, px) * 1000.0 : 0.0,
      driftWindCoriolisM: pz,
      spinDriftM: sd,
      driftTotalM: pz + sdUsed,
      spinUnstable: !sdOk,
      driftMrad: px > 0 ? (pz + sdUsed) / px * 1000.0 : 0.0,
      speedMs: v,
      mach: a != 0 ? vr / a : double.nan, // Mach relativo al aire
      energyJ: 0.5 * proj.mass * v * v,
    );
  }

  List<RangeSample?> table(List<double> ranges,
      {double sightHeight = 0.0, double losAngleDeg = 0.0}) {
    return [
      for (final x in ranges)
        x <= xEnd + 1e-6
            ? atRange(x, sightHeight: sightHeight, losAngleDeg: losAngleDeg)
            : null
    ];
  }

  /// Altura máxima sobre la boca [m].
  double get maxHeight {
    var m = -double.infinity;
    for (final y in _ys) {
      if (y[1] > m) m = y[1];
    }
    return m;
  }

  ImpactResult get impact {
    final t = tEnd;
    final s = state(t);
    final v = math.sqrt(s[3] * s[3] + s[4] * s[4] + s[5] * s[5]);
    final sd = _spinDrift(t);
    final sdOk = !sd.isNaN;
    return ImpactResult(
      rangeM: s[0],
      timeS: t,
      speedMs: v,
      angleDeg: math.atan2(-s[4], s[3]) * 180.0 / math.pi,
      spinDriftM: sd,
      spinUnstable: !sdOk,
      driftTotalM: s[2] + (sdOk ? sd : 0.0),
      hitGround: _hitGround,
      hitMaxRange: _hitMaxRange,
      tMaxReached: _tMaxReached,
    );
  }
}

// ---------------------------------------------------------------------------
// SIMULACIÓN (RKF45 adaptativo con salida densa Hermite)
// ---------------------------------------------------------------------------
Trajectory simulate(
  Projectile proj,
  double muzzleVelocity,
  double elevationDeg, {
  double azimuthDeg = 0.0,
  double? latitudeDeg,
  List<double> wind = const [0.0, 0.0, 0.0],
  Atmosphere? atmosphere,
  double? groundLevel = 0.0,
  double maxRange = 1.0e6,
  double tMax = 900.0,
  double rtol = 1e-8,
  double atol = 1e-9,
}) {
  final atm = atmosphere ?? Atmosphere();
  final drag = kDragModels[proj.dragModel]!;
  drag._warned = false; // un aviso por simulación
  final warnings = <String>[];
  drag.warnSink = warnings;
  final k0 = math.pi / 8.0 / proj.bcSi;
  final hSt = atm.hStation;
  final wx = wind[0], wy = wind[1], wz = wind[2];

  double ox = 0.0, oy = 0.0, oz = 0.0;
  var coriolis = false;
  if (latitudeDeg != null) {
    final phi = latitudeDeg * math.pi / 180.0;
    final alpha = azimuthDeg * math.pi / 180.0;
    ox = kOmegaEarth * math.cos(phi) * math.cos(alpha);
    oy = kOmegaEarth * math.sin(phi);
    oz = -kOmegaEarth * math.cos(phi) * math.sin(alpha);
    coriolis = true;
  }

  List<double> rhs(double t, List<double> s) {
    final py = s[1], vx = s[3], vy = s[4], vz = s[5];
    final st = atm.state(hSt + py);
    final rho = st[2], a = st[3];
    final rx = vx - wx, ry = vy - wy, rz = vz - wz;
    final vr = math.sqrt(rx * rx + ry * ry + rz * rz);
    final k = k0 * rho * drag.cd(vr / a) * vr;
    var ax = -k * rx, ay = -k * ry - kG0, az = -k * rz;
    if (coriolis) {
      // a = -2 Omega x v
      ax -= 2.0 * (oy * vz - oz * vy);
      ay -= 2.0 * (oz * vx - ox * vz);
      az -= 2.0 * (ox * vy - oy * vx);
    }
    return [vx, vy, vz, ax, ay, az];
  }

  final el = elevationDeg * math.pi / 180.0;
  final s0 = <double>[
    0.0, 0.0, 0.0,
    muzzleVelocity * math.cos(el),
    muzzleVelocity * math.sin(el),
    0.0
  ];

  // Guarda solo si el suelo coincide con la boca (y0 == groundLevel): ahí el
  // evento vale 0 en t=0 y se dispararía en el primer paso con un tiro a
  // nivel o descendente.
  final guardMuzzle = groundLevel == 0.0;

  double groundEvent(List<double> s) {
    if (guardMuzzle && s[0] <= 1e-3) return 1.0;
    return s[1] - groundLevel!;
  }

  final ts = <double>[0.0];
  final ys = <List<double>>[List<double>.from(s0)];
  final fs = <List<double>>[rhs(0.0, s0)];

  var t = 0.0;
  var y = List<double>.from(s0);
  var h = 1e-5;
  var hitGround = false;
  var hitMaxRange = false;

  List<double> rkStep(List<double> yc, double tc, double hc, List<double> errOut) {
    List<double> f(List<double> yy, double tt) => rhs(tt, yy);
    List<double> add(List<double> a2, List<double> b2, double c2) =>
        [for (var i = 0; i < 6; i++) a2[i] + hc * c2 * b2[i]];
    final k1 = fs.last;
    final k2 = f(add(yc, k1, 1.0 / 4.0), tc + hc / 4.0);
    final k3 = f(
        [for (var i = 0; i < 6; i++) yc[i] + hc * (3.0 / 32.0 * k1[i] + 9.0 / 32.0 * k2[i])],
        tc + 3.0 * hc / 8.0);
    final k4 = f(
        [
          for (var i = 0; i < 6; i++)
            yc[i] +
                hc *
                    (1932.0 / 2197.0 * k1[i] -
                        7200.0 / 2197.0 * k2[i] +
                        7296.0 / 2197.0 * k3[i])
        ],
        tc + 12.0 * hc / 13.0);
    final k5 = f(
        [
          for (var i = 0; i < 6; i++)
            yc[i] +
                hc *
                    (439.0 / 216.0 * k1[i] -
                        8.0 * k2[i] +
                        3680.0 / 513.0 * k3[i] -
                        845.0 / 4104.0 * k4[i])
        ],
        tc + hc);
    final k6 = f(
        [
          for (var i = 0; i < 6; i++)
            yc[i] +
                hc *
                    (-8.0 / 27.0 * k1[i] +
                        2.0 * k2[i] -
                        3544.0 / 2565.0 * k3[i] +
                        1859.0 / 4104.0 * k4[i] -
                        11.0 / 40.0 * k5[i])
        ],
        tc + hc / 2.0);
    final y5 = <double>[];
    for (var i = 0; i < 6; i++) {
      final y4v = yc[i] +
          hc *
              (25.0 / 216.0 * k1[i] +
                  1408.0 / 2565.0 * k3[i] +
                  2197.0 / 4104.0 * k4[i] -
                  1.0 / 5.0 * k5[i]);
      final y5v = yc[i] +
          hc *
              (16.0 / 135.0 * k1[i] +
                  6656.0 / 12825.0 * k3[i] +
                  28561.0 / 56430.0 * k4[i] -
                  9.0 / 50.0 * k5[i] +
                  2.0 / 55.0 * k6[i]);
      errOut[i] = (y5v - y4v).abs();
      y5.add(y5v);
    }
    return y5;
  }

  final err = List<double>.filled(6, 0.0);
  while (t < tMax && !hitGround && !hitMaxRange) {
    h = math.min(h, tMax - t);
    final yNew = rkStep(y, t, h, err);
    var errMax = 0.0;
    for (var i = 0; i < 6; i++) {
      final scale = atol + rtol * math.max(y[i].abs(), yNew[i].abs());
      final e = err[i] / scale;
      if (e > errMax) errMax = e;
    }
    if (errMax <= 1.0) {
      // paso aceptado
      final tNew = t + h;
      final fNew = rhs(tNew, yNew);
      // eventos: suelo (dirección -1) y alcance máximo (dirección +1)
      if (groundLevel != null) {
        final g0v = groundEvent(y);
        final g1v = groundEvent(yNew);
        if (g0v > 0 && g1v <= 0) {
          // refinar el cruce por bisección sobre la Hermite del paso
          // (intervalo original [t, tNew] fijo; solo el punto evaluado se mueve)
          final t0 = t, t1 = tNew;
          var a2 = t, b2 = tNew;
          final ya = y, yb = yNew;
          final fa = fs.last, fb = fNew;
          List<double> hermite(double tt) {
            final hh = t1 - t0;
            final s = (tt - t0) / hh;
            final s2 = s * s, s3 = s2 * s;
            final h00 = 2 * s3 - 3 * s2 + 1;
            final h10 = s3 - 2 * s2 + s;
            final h01 = -2 * s3 + 3 * s2;
            final h11 = s3 - s2;
            return List<double>.generate(
                6,
                (i) =>
                    h00 * ya[i] + h10 * hh * fa[i] + h01 * yb[i] + h11 * hh * fb[i]);
          }

          for (var it = 0; it < 60; it++) {
            final m = 0.5 * (a2 + b2);
            if (groundEvent(hermite(m)) > 0) {
              a2 = m;
            } else {
              b2 = m;
            }
          }
          final tHit = 0.5 * (a2 + b2);
          final yHit = hermite(tHit);
          ts.add(tHit);
          ys.add(yHit);
          fs.add(rhs(tHit, yHit));
          hitGround = true;
          break;
        }
      }
      if (yNew[0] >= maxRange) {
        // cruce de alcance máximo: refinar por bisección en x
        final t0 = t, t1 = tNew;
        var a2 = t, b2 = tNew;
        final ya = y, yb = yNew;
        final fa = fs.last, fb = fNew;
        List<double> hermite(double tt) {
          final hh = t1 - t0;
          final s = (tt - t0) / hh;
          final s2 = s * s, s3 = s2 * s;
          final h00 = 2 * s3 - 3 * s2 + 1;
          final h10 = s3 - 2 * s2 + s;
          final h01 = -2 * s3 + 3 * s2;
          final h11 = s3 - s2;
          return List<double>.generate(6,
              (i) => h00 * ya[i] + h10 * hh * fa[i] + h01 * yb[i] + h11 * hh * fb[i]);
        }

        for (var it = 0; it < 60; it++) {
          final m = 0.5 * (a2 + b2);
          if (hermite(m)[0] < maxRange) {
            a2 = m;
          } else {
            b2 = m;
          }
        }
        final tHit = 0.5 * (a2 + b2);
        final yHit = hermite(tHit);
        ts.add(tHit);
        ys.add(yHit);
        fs.add(rhs(tHit, yHit));
        hitMaxRange = true;
        break;
      }
      ts.add(tNew);
      ys.add(yNew);
      fs.add(fNew);
      t = tNew;
      y = yNew;
      if (errMax == 0.0) {
        h *= 4.0;
      } else {
        h *= math.min(4.0, math.max(0.1, 0.84 * math.pow(1.0 / errMax, 0.25)));
      }
      h = math.min(h, 0.01); // densidad de malla suficiente para la Hermite
    } else {
      h *= math.min(1.0, math.max(0.1, 0.84 * math.pow(1.0 / errMax, 0.25)));
      if (h < 1e-12) {
        throw StateError('Integración balística estancada (paso < 1e-12 s)');
      }
    }
  }

  double? sg;
  if (proj.length != null && proj.twist != null) {
    final st0 = atm.state(hSt);
    sg = gyroscopicStability(proj, muzzleVelocity, st0[0], st0[1]);
    if (sg < 1.0) {
      warnings.add(
          'Sg = ${sg.toStringAsFixed(2)} < 1: proyectil giroscópicamente inestable; '
          'la fórmula de deriva por giro (Litz) no es fiable.');
    }
  }
  drag.warnSink = null;
  return Trajectory(proj, muzzleVelocity, el, atm, groundLevel, sg, wind,
      warnings, ts, ys, fs, hitGround, hitMaxRange);
}

// ---------------------------------------------------------------------------
// SOLVER DE ELEVACIÓN (cero del arma) - Brent
// ---------------------------------------------------------------------------
double _brentq(double Function(double) f, double a, double b, double xtol) {
  var fa = f(a), fb = f(b);
  if (fa == 0.0) return a;
  if (fb == 0.0) return b;
  if (fa.sign == fb.sign) {
    throw ArgumentError('brentq: f(a) y f(b) tienen el mismo signo');
  }
  var c = a, fc = fa;
  var d = b - a, e = d;
  for (var it = 0; it < 200; it++) {
    if (fb.sign == fc.sign) {
      c = a;
      fc = fa;
      d = b - a;
      e = d;
    }
    if (fc.abs() < fb.abs()) {
      a = b;
      b = c;
      c = a;
      fa = fb;
      fb = fc;
      fc = fa;
    }
    final tol1 = 2.0 * 2.220446049250313e-16 * b.abs() + 0.5 * xtol;
    final xm = 0.5 * (c - b);
    if (xm.abs() <= tol1 || fb == 0.0) return b;
    if (e.abs() >= tol1 && fa.abs() > fb.abs()) {
      var s = fb / fa;
      double p, q;
      if (a == c) {
        p = 2.0 * xm * s;
        q = 1.0 - s;
      } else {
        final q2 = fa / fc, r = fb / fc;
        p = s * (2.0 * xm * q2 * (q2 - r) - (b - a) * (r - 1.0));
        q = (q2 - 1.0) * (r - 1.0) * (s - 1.0);
      }
      if (p > 0) {
        q = -q;
      } else {
        p = -p;
      }
      if (2.0 * p < math.min(3.0 * xm * q - (tol1 * q).abs(), (e * q).abs())) {
        e = d;
        d = p / q;
      } else {
        d = xm;
        e = d;
      }
    } else {
      d = xm;
      e = d;
    }
    a = b;
    fa = fb;
    b += d.abs() > tol1 ? d : (xm > 0 ? tol1 : -tol1);
    fb = f(b);
  }
  return b;
}

/// Elevación del ánima [grados sobre la horizontal] para que la bala cruce la
/// línea de mira a [targetRange] (distancia HORIZONTAL). Es el 'cero' del arma.
///
/// La LOS parte de [sightHeight] sobre la boca con inclinación [losAngleDeg]
/// (0 = blanco a la altura de la mira). Devuelve la solución de ángulo bajo
/// (trayectoria tensa), no la de tiro parabólico alto. Para un cero
/// convencional pasa viento nulo y sin Coriolis.
double solveElevation(
  Projectile proj,
  double muzzleVelocity,
  double targetRange, {
  double sightHeight = 0.0,
  double losAngleDeg = 0.0,
  Atmosphere? atmosphere,
  double rtol = 1e-8,
  double atol = 1e-9,
}) {
  final targetY =
      sightHeight + targetRange * math.tan(losAngleDeg * math.pi / 180.0);
  final maxRange = targetRange * 1.05 + 1.0;

  double f(double elDeg) {
    final tr = simulate(proj, muzzleVelocity, elDeg,
        atmosphere: atmosphere,
        groundLevel: null,
        maxRange: maxRange,
        rtol: rtol,
        atol: atol);
    if (tr.xEnd < targetRange - 1e-6) {
      return -(targetRange - tr.xEnd) - 1.0;
    }
    return tr.atRange(targetRange).yM - targetY;
  }

  final lo = math.min(0.0, losAngleDeg) - 5.0;
  final fLo = f(lo);
  if (fLo > 0) {
    throw ArgumentError(
        'Incluso con elevación mínima la bala pasa por encima de la LOS');
  }
  const step = 0.5;
  var hi = lo + step;
  while (hi <= 89.0) {
    // primer cambio de signo = solución baja
    final fHi = f(hi);
    if (fHi >= 0) {
      return _brentq(f, hi - step, hi, 1e-10);
    }
    hi += step;
  }
  throw ArgumentError('Distancia fuera de alcance para esta velocidad y BC');
}
