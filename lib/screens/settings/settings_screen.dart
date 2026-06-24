import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/calculation_storage.dart';
import '../../services/cartridge_storage.dart';
import '../../services/scope_storage.dart';
import '../../services/api_key_service.dart';
import '../../services/weather_service.dart';
import '../privacy/privacy_policy_screen.dart';
import 'package:musca/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<Locale> onLocaleChanged;
  const SettingsPage({
    super.key,
    required this.onThemeChanged,
    required this.onLocaleChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeMode _selectedTheme = ThemeMode.light;
  Locale? _selectedLocale;
  bool _isInitialized = false;
  bool _isApiConfigured = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final brightness = Theme.of(context).brightness;
      _selectedTheme =
          brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;

      final currentLocale = Localizations.localeOf(context);
      _selectedLocale = Locale(currentLocale.languageCode);

      _isInitialized = true;
      _checkApiStatus();
    }
  }

  Future<void> _checkApiStatus() async {
    final isConfigured = await WeatherService.isApiConfigured();
    setState(() {
      _isApiConfigured = isConfigured;
    });
  }

  void _updateTheme(ThemeMode theme) {
    setState(() {
      _selectedTheme = theme;
    });
    widget.onThemeChanged(theme);
  }

  void _updateLocale(Locale locale) {
    setState(() {
      _selectedLocale = locale;
    });
    widget.onLocaleChanged(locale);
  }

  // Add method to clear all calculations with confirmation dialog
  Future<void> _showClearConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteAllShots),
          content: Text(
            AppLocalizations.of(
                  context,
                )!.thsWillPermanentlyDeleteAllYourSavedShots +
                ' This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(AppLocalizations.of(context)!.deleteAll),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _clearAllCalculations();
              },
            ),
          ],
        );
      },
    );
  }

  // Method to clear all calculations
  Future<void> _clearAllCalculations() async {
    await CalculationStorage.clearAllCalculations();

    // Show confirmation to user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.allCalculationsHaveBeenDeleted,
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Add method to clear all guns with confirmation dialog
  Future<void> _showClearGunsConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteAllGuns),
          content: Text(
            AppLocalizations.of(
                  context,
                )!.thisWillPermanentlyDeleteAllYourSavedGuns +
                ' This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(AppLocalizations.of(context)!.deleteAll),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _clearAllGuns();
              },
            ),
          ],
        );
      },
    );
  }

  // Method to clear all guns
  Future<void> _clearAllGuns() async {
    await CalculationStorage.clearAllGuns();

    // Show confirmation to user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.allGunsHaveBeenDeleted),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Add method to clear all cartridges with confirmation dialog
  Future<void> _showClearCartridgesConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteAllCartridges),
          content: Text(
            AppLocalizations.of(
                  context,
                )!.thisWillPermanentlyDeleteAllYourSavedCartridges +
                ' This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(AppLocalizations.of(context)!.deleteAll),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _clearAllCartridges();
              },
            ),
          ],
        );
      },
    );
  }

  // Method to clear all cartridges
  Future<void> _clearAllCartridges() async {
    await CartridgeStorage.clearAllCartridges();

    // Show confirmation to user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.allCartridgesHaveBeenDeleted,
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Add method to clear all scopes with confirmation dialog
  Future<void> _showClearScopesConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteAllScopes),
          content: Text(
            AppLocalizations.of(
                  context,
                )!.thisWillPermanentlyDeleteAllYourSavedScopes +
                ' This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(AppLocalizations.of(context)!.deleteAll),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _clearAllScopes();
              },
            ),
          ],
        );
      },
    );
  }

  // Method to clear all scopes
  Future<void> _clearAllScopes() async {
    await ScopeStorage.clearAllScopes();

    // Show confirmation to user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.allScopesHaveBeenDeleted),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Method to open URL with fallback for web
  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      if (kIsWeb) {
        // For web, try external mode first
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          // Fallback: show URL in a dialog for manual copying
          _showUrlDialog(url);
        }
      } else {
        // For mobile platforms
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          throw 'Could not launch $url';
        }
      }
    } catch (e) {
      if (mounted) {
        // Show URL in dialog as fallback
        _showUrlDialog(url);
      }
    }
  }

  // Fallback method to show URL in dialog
  void _showUrlDialog(String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.openLink),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.copyThisUrlToYourBrowser),
              const SizedBox(height: 8),
              SelectableText(
                url,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.close),
            ),
          ],
        );
      },
    );
  }

  // Method to show Weather API key configuration dialog
  Future<void> _showWeatherApiKeyDialog() async {
    final TextEditingController apiKeyController = TextEditingController();

    // Load current API key if exists
    final currentApiKey = await ApiKeyService.getWeatherApiKey();
    if (currentApiKey != null) {
      apiKeyController.text = currentApiKey;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.configureWeatherApiKey),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(
                  context,
                )!.enterYourFreeWeatherApiKeyFromWeatherapicom,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: apiKeyController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.apiKeyLabel,
                  hintText: AppLocalizations.of(context)!.enterApiKeyHint,
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _launchUrl('https://www.weatherapi.com/'),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Get your free API key at: ',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      TextSpan(
                        text: 'https://www.weatherapi.com/',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.clear),
              onPressed: () async {
                await ApiKeyService.removeWeatherApiKey();
                await _checkApiStatus(); // Update status
                Navigator.of(dialogContext).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.weatherApiKeyRemoved,
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.save),
              onPressed: () async {
                final apiKey = apiKeyController.text.trim();
                if (apiKey.isNotEmpty) {
                  await ApiKeyService.saveWeatherApiKey(apiKey);
                  await _checkApiStatus(); // Update status
                  Navigator.of(dialogContext).pop();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(
                            context,
                          )!.weatherApiKeySavedSuccessfully,
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.pleaseEnterAValidApiKey,
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                AppLocalizations.of(context)!.settingsTitle,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _updateTheme(ThemeMode.light),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                _selectedTheme == ThemeMode.light
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.wb_sunny,
                            size: 20,
                            color:
                                _selectedTheme == ThemeMode.light
                                    ? Colors.white
                                    : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _updateTheme(ThemeMode.dark),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                _selectedTheme == ThemeMode.dark
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.nightlight_round,
                            size: 20,
                            color: Theme.of(context).colorScheme.surfaceBright,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Language Selection Section
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _updateLocale(const Locale('en')),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                _selectedLocale?.languageCode == 'en'
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest
                                    : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'EN',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    _selectedLocale?.languageCode == 'en'
                                        ? (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Theme.of(
                                              context,
                                            ).scaffoldBackgroundColor
                                            : Colors.white)
                                        : Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _updateLocale(const Locale('es')),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                _selectedLocale?.languageCode == 'es'
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest
                                    : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'ES',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    _selectedLocale?.languageCode == 'es'
                                        ? (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Theme.of(
                                              context,
                                            ).scaffoldBackgroundColor
                                            : Colors.white)
                                        : Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // API Configuration Section
                const Divider(),
                const SizedBox(height: 16),

                // Weather API Key Configuration Button
                GestureDetector(
                  onTap: _showWeatherApiKeyDialog,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 12.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.api,
                                size: 32,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _isApiConfigured
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        _isApiConfigured
                                            ? Colors.green
                                            : Colors.orange,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _isApiConfigured ? 'Configured' : 'Not Set',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        _isApiConfigured
                                            ? Colors.green
                                            : Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppLocalizations.of(context)!.configureWeatherApi,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Privacy Policy Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 12.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.privacy_tip,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppLocalizations.of(context)!.privacyPolicy,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Data Management Section
                const Divider(),
                const SizedBox(height: 16),

                Card(
                  elevation: 4,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.only(
                        left: 48.0,
                        right: 16.0,
                      ),
                      title: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.folder_delete,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppLocalizations.of(context)!.manageData,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: const SizedBox.shrink(),
                      children: [
                        InkWell(
                          onTap: _showClearConfirmationDialog,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/icon/shoot.svg',
                                  width: 32,
                                  height: 32,
                                  colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.error, BlendMode.srcIn),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  AppLocalizations.of(context)!.clearSavedShots,
                                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _showClearGunsConfirmationDialog,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/icon/rifle.svg',
                                  width: 32,
                                  height: 32,
                                  colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.error, BlendMode.srcIn),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  AppLocalizations.of(context)!.clearSavedGuns,
                                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _showClearCartridgesConfirmationDialog,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/icon/bullet.svg',
                                  width: 32,
                                  height: 32,
                                  colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.error, BlendMode.srcIn),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  AppLocalizations.of(context)!.clearSavedCartridges,
                                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _showClearScopesConfirmationDialog,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/icon/scope.svg',
                                  width: 32,
                                  height: 32,
                                  colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.error, BlendMode.srcIn),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  AppLocalizations.of(context)!.clearSavedScopes,
                                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
