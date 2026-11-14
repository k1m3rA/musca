// Verificación extremo a extremo del calculador (v5) contra la tabla
// publicada Beck Defense / JBM para 6.5 CM 140 ELD-M. No forma parte de la
// app; se ejecuta con `dart run tool/calc_reference_check.dart`.
import 'dart:math' as math;
import '../lib/models/cartridge_model.dart';
import '../lib/models/gun_model.dart';
import '../lib/models/scope_model.dart';
import '../lib/services/ballistics_calculator.dart';

void main() {
  const yd = 0.9144, fps = 0.3048, inch = 0.0254;
  // Beck/JBM: 6.5 CM 140 gr ELD-M, G1 0.646, 2735 fps, mira 1.6", 1000 ft
  // (304.8 m), 70 F (21.1 C), HR 45 %, P 29.53 inHg corregida a n.m.,
  // viento 10 mph a las 3 (de la derecha). Cero a 100 yd.
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

  final dropIn = r.dropVertical / inch;
  final driftIn = r.driftHorizontal / inch;
  final vFps = r.speedMs / fps;
  print('A 1000 yd (JBM (cero 400): caida -230.4", deriva 61.6" izquierda, '
      'v 1581.9 fps, ToF 1.4469 s):');
  print('  caida  = ${dropIn.toStringAsFixed(1)} in');
  print('  deriva = ${driftIn.toStringAsFixed(1)} in');
  print('  v      = ${vFps.toStringAsFixed(1)} fps');
  print('  ToF    = ${r.timeS.toStringAsFixed(4)} s');
  print('  energia= ${r.energyJ.toStringAsFixed(0)} J, '
      'mach=${r.mach.toStringAsFixed(3)}');

  final okDrop = (dropIn - -230.4).abs() < 2.0;
  final okDrift = (driftIn - -61.6).abs() < 2.0;
  final okV = (vFps - 1581.9).abs() < 5.0;
  final okTof = (r.timeS - 1.4469).abs() < 0.005;
  print(okDrop && okDrift && okV && okTof
      ? 'REFERENCIA JBM: OK'
      : 'REFERENCIA JBM: FUERA DE TOLERANCIA');
  if (!(okDrop && okDrift && okV && okTof)) {
    throw StateError('reference check failed');
  }
}
