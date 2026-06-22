import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/home/home_screen.dart';
import '../screens/calculator/calculator_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/profile/armory_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tutorial_overlay.dart';

class NavigationContainer extends StatefulWidget {
  final String title;
  final Function(ThemeMode) onThemeChanged;
  final Function(Locale) onLocaleChanged;

  const NavigationContainer({
    super.key,
    required this.title,
    required this.onThemeChanged,
    required this.onLocaleChanged,
  });

  @override
  State<NavigationContainer> createState() => _NavigationContainerState();
}

class _NavigationContainerState extends State<NavigationContainer> {
  int _currentIndex = 0;
  DateTime _lastHomeRefresh = DateTime.now();
  final GlobalKey<State<CalculatorScreen>> _calculatorKey = GlobalKey<State<CalculatorScreen>>();
  final GlobalKey _rifleButtonKey = GlobalKey();
  
  // Simple notification mechanism
  final ValueNotifier<bool> _reloadCalculatorProfiles = ValueNotifier<bool>(false);
  
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    _checkTutorial();
  }

  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    // Forzamos a false temporalmente para que puedas verlo
    final hasSeenTutorial = false; // prefs.getBool('has_seen_tutorial') ?? false;
    
    if (!hasSeenTutorial) {
      // Retraso para que la animación de la UI inicial termine antes de mostrar el overlay
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _showTutorial = true;
          });
        }
      });
    }
  }

  Future<void> _dismissTutorial() async {
    setState(() {
      _showTutorial = false;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_tutorial', true);
  }

  void _changeScreen(int index) {
    print('Navigation requested to screen index: $index'); // Debug print
    final previousIndex = _currentIndex;
    setState(() {
      _currentIndex = index;
      // Refresh home screen when navigating to it from another screen
      if (index == 0 && previousIndex != 0) {
        _lastHomeRefresh = DateTime.now();
      }      // When navigating to calculator from armory, trigger profile reload
      if (index == 1 && previousIndex == 2) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _reloadCalculatorProfiles.value = !_reloadCalculatorProfiles.value;
        });
      }
    });
  }@override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeContent(
        key: ValueKey(_lastHomeRefresh.millisecondsSinceEpoch),
        title: widget.title,
        onNavigateTo: _changeScreen,
      ),      CalculatorScreen(
        key: _calculatorKey,
        onNavigate: _changeScreen,
        reloadProfilesNotifier: _reloadCalculatorProfiles,
      ), // Pass the navigation callback
      ProfileScreen(onNavigate: _changeScreen), // Add the new profile screen
      SettingsPage(
        onThemeChanged: widget.onThemeChanged,
        onLocaleChanged: widget.onLocaleChanged,
      ),
    ];

    Widget scaffold = Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home),
              _buildNavItem(1, null, svgAsset: 'assets/icon/shoot.svg'),
              _buildNavItem(2, null, svgAsset: 'assets/icon/rifle.svg', key: _rifleButtonKey),
              _buildNavItem(3, Icons.settings),
            ],
          ),
        ),
      ),
    );

    if (_showTutorial) {
      return Stack(
        children: [
          scaffold,
          TutorialOverlay(
            onDismiss: _dismissTutorial,
            onTargetTap: () {
              _dismissTutorial();
              _changeScreen(2);
            },
            targetKey: _rifleButtonKey,
          ),
        ],
      );
    }

    return scaffold;
  }

  Widget _buildNavItem(int index, IconData? icon, {String? svgAsset, Key? key}) {
    final isSelected = _currentIndex == index;
    final iconColor = isSelected || Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface;
        
    return Container(
      key: key,
      width: 70, // Added a wider width
      decoration: BoxDecoration(
        color: isSelected 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.2) 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: IconButton(
        icon: icon != null 
            ? Icon(icon, color: iconColor)
            : svgAsset != null 
                ? SvgPicture.asset(
                    svgAsset,
                    colorFilter: ColorFilter.mode(
                      iconColor,
                      BlendMode.srcIn,
                    ),
                  )
                : Icon(Icons.error, color: iconColor),
        onPressed: () => _changeScreen(index),
      ),
    );
  }
}
