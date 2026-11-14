import 'package:shared_preferences/shared_preferences.dart';

import '../models/gun_model.dart';
import 'cartridge_storage.dart';
import 'gun_storage.dart';

/// Migraciones de datos entre versiones de la app.
class ProfileMigration {
  static const String _mvMigratedKey = 'musca.muzzleVelocityToCartridge.v1';

  /// La velocidad inicial pasa del perfil del rifle al del cartucho.
  ///
  /// Los cartuchos guardados antes del cambio no tienen velocidad propia:
  /// se les copia la del rifle seleccionado (o del primero guardado) para
  /// que el usuario no pierda el dato. Se ejecuta una sola vez por
  /// dispositivo. Mientras un cartucho no tenga velocidad, el motor usa la
  /// del arma como respaldo.
  static Future<void> migrateMuzzleVelocityToCartridges() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_mvMigratedKey) == true) return;

    final cartridges = await CartridgeStorage.getCartridges();
    final pending = cartridges.where((c) => c.muzzleVelocity == null).toList();
    if (pending.isNotEmpty) {
      double source = 800.0;
      final guns = await GunStorage.getGuns();
      if (guns.isNotEmpty) {
        final selectedId = await GunStorage.getSelectedGunId();
        Gun? selected;
        for (final gun in guns) {
          if (gun.id == selectedId) selected = gun;
        }
        source = (selected ?? guns.first).muzzleVelocity;
      }

      for (final cartridge in pending) {
        await CartridgeStorage.saveCartridge(
          cartridge.copyWith(muzzleVelocity: source),
        );
      }
    }

    await prefs.setBool(_mvMigratedKey, true);
  }
}
