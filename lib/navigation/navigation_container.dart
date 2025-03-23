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

  @override
  void initState() {
    super.initState();
  }

  void _changeScreen(int index) {
    print('Navigation requested to screen index: $index'); // Debug print
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeContent(
        title: widget.title,
        onNavigateTo: _changeScreen,
      ),
      const CalculatorScreen(),
      SettingsPage(onThemeChanged: widget.onThemeChanged),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home),
              _buildNavItem(1, Icons.calculate),
              _buildNavItem(2, Icons.settings),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _currentIndex == index;
    return Container(
      width: 70, // Added a wider width
      decoration: BoxDecoration(
        color: isSelected 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.2) 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: () => _changeScreen(index),
      ),
    );
  }
}
