import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/calculation_storage.dart';
import '../../services/cartridge_storage.dart'; // Add import for CartridgeStorage
import '../../services/scope_storage.dart'; // Add import for ScopeStorage
import '../../services/api_key_service.dart';
import '../../services/weather_service.dart';
import '../privacy/privacy_policy_screen.dart';

class SettingsPage extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeChanged;
  const SettingsPage({super.key, required this.onThemeChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeMode _selectedTheme = ThemeMode.light;
  bool _isInitialized = false;
  bool _isApiConfigured = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final brightness = Theme.of(context).brightness;
      _selectedTheme = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
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

  // Add method to clear all guns with confirmation dialog
  Future<void> _showClearGunsConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete all guns?'),
          content: const Text(
            'This will permanently delete all your saved guns. '
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
        const SnackBar(
          content: Text('All guns have been deleted'),
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
          title: const Text('Delete all cartridges?'),
          content: const Text(
            'This will permanently delete all your saved cartridges. '
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
        const SnackBar(
          content: Text('All cartridges have been deleted'),
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
          title: const Text('Delete all scopes?'),
          content: const Text(
            'This will permanently delete all your saved scopes. '
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
        const SnackBar(
          content: Text('All scopes have been deleted'),
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
          title: const Text('Open Link'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Copy this URL to your browser:'),
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
              child: const Text('Close'),
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
          title: const Text('Configure Weather API Key'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your Free Weather API key from weatherapi.com:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  hintText: 'Enter your weather API key',
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
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
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
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Clear'),
              onPressed: () async {
                await ApiKeyService.removeWeatherApiKey();
                await _checkApiStatus(); // Update status
                Navigator.of(dialogContext).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Weather API key removed'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                final apiKey = apiKeyController.text.trim();
                if (apiKey.isNotEmpty) {
                  await ApiKeyService.saveWeatherApiKey(apiKey);
                  await _checkApiStatus(); // Update status
                  Navigator.of(dialogContext).pop();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Weather API key saved successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid API key'),
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
              "Settings",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
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
                
                // API Configuration Section
                const Divider(),
                const SizedBox(height: 16),
                
                // Weather API Key Configuration Button
                GestureDetector(
                  onTap: _showWeatherApiKeyDialog,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _isApiConfigured 
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _isApiConfigured ? Colors.green : Colors.orange,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _isApiConfigured ? 'Configured' : 'Not Set',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _isApiConfigured ? Colors.green : Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Configure Weather API',
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
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
                            'Privacy Policy',
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
                
                // Clear Calculations Button
                GestureDetector(
                  onTap: _showClearConfirmationDialog,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
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
                const SizedBox(height: 16),
                
                // Clear Guns Button
                GestureDetector(
                  onTap: _showClearGunsConfirmationDialog,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
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
                            'Clear Saved Guns',
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

                // Clear Cartridges Button
                GestureDetector(
                  onTap: _showClearCartridgesConfirmationDialog,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
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
                            'Clear Saved Cartridges',
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

                // Clear Scopes Button
                GestureDetector(
                  onTap: _showClearScopesConfirmationDialog,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
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
                            'Clear Saved Scopes',
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
                const SizedBox(height: 8),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
