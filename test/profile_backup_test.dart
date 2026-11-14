import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:musca/models/gun_model.dart';
import 'package:musca/models/scope_model.dart';
import 'package:musca/models/cartridge_model.dart';
import 'package:musca/services/gun_storage.dart';
import 'package:musca/services/scope_storage.dart';
import 'package:musca/services/cartridge_storage.dart';
import 'package:musca/services/profile_backup_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> seedProfiles() async {
    await GunStorage.saveGun(Gun(
      id: 'g1',
      name: 'Rifle 1',
      twistRate: 9,
      twistDirection: 1,
      muzzleVelocity: 800,
      zeroRange: 100,
    ));
    await ScopeStorage.saveScope(Scope(
      id: 's1',
      name: 'Visor 1',
      sightHeight: 5.0,
      units: 7,
    ));
    await CartridgeStorage.saveCartridge(Cartridge(
      id: 'c1',
      name: 'Cartucho 1',
      diameter: '6.5',
      bulletWeight: 140,
      bulletLength: 33.5,
      ballisticCoefficient: 0.61,
      bcModelType: 1,
    ));
    await GunStorage.saveSelectedGunId('g1');
    await ScopeStorage.saveSelectedScopeId('s1');
    await CartridgeStorage.saveSelectedCartridgeId('c1');
  }

  test('export -> parse conserva perfiles y selección', () async {
    await seedProfiles();

    final content = await ProfileBackupService.buildBackupJson();
    final backup = ProfileBackupService.parseBackup(content);

    expect(backup.guns.map((g) => g.id), ['g1']);
    expect(backup.scopes.map((s) => s.id), ['s1']);
    expect(backup.cartridges.map((c) => c.id), ['c1']);
    expect(backup.guns.single.name, 'Rifle 1');
    expect(backup.cartridges.single.bcModelType, 1);
    expect(backup.selectedGunId, 'g1');
    expect(backup.selectedScopeId, 's1');
    expect(backup.selectedCartridgeId, 'c1');
  });

  test('importar en vacío añade todo y restaura selección', () async {
    await seedProfiles();
    final backup =
        ProfileBackupService.parseBackup(await ProfileBackupService.buildBackupJson());

    await GunStorage.clearAllGuns();
    await ScopeStorage.clearAllScopes();
    await CartridgeStorage.clearAllCartridges();
    await GunStorage.saveSelectedGunId(null);

    final result = await ProfileBackupService.importBackup(backup, replace: false);

    expect(result.added, 3);
    expect(result.updated, 0);
    expect((await GunStorage.getGuns()).single.name, 'Rifle 1');
    expect(await GunStorage.getSelectedGunId(), 'g1');
    expect(await ScopeStorage.getSelectedScopeId(), 's1');
    expect(await CartridgeStorage.getSelectedCartridgeId(), 'c1');
  });

  test('combinar actualiza por id y no borra los demás', () async {
    await seedProfiles();
    final backup =
        ProfileBackupService.parseBackup(await ProfileBackupService.buildBackupJson());

    // Perfil local extra que no está en la copia
    await GunStorage.saveGun(Gun(
      id: 'g2',
      name: 'Rifle local',
      twistRate: 10,
      twistDirection: 0,
      muzzleVelocity: 790,
      zeroRange: 100,
    ));

    final result = await ProfileBackupService.importBackup(backup, replace: false);

    expect(result.added, 0);
    expect(result.updated, 3);
    final guns = await GunStorage.getGuns();
    expect(guns.length, 2); // g1 actualizada + g2 intacta
  });

  test('reemplazar deja solo lo de la copia', () async {
    await seedProfiles();
    final backup =
        ProfileBackupService.parseBackup(await ProfileBackupService.buildBackupJson());

    await GunStorage.saveGun(Gun(
      id: 'g2',
      name: 'Rifle local',
      twistRate: 10,
      twistDirection: 0,
      muzzleVelocity: 790,
      zeroRange: 100,
    ));

    await ProfileBackupService.importBackup(backup, replace: true);

    final guns = await GunStorage.getGuns();
    expect(guns.length, 1);
    expect(guns.single.id, 'g1');
  });

  test('rechaza archivos que no son copias de Musca', () {
    expect(() => ProfileBackupService.parseBackup('no json'),
        throwsA(isA<ProfileBackupException>()));
    expect(() => ProfileBackupService.parseBackup('{"foo": 1}'),
        throwsA(isA<ProfileBackupException>()));
    expect(
        () => ProfileBackupService.parseBackup(
            '{"app": "musca", "formatVersion": 99, "guns": []}'),
        throwsA(isA<ProfileBackupException>()));
  });
}
