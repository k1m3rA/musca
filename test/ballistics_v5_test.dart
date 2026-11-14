// Autotests del modelo balístico v5 (port de run_selftests() del modelo de
// referencia) más una comprobación extremo a extremo del calculador contra la
// tabla publicada Beck Defense / JBM. Ejecutar con: flutter test
import 'package:flutter_test/flutter_test.dart';
import 'package:musca/models/cartridge_model.dart';
import 'package:musca/models/gun_model.dart';
import 'package:musca/models/scope_model.dart';
import 'package:musca/services/ballistics_calculator.dart';
import 'package:musca/services/ballistics_v5.dart';
import 'dart:math' as math;

const _fps = 0.3048;
const _grainKg = 6.479891e-5;

Projectile _p308() =>
    Projectile(mass: 168 * _grainKg, diameter: 0.308 * 0.0254, bc: 0.462);

void main() {
  group('modelo v5', () {
    test('1) BC 0.262 lb/in2 -> kg/m2', () {
      final p = Projectile(mass: 4.0e-3, diameter: 5.7e-3, bc: 0.262);
      expect((p.bcSi - 184.2).abs(), lessThan(0.1));
    });

    test('2) Densidad ISA 1976 vs valores tabulados (< 0.1 %)', () {
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
      expect(worst, lessThan(1e-3));
    });

    test('3) Vacío: alcance = v0^2 sin2θ / g', () {
      const v0 = 300.0, th = 30.0;
      final vac =
          Projectile(mass: 1.0, diameter: 0.01, bc: 1e12, bcUnits: 'si');
      final tr = simulate(vac, v0, th);
      final rTh = v0 * v0 * math.sin(2 * th * math.pi / 180.0) / kG0;
      expect((tr.impact.rangeM / rTh - 1).abs(), lessThan(1e-4));
    });

    test('4) Convergencia (Δy a 1000 yd < 1 mm)', () {
      final p = _p308();
      final a = simulate(p, 2650 * _fps, 0.5,
          groundLevel: null, maxRange: 914.4, rtol: 1e-8);
      final b = simulate(p, 2650 * _fps, 0.5,
          groundLevel: null, maxRange: 914.4, rtol: 1e-12, atol: 1e-12);
      expect((a.atRange(914.4).yM - b.atRange(914.4).yM).abs(),
          lessThan(1e-3));
    });

    test('5) G1(.462) vs G7(.218) a 500 m: caídas coherentes (< 5 %)', () {
      final pG1 = _p308();
      final pG7 = Projectile(
          mass: 168 * _grainKg,
          diameter: 0.308 * 0.0254,
          bc: 0.218,
          dragModel: 'G7');
      final e1 = solveElevation(pG1, 2650 * _fps, 91.44, sightHeight: 0.0381);
      final e7 = solveElevation(pG7, 2650 * _fps, 91.44, sightHeight: 0.0381);
      final r1 =
          simulate(pG1, 2650 * _fps, e1, groundLevel: null, maxRange: 600)
              .atRange(500, sightHeight: 0.0381);
      final r7 =
          simulate(pG7, 2650 * _fps, e7, groundLevel: null, maxRange: 600)
              .atRange(500, sightHeight: 0.0381);
      expect((r1.dropM / r7.dropM - 1).abs(), lessThan(0.05));
    });

    test('6) Signos físicos: viento y Coriolis', () {
      final pG1 = _p308();
      final e1 = solveElevation(pG1, 2650 * _fps, 91.44, sightHeight: 0.0381);
      final w = windVector(5.0, 90.0); // viento de la derecha
      final tw = simulate(pG1, 2650 * _fps, e1,
          wind: w, groundLevel: null, maxRange: 500);
      expect(tw.atRange(500, sightHeight: 0.0381).driftWindCoriolisM,
          lessThan(0));
      final tc = simulate(pG1, 2650 * _fps, e1,
          latitudeDeg: 45, azimuthDeg: 0, groundLevel: null, maxRange: 900);
      expect(tc.atRange(900, sightHeight: 0.0381).driftWindCoriolisM,
          greaterThan(0));
    });

    test('7) Sin length/twist: deriva por giro = 0', () {
      final r = simulate(_p308(), 2650 * _fps, 0.5,
              groundLevel: null, maxRange: 300)
          .atRange(300);
      expect(r.spinDriftM, 0.0);
    });

    test('8) Cero con LOS horizontal e inclinada: cruce exacto', () {
      final p = _p308();
      for (final los in [0.0, 15.0, -20.0]) {
        final el = solveElevation(p, 2650 * _fps, 200.0,
            sightHeight: 0.0381, losAngleDeg: los);
        final r = simulate(p, 2650 * _fps, el,
                groundLevel: null, maxRange: 300)
            .atRange(200.0, sightHeight: 0.0381, losAngleDeg: los);
        expect(r.dropM.abs(), lessThan(1e-6));
      }
    });

    test('9) Aviso fuera de la tabla (Mach > 5) y Cd nunca negativo', () {
      final pG7 = Projectile(
          mass: 168 * _grainKg,
          diameter: 0.308 * 0.0254,
          bc: 0.218,
          dragModel: 'G7');
      final tr = simulate(pG7, 2000.0, 1.0, groundLevel: null, maxRange: 300);
      expect(tr.warnings.any((x) => x.contains('fuera de la tabla')), isTrue);
      expect(kDragModels['G7']!.cd(20.0), kDragModels['G7']!.cd(5.0));
      expect(kDragModels['G7']!.cd(5.0), greaterThan(0));
    });

    test('10) Aviso con Sg < 1', () {
      final pu = Projectile(
          mass: 168 * _grainKg,
          diameter: 0.308 * 0.0254,
          bc: 0.462,
          length: 31.2e-3,
          twist: 30 * 0.0254);
      final tr =
          simulate(pu, 2650 * _fps, 0.5, groundLevel: null, maxRange: 300);
      expect(tr.warnings.any((x) => x.contains('inestable')), isTrue);
    });

    test('11) Mach con viento = |v - w| / a', () {
      final p = _p308();
      final wt = windVector(20.0, 180.0); // 20 m/s de cola
      final trw = simulate(p, 2650 * _fps, 0.6,
          wind: wt, groundLevel: null, maxRange: 600);
      final rw = trw.atRange(600);
      final aLoc = trw.atm.state(rw.yM)[3];
      final s = trw.state(rw.timeS);
      final machRel = math.sqrt(math.pow(s[3] - wt[0], 2) +
              math.pow(s[4] - wt[1], 2) +
              math.pow(s[5] - wt[2], 2)) /
          aLoc;
      expect((rw.mach - machRel).abs(), lessThan(1e-9));
      expect(rw.mach, lessThan(rw.speedMs / aLoc));
    });

    test('12) Plano de suelo por encima de la boca no corta al instante', () {
      final p = _p308();
      final trg = simulate(p, 2650 * _fps, 3.0, groundLevel: 5.0);
      expect(trg.xEnd, greaterThan(1000));
      final trz = simulate(p, 2650 * _fps, 0.0, groundLevel: 0.0);
      expect(trz.hitGround, isTrue);
      expect(trz.xEnd, lessThan(0.01));
    });

    test('13) Sg<1: spin_drift=NaN, excluida del total', () {
      final pu = Projectile(
          mass: 168 * _grainKg,
          diameter: 0.308 * 0.0254,
          bc: 0.462,
          length: 31.2e-3,
          twist: 30 * 0.0254);
      final tru =
          simulate(pu, 2650 * _fps, 0.5, groundLevel: null, maxRange: 300);
      final ru = tru.atRange(300);
      expect(ru.spinDriftM.isNaN, isTrue);
      expect(ru.spinUnstable, isTrue);
      expect(ru.driftTotalM, ru.driftWindCoriolisM);
    });

    test('14) Motivos de terminación', () {
      final p = _p308();
      final tG = simulate(p, 2650 * _fps, 0.5, groundLevel: 0.0);
      final tR = simulate(p, 2650 * _fps, 0.5,
          groundLevel: null, maxRange: 500.0);
      final tT =
          simulate(p, 2650 * _fps, 0.5, groundLevel: 500.0, tMax: 20.0);
      expect(tG.hitGround, isTrue);
      expect(tG.hitMaxRange, isFalse);
      expect(tG.tMaxReached, isFalse);
      expect(tR.hitMaxRange, isTrue);
      expect(tR.hitGround, isFalse);
      expect(tR.tMaxReached, isFalse);
      expect(tR.impact.hitMaxRange, tR.hitMaxRange);
      expect(tT.tMaxReached, isTrue);
      expect(tT.hitGround, isFalse);
      expect(tT.impact.tMaxReached, isTrue);
      expect(tG.impact.rangeM, isA<double>());
    });
  });

  group('calculador (referencia JBM)', () {
    // Beck Defense / JBM: 6.5 CM 140 gr ELD-M, G1 0.646, 2735 fps, mira 1.6",
    // 1000 ft (304.8 m), 70 F, HR 45 %, P 29.53 inHg c.n.m., viento 10 mph a
    // las 3 (de la derecha), cero a 400 yd. A 1000 yd: caida -230.4",
    // deriva 61.6" a la izquierda, v 1581.9 fps, ToF 1.4469 s.
    test('extremo a extremo vs tabla publicada', () {
      const yd = 0.9144, fps = 0.3048, inch = 0.0254;
      final pSl = 29.53 * 3386.389;
      final pSt = pSl * math.pow(1 - 2.25577e-5 * 304.8, 5.25588);
      final gun = Gun(
          id: 'g',
          name: 'g',
          twistRate: 8.0,
          twistDirection: 1,
          muzzleVelocity: 2735 * fps,
          zeroRange: 400 * yd);
      final cart = Cartridge(
          id: 'c',
          name: 'c',
          diameter: '0.6706', // 0.264"
          bulletWeight: 140.0,
          bulletLength: 0.0,
          ballisticCoefficient: 0.646,
          bcModelType: 0);
      final scope = Scope(id: 's', name: 's', sightHeight: 1.6, units: 0);
      final r = BallisticsCalculator.calculateWithProfiles(
          1000 * yd, 10 * 0.44704, 270.0, gun, cart, scope,
          temperature: 21.11, pressure: pSt, humidity: 45.0, altitude: 304.8);
      expect((r.dropVertical / inch - -230.4).abs(), lessThan(0.5));
      expect((r.driftHorizontal / inch - -61.6).abs(), lessThan(1.0));
      expect((r.speedMs / fps - 1581.9).abs(), lessThan(2.0));
      expect((r.timeS - 1.4469).abs(), lessThan(0.002));
    });
  });
}
