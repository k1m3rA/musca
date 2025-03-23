import 'package:flutter/material.dart';
import '../../services/calculation_storage.dart';

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

  // Add method to clear all calculations with confirmation dialog
  Future<void> _showClearConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete all shots?'),
          content: const Text(
            'Ths will permanently delete all your saved shots. '
            'This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete All'),
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
        const SnackBar(
          content: Text('All calculations have been deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
              "Settings",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                              color: _selectedTheme == ThemeMode.light
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.wb_sunny,
                              size: 20,
                              color: _selectedTheme == ThemeMode.light
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
                            color: _selectedTheme == ThemeMode.dark
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
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
                  
                  // Data Management Section
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Clear Calculations Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _showClearConfirmationDialog,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.delete_forever,
                                  size: 32,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Clear Saved Shots',
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
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
