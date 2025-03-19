import 'package:flutter/material.dart';
import '../settings/settings_screen.dart';

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
        builder: (context) => SettingsPage(onThemeChanged: widget.onThemeChanged),
      ),
    );
    if (selectedTheme != null) {
      widget.onThemeChanged(selectedTheme);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(widget.title),
            ),
          ),
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