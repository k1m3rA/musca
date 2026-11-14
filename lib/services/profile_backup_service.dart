import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/gun_model.dart';
import '../models/scope_model.dart';
import '../models/cartridge_model.dart';
import 'gun_storage.dart';
import 'scope_storage.dart';
import 'cartridge_storage.dart';

/// Error al leer o interpretar un archivo .musca.
class ProfileBackupException implements Exception {
  final String message;
  ProfileBackupException(this.message);

  @override
  String toString() => 'ProfileBackupException: $message';
}

/// Contenido de una copia de perfiles ya parseada y validada.
class ProfileBackup {
  final List<Gun> guns;
  final List<Scope> scopes;
  final List<Cartridge> cartridges;
  final String? selectedGunId;
  final String? selectedScopeId;
  final String? selectedCartridgeId;

  ProfileBackup({
    required this.guns,
    required this.scopes,
    required this.cartridges,
    this.selectedGunId,
    this.selectedScopeId,
    this.selectedCartridgeId,
  });

  int get totalProfiles => guns.length + scopes.length + cartridges.length;
}

/// Resumen de una importación: cuántos perfiles se añadieron y cuántos
/// actualizaron a uno existente con el mismo id.
class ProfileImportResult {
  int added = 0;
  int updated = 0;
}

/// Exporta e importa la copia de perfiles (armas, visores y cartuchos)
/// en un archivo .musca con JSON legible y sin cifrar.
class ProfileBackupService {
  static const int currentFormatVersion = 1;

  /// Genera el contenido JSON de la copia con los perfiles actuales.
  static Future<String> buildBackupJson() async {
    final guns = await GunStorage.getGuns();
    final scopes = await ScopeStorage.getScopes();
    final cartridges = await CartridgeStorage.getCartridges();

    final payload = <String, dynamic>{
      'app': 'musca',
      'formatVersion': currentFormatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'selectedGunId': await GunStorage.getSelectedGunId(),
      'selectedScopeId': await ScopeStorage.getSelectedScopeId(),
      'selectedCartridgeId': await CartridgeStorage.getSelectedCartridgeId(),
      'guns': guns.map((gun) => gun.toMap()).toList(),
      'scopes': scopes.map((scope) => scope.toJson()).toList(),
      'cartridges': cartridges.map((cartridge) => cartridge.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Escribe la copia en un archivo .musca temporal y devuelve su ruta.
  static Future<File> writeBackupFile() async {
    final content = await buildBackupJson();
    final dir = await getTemporaryDirectory();
    final stamp = DateFormat('yyyyMMdd-HHmm').format(DateTime.now());
    final file = File('${dir.path}/musca-perfiles-$stamp.musca');
    await file.writeAsString(content, flush: true);
    return file;
  }

  /// Abre la hoja de compartir de Android con la copia .musca.
  static Future<void> shareBackup() async {
    final file = await writeBackupFile();
    await Share.shareXFiles([XFile(file.path)]);
  }

  /// Lee el contenido de un resultado del selector de archivos.
  static Future<String?> readPickedFileContent(PlatformFile picked) async {
    if (picked.bytes != null) {
      return utf8.decode(picked.bytes!, allowMalformed: true);
    }
    final path = picked.path;
    if (path == null) {
      return null;
    }
    return File(path).readAsString();
  }

  /// Parsea y valida el contenido de un archivo .musca.
  /// Lanza [ProfileBackupException] si no es una copia válida.
  static ProfileBackup parseBackup(String content) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(content);
    } catch (_) {
      throw ProfileBackupException('El archivo no contiene JSON válido.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw ProfileBackupException('El archivo no es una copia de Musca.');
    }
    if (decoded['app'] != 'musca') {
      throw ProfileBackupException('El archivo no es una copia de Musca.');
    }
    final version = decoded['formatVersion'];
    if (version is! int || version < 1 || version > currentFormatVersion) {
      throw ProfileBackupException('Versión de copia no soportada.');
    }

    List<T> parseList<T>(
      String key,
      T Function(Map<String, dynamic> json) fromJson,
    ) {
      final raw = decoded[key];
      if (raw == null) return <T>[];
      if (raw is! List) {
        throw ProfileBackupException('La sección "$key" no es válida.');
      }
      final items = <T>[];
      for (final entry in raw) {
        if (entry is! Map<String, dynamic>) {
          throw ProfileBackupException('Entrada no válida en "$key".');
        }
        try {
          items.add(fromJson(entry));
        } catch (_) {
          throw ProfileBackupException('Entrada no válida en "$key".');
        }
      }
      return items;
    }

    return ProfileBackup(
      guns: parseList('guns', Gun.fromMap),
      scopes: parseList('scopes', Scope.fromJson),
      cartridges: parseList('cartridges', Cartridge.fromJson),
      selectedGunId: decoded['selectedGunId'] as String?,
      selectedScopeId: decoded['selectedScopeId'] as String?,
      selectedCartridgeId: decoded['selectedCartridgeId'] as String?,
    );
  }

  /// Indica si ya hay perfiles guardados (para decidir si hay que
  /// preguntar combinar/reemplazar antes de importar).
  static Future<bool> hasExistingProfiles() async {
    final guns = await GunStorage.getGuns();
    if (guns.isNotEmpty) return true;
    final scopes = await ScopeStorage.getScopes();
    if (scopes.isNotEmpty) return true;
    final cartridges = await CartridgeStorage.getCartridges();
    return cartridges.isNotEmpty;
  }

  /// Aplica la copia importada.
  ///
  /// Con [replace] a true borra primero todos los perfiles actuales;
  /// con false combina: actualiza los perfiles con el mismo id y añade
  /// los nuevos, sin borrar nada.
  ///
  /// Después restaura la selección (arma/visor/cartucho) guardada en la
  /// copia, solo si esos perfiles existen tras la importación.
  static Future<ProfileImportResult> importBackup(
    ProfileBackup backup, {
    required bool replace,
  }) async {
    final result = ProfileImportResult();

    if (replace) {
      await GunStorage.clearAllGuns();
      await ScopeStorage.clearAllScopes();
      await CartridgeStorage.clearAllCartridges();
      await GunStorage.saveSelectedGunId(null);
      await ScopeStorage.saveSelectedScopeId(null);
      await CartridgeStorage.saveSelectedCartridgeId(null);
    }

    final existingGunIds = (await GunStorage.getGuns()).map((g) => g.id).toSet();
    for (final gun in backup.guns) {
      if (existingGunIds.contains(gun.id)) {
        result.updated++;
      } else {
        result.added++;
      }
      await GunStorage.saveGun(gun);
    }

    final existingScopeIds =
        (await ScopeStorage.getScopes()).map((s) => s.id).toSet();
    for (final scope in backup.scopes) {
      if (existingScopeIds.contains(scope.id)) {
        result.updated++;
      } else {
        result.added++;
      }
      await ScopeStorage.saveScope(scope);
    }

    final existingCartridgeIds =
        (await CartridgeStorage.getCartridges()).map((c) => c.id).toSet();
    for (final cartridge in backup.cartridges) {
      if (existingCartridgeIds.contains(cartridge.id)) {
        result.updated++;
      } else {
        result.added++;
      }
      await CartridgeStorage.saveCartridge(cartridge);
    }

    await _restoreSelection(
      selectedGunId: backup.selectedGunId,
      selectedScopeId: backup.selectedScopeId,
      selectedCartridgeId: backup.selectedCartridgeId,
    );

    return result;
  }

  static Future<void> _restoreSelection({
    String? selectedGunId,
    String? selectedScopeId,
    String? selectedCartridgeId,
  }) async {
    if (selectedGunId != null) {
      final guns = await GunStorage.getGuns();
      if (guns.any((g) => g.id == selectedGunId)) {
        await GunStorage.saveSelectedGunId(selectedGunId);
      }
    }
    if (selectedScopeId != null) {
      final scopes = await ScopeStorage.getScopes();
      if (scopes.any((s) => s.id == selectedScopeId)) {
        await ScopeStorage.saveSelectedScopeId(selectedScopeId);
      }
    }
    if (selectedCartridgeId != null) {
      final cartridges = await CartridgeStorage.getCartridges();
      if (cartridges.any((c) => c.id == selectedCartridgeId)) {
        await CartridgeStorage.saveSelectedCartridgeId(selectedCartridgeId);
      }
    }
  }
}
