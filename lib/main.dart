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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 96, 25, 163),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      themeMode: _themeMode,
      home: MyHomePage(title: 'Musca Calculator', onThemeChanged: _updateTheme),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.onThemeChanged,
  });

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
      // Contenido principal en un CustomScrollView
      body: CustomScrollView(
        slivers: [
          // SliverAppBar con título grande
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(widget.title),
            ),
          ),
          // Resto del contenido
          SliverFillRemaining(
            child: Center(
              child: Text(
                'Main content goes here',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      // Barra inferior de navegación con los botones
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.calculate),
                onPressed: () {
                  // Acción del botón Calculator
                },
              ),
              IconButton(
                icon: const Icon(Icons.people),
                onPressed: () {
                  // Acción del botón Profiles
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _openSettings,
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
    if (!_isInitialized) {
      final brightness = Theme.of(context).brightness;
      _selectedTheme = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar en la pantalla de ajustes
          SliverAppBar(
            pinned: true,
            expandedHeight: 150,
            flexibleSpace: const FlexibleSpaceBar(
              centerTitle: true,
              title: Text("Ajustes"),
            ),
          ),
          // Contenido de la pantalla de ajustes
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'App theme:',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                      ),
                      const SizedBox(width: 80),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTheme = ThemeMode.light;
                            });
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
                              size: 20,
                              color: _selectedTheme == ThemeMode.light
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTheme = ThemeMode.dark;
                            });
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
                              size: 20,
                              color: _selectedTheme == ThemeMode.dark
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
