import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeChanged;
  const SettingsPage({super.key, required this.onThemeChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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

  void _updateTheme(ThemeMode theme) {
    setState(() {
      _selectedTheme = theme;
    });
    widget.onThemeChanged(theme);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 150,
            flexibleSpace: const FlexibleSpaceBar(
              centerTitle: true,
              title: Text("Ajustes"),
            ),
          ),
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
                          onTap: () => _updateTheme(ThemeMode.light),
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
                          onTap: () => _updateTheme(ThemeMode.dark),
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
