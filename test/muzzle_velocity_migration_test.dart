import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:musca/models/gun_model.dart';
import 'package:musca/models/cartridge_model.dart';
import 'package:musca/services/gun_storage.dart';
import 'package:musca/services/cartridge_storage.dart';
import 'package:musca/services/profile_migration.dart';

Gun gun(String id, double mv) => Gun(
      id: id,
      name: id,
      twistRate: 10,
      twistDirection: 1,
      muzzleVelocity: mv,
      zeroRange: 100,
    );

Cartridge cartridge(String id, {double? mv}) => Cartridge(
      id: id,
      name: id,
      diameter: '0.782',
      bulletWeight: 150,
      bulletLength: 3.5,
      ballisticCoefficient: 0.5,
      muzzleVelocity: mv,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('el modelo guarda y lee muzzleVelocity (null en datos antiguos)', () {
    final conMv = Cartridge.fromJson(cartridge('c1', mv: 812.5).toJson());
    expect(conMv.muzzleVelocity, 812.5);
    // JSON antiguo sin el campo
    final legacyJson = cartridge('c2').toJson()..remove('muzzleVelocity');
    expect(Cartridge.fromJson(legacyJson).muzzleVelocity, isNull);
  });

  test('la migración copia la velocidad del rifle seleccionado', () async {
    await GunStorage.saveGun(gun('g1', 800));
    await GunStorage.saveGun(gun('g2', 750));
    await GunStorage.saveSelectedGunId('g2');
    await CartridgeStorage.saveCartridge(cartridge('c1'));
    await CartridgeStorage.saveCartridge(cartridge('c2', mv: 880));

    await ProfileMigration.migrateMuzzleVelocityToCartridges();

    final cartridges = await CartridgeStorage.getCartridges();
    expect(cartridges.firstWhere((c) => c.id == 'c1').muzzleVelocity, 750);
    expect(cartridges.firstWhere((c) => c.id == 'c2').muzzleVelocity, 880);
  });

  test('la migración no se repite y sin rifles usa 800', () async {
    await CartridgeStorage.saveCartridge(cartridge('c1'));
    await ProfileMigration.migrateMuzzleVelocityToCartridges();
    expect(
        (await CartridgeStorage.getCartridges()).single.muzzleVelocity, 800.0);

    // Segunda ejecución: no toca nada aunque cambie el rifle seleccionado
    await GunStorage.saveGun(gun('g1', 999));
    await GunStorage.saveSelectedGunId('g1');
    await ProfileMigration.migrateMuzzleVelocityToCartridges();
    expect(
        (await CartridgeStorage.getCartridges()).single.muzzleVelocity, 800.0);
  });
}
