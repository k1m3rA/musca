import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:musca/l10n/app_localizations.dart';
import '../navigation/navigation_container.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;
  bool _preferencesLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    ThemeMode theme = ThemeMode.system;
    Locale? locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('musca.themeMode');
      if (savedTheme == 'light') theme = ThemeMode.light;
      if (savedTheme == 'dark') theme = ThemeMode.dark;
      final savedLocale = prefs.getString('musca.locale');
      if (savedLocale == 'en' || savedLocale == 'es') {
        locale = Locale(savedLocale!);
      }
    } catch (e) {
      debugPrint('Could not load appearance preferences: $e');
    }
    if (!mounted) return;
    setState(() {
      _themeMode = theme;
      _locale = locale;
      _preferencesLoaded = true;
    });
  }

  Future<void> _savePreference(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = await prefs.setString(key, value);
      if (!saved) debugPrint('Could not save preference: $key');
    } catch (e) {
      debugPrint('Could not save preference $key: $e');
    }
  }

  void _updateTheme(ThemeMode newTheme) {
    setState(() {
      _themeMode = newTheme;
    });
    _savePreference('musca.themeMode', newTheme.name);
  }

  void _updateLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
    _savePreference('musca.locale', newLocale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    if (!_preferencesLoaded) return const SizedBox.shrink();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Musca',
      locale: _locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (deviceLocale != null && deviceLocale.languageCode == 'es') {
          return const Locale('es');
        }
        return const Locale('en');
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 96, 25, 163),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      themeMode: _themeMode,
      home: NavigationContainer(
        title: 'Last Shots', 
        onThemeChanged: _updateTheme,
        onLocaleChanged: _updateLocale,
      ),
    );
  }
}
