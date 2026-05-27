// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get addFirstCartridge => 'Add first Cartridge';

  @override
  String get addFirstGun => 'Add first Gun';

  @override
  String get addFirstScope => 'Add first Scope';

  @override
  String get addFirstShot => 'Add first shot';

  @override
  String get addNewCartridge => 'Add New Cartridge';

  @override
  String get addNewGun => 'Add New Gun';

  @override
  String get addNewScope => 'Add New Scope';

  @override
  String get addNewShot => 'Add New Shot';

  @override
  String get allCalculationsHaveBeenDeleted =>
      'All calculations have been deleted';

  @override
  String get allCartridgesHaveBeenDeleted => 'All cartridges have been deleted';

  @override
  String get allGunsHaveBeenDeleted => 'All guns have been deleted';

  @override
  String get allScopesHaveBeenDeleted => 'All scopes have been deleted';

  @override
  String angleAndWind(String angle, String windDirection, String windSpeed) {
    return 'Angle: $angle° • Wind: ${windSpeed}m/s @ $windDirection°';
  }

  @override
  String get apiKeyLabel => 'API Key';

  @override
  String get appPermissions => 'App Permissions';

  @override
  String areYouSureDeleteCartridge(String cartridgeName) {
    return 'Are you sure you want to delete $cartridgeName?';
  }

  @override
  String areYouSureDeleteGun(String gunName) {
    return 'Are you sure you want to delete $gunName?';
  }

  @override
  String areYouSureDeleteScope(String scopeName) {
    return 'Are you sure you want to delete $scopeName?';
  }

  @override
  String get armory => 'Armory';

  @override
  String get ballisticCoefficient => 'Ballistic Coefficient';

  @override
  String get ballisticsResults => 'Ballistics Results';

  @override
  String get ballisticsTrajectory => 'Ballistics Trajectory';

  @override
  String bcFormat(String bc, String model) {
    return 'BC: $bc $model';
  }

  @override
  String get bulletDriftHorizontal => 'Bullet drift (horizontal)';

  @override
  String get bulletTrajectoryVerticalDrop =>
      'Bullet trajectory (vertical drop)';

  @override
  String get cancel => 'Cancel';

  @override
  String get cartridgeName => 'Cartridge Name';

  @override
  String get cartridgeProfile => 'Cartridge Profile';

  @override
  String get cartridgeProfileMissing => '• Cartridge profile missing';

  @override
  String get centimeters => 'Centimeters';

  @override
  String get clear => 'Clear';

  @override
  String get clearSavedCartridges => 'Clear Saved Cartridges';

  @override
  String get clearSavedGuns => 'Clear Saved Guns';

  @override
  String get clearSavedScopes => 'Clear Saved Scopes';

  @override
  String get clearSavedShots => 'Clear Saved Shots';

  @override
  String get clickUnits => 'Click Units';

  @override
  String clickUnitsFormat(String units) {
    return 'Click Units: $units';
  }

  @override
  String get close => 'Close';

  @override
  String get cmAbsolute => 'cm (absolute)';

  @override
  String get cmRelative => 'cm (relative)';

  @override
  String compassLabel(String direction) {
    return 'Compass: $direction°';
  }

  @override
  String get configureInSettingsConfigureWeatherApi =>
      'Configure in Settings > Configure Weather API';

  @override
  String get configureWeatherApi => 'Configure Weather API';

  @override
  String get configureWeatherApiKey => 'Configure Weather API Key';

  @override
  String get copyThisUrlToYourBrowser => 'Copy this URL to your browser:';

  @override
  String get correctionTable => 'Correction Table';

  @override
  String
  get correctionsRelativeToLineOfSightPositiveDropBulletHitsBelowLineOfSightPositiveDriftBulletHitsToTheRight =>
      'Corrections relative to line of sight. Positive drop = bullet hits below line of sight. Positive drift = bullet hits to the right.';

  @override
  String get delete => 'Delete';

  @override
  String get deleteAll => 'Delete All';

  @override
  String get deleteAllCartridges => 'Delete all cartridges?';

  @override
  String get deleteAllGuns => 'Delete all guns?';

  @override
  String get deleteAllScopes => 'Delete all scopes?';

  @override
  String get deleteAllShots => 'Delete all shots?';

  @override
  String get deleteCartridge => 'Delete Cartridge';

  @override
  String get deleteGun => 'Delete Gun';

  @override
  String get deleteScope => 'Delete Scope';

  @override
  String get developedByMiguelBenetAkaK1m3ra =>
      'developed by Miguel Benet. aka. k1m3rA';

  @override
  String get diameter => 'Diameter';

  @override
  String diameterWeightFormat(String diameter, String weight) {
    return 'Diameter: $diameter cm · Weight: $weight gr';
  }

  @override
  String get distanceLabel => 'Distance';

  @override
  String get distanceMustBeGreaterThan0m => 'Distance must be greater than 0m';

  @override
  String get drift => 'Drift';

  @override
  String get drop => 'Drop';

  @override
  String get enterApiKeyHint => 'Enter your weather API key';

  @override
  String get enterDataAndSelectProfilesToSeeBallisticsCalculations =>
      'Enter data and select profiles to see ballistics calculations';

  @override
  String get enterYourFreeWeatherApiKeyFromWeatherapicom =>
      'Enter your Free Weather API key from weatherapi.com:';

  @override
  String get environmentalData => 'Environmental Data';

  @override
  String errorSavingCalculation(String error) {
    return 'Error saving calculation: $error';
  }

  @override
  String errorSavingGun(String error) {
    return 'Error saving gun: $error';
  }

  @override
  String get exportToPdf => 'Export to PDF';

  @override
  String get g1 => 'G1';

  @override
  String get g7 => 'G7';

  @override
  String get goToProfiles => 'Go to Profiles';

  @override
  String get goToTheArmoryToSelectYourProfiles =>
      'Go to the Armory to select your profiles';

  @override
  String get goToTheProfilesTabToCreateAndSelectProfiles =>
      'Go to the Profiles tab to create and select profiles.';

  @override
  String get gunName => 'Gun Name';

  @override
  String get gunProfile => 'Gun Profile';

  @override
  String get gunProfileMissing => '• Gun profile missing';

  @override
  String get halfMoa => '1/2 MOA';

  @override
  String get inAbsolute => 'in (absolute)';

  @override
  String get inRelative => 'in (relative)';

  @override
  String get inches => 'Inches';

  @override
  String get inclination => 'Inclination';

  @override
  String get invalidDistance => 'Invalid Distance';

  @override
  String get keyPrivacyPoints => 'Key Privacy Points';

  @override
  String get language => 'Language';

  @override
  String get lastShots => 'Last Shots';

  @override
  String get latestShot => 'Latest Shot';

  @override
  String get leftTwist => 'Left Twist';

  @override
  String get legend => 'Legend';

  @override
  String get length => 'Length';

  @override
  String get mAbsolute => 'm (absolute)';

  @override
  String get mRelative => 'm (relative)';

  @override
  String get moa => 'MOA';

  @override
  String get mrad => 'MRAD';

  @override
  String get musca => 'Musca';

  @override
  String get muzzleVelocity => 'Muzzle Velocity';

  @override
  String get noCartridgesAddedYet => 'No cartridges added yet';

  @override
  String get noCompassAvailable => 'No compass available';

  @override
  String get noGunsAddedYet => 'No guns added yet';

  @override
  String get noProfilesSelected => 'No profiles selected';

  @override
  String get noSavedShotsYet => 'No saved shots yet';

  @override
  String get noScopesAddedYet => 'No scopes added yet';

  @override
  String
  get notePositiveDropBulletHitsBelowLineOfSightPositiveDriftBulletHitsToTheRight =>
      'Note: Positive drop = bullet hits below line of sight, Positive drift = bullet hits to the right';

  @override
  String get ok => 'OK';

  @override
  String get oneEighthMoa => '1/8 MOA';

  @override
  String get oneThirdMoa => '1/3 MOA';

  @override
  String get oneTwentiethMrad => '1/20 MRAD';

  @override
  String get openLink => 'Open Link';

  @override
  String get pleaseEnterADistanceGreaterThan0MetersBeforeSaving =>
      'Please enter a distance greater than 0 meters before saving.';

  @override
  String get pleaseEnterAValidApiKey => 'Please enter a valid API key';

  @override
  String get pleaseSelectAllRequiredProfilesBeforeSaving =>
      'Please select all required profiles before saving:';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get profilesRequired => 'Profiles Required';

  @override
  String get quarterMoa => '1/4 MOA';

  @override
  String get readOurCompletePrivacyPolicyOnline =>
      'Read our complete privacy policy online';

  @override
  String get rightTwist => 'Right Twist';

  @override
  String get save => 'Save';

  @override
  String get saveAngle => 'Save Angle';

  @override
  String get scopeName => 'Scope Name';

  @override
  String get scopeProfile => 'Scope Profile';

  @override
  String get scopeProfileMissing => '• Scope profile missing';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get shotCalculation => 'Shot Calculation';

  @override
  String shotSaved(String distance, String windSpeed) {
    return 'Shot saved! Distance: ${distance}m, Wind: ${windSpeed}m/s';
  }

  @override
  String get sightHeight => 'Sight Height';

  @override
  String sightHeightFormat(String height, String unit) {
    return 'Sight Height: $height $unit';
  }

  @override
  String stepMLabel(String step) {
    return '${step}m';
  }

  @override
  String get stepSizeM => 'Step Size (m):';

  @override
  String get stepSizeMLabel => 'Step Size (m):';

  @override
  String get targetDistance => 'Target distance';

  @override
  String get thisWillPermanentlyDeleteAllYourSavedCartridges =>
      'This will permanently delete all your saved cartridges. ';

  @override
  String get thisWillPermanentlyDeleteAllYourSavedGuns =>
      'This will permanently delete all your saved guns. ';

  @override
  String get thisWillPermanentlyDeleteAllYourSavedScopes =>
      'This will permanently delete all your saved scopes. ';

  @override
  String get thsWillPermanentlyDeleteAllYourSavedShots =>
      'Ths will permanently delete all your saved shots. ';

  @override
  String get twistRate => 'Twist Rate';

  @override
  String get unableToCalculateTrajectorynpleaseEnsureAllProfilesAreSelected =>
      'Unable to calculate trajectory.\\nPlease ensure all profiles are selected.';

  @override
  String get unidad => 'Unidad: ';

  @override
  String get units => 'Units:';

  @override
  String get unitsLabel => 'Units:';

  @override
  String get verticalAngle => 'Vertical angle';

  @override
  String get viewFullPrivacyPolicy => 'View Full Privacy Policy';

  @override
  String get weatherApiKeyRemoved => 'Weather API key removed';

  @override
  String get weatherApiKeySavedSuccessfully =>
      'Weather API key saved successfully';

  @override
  String get weight => 'Weight';

  @override
  String get windDirection => 'Wind Direction';

  @override
  String windLabel(String direction) {
    return 'Wind: $direction°';
  }

  @override
  String get windSpeedLabel => 'Wind Speed';

  @override
  String get yourPrivacyMatters => 'Your Privacy Matters';

  @override
  String get zeroNorth => '0° = North';

  @override
  String get zeroRange => 'Zero range';

  @override
  String get zeroRangeLabel => 'Zero Range';

  @override
  String get yourCartridges => 'Your Cartridges';

  @override
  String get yourGuns => 'Your Guns';

  @override
  String get yourScopes => 'Your Scopes';

  @override
  String lengthBcFormat(String length, String bc, String model) {
    return 'Length: $length cm · BC: $bc $model';
  }

  @override
  String gunDescriptionFormat(
    String twistDir,
    String twistRate,
    String mv,
    String zero,
  ) {
    return '$twistDir: 1:$twistRate, MV: $mv m/s, Zero: $zero m';
  }

  @override
  String get temperature => 'Temperature';

  @override
  String get pressure => 'Pressure';

  @override
  String get humidity => 'Humidity';

  @override
  String get latitude => 'Latitude';

  @override
  String get weatherApiNotConfigured => 'Weather API not configured';

  @override
  String get invalidWeatherApiKey => 'Invalid Weather API key';

  @override
  String get horizontalDrift => 'Horizontal Drift';

  @override
  String get verticalDrop => 'Vertical Drop';

  @override
  String get right => 'Right';

  @override
  String get left => 'Left';

  @override
  String get up => 'Up';

  @override
  String get down => 'Down';

  @override
  String get noCorrection => 'No correction';

  @override
  String adjustDirection(String direction) {
    return 'Adjust $direction';
  }

  @override
  String get angle => 'Angle';

  @override
  String get profileDetails => 'Profile Details';

  @override
  String get viewTrajectoryChartTooltip =>
      'View Trajectory Chart with Line of Sight';

  @override
  String get bulletWeight => 'Bullet Weight';

  @override
  String get bulletLength => 'Bullet Length';

  @override
  String get bcModel => 'BC Model';

  @override
  String get unitsTitle => 'Units';

  @override
  String get grains => 'grains';

  @override
  String get angleRangeHelper => 'Range: -90° to 90°';

  @override
  String get minSightHeightHelper => 'Min: 0 cm';

  @override
  String get fieldData => 'Field Data';

  @override
  String shotAtDistance(Object distance) {
    return 'Shot at ${distance}m';
  }

  @override
  String windInfo(Object windDirection, Object windSpeed) {
    return 'Wind: ${windSpeed}m/s @ $windDirectionº';
  }

  @override
  String angleTempInfo(Object angle, Object temp) {
    return 'Angle: $angleº • Temperature: $tempºC';
  }

  @override
  String impactInfo(Object drift, Object drop) {
    return 'Impact: ${drop}cm drop, ${drift}cm drift';
  }

  @override
  String targetLabel(Object distance) {
    return 'Target\n${distance}m';
  }

  @override
  String zeroLabel(Object zero) {
    return 'Zero\n${zero}m';
  }

  @override
  String get losBoreAxis => 'Line of sight (bore axis)';

  @override
  String get losHorizontal => 'Line of sight (horizontal)';

  @override
  String get losZeroed => 'Line of sight (zeroed)';

  @override
  String get dropChartDesc =>
      'X-axis: Distance (m) • Y-axis: Height relative to bore (cm)\nPositive values = upward drop, negative values = downward drop';

  @override
  String get losCoincides => '\nLine of sight coincides with bore axis';

  @override
  String get losIsHorizontal => '\nLine of sight is horizontal at scope height';

  @override
  String get losIntersects =>
      '\nLine of sight intersects trajectory at zero range';

  @override
  String get driftChartDesc =>
      'X-axis: Distance (m) • Y-axis: Horizontal drift (cm)\nPositive values = drift to the right, negative values = drift to the left';

  @override
  String get driftChartDesc2 =>
      '\nShows bullet horizontal displacement due to wind, spin drift, and Coriolis effect';

  @override
  String get generateTrajectoryTable => 'Generate Trajectory Table';

  @override
  String profilesLabel(Object cartridge, Object gun, Object scope) {
    return 'Profiles: $gun | $cartridge | $scope';
  }

  @override
  String get unknownGun => 'Unknown Gun';

  @override
  String get unknownCartridge => 'Unknown Cartridge';

  @override
  String get unknownScope => 'Unknown Scope';

  @override
  String windInfoPdf(Object windDirection, Object windSpeed) {
    return 'Wind: ${windSpeed}m/s at $windDirection degrees';
  }

  @override
  String angleTempInfoPdf(Object angle, Object temp) {
    return 'Angle: $angle degrees - Temperature: $temp degrees C';
  }

  @override
  String stepSizeUnitsPdf(Object stepSize, Object units) {
    return 'Step Size: ${stepSize}m - Units: $units';
  }

  @override
  String get distanceM => 'Distance (m)';

  @override
  String dropUnits(Object units) {
    return 'Drop ($units)';
  }

  @override
  String driftUnits(Object units) {
    return 'Drift ($units)';
  }

  @override
  String get distanceMTable => 'Distance\n(m)';

  @override
  String dropUnitsTable(Object units) {
    return 'Drop\n($units)';
  }

  @override
  String driftUnitsTable(Object units) {
    return 'Drift\n($units)';
  }
}
