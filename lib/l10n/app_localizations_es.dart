// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get addFirstCartridge => 'Añadir el primer Cartucho';

  @override
  String get addFirstGun => 'Añadir la primera Arma';

  @override
  String get addFirstScope => 'Añadir el primer Visor';

  @override
  String get addFirstShot => 'Añadir el primer Disparo';

  @override
  String get addNewCartridge => 'Añadir Nuevo Cartucho';

  @override
  String get addNewGun => 'Añadir Nueva Arma';

  @override
  String get addNewScope => 'Añadir Nuevo Visor';

  @override
  String get addNewShot => 'Añadir Nuevo Disparo';

  @override
  String get allCalculationsHaveBeenDeleted =>
      'Todos los cálculos han sido eliminados';

  @override
  String get allCartridgesHaveBeenDeleted =>
      'Todos los cartuchos han sido eliminados';

  @override
  String get goThere => 'Ir allí';

  @override
  String get allGunsHaveBeenDeleted => 'Todas las armas han sido eliminadas';

  @override
  String get allScopesHaveBeenDeleted =>
      'Todos los visores han sido eliminados';

  @override
  String angleAndWind(String angle, String windDirection, String windSpeed) {
    return 'Ángulo: $angle° • Viento: ${windSpeed}m/s @ $windDirection°';
  }

  @override
  String get apiKeyLabel => 'Clave API';

  @override
  String get appPermissions => 'Permisos de la Aplicación';

  @override
  String areYouSureDeleteCartridge(String cartridgeName) {
    return '¿Seguro que quieres eliminar $cartridgeName?';
  }

  @override
  String areYouSureDeleteGun(String gunName) {
    return '¿Seguro que quieres eliminar $gunName?';
  }

  @override
  String areYouSureDeleteScope(String scopeName) {
    return '¿Seguro que quieres eliminar $scopeName?';
  }

  @override
  String get armory => 'Armería';

  @override
  String get ballisticCoefficient => 'Coeficiente Balístico';

  @override
  String get ballisticsResults => 'Resultados Balísticos';

  @override
  String get ballisticsTrajectory => 'Trayectoria Balística';

  @override
  String bcFormat(String bc, String model) {
    return 'CB: $bc $model';
  }

  @override
  String get bulletDriftHorizontal => 'Deriva de la bala (horizontal)';

  @override
  String get bulletTrajectoryVerticalDrop =>
      'Trayectoria de la bala (caída vertical)';

  @override
  String get cancel => 'Cancelar';

  @override
  String get cartridgeName => 'Nombre del Cartucho';

  @override
  String get cartridgeProfile => 'Perfil de Cartucho';

  @override
  String get cartridgeProfileMissing => '• Falta el perfil del cartucho';

  @override
  String get centimeters => 'Centímetros';

  @override
  String get clear => 'Limpiar';

  @override
  String get clearSavedCartridges => 'Limpiar Cartuchos Guardados';

  @override
  String get clearSavedGuns => 'Limpiar Armas Guardadas';

  @override
  String get clearSavedScopes => 'Limpiar Visores Guardados';

  @override
  String get clearSavedShots => 'Limpiar Disparos Guardados';

  @override
  String get clickUnits => 'Unidades de Clic';

  @override
  String clickUnitsFormat(String units) {
    return 'Unidades de Clic: $units';
  }

  @override
  String get close => 'Cerrar';

  @override
  String get cmAbsolute => 'cm (absoluto)';

  @override
  String get cmRelative => 'cm (relativo)';

  @override
  String compassLabel(String direction) {
    return 'Brújula: $direction°';
  }

  @override
  String get configureInSettingsConfigureWeatherApi =>
      'Configurar en Ajustes > Configurar API del Clima';

  @override
  String get configureWeatherApi => 'Configurar API del Clima';

  @override
  String get configureWeatherApiKey => 'Configurar Clave API del Clima';

  @override
  String get copyThisUrlToYourBrowser => 'Copia esta URL en tu navegador:';

  @override
  String get correctionTable => 'Tabla de Correcciones';

  @override
  String
  get correctionsRelativeToLineOfSightPositiveDropBulletHitsBelowLineOfSightPositiveDriftBulletHitsToTheRight =>
      'Correcciones relativas a la línea de visión. Caída positiva = impacto debajo de la línea. Deriva positiva = impacto a la derecha.';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteAll => 'Eliminar Todo';

  @override
  String get deleteAllCartridges => '¿Eliminar todos los cartuchos?';

  @override
  String get deleteAllGuns => '¿Eliminar todas las armas?';

  @override
  String get deleteAllScopes => '¿Eliminar todos los visores?';

  @override
  String get deleteAllShots => '¿Eliminar todos los disparos?';

  @override
  String get deleteCartridge => 'Eliminar Cartucho';

  @override
  String get deleteGun => 'Eliminar Arma';

  @override
  String get deleteScope => 'Eliminar Visor';

  @override
  String get developedByMiguelBenetAkaK1m3ra =>
      'desarrollado por Miguel Benet. aka. k1m3rA';

  @override
  String get diameter => 'Diámetro';

  @override
  String diameterWeightFormat(String diameter, String weight) {
    return 'Diámetro: $diameter cm · Peso: $weight gr';
  }

  @override
  String get distanceLabel => 'Distancia';

  @override
  String get distanceMustBeGreaterThan0m =>
      'La distancia debe ser mayor que 0m';

  @override
  String get drift => 'Deriva';

  @override
  String get drop => 'Caída';

  @override
  String get enterApiKeyHint => 'Introduce tu clave API del clima';

  @override
  String get enterDataAndSelectProfilesToSeeBallisticsCalculations =>
      'Introduce datos y selecciona perfiles para ver los cálculos balísticos';

  @override
  String get enterYourFreeWeatherApiKeyFromWeatherapicom =>
      'Introduce tu clave API gratuita de weatherapi.com:';

  @override
  String get environmentalData => 'Datos Ambientales';

  @override
  String errorSavingCalculation(String error) {
    return 'Error al guardar el cálculo: $error';
  }

  @override
  String errorSavingGun(String error) {
    return 'Error al guardar el arma: $error';
  }

  @override
  String get exportToPdf => 'Exportar a PDF';

  @override
  String get g1 => 'G1';

  @override
  String get g7 => 'G7';

  @override
  String get goToProfiles => 'Ir a Perfiles';

  @override
  String get goToTheArmoryToSelectYourProfiles =>
      'Ve a la Armería para seleccionar tus perfiles';

  @override
  String get goToTheProfilesTabToCreateAndSelectProfiles =>
      'Ve a la pestaña de Perfiles para crear y seleccionar perfiles.';

  @override
  String get gunName => 'Nombre del Arma';

  @override
  String get gunProfile => 'Perfil de Arma';

  @override
  String get gunProfileMissing => '• Falta el perfil de la arma';

  @override
  String get halfMoa => '1/2 MOA';

  @override
  String get inAbsolute => 'in (absoluto)';

  @override
  String get inRelative => 'in (relativo)';

  @override
  String get inches => 'Pulgadas';

  @override
  String get inclination => 'Inclinación';

  @override
  String get invalidDistance => 'Distancia Inválida';

  @override
  String get keyPrivacyPoints => 'Puntos Clave de Privacidad';

  @override
  String get language => 'Idioma';

  @override
  String get lastShots => 'Tiros';

  @override
  String get latestShot => 'Último Tiro';

  @override
  String get leftTwist => 'Giro a la Izquierda';

  @override
  String get legend => 'Leyenda';

  @override
  String get length => 'Longitud';

  @override
  String get manageData => 'Gestionar Datos';

  @override
  String get mAbsolute => 'm (absoluto)';

  @override
  String get mRelative => 'm (relativo)';

  @override
  String get moa => 'MOA';

  @override
  String get mrad => 'MRAD';

  @override
  String get musca => 'Musca';

  @override
  String get muzzleVelocity => 'Velocidad de salida';

  @override
  String get noCartridgesAddedYet => 'Aún no se han añadido cartuchos';

  @override
  String get noCompassAvailable => 'Brújula no disponible';

  @override
  String get noGunsAddedYet => 'Aún no se han añadido armas';

  @override
  String get noProfilesSelected => 'No se han seleccionado perfiles';

  @override
  String get noSavedShotsYet => 'Aún no hay disparos guardados';

  @override
  String get noScopesAddedYet => 'Aún no se han añadido visores';

  @override
  String
  get notePositiveDropBulletHitsBelowLineOfSightPositiveDriftBulletHitsToTheRight =>
      'Nota: Caída positiva = impacto debajo de la línea, Deriva positiva = impacto a la derecha';

  @override
  String get ok => 'OK';

  @override
  String get oneEighthMoa => '1/8 MOA';

  @override
  String get oneThirdMoa => '1/3 MOA';

  @override
  String get oneTwentiethMrad => '1/20 MRAD';

  @override
  String get openLink => 'Abrir Enlace';

  @override
  String get pleaseEnterADistanceGreaterThan0MetersBeforeSaving =>
      'Por favor, introduce una distancia mayor a 0 metros antes de guardar.';

  @override
  String get pleaseEnterAValidApiKey =>
      'Por favor, introduce una clave API válida';

  @override
  String get pleaseSelectAllRequiredProfilesBeforeSaving =>
      'Por favor, selecciona todos los perfiles requeridos antes de guardar:';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get profilesRequired => 'Perfiles Requeridos';

  @override
  String get quarterMoa => '1/4 MOA';

  @override
  String get readOurCompletePrivacyPolicyOnline =>
      'Lee nuestra política de privacidad completa en línea';

  @override
  String get rightTwist => 'Giro a la Derecha';

  @override
  String get save => 'Guardar';

  @override
  String get saveAngle => 'Guardar Ángulo';

  @override
  String get scopeName => 'Nombre del Visor';

  @override
  String get scopeProfile => 'Perfil de Visor';

  @override
  String get scopeProfileMissing => '• Falta el perfil del visor';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get shotCalculation => 'Cálculo de Disparo';

  @override
  String shotSaved(String distance, String windSpeed) {
    return '¡Tiro guardado! Distancia: ${distance}m, Viento: ${windSpeed}m/s';
  }

  @override
  String get sightHeight => 'Altura del Visor';

  @override
  String sightHeightFormat(String height, String unit) {
    return 'Altura del Visor: $height $unit';
  }

  @override
  String stepMLabel(String step) {
    return '${step}m';
  }

  @override
  String get stepSizeM => 'Tamaño de Paso (m):';

  @override
  String get stepSizeMLabel => 'Tamaño de paso (m):';

  @override
  String get targetDistance => 'Distancia al objetivo';

  @override
  String get thisWillPermanentlyDeleteAllYourSavedCartridges =>
      'Esto eliminará permanentemente todos tus cartuchos guardados. ';

  @override
  String get thisWillPermanentlyDeleteAllYourSavedGuns =>
      'Esto eliminará permanentemente todas tus armas guardadas. ';

  @override
  String get thisWillPermanentlyDeleteAllYourSavedScopes =>
      'Esto eliminará permanentemente todos tus visores guardados. ';

  @override
  String get thsWillPermanentlyDeleteAllYourSavedShots =>
      'Esto eliminará permanentemente todos tus disparos guardados. ';

  @override
  String get twistRate => 'Paso de estría';

  @override
  String get unableToCalculateTrajectorynpleaseEnsureAllProfilesAreSelected =>
      'Unable to calculate trajectory.\\nPlease ensure all profiles are selected.';

  @override
  String get unidad => 'Unidad: ';

  @override
  String get units => 'Unidades:';

  @override
  String get unitsLabel => 'Unidades:';

  @override
  String get verticalAngle => 'Ángulo vertical';

  @override
  String get viewFullPrivacyPolicy => 'Ver Política de Privacidad Completa';

  @override
  String get weatherApiKeyRemoved => 'Clave API del clima eliminada';

  @override
  String get weatherApiKeySavedSuccessfully =>
      'Clave API del clima guardada correctamente';

  @override
  String get weight => 'Peso';

  @override
  String get windDirection => 'Dirección del Viento';

  @override
  String windLabel(String direction) {
    return 'Viento: $direction°';
  }

  @override
  String get windSpeedLabel => 'Velocidad del viento';

  @override
  String get yourPrivacyMatters => 'Tu Privacidad es Importante';

  @override
  String get zeroNorth => '0° = North';

  @override
  String get zeroRange => 'Rango de cero';

  @override
  String get zeroRangeLabel => 'Distancia de cero';

  @override
  String get yourCartridges => 'Tus Cartuchos';

  @override
  String get yourGuns => 'Tus Armas';

  @override
  String get yourScopes => 'Tus Visores';

  @override
  String lengthBcFormat(String length, String bc, String model) {
    return 'Longitud: $length cm · CB: $bc $model';
  }

  @override
  String gunDescriptionFormat(
    String twistDir,
    String twistRate,
    String mv,
    String zero,
  ) {
    return '$twistDir: 1:$twistRate, Vel.: $mv m/s, Cero: $zero m';
  }

  @override
  String get temperature => 'Temperatura';

  @override
  String get pressure => 'Presión';

  @override
  String get humidity => 'Humedad';

  @override
  String get latitude => 'Latitud';

  @override
  String get weatherApiNotConfigured => 'API del clima no configurada';

  @override
  String get invalidWeatherApiKey => 'Clave API del clima inválida';

  @override
  String get horizontalDrift => 'Deriva Horizontal';

  @override
  String get verticalDrop => 'Caída Vertical';

  @override
  String get right => 'Derecha';

  @override
  String get left => 'Izquierda';

  @override
  String get up => 'Arriba';

  @override
  String get down => 'Abajo';

  @override
  String get noCorrection => 'Sin corrección';

  @override
  String adjustDirection(String direction) {
    return 'Ajustar $direction';
  }

  @override
  String get angle => 'Ángulo';

  @override
  String get profileDetails => 'Detalles del Perfil';

  @override
  String get viewTrajectoryChartTooltip =>
      'Ver Gráfica de Trayectoria con Línea de Visión';

  @override
  String get bulletWeight => 'Peso de la Bala';

  @override
  String get bulletLength => 'Longitud de la Bala';

  @override
  String get bcModel => 'Modelo CB';

  @override
  String get unitsTitle => 'Unidades';

  @override
  String get grains => 'grains';

  @override
  String get angleRangeHelper => 'Rango: -90° a 90°';

  @override
  String get minSightHeightHelper => 'Mín: 0 cm';

  @override
  String get fieldData => 'Datos de Campo';

  @override
  String shotAtDistance(Object distance) {
    return 'Disparo a ${distance}m';
  }

  @override
  String windInfo(Object windDirection, Object windSpeed) {
    return 'Viento: ${windSpeed}m/s a $windDirectionº';
  }

  @override
  String angleTempInfo(Object angle, Object temp) {
    return 'Ángulo: $angleº • Temp.: $tempºC';
  }

  @override
  String impactInfo(Object drift, Object drop) {
    return 'Impacto: caída ${drop}cm, deriva ${drift}cm';
  }

  @override
  String targetLabel(Object distance) {
    return 'Objetivo\n${distance}m';
  }

  @override
  String zeroLabel(Object zero) {
    return 'Cero\n${zero}m';
  }

  @override
  String get losBoreAxis => 'Línea de visión (eje del cañón)';

  @override
  String get losHorizontal => 'Línea de visión (horizontal)';

  @override
  String get losZeroed => 'Línea de visión (a cero)';

  @override
  String get dropChartDesc =>
      'Eje X: Distancia (m) • Eje Y: Altura rel. al cañón (cm)\nPositivo = subida, negativo = caída';

  @override
  String get losCoincides =>
      '\nLa línea de visión coincide con el eje del cañón';

  @override
  String get losIsHorizontal =>
      '\nLa línea de visión es horizontal a la altura del visor';

  @override
  String get losIntersects =>
      '\nLa línea de visión cruza la trayectoria en la distancia de cero';

  @override
  String get driftChartDesc =>
      'Eje X: Distancia (m) • Eje Y: Deriva horizontal (cm)\nPositivo = deriva derecha, negativo = deriva izquierda';

  @override
  String get driftChartDesc2 =>
      '\nMuestra el desplazamiento horizontal por viento, deriva de giro y efecto Coriolis';

  @override
  String get generateTrajectoryTable => 'Generar Tabla de Trayectoria';

  @override
  String profilesLabel(Object cartridge, Object gun, Object scope) {
    return 'Perfiles: $gun | $cartridge | $scope';
  }

  @override
  String get unknownGun => 'Arma Desconocida';

  @override
  String get unknownCartridge => 'Cartucho Desconocido';

  @override
  String get unknownScope => 'Visor Desconocido';

  @override
  String windInfoPdf(Object windDirection, Object windSpeed) {
    return 'Viento: ${windSpeed}m/s a $windDirection grados';
  }

  @override
  String angleTempInfoPdf(Object angle, Object temp) {
    return 'Ángulo: $angle grados - Temp.: $temp grados C';
  }

  @override
  String stepSizeUnitsPdf(Object stepSize, Object units) {
    return 'Tamaño de paso: ${stepSize}m - Unidades: $units';
  }

  @override
  String get distanceM => 'Distancia (m)';

  @override
  String dropUnits(Object units) {
    return 'Caída ($units)';
  }

  @override
  String driftUnits(Object units) {
    return 'Deriva ($units)';
  }

  @override
  String get distanceMTable => 'Distancia\n(m)';

  @override
  String dropUnitsTable(Object units) {
    return 'Caída\n($units)';
  }

  @override
  String driftUnitsTable(Object units) {
    return 'Deriva\n($units)';
  }
}
