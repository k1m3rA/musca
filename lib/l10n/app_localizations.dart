import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @addFirstCartridge.
  ///
  /// In en, this message translates to:
  /// **'Add first Cartridge'**
  String get addFirstCartridge;

  /// No description provided for @addFirstGun.
  ///
  /// In en, this message translates to:
  /// **'Add first Gun'**
  String get addFirstGun;

  /// No description provided for @addFirstScope.
  ///
  /// In en, this message translates to:
  /// **'Add first Scope'**
  String get addFirstScope;

  /// No description provided for @addFirstShot.
  ///
  /// In en, this message translates to:
  /// **'Add first shot'**
  String get addFirstShot;

  /// No description provided for @addNewCartridge.
  ///
  /// In en, this message translates to:
  /// **'Add New Cartridge'**
  String get addNewCartridge;

  /// No description provided for @addNewGun.
  ///
  /// In en, this message translates to:
  /// **'Add New Gun'**
  String get addNewGun;

  /// No description provided for @addNewScope.
  ///
  /// In en, this message translates to:
  /// **'Add New Scope'**
  String get addNewScope;

  /// No description provided for @addNewShot.
  ///
  /// In en, this message translates to:
  /// **'Add New Shot'**
  String get addNewShot;

  /// No description provided for @allCalculationsHaveBeenDeleted.
  ///
  /// In en, this message translates to:
  /// **'All calculations have been deleted'**
  String get allCalculationsHaveBeenDeleted;

  /// No description provided for @allCartridgesHaveBeenDeleted.
  ///
  /// In en, this message translates to:
  /// **'All cartridges have been deleted'**
  String get allCartridgesHaveBeenDeleted;

  /// No description provided for @allGunsHaveBeenDeleted.
  ///
  /// In en, this message translates to:
  /// **'All guns have been deleted'**
  String get allGunsHaveBeenDeleted;

  /// No description provided for @allScopesHaveBeenDeleted.
  ///
  /// In en, this message translates to:
  /// **'All scopes have been deleted'**
  String get allScopesHaveBeenDeleted;

  /// No description provided for @angleAndWind.
  ///
  /// In en, this message translates to:
  /// **'Angle: {angle}° • Wind: {windSpeed}m/s @ {windDirection}°'**
  String angleAndWind(String angle, String windDirection, String windSpeed);

  /// No description provided for @apiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKeyLabel;

  /// No description provided for @appPermissions.
  ///
  /// In en, this message translates to:
  /// **'App Permissions'**
  String get appPermissions;

  /// No description provided for @areYouSureDeleteCartridge.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {cartridgeName}?'**
  String areYouSureDeleteCartridge(String cartridgeName);

  /// No description provided for @areYouSureDeleteGun.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {gunName}?'**
  String areYouSureDeleteGun(String gunName);

  /// No description provided for @areYouSureDeleteScope.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {scopeName}?'**
  String areYouSureDeleteScope(String scopeName);

  /// No description provided for @armory.
  ///
  /// In en, this message translates to:
  /// **'Armory'**
  String get armory;

  /// No description provided for @ballisticCoefficient.
  ///
  /// In en, this message translates to:
  /// **'Ballistic Coefficient'**
  String get ballisticCoefficient;

  /// No description provided for @ballisticsResults.
  ///
  /// In en, this message translates to:
  /// **'Ballistics Results'**
  String get ballisticsResults;

  /// No description provided for @ballisticsTrajectory.
  ///
  /// In en, this message translates to:
  /// **'Ballistics Trajectory'**
  String get ballisticsTrajectory;

  /// No description provided for @bcFormat.
  ///
  /// In en, this message translates to:
  /// **'BC: {bc} {model}'**
  String bcFormat(String bc, String model);

  /// No description provided for @bulletDriftHorizontal.
  ///
  /// In en, this message translates to:
  /// **'Bullet drift (horizontal)'**
  String get bulletDriftHorizontal;

  /// No description provided for @bulletTrajectoryVerticalDrop.
  ///
  /// In en, this message translates to:
  /// **'Bullet trajectory (vertical drop)'**
  String get bulletTrajectoryVerticalDrop;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cartridgeName.
  ///
  /// In en, this message translates to:
  /// **'Cartridge Name'**
  String get cartridgeName;

  /// No description provided for @cartridgeProfile.
  ///
  /// In en, this message translates to:
  /// **'Cartridge Profile'**
  String get cartridgeProfile;

  /// No description provided for @cartridgeProfileMissing.
  ///
  /// In en, this message translates to:
  /// **'• Cartridge profile missing'**
  String get cartridgeProfileMissing;

  /// No description provided for @centimeters.
  ///
  /// In en, this message translates to:
  /// **'Centimeters'**
  String get centimeters;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearSavedCartridges.
  ///
  /// In en, this message translates to:
  /// **'Clear Saved Cartridges'**
  String get clearSavedCartridges;

  /// No description provided for @clearSavedGuns.
  ///
  /// In en, this message translates to:
  /// **'Clear Saved Guns'**
  String get clearSavedGuns;

  /// No description provided for @clearSavedScopes.
  ///
  /// In en, this message translates to:
  /// **'Clear Saved Scopes'**
  String get clearSavedScopes;

  /// No description provided for @clearSavedShots.
  ///
  /// In en, this message translates to:
  /// **'Clear Saved Shots'**
  String get clearSavedShots;

  /// No description provided for @clickUnits.
  ///
  /// In en, this message translates to:
  /// **'Click Units'**
  String get clickUnits;

  /// No description provided for @clickUnitsFormat.
  ///
  /// In en, this message translates to:
  /// **'Click Units: {units}'**
  String clickUnitsFormat(String units);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cmAbsolute.
  ///
  /// In en, this message translates to:
  /// **'cm (absolute)'**
  String get cmAbsolute;

  /// No description provided for @cmRelative.
  ///
  /// In en, this message translates to:
  /// **'cm (relative)'**
  String get cmRelative;

  /// No description provided for @compassLabel.
  ///
  /// In en, this message translates to:
  /// **'Compass: {direction}°'**
  String compassLabel(String direction);

  /// No description provided for @configureInSettingsConfigureWeatherApi.
  ///
  /// In en, this message translates to:
  /// **'Configure in Settings > Configure Weather API'**
  String get configureInSettingsConfigureWeatherApi;

  /// No description provided for @configureWeatherApi.
  ///
  /// In en, this message translates to:
  /// **'Configure Weather API'**
  String get configureWeatherApi;

  /// No description provided for @configureWeatherApiKey.
  ///
  /// In en, this message translates to:
  /// **'Configure Weather API Key'**
  String get configureWeatherApiKey;

  /// No description provided for @copyThisUrlToYourBrowser.
  ///
  /// In en, this message translates to:
  /// **'Copy this URL to your browser:'**
  String get copyThisUrlToYourBrowser;

  /// No description provided for @correctionTable.
  ///
  /// In en, this message translates to:
  /// **'Correction Table'**
  String get correctionTable;

  /// No description provided for @correctionsRelativeToLineOfSightPositiveDropBulletHitsBelowLineOfSightPositiveDriftBulletHitsToTheRight.
  ///
  /// In en, this message translates to:
  /// **'Corrections relative to line of sight. Positive drop = bullet hits below line of sight. Positive drift = bullet hits to the right.'**
  String
  get correctionsRelativeToLineOfSightPositiveDropBulletHitsBelowLineOfSightPositiveDriftBulletHitsToTheRight;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @deleteAllCartridges.
  ///
  /// In en, this message translates to:
  /// **'Delete all cartridges?'**
  String get deleteAllCartridges;

  /// No description provided for @deleteAllGuns.
  ///
  /// In en, this message translates to:
  /// **'Delete all guns?'**
  String get deleteAllGuns;

  /// No description provided for @deleteAllScopes.
  ///
  /// In en, this message translates to:
  /// **'Delete all scopes?'**
  String get deleteAllScopes;

  /// No description provided for @deleteAllShots.
  ///
  /// In en, this message translates to:
  /// **'Delete all shots?'**
  String get deleteAllShots;

  /// No description provided for @deleteCartridge.
  ///
  /// In en, this message translates to:
  /// **'Delete Cartridge'**
  String get deleteCartridge;

  /// No description provided for @deleteGun.
  ///
  /// In en, this message translates to:
  /// **'Delete Gun'**
  String get deleteGun;

  /// No description provided for @deleteScope.
  ///
  /// In en, this message translates to:
  /// **'Delete Scope'**
  String get deleteScope;

  /// No description provided for @developedByMiguelBenetAkaK1m3ra.
  ///
  /// In en, this message translates to:
  /// **'developed by Miguel Benet. aka. k1m3rA'**
  String get developedByMiguelBenetAkaK1m3ra;

  /// No description provided for @diameter.
  ///
  /// In en, this message translates to:
  /// **'Diameter'**
  String get diameter;

  /// No description provided for @diameterWeightFormat.
  ///
  /// In en, this message translates to:
  /// **'Diameter: {diameter} cm · Weight: {weight} gr'**
  String diameterWeightFormat(String diameter, String weight);

  /// No description provided for @distanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distanceLabel;

  /// No description provided for @distanceMustBeGreaterThan0m.
  ///
  /// In en, this message translates to:
  /// **'Distance must be greater than 0m'**
  String get distanceMustBeGreaterThan0m;

  /// No description provided for @drift.
  ///
  /// In en, this message translates to:
  /// **'Drift'**
  String get drift;

  /// No description provided for @drop.
  ///
  /// In en, this message translates to:
  /// **'Drop'**
  String get drop;

  /// No description provided for @enterApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your weather API key'**
  String get enterApiKeyHint;

  /// No description provided for @enterDataAndSelectProfilesToSeeBallisticsCalculations.
  ///
  /// In en, this message translates to:
  /// **'Enter data and select profiles to see ballistics calculations'**
  String get enterDataAndSelectProfilesToSeeBallisticsCalculations;

  /// No description provided for @enterYourFreeWeatherApiKeyFromWeatherapicom.
  ///
  /// In en, this message translates to:
  /// **'Enter your Free Weather API key from weatherapi.com:'**
  String get enterYourFreeWeatherApiKeyFromWeatherapicom;

  /// No description provided for @environmentalData.
  ///
  /// In en, this message translates to:
  /// **'Environmental Data'**
  String get environmentalData;

  /// No description provided for @errorSavingCalculation.
  ///
  /// In en, this message translates to:
  /// **'Error saving calculation: {error}'**
  String errorSavingCalculation(String error);

  /// No description provided for @errorSavingGun.
  ///
  /// In en, this message translates to:
  /// **'Error saving gun: {error}'**
  String errorSavingGun(String error);

  /// No description provided for @exportToPdf.
  ///
  /// In en, this message translates to:
  /// **'Export to PDF'**
  String get exportToPdf;

  /// No description provided for @g1.
  ///
  /// In en, this message translates to:
  /// **'G1'**
  String get g1;

  /// No description provided for @g7.
  ///
  /// In en, this message translates to:
  /// **'G7'**
  String get g7;

  /// No description provided for @goToProfiles.
  ///
  /// In en, this message translates to:
  /// **'Go to Profiles'**
  String get goToProfiles;

  /// No description provided for @goToTheArmoryToSelectYourProfiles.
  ///
  /// In en, this message translates to:
  /// **'Go to the Armory to select your profiles'**
  String get goToTheArmoryToSelectYourProfiles;

  /// No description provided for @goToTheProfilesTabToCreateAndSelectProfiles.
  ///
  /// In en, this message translates to:
  /// **'Go to the Profiles tab to create and select profiles.'**
  String get goToTheProfilesTabToCreateAndSelectProfiles;

  /// No description provided for @gunName.
  ///
  /// In en, this message translates to:
  /// **'Gun Name'**
  String get gunName;

  /// No description provided for @gunProfile.
  ///
  /// In en, this message translates to:
  /// **'Gun Profile'**
  String get gunProfile;

  /// No description provided for @gunProfileMissing.
  ///
  /// In en, this message translates to:
  /// **'• Gun profile missing'**
  String get gunProfileMissing;

  /// No description provided for @halfMoa.
  ///
  /// In en, this message translates to:
  /// **'1/2 MOA'**
  String get halfMoa;

  /// No description provided for @inAbsolute.
  ///
  /// In en, this message translates to:
  /// **'in (absolute)'**
  String get inAbsolute;

  /// No description provided for @inRelative.
  ///
  /// In en, this message translates to:
  /// **'in (relative)'**
  String get inRelative;

  /// No description provided for @inches.
  ///
  /// In en, this message translates to:
  /// **'Inches'**
  String get inches;

  /// No description provided for @inclination.
  ///
  /// In en, this message translates to:
  /// **'Inclination'**
  String get inclination;

  /// No description provided for @invalidDistance.
  ///
  /// In en, this message translates to:
  /// **'Invalid Distance'**
  String get invalidDistance;

  /// No description provided for @keyPrivacyPoints.
  ///
  /// In en, this message translates to:
  /// **'Key Privacy Points'**
  String get keyPrivacyPoints;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @lastShots.
  ///
  /// In en, this message translates to:
  /// **'Last Shots'**
  String get lastShots;

  /// No description provided for @latestShot.
  ///
  /// In en, this message translates to:
  /// **'Latest Shot'**
  String get latestShot;

  /// No description provided for @leftTwist.
  ///
  /// In en, this message translates to:
  /// **'Left Twist'**
  String get leftTwist;

  /// No description provided for @legend.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get legend;

  /// No description provided for @length.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get length;

  /// No description provided for @mAbsolute.
  ///
  /// In en, this message translates to:
  /// **'m (absolute)'**
  String get mAbsolute;

  /// No description provided for @mRelative.
  ///
  /// In en, this message translates to:
  /// **'m (relative)'**
  String get mRelative;

  /// No description provided for @moa.
  ///
  /// In en, this message translates to:
  /// **'MOA'**
  String get moa;

  /// No description provided for @mrad.
  ///
  /// In en, this message translates to:
  /// **'MRAD'**
  String get mrad;

  /// No description provided for @musca.
  ///
  /// In en, this message translates to:
  /// **'Musca'**
  String get musca;

  /// No description provided for @muzzleVelocity.
  ///
  /// In en, this message translates to:
  /// **'Muzzle Velocity'**
  String get muzzleVelocity;

  /// No description provided for @noCartridgesAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No cartridges added yet'**
  String get noCartridgesAddedYet;

  /// No description provided for @noCompassAvailable.
  ///
  /// In en, this message translates to:
  /// **'No compass available'**
  String get noCompassAvailable;

  /// No description provided for @noGunsAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No guns added yet'**
  String get noGunsAddedYet;

  /// No description provided for @noProfilesSelected.
  ///
  /// In en, this message translates to:
  /// **'No profiles selected'**
  String get noProfilesSelected;

  /// No description provided for @noSavedShotsYet.
  ///
  /// In en, this message translates to:
  /// **'No saved shots yet'**
  String get noSavedShotsYet;

  /// No description provided for @noScopesAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No scopes added yet'**
  String get noScopesAddedYet;

  /// No description provided for @notePositiveDropBulletHitsBelowLineOfSightPositiveDriftBulletHitsToTheRight.
  ///
  /// In en, this message translates to:
  /// **'Note: Positive drop = bullet hits below line of sight, Positive drift = bullet hits to the right'**
  String
  get notePositiveDropBulletHitsBelowLineOfSightPositiveDriftBulletHitsToTheRight;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @oneEighthMoa.
  ///
  /// In en, this message translates to:
  /// **'1/8 MOA'**
  String get oneEighthMoa;

  /// No description provided for @oneThirdMoa.
  ///
  /// In en, this message translates to:
  /// **'1/3 MOA'**
  String get oneThirdMoa;

  /// No description provided for @oneTwentiethMrad.
  ///
  /// In en, this message translates to:
  /// **'1/20 MRAD'**
  String get oneTwentiethMrad;

  /// No description provided for @openLink.
  ///
  /// In en, this message translates to:
  /// **'Open Link'**
  String get openLink;

  /// No description provided for @pleaseEnterADistanceGreaterThan0MetersBeforeSaving.
  ///
  /// In en, this message translates to:
  /// **'Please enter a distance greater than 0 meters before saving.'**
  String get pleaseEnterADistanceGreaterThan0MetersBeforeSaving;

  /// No description provided for @pleaseEnterAValidApiKey.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid API key'**
  String get pleaseEnterAValidApiKey;

  /// No description provided for @pleaseSelectAllRequiredProfilesBeforeSaving.
  ///
  /// In en, this message translates to:
  /// **'Please select all required profiles before saving:'**
  String get pleaseSelectAllRequiredProfilesBeforeSaving;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @profilesRequired.
  ///
  /// In en, this message translates to:
  /// **'Profiles Required'**
  String get profilesRequired;

  /// No description provided for @quarterMoa.
  ///
  /// In en, this message translates to:
  /// **'1/4 MOA'**
  String get quarterMoa;

  /// No description provided for @readOurCompletePrivacyPolicyOnline.
  ///
  /// In en, this message translates to:
  /// **'Read our complete privacy policy online'**
  String get readOurCompletePrivacyPolicyOnline;

  /// No description provided for @rightTwist.
  ///
  /// In en, this message translates to:
  /// **'Right Twist'**
  String get rightTwist;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveAngle.
  ///
  /// In en, this message translates to:
  /// **'Save Angle'**
  String get saveAngle;

  /// No description provided for @scopeName.
  ///
  /// In en, this message translates to:
  /// **'Scope Name'**
  String get scopeName;

  /// No description provided for @scopeProfile.
  ///
  /// In en, this message translates to:
  /// **'Scope Profile'**
  String get scopeProfile;

  /// No description provided for @scopeProfileMissing.
  ///
  /// In en, this message translates to:
  /// **'• Scope profile missing'**
  String get scopeProfileMissing;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @shotCalculation.
  ///
  /// In en, this message translates to:
  /// **'Shot Calculation'**
  String get shotCalculation;

  /// No description provided for @shotSaved.
  ///
  /// In en, this message translates to:
  /// **'Shot saved! Distance: {distance}m, Wind: {windSpeed}m/s'**
  String shotSaved(String distance, String windSpeed);

  /// No description provided for @sightHeight.
  ///
  /// In en, this message translates to:
  /// **'Sight Height'**
  String get sightHeight;

  /// No description provided for @sightHeightFormat.
  ///
  /// In en, this message translates to:
  /// **'Sight Height: {height} {unit}'**
  String sightHeightFormat(String height, String unit);

  /// No description provided for @stepMLabel.
  ///
  /// In en, this message translates to:
  /// **'{step}m'**
  String stepMLabel(String step);

  /// No description provided for @stepSizeM.
  ///
  /// In en, this message translates to:
  /// **'Step Size (m):'**
  String get stepSizeM;

  /// No description provided for @stepSizeMLabel.
  ///
  /// In en, this message translates to:
  /// **'Step Size (m):'**
  String get stepSizeMLabel;

  /// No description provided for @targetDistance.
  ///
  /// In en, this message translates to:
  /// **'Target distance'**
  String get targetDistance;

  /// No description provided for @thisWillPermanentlyDeleteAllYourSavedCartridges.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your saved cartridges. '**
  String get thisWillPermanentlyDeleteAllYourSavedCartridges;

  /// No description provided for @thisWillPermanentlyDeleteAllYourSavedGuns.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your saved guns. '**
  String get thisWillPermanentlyDeleteAllYourSavedGuns;

  /// No description provided for @thisWillPermanentlyDeleteAllYourSavedScopes.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your saved scopes. '**
  String get thisWillPermanentlyDeleteAllYourSavedScopes;

  /// No description provided for @thsWillPermanentlyDeleteAllYourSavedShots.
  ///
  /// In en, this message translates to:
  /// **'Ths will permanently delete all your saved shots. '**
  String get thsWillPermanentlyDeleteAllYourSavedShots;

  /// No description provided for @twistRate.
  ///
  /// In en, this message translates to:
  /// **'Twist Rate'**
  String get twistRate;

  /// No description provided for @unableToCalculateTrajectorynpleaseEnsureAllProfilesAreSelected.
  ///
  /// In en, this message translates to:
  /// **'Unable to calculate trajectory.\\nPlease ensure all profiles are selected.'**
  String get unableToCalculateTrajectorynpleaseEnsureAllProfilesAreSelected;

  /// No description provided for @unidad.
  ///
  /// In en, this message translates to:
  /// **'Unidad: '**
  String get unidad;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units:'**
  String get units;

  /// No description provided for @unitsLabel.
  ///
  /// In en, this message translates to:
  /// **'Units:'**
  String get unitsLabel;

  /// No description provided for @verticalAngle.
  ///
  /// In en, this message translates to:
  /// **'Vertical angle'**
  String get verticalAngle;

  /// No description provided for @viewFullPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'View Full Privacy Policy'**
  String get viewFullPrivacyPolicy;

  /// No description provided for @weatherApiKeyRemoved.
  ///
  /// In en, this message translates to:
  /// **'Weather API key removed'**
  String get weatherApiKeyRemoved;

  /// No description provided for @weatherApiKeySavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Weather API key saved successfully'**
  String get weatherApiKeySavedSuccessfully;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @windDirection.
  ///
  /// In en, this message translates to:
  /// **'Wind Direction'**
  String get windDirection;

  /// No description provided for @windLabel.
  ///
  /// In en, this message translates to:
  /// **'Wind: {direction}°'**
  String windLabel(String direction);

  /// No description provided for @windSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Wind Speed'**
  String get windSpeedLabel;

  /// No description provided for @yourPrivacyMatters.
  ///
  /// In en, this message translates to:
  /// **'Your Privacy Matters'**
  String get yourPrivacyMatters;

  /// No description provided for @zeroNorth.
  ///
  /// In en, this message translates to:
  /// **'0° = North'**
  String get zeroNorth;

  /// No description provided for @zeroRange.
  ///
  /// In en, this message translates to:
  /// **'Zero range'**
  String get zeroRange;

  /// No description provided for @zeroRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Zero Range'**
  String get zeroRangeLabel;

  /// No description provided for @yourCartridges.
  ///
  /// In en, this message translates to:
  /// **'Your Cartridges'**
  String get yourCartridges;

  /// No description provided for @yourGuns.
  ///
  /// In en, this message translates to:
  /// **'Your Guns'**
  String get yourGuns;

  /// No description provided for @yourScopes.
  ///
  /// In en, this message translates to:
  /// **'Your Scopes'**
  String get yourScopes;

  /// No description provided for @lengthBcFormat.
  ///
  /// In en, this message translates to:
  /// **'Length: {length} cm · BC: {bc} {model}'**
  String lengthBcFormat(String length, String bc, String model);

  /// No description provided for @gunDescriptionFormat.
  ///
  /// In en, this message translates to:
  /// **'{twistDir}: 1:{twistRate}, MV: {mv} m/s, Zero: {zero} m'**
  String gunDescriptionFormat(
    String twistDir,
    String twistRate,
    String mv,
    String zero,
  );

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @pressure.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get pressure;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @weatherApiNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Weather API not configured'**
  String get weatherApiNotConfigured;

  /// No description provided for @invalidWeatherApiKey.
  ///
  /// In en, this message translates to:
  /// **'Invalid Weather API key'**
  String get invalidWeatherApiKey;

  /// No description provided for @horizontalDrift.
  ///
  /// In en, this message translates to:
  /// **'Horizontal Drift'**
  String get horizontalDrift;

  /// No description provided for @verticalDrop.
  ///
  /// In en, this message translates to:
  /// **'Vertical Drop'**
  String get verticalDrop;

  /// No description provided for @right.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get right;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// No description provided for @up.
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get up;

  /// No description provided for @down.
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get down;

  /// No description provided for @noCorrection.
  ///
  /// In en, this message translates to:
  /// **'No correction'**
  String get noCorrection;

  /// No description provided for @adjustDirection.
  ///
  /// In en, this message translates to:
  /// **'Adjust {direction}'**
  String adjustDirection(String direction);

  /// No description provided for @angle.
  ///
  /// In en, this message translates to:
  /// **'Angle'**
  String get angle;

  /// No description provided for @profileDetails.
  ///
  /// In en, this message translates to:
  /// **'Profile Details'**
  String get profileDetails;

  /// No description provided for @bulletWeight.
  ///
  /// In en, this message translates to:
  /// **'Bullet Weight'**
  String get bulletWeight;

  /// No description provided for @bulletLength.
  ///
  /// In en, this message translates to:
  /// **'Bullet Length'**
  String get bulletLength;

  /// No description provided for @bcModel.
  ///
  /// In en, this message translates to:
  /// **'BC Model'**
  String get bcModel;

  /// No description provided for @unitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get unitsTitle;

  /// No description provided for @grains.
  ///
  /// In en, this message translates to:
  /// **'grains'**
  String get grains;

  /// No description provided for @angleRangeHelper.
  ///
  /// In en, this message translates to:
  /// **'Range: -90° to 90°'**
  String get angleRangeHelper;

  /// No description provided for @minSightHeightHelper.
  ///
  /// In en, this message translates to:
  /// **'Min: 0 cm'**
  String get minSightHeightHelper;

  /// No description provided for @fieldData.
  ///
  /// In en, this message translates to:
  /// **'Field Data'**
  String get fieldData;

  /// No description provided for @shotAtDistance.
  ///
  /// In en, this message translates to:
  /// **'Shot at {distance}m'**
  String shotAtDistance(Object distance);

  /// No description provided for @windInfo.
  ///
  /// In en, this message translates to:
  /// **'Wind: {windSpeed}m/s @ {windDirection}º'**
  String windInfo(Object windDirection, Object windSpeed);

  /// No description provided for @angleTempInfo.
  ///
  /// In en, this message translates to:
  /// **'Angle: {angle}º • Temperature: {temp}ºC'**
  String angleTempInfo(Object angle, Object temp);

  /// No description provided for @impactInfo.
  ///
  /// In en, this message translates to:
  /// **'Impact: {drop}cm drop, {drift}cm drift'**
  String impactInfo(Object drift, Object drop);

  /// No description provided for @targetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target\n{distance}m'**
  String targetLabel(Object distance);

  /// No description provided for @zeroLabel.
  ///
  /// In en, this message translates to:
  /// **'Zero\n{zero}m'**
  String zeroLabel(Object zero);

  /// No description provided for @losBoreAxis.
  ///
  /// In en, this message translates to:
  /// **'Line of sight (bore axis)'**
  String get losBoreAxis;

  /// No description provided for @losHorizontal.
  ///
  /// In en, this message translates to:
  /// **'Line of sight (horizontal)'**
  String get losHorizontal;

  /// No description provided for @losZeroed.
  ///
  /// In en, this message translates to:
  /// **'Line of sight (zeroed)'**
  String get losZeroed;

  /// No description provided for @dropChartDesc.
  ///
  /// In en, this message translates to:
  /// **'X-axis: Distance (m) • Y-axis: Height relative to bore (cm)\nPositive values = upward drop, negative values = downward drop'**
  String get dropChartDesc;

  /// No description provided for @losCoincides.
  ///
  /// In en, this message translates to:
  /// **'\nLine of sight coincides with bore axis'**
  String get losCoincides;

  /// No description provided for @losIsHorizontal.
  ///
  /// In en, this message translates to:
  /// **'\nLine of sight is horizontal at scope height'**
  String get losIsHorizontal;

  /// No description provided for @losIntersects.
  ///
  /// In en, this message translates to:
  /// **'\nLine of sight intersects trajectory at zero range'**
  String get losIntersects;

  /// No description provided for @driftChartDesc.
  ///
  /// In en, this message translates to:
  /// **'X-axis: Distance (m) • Y-axis: Horizontal drift (cm)\nPositive values = drift to the right, negative values = drift to the left'**
  String get driftChartDesc;

  /// No description provided for @driftChartDesc2.
  ///
  /// In en, this message translates to:
  /// **'\nShows bullet horizontal displacement due to wind, spin drift, and Coriolis effect'**
  String get driftChartDesc2;

  /// No description provided for @generateTrajectoryTable.
  ///
  /// In en, this message translates to:
  /// **'Generate Trajectory Table'**
  String get generateTrajectoryTable;

  /// No description provided for @profilesLabel.
  ///
  /// In en, this message translates to:
  /// **'Profiles: {gun} | {cartridge} | {scope}'**
  String profilesLabel(Object cartridge, Object gun, Object scope);

  /// No description provided for @unknownGun.
  ///
  /// In en, this message translates to:
  /// **'Unknown Gun'**
  String get unknownGun;

  /// No description provided for @unknownCartridge.
  ///
  /// In en, this message translates to:
  /// **'Unknown Cartridge'**
  String get unknownCartridge;

  /// No description provided for @unknownScope.
  ///
  /// In en, this message translates to:
  /// **'Unknown Scope'**
  String get unknownScope;

  /// No description provided for @windInfoPdf.
  ///
  /// In en, this message translates to:
  /// **'Wind: {windSpeed}m/s at {windDirection} degrees'**
  String windInfoPdf(Object windDirection, Object windSpeed);

  /// No description provided for @angleTempInfoPdf.
  ///
  /// In en, this message translates to:
  /// **'Angle: {angle} degrees - Temperature: {temp} degrees C'**
  String angleTempInfoPdf(Object angle, Object temp);

  /// No description provided for @stepSizeUnitsPdf.
  ///
  /// In en, this message translates to:
  /// **'Step Size: {stepSize}m - Units: {units}'**
  String stepSizeUnitsPdf(Object stepSize, Object units);

  /// No description provided for @distanceM.
  ///
  /// In en, this message translates to:
  /// **'Distance (m)'**
  String get distanceM;

  /// No description provided for @dropUnits.
  ///
  /// In en, this message translates to:
  /// **'Drop ({units})'**
  String dropUnits(Object units);

  /// No description provided for @driftUnits.
  ///
  /// In en, this message translates to:
  /// **'Drift ({units})'**
  String driftUnits(Object units);

  /// No description provided for @distanceMTable.
  ///
  /// In en, this message translates to:
  /// **'Distance\n(m)'**
  String get distanceMTable;

  /// No description provided for @dropUnitsTable.
  ///
  /// In en, this message translates to:
  /// **'Drop\n({units})'**
  String dropUnitsTable(Object units);

  /// No description provided for @driftUnitsTable.
  ///
  /// In en, this message translates to:
  /// **'Drift\n({units})'**
  String driftUnitsTable(Object units);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
