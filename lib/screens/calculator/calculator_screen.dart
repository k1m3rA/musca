import 'package:flutter/material.dart';
import 'widgets/distance_input.dart';
import 'widgets/angle_input.dart';
import 'widgets/wind_speed_input.dart';
import 'widgets/compass_widget.dart';
import 'widgets/wind_direction_input.dart';
import 'widgets/camera_angle_screen.dart';
import 'widgets/environmental_input.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../models/calculation.dart';
import '../../services/calculation_storage.dart';
import '../../services/ballistics_calculator.dart';
import '../../services/gun_storage.dart';
import '../../services/cartridge_storage.dart';
import '../../services/scope_storage.dart';
import '../../models/gun_model.dart';
import '../../models/cartridge_model.dart';
import '../../models/scope_model.dart';

class CalculatorScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  final ValueNotifier<bool>? reloadProfilesNotifier;
  
  const CalculatorScreen({
    super.key, 
    this.onNavigate,
    this.reloadProfilesNotifier,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _distanceController = TextEditingController(text: '100.0');
  double _distance = 100.0;
  final double _scrollStep = 0.5;
  final TextEditingController _angleController = TextEditingController(text: '0.0');
  double _angle = 0.0;
  final TextEditingController _windSpeedController = TextEditingController(text: '0.0');
  double _windSpeed = 0.0;
  final TextEditingController _windDirectionController = TextEditingController(text: '0.0');  double _windDirection = 0.0;  bool _hasCompass = false;
  BallisticsResult? _ballisticsResult;

  // Add new controllers and variables for environmental data
  final TextEditingController _temperatureController = TextEditingController(text: '20.0');
  double _temperature = 20.0;
  final TextEditingController _pressureController = TextEditingController(text: '1013.0');
  double _pressure = 1013.0;
  final TextEditingController _humidityController = TextEditingController(text: '50.0');
  double _humidity = 50.0;

  // Profile data
  Gun? _selectedGun;
  Cartridge? _selectedCartridge;
  Scope? _selectedScope;  
  
  // Add new variable for latitude
  double _latitude = 0.0;

  @override
  void initState() {
    super.initState();
    
    _distanceController.addListener(_updateDistanceFromText);
    _angleController.addListener(_updateAngleFromText);
    _windSpeedController.addListener(_updateWindSpeedFromText);
    _windDirectionController.addListener(_updateWindDirectionFromText);
    
    // Add listeners for environmental data
    _temperatureController.addListener(_updateTemperatureFromText);
    _pressureController.addListener(_updatePressureFromText);
    _humidityController.addListener(_updateHumidityFromText);
    
    // Listen for profile reload notifications
    widget.reloadProfilesNotifier?.addListener(_onReloadProfilesNotification);
    
    // Load selected profiles
    _loadSelectedProfiles();
    
    // Check if compass is available
    _checkCompassAvailability();
  }
  // This will be called when returning from other screens
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only reload if widget is already mounted and not in initial build
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadSelectedProfiles();
        }
      });
    }
  }  // Public method to be called from navigation container
  void reloadProfilesFromNavigation() {
    print('Reloading profiles from navigation...'); // Debug print
    _loadSelectedProfiles();
  }

  // Method called when ValueNotifier changes
  void _onReloadProfilesNotification() {
    print('Profile reload notification received!'); // Debug print
    _loadSelectedProfiles();
  }  Future<void> _loadSelectedProfiles() async {
    try {
      final gun = await GunStorage.getSelectedGun();
      final cartridge = await CartridgeStorage.getSelectedCartridge();
      final scope = await ScopeStorage.getSelectedScope();
      
      setState(() {
        _selectedGun = gun;
        _selectedCartridge = cartridge;
        _selectedScope = scope;
      });
      
      // Profile loaded, calculations will run when calculate button is pressed
    } catch (e) {
      print('Error loading selected profiles: $e');
    }
  }

  Future<void> _checkCompassAvailability() async {
    setState(() {
      _hasCompass = FlutterCompass.events != null;
    });
  }  void _updateWindDirectionFromText() {
    if (_windDirectionController.text.isNotEmpty) {
      try {
        final newValue = double.parse(_windDirectionController.text);
        setState(() => _windDirection = newValue);
      } catch (_) {}
    }
  }
  void _updateDistanceFromText() {
    if (_distanceController.text.isNotEmpty) {
      try {
        final newValue = double.parse(_distanceController.text);
        setState(() => _distance = newValue);
      } catch (_) {}
    }
  }
  void _updateAngleFromText() {
    if (_angleController.text.isNotEmpty) {
      try {
        final newValue = double.parse(_angleController.text);
        setState(() => _angle = newValue);
      } catch (_) {}
    }
  }
  void _updateWindSpeedFromText() {
    if (_windSpeedController.text.isNotEmpty) {
      try {
        final newValue = double.parse(_windSpeedController.text);
        setState(() => _windSpeed = newValue);
      } catch (_) {}
    }
  }

  void _updateTemperatureFromText() {
    if (_temperatureController.text.isNotEmpty) {
      try {
        final newValue = double.parse(_temperatureController.text);
        setState(() => _temperature = newValue);
      } catch (_) {}
    }
  }

  void _updatePressureFromText() {
    if (_pressureController.text.isNotEmpty) {
      try {
        final newValue = double.parse(_pressureController.text);
        setState(() => _pressure = newValue);
      } catch (_) {}
    }
  }

  void _updateHumidityFromText() {
    if (_humidityController.text.isNotEmpty) {
      try {
        final newValue = double.parse(_humidityController.text);
        setState(() => _humidity = newValue);
      } catch (_) {}
    }
  }  void _updateDistance(double delta) {
    final newDistance = _distance + delta;
    if (newDistance >= 0) {
      setState(() {
        _distance = newDistance;
        _distanceController.text = _distance.toStringAsFixed(1);
      });
    }
  }

  void _updateAngle(double delta) {
    final newAngle = _angle + delta;
    // Apply the same 90-degree limit as in AngleInput widget
    final clampedAngle = newAngle.clamp(-90.0, 90.0);
    setState(() {
      _angle = clampedAngle;
      _angleController.text = _angle.toStringAsFixed(1);
    });
  }  void _updateWindSpeed(double delta) {
    final newWindSpeed = _windSpeed + delta;
    if (newWindSpeed >= 0) {
      setState(() {
        _windSpeed = newWindSpeed;
        _windSpeedController.text = _windSpeed.toStringAsFixed(1);
      });
    }
  }
  void _updateWindDirection(double delta) {
    setState(() {
      _windDirection = (_windDirection + delta) % 360;
      if (_windDirection < 0) _windDirection += 360;
      _windDirectionController.text = _windDirection.round().toString();
    });
  }

  void _updateTemperature(double delta) {
    final newTemperature = _temperature + delta;
    setState(() {
      _temperature = newTemperature;
      _temperatureController.text = _temperature.toStringAsFixed(1);
    });
  }

  void _updatePressure(double delta) {
    final newPressure = _pressure + delta;
    if (newPressure > 0) {
      setState(() {
        _pressure = newPressure;
        _pressureController.text = _pressure.toStringAsFixed(1);
      });
    }
  }
  void _updateHumidity(double delta) {
    final newHumidity = _humidity + delta;
    if (newHumidity >= 0 && newHumidity <= 100) {
      setState(() {
        _humidity = newHumidity;
        _humidityController.text = _humidity.toStringAsFixed(1);
      });
    }
  }
  Future<void> _openCameraForAngle() async {
    final measuredAngle = await Navigator.push<double>(
      context,
      MaterialPageRoute(builder: (context) => const CameraAngleScreen()),
    );
    
    if (measuredAngle != null) {
      // Apply the same 90-degree limit as in AngleInput widget
      final clampedAngle = measuredAngle.clamp(-90.0, 90.0);
      setState(() {
        _angle = clampedAngle;
        _angleController.text = _angle.toStringAsFixed(1);
      });
    }
  }

  Future<void> _saveCalculation() async {
    // Validate that all required profiles are selected
    if (_selectedGun == null || _selectedCartridge == null || _selectedScope == null) {
      _showProfileErrorDialog();
      return;
    }
    
    // Validate that distance is greater than 0
    if (_distance <= 0) {
      _showDistanceErrorDialog();
      return;
    }
    
    try {
      // Use the SAME ballistics result that's already calculated and displayed
      // This ensures perfect consistency between display and saved data
      final ballisticsResult = _ballisticsResult ?? BallisticsCalculator.calculateWithProfiles(
        _distance,
        _windSpeed,
        _windDirection,
        _selectedGun!,
        _selectedCartridge!,
        _selectedScope!,        temperature: _temperature,
        pressure: _pressure,
        humidity: _humidity,
        elevationAngle: _angle,     // Include elevation angle in save as well
        azimuthAngle: _windDirection,
        latitude: _latitude, // Add missing latitude parameter
      );
        final calculation = Calculation(
        distance: _distance,
        angle: _angle,
        windSpeed: _windSpeed,
        windDirection: _windDirection,
        temperature: _temperature,
        pressure: _pressure,
        humidity: _humidity,
        latitude: _latitude, // Add latitude to saved calculation
        driftHorizontal: ballisticsResult.driftHorizontal,
        dropVertical: ballisticsResult.dropVertical,
        driftMrad: ballisticsResult.driftMrad,
        dropMrad: ballisticsResult.dropMrad,
        driftMoa: ballisticsResult.driftMoa,
        dropMoa: ballisticsResult.dropMoa,
      );
      
      await CalculationStorage.saveCalculation(calculation);
      
      if (!mounted) return;
      
      final snackBar = SnackBar(
        content: Text('Shot saved! Distance: ${_distance.toStringAsFixed(1)}m, Wind: ${_windSpeed.toStringAsFixed(1)}m/s'), // Changed from km/h to m/s
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(left: 16.0, right: 16.0),
        duration: const Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      
      if (widget.onNavigate != null) {
        widget.onNavigate!(0);
      }
    } catch (e) {
      if (!mounted) return;
      
      final snackBar = SnackBar(
        content: Text('Error saving calculation: $e'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(left: 16.0, right: 16.0),
        duration: const Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _showProfileErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profiles Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please select all required profiles before saving:'),
              const SizedBox(height: 8),
              if (_selectedGun == null) const Text('• Gun profile missing'),
              if (_selectedCartridge == null) const Text('• Cartridge profile missing'),
              if (_selectedScope == null) const Text('• Scope profile missing'),
              const SizedBox(height: 16),
              const Text('Go to the Profiles tab to create and select profiles.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (widget.onNavigate != null) {
                  widget.onNavigate!(2); // Navigate to profiles tab
                }
              },
              child: const Text('Go to Profiles'),
            ),
          ],
        );
      },
    );
  }

  void _showDistanceErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Distance'),
          content: const Text('Please enter a distance greater than 0 meters before saving.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Calculate ballistics - called when user presses calculate button
  void _calculateBallistics() {
    if (_distance > 0 && _selectedGun != null && _selectedCartridge != null && _selectedScope != null) {
      try {
        final result = BallisticsCalculator.calculateWithProfiles(
          _distance,
          _windSpeed,
          _windDirection,
          _selectedGun!,
          _selectedCartridge!,
          _selectedScope!,
          temperature: _temperature,  // Always use current screen value
          pressure: _pressure,        // Always use current screen value
          humidity: _humidity,        // Always use current screen value
          elevationAngle: _angle,     // Use elevation angle from user input
          azimuthAngle: _windDirection, // Use azimuth from compass/wind direction
          latitude: _latitude, // Pass the latitude to the calculator
        );
        setState(() {
          _ballisticsResult = result;
        });
      } catch (e) {
        print('Error calculating ballistics: $e');
        setState(() {
          _ballisticsResult = null;
        });
      }
    } else {
      setState(() {
        _ballisticsResult = null;
      });
    }
  }
    void _updateLatitude(double newLatitude) {
    setState(() {
      _latitude = newLatitude;
    });
  }

  @override
  void dispose() {
    // Remove profile reload listener
    widget.reloadProfilesNotifier?.removeListener(_onReloadProfilesNotification);
    
    _distanceController.dispose();
    _angleController.dispose();
    _windSpeedController.dispose();
    _windDirectionController.dispose(); 
    _temperatureController.dispose();
    _pressureController.dispose();
    _humidityController.dispose();
    super.dispose();
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
                "Field Data",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DistanceInput(
                    controller: _distanceController,
                    scrollStep: _scrollStep,
                    onUpdateDistance: _updateDistance,
                  ),
                  const SizedBox(height: 20),
                  AngleInput(
                    controller: _angleController,
                    scrollStep: 1.0,
                    onUpdateAngle: _updateAngle,
                    onCameraPressed: _openCameraForAngle,
                  ),
                  const SizedBox(height: 20),
                  WindSpeedInput(
                    controller: _windSpeedController,
                    scrollStep: 0.1, // Changed from 0.5 to 0.1 for m/s
                    onUpdateWindSpeed: _updateWindSpeed,
                  ),
                  const SizedBox(height: 20),
                    _hasCompass 
                    ? CompassWidget(                        onWindDirectionChanged: (direction) {
                          setState(() {
                            _windDirection = direction;
                            _windDirectionController.text = _windDirection.round().toString();
                          });
                        },
                      )
                    : WindDirectionInput(
                        controller: _windDirectionController,
                        scrollStep: 5.0,
                        onUpdateWindDirection: _updateWindDirection,
                      ),
                      
                  const SizedBox(height: 20),
                  
                  EnvironmentalInput(
                    temperatureController: _temperatureController,
                    pressureController: _pressureController,
                    humidityController: _humidityController,
                    scrollStep: 0.5,
                    onUpdateTemperature: _updateTemperature,
                    onUpdatePressure: _updatePressure,
                    onUpdateHumidity: _updateHumidity,
                    onUpdateLatitude: _updateLatitude, // Pass the latitude callback
                  ),
                    const SizedBox(height: 20),                  // Display the current latitude value (optional)
                  if (_latitude != 0.0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Coriolis: Using latitude ${_latitude.toStringAsFixed(4)}°',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 0.0, right: 7.0),
        child: FloatingActionButton(
          onPressed: _saveCalculation,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
          child: Icon(Icons.my_location, color: Theme.of(context).scaffoldBackgroundColor),
        ),
      ),
    );  }
}
