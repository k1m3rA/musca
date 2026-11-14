// Autotests del modelo balístico v5 (port de run_selftests() del modelo de
// referencia en Python). Ejecutable sin Flutter:
//   dart run tool/selftest_v5.dart
// La batería de flutter_test en test/ballistics_v5_test.dart compara los
// mismos números contra el propio motor (autoconsistencia + referencias
// físicas); este script es la verificación rápida del port.
import 'dart:math' as math;
import '../lib/services/ballistics_v5.dart';

bool _ok = true;

void check(String name, bool cond, [String info = '']) {
  _ok = _ok && cond;
  print('[${cond ? 'OK' : 'FALLO'}] $name $info');
}

const _fps = 0.3048;
const _grainKg = 6.479891e-5;

void main() {
  // 1) Conversión de unidades del BC
  final p = Projectile(mass: 4.0e-3, diameter: 5.7e-3, bc: 0.262);
  check('BC 0.262 lb/in2 -> kg/m2', (p.bcSi - 184.2).abs() < 0.1,
      '(${p.bcSi.toStringAsFixed(1)})');

  // 2) Atmósfera ISA 1976 contra valores tabulados
  final ref = {
    0.0: 1.2250,
    5000.0: 0.73643,
    10000.0: 0.41351,
    15000.0: 0.19475,
    20000.0: 0.088910,
    30000.0: 0.018410,
    40000.0: 0.0039957,
  };
  final atm = Atmosphere();
  var worst = 0.0;
  ref.forEach((h, r) {
    final e = (atm.state(h)[2] / r - 1.0).abs();
    if (e > worst) worst = e;
  });
  check('Densidad ISA vs tablas (error rel. máx < 0.1 %)', worst < 1e-3,
      '(${(worst * 100).toStringAsFixed(3)} %)');

  // 3) Límite sin arrastre: alcance de tiro parabólico
  const v0 = 300.0, th = 30.0;
  final vac = Projectile(mass: 1.0, diameter: 0.01, bc: 1e12, bcUnits: 'si');
  final tr = simulate(vac, v0, th);
  final rTh = v0 * v0 * math.sin(2 * th * math.pi / 180.0) / kG0;
  check('Vacío: alcance = v0^2 sin2θ / g',
      (tr.impact.rangeM / rTh - 1).abs() < 1e-4,
      '(${tr.impact.rangeM.toStringAsFixed(2)} vs ${rTh.toStringAsFixed(2)} m)');

  // 4) Convergencia numérica
  final p308 = Projectile(
      mass: 168 * _grainKg, diameter: 0.308 * 0.0254, bc: 0.462);
  final a = simulate(p308, 2650 * _fps, 0.5,
      groundLevel: null, maxRange: 914.4, rtol: 1e-8);
  final b = simulate(p308, 2650 * _fps, 0.5,
      groundLevel: null, maxRange: 914.4, rtol: 1e-12, atol: 1e-12);
  final dy = (a.atRange(914.4).yM - b.atRange(914.4).yM).abs();
  check('Convergencia (Δy a 1000 yd < 1 mm)', dy < 1e-3,
      '(${(dy * 1000).toStringAsFixed(4)} mm)');

  // 5) Consistencia G1 <-> G7
  final pG1 = Projectile(
      mass: 168 * _grainKg, diameter: 0.308 * 0.0254, bc: 0.462);
  final pG7 = Projectile(
      mass: 168 * _grainKg,
      diameter: 0.308 * 0.0254,
      bc: 0.218,
      dragModel: 'G7');
  final e1 = solveElevation(pG1, 2650 * _fps, 91.44, sightHeight: 0.0381);
  final e7 = solveElevation(pG7, 2650 * _fps, 91.44, sightHeight: 0.0381);
  final r1 = simulate(pG1, 2650 * _fps, e1, groundLevel: null, maxRange: 600)
      .atRange(500, sightHeight: 0.0381);
  final r7 = simulate(pG7, 2650 * _fps, e7, groundLevel: null, maxRange: 600)
      .atRange(500, sightHeight: 0.0381);
  final rel = (r1.dropM / r7.dropM - 1).abs();
  check('G1(.462) vs G7(.218) a 500 m: caídas coherentes (< 5 %)', rel < 0.05,
      '(G1 ${r1.dropM.toStringAsFixed(2)} m, G7 ${r7.dropM.toStringAsFixed(2)} m, dif ${(rel * 100).toStringAsFixed(1)} %)');

  // 6) Signos físicos: viento y Coriolis
  final w = windVector(5.0, 90.0); // viento de la derecha
  final tw =
      simulate(pG1, 2650 * _fps, e1, wind: w, groundLevel: null, maxRange: 500);
  check('Viento de la derecha desplaza el impacto a la IZQUIERDA',
      tw.atRange(500, sightHeight: 0.0381).driftWindCoriolisM < 0);
  final tc = simulate(pG1, 2650 * _fps, e1,
      latitudeDeg: 45, azimuthDeg: 0, groundLevel: null, maxRange: 900);
  check('Coriolis hemisferio N, tiro al norte: deriva a la DERECHA',
      tc.atRange(900, sightHeight: 0.0381).driftWindCoriolisM > 0);

  // 7) Proyectil sin length/twist: funciona (sin deriva por giro)
  final pn = Projectile(
      mass: 168 * _grainKg, diameter: 0.308 * 0.0254, bc: 0.462);
  final rn = simulate(pn, 2650 * _fps, 0.5, groundLevel: null, maxRange: 300)
      .atRange(300);
  check('Sin length/twist: sg=None y deriva por giro = 0', rn.spinDriftM == 0.0);

  // 8) Cero con LOS horizontal e inclinada: la bala cruza exactamente la LOS
  for (final los in [0.0, 15.0, -20.0]) {
    final el = solveElevation(pG1, 2650 * _fps, 200.0,
        sightHeight: 0.0381, losAngleDeg: los);
    final r = simulate(pG1, 2650 * _fps, el, groundLevel: null, maxRange: 300)
        .atRange(200.0, sightHeight: 0.0381, losAngleDeg: los);
    check('Cero con LOS a ${los >= 0 ? '+' : ''}${los.toStringAsFixed(0)}°: cruce exacto (|Δ| < 1e-6 m)',
        r.dropM.abs() < 1e-6, '(elevación ánima ${el.toStringAsFixed(4)}°)');
  }

  // 9) Aviso fuera de la tabla (Mach > 5) y Cd nunca negativo
  final tr9 = simulate(pG7, 2000.0, 1.0, groundLevel: null, maxRange: 300);
  check('Aviso al superar Mach 5 de la tabla',
      tr9.warnings.any((x) => x.contains('fuera de la tabla')));
  check('Cd(M=20) constante y positivo',
      kDragModels['G7']!.cd(20.0) == kDragModels['G7']!.cd(5.0) &&
          kDragModels['G7']!.cd(5.0) > 0);

  // 10) Aviso Sg < 1
  final pu = Projectile(
      mass: 168 * _grainKg,
      diameter: 0.308 * 0.0254,
      bc: 0.462,
      length: 31.2e-3,
      twist: 30 * 0.0254);
  final tr10 =
      simulate(pu, 2650 * _fps, 0.5, groundLevel: null, maxRange: 300);
  check('Aviso con Sg < 1', tr10.warnings.any((x) => x.contains('inestable')));

  // 11) Mach reportado = velocidad RELATIVA AL AIRE
  final wt = windVector(20.0, 180.0); // 20 m/s de cola
  final trw = simulate(pG1, 2650 * _fps, 0.6,
      wind: wt, groundLevel: null, maxRange: 600);
  final rw = trw.atRange(600);
  final aLoc = trw.atm.state(rw.yM)[3];
  final s = trw.state(rw.timeS);
  final machRel = math.sqrt(math.pow(s[3] - wt[0], 2) +
          math.pow(s[4] - wt[1], 2) +
          math.pow(s[5] - wt[2], 2)) /
      aLoc;
  check('Mach con viento = |v - w| / a',
      (rw.mach - machRel).abs() < 1e-9 && rw.mach < rw.speedMs / aLoc);

  // 12) Plano de suelo por encima de la boca: no corta al instante
  final trg = simulate(pG1, 2650 * _fps, 3.0, groundLevel: 5.0);
  check('ground_level=+5 m: la bala llega lejos (x_end > 1000 m)',
      trg.xEnd > 1000, '(${trg.xEnd.toStringAsFixed(0)} m)');
  final trz = simulate(pG1, 2650 * _fps, 0.0, groundLevel: 0.0);
  check('Tiro a nivel con suelo en la boca: impacto inmediato (hit_ground)',
      trz.hitGround && trz.xEnd < 0.01);

  // 13) Sg < 1: deriva por giro desconocida (NaN), excluida del total
  final tru = simulate(pu, 2650 * _fps, 0.5, groundLevel: null, maxRange: 300);
  final ru = tru.atRange(300);
  check('Sg<1: spin_drift=NaN, spin_unstable=True, total = viento+Coriolis',
      ru.spinDriftM.isNaN &&
          ru.spinUnstable &&
          ru.driftTotalM == ru.driftWindCoriolisM);

  // 14) Motivo de terminación
  final pf = Projectile(
      mass: 168 * _grainKg, diameter: 0.308 * 0.0254, bc: 0.462);
  final tG = simulate(pf, 2650 * _fps, 0.5, groundLevel: 0.0);
  final tR = simulate(pf, 2650 * _fps, 0.5, groundLevel: null, maxRange: 500.0);
  final tT =
      simulate(pf, 2650 * _fps, 0.5, groundLevel: 500.0, tMax: 20.0);
  check('Terminación por suelo: hit_ground y no t_max_reached',
      tG.hitGround && !tG.hitMaxRange && !tG.tMaxReached);
  check('Terminación por max_range: hit_max_range y no hit_ground',
      tR.hitMaxRange && !tR.hitGround && !tR.tMaxReached);
  check('impact() expone hit_max_range',
      tR.impact.hitMaxRange == tR.hitMaxRange);
  check('Plano inalcanzable: t_max_reached=True (no es un impacto)',
      tT.tMaxReached && !tT.hitGround && tT.impact.tMaxReached);
  check('impact() devuelve valores finitos', tG.impact.rangeM.isFinite);

  print(_ok ? '\nTodos los tests OK' : '\nHAY TESTS FALLIDOS');
  if (!_ok) {
    throw StateError('selftest v5: fallos');
  }
}
