import 'package:flutter_test/flutter_test.dart';
import 'package:musca/data/cartridge_presets.dart';

void main() {
  test('la batería de calibres es válida', () {
    expect(kCartridgePresets.length, 44);
    final names = kCartridgePresets.map((p) => p.name).toList();
    expect(names.toSet().length, names.length); // sin duplicados
    for (final p in kCartridgePresets) {
      expect(p.diameterCm, inInclusiveRange(0.4, 2.0), reason: p.name);
      expect(p.bulletLengthCm, inInclusiveRange(0.5, 7.0), reason: p.name);
      expect(p.bulletWeightGr, inInclusiveRange(10, 800), reason: p.name);
      expect(p.ballisticCoefficient, inInclusiveRange(0.05, 1.3),
          reason: p.name);
      expect(p.bcModelType, isIn([0, 1]), reason: p.name);
      expect(p.muzzleVelocity, inInclusiveRange(200, 1400), reason: p.name);
    }
  });

  test('incluye el 8x68 S con el RWS KS 180 gr', () {
    final rws = kCartridgePresets.firstWhere((p) => p.name.contains('8x68'));
    expect(rws.bulletWeightGr, 180);
    expect(rws.diameterCm, closeTo(0.82, 0.001));
    expect(rws.muzzleVelocity, greaterThan(900));
  });
}
