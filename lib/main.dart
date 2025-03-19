import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _updateTheme(ThemeMode newTheme) {
    setState(() {
      _themeMode = newTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Musca',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      // Se usa una copia de ThemeData.dark() con fondo gris oscuro
      darkTheme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.grey[900]),
      themeMode: _themeMode,
      home: MyHomePage(title: 'Musca Calculator', onThemeChanged: _updateTheme),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.onThemeChanged});

  final String title;
  final Function(ThemeMode) onThemeChanged;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> _openSettings() async {
    final ThemeMode? selectedTheme = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
    if (selectedTheme != null) {
      widget.onThemeChanged(selectedTheme);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Acción del botón 1
                  },
                  child: const Text('Botón 1'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Acción del botón 2
                  },
                  child: const Text('Botón 2'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _openSettings,
                  child: const Text('Ajustes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Por defecto se selecciona claro (ThemeMode.light)
  ThemeMode _selectedTheme = ThemeMode.light;

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Se inicializa _selectedTheme según el tema actual de la aplicación.
    if (!_isInitialized) {
      final brightness = Theme.of(context).brightness;
      _selectedTheme = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajustes")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // const Align(
            //   alignment: Alignment.centerLeft,
            //   child: Text(
            //     "Tema",
            //     style: TextStyle(fontSize: 16),
            //   ),
            // ),
            Divider(thickness: 1, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTheme = ThemeMode.light;
                      });
                      // Actualiza el tema sin salir de la pantalla de ajustes.
                      context
                          .findAncestorStateOfType<_MyAppState>()
                          ?._updateTheme(_selectedTheme);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedTheme == ThemeMode.light
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.wb_sunny,
                        size: 30,
                        color: _selectedTheme == ThemeMode.light
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTheme = ThemeMode.dark;
                      });
                      // Actualiza el tema sin salir de la pantalla de ajustes.
                      context
                          .findAncestorStateOfType<_MyAppState>()
                          ?._updateTheme(_selectedTheme);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedTheme == ThemeMode.dark
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.nightlight_round,
                        size: 30,
                        color: _selectedTheme == ThemeMode.dark
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
