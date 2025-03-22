import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/calculator/calculator_screen.dart';
import '../screens/settings/settings_screen.dart';

class NavigationContainer extends StatefulWidget {
  final String title;
  final Function(ThemeMode) onThemeChanged;

  const NavigationContainer({
    super.key,
    required this.title,
    required this.onThemeChanged,
  });

  @override
  State<NavigationContainer> createState() => _NavigationContainerState();
}

class _NavigationContainerState extends State<NavigationContainer> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeContent(title: widget.title),
      const CalculatorScreen(),
      SettingsPage(onThemeChanged: widget.onThemeChanged),
    ];
  }

  void _changeScreen(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home),
                color: _currentIndex == 0 
                    ? Theme.of(context).colorScheme.primary 
                    : null,
                onPressed: () => _changeScreen(0),
              ),
              IconButton(
                icon: const Icon(Icons.calculate),
                color: _currentIndex == 1 
                    ? Theme.of(context).colorScheme.primary 
                    : null,
                onPressed: () => _changeScreen(1),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                color: _currentIndex == 2 
                    ? Theme.of(context).colorScheme.primary 
                    : null,
                onPressed: () => _changeScreen(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
