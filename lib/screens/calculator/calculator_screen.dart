import 'package:flutter/material.dart';
import 'widgets/distance_input.dart';
import 'widgets/angle_input.dart';
import 'widgets/wind_speed_input.dart';
import 'widgets/compass_widget.dart';
import 'widgets/wind_direction_input.dart'; // Re-added import for WindDirectionInput
import 'widgets/camera_angle_screen.dart'; // Add this import
import 'package:flutter_compass/flutter_compass.dart';
import '../../models/calculation.dart';
import '../../services/calculation_storage.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _distanceController = TextEditingController(text: '0.0');
  double _distance = 0.0;
  final double _scrollStep = 0.5;
  final TextEditingController _angleController = TextEditingController(text: '0.0');
  double _angle = 0.0;
  final TextEditingController _windSpeedController = TextEditingController(text: '0.0');
  double _windSpeed = 0.0;
  
  // Re-added wind direction controller and variable
  final TextEditingController _windDirectionController = TextEditingController(text: '0.0');
  double _windDirection = 0.0;
  
  // New variable to track compass availability
  bool _hasCompass = false;

  @override
  void initState() {
    super.initState();
    _distanceController.addListener(_updateDistanceFromText);
    _angleController.addListener(_updateAngleFromText);
    _windSpeedController.addListener(_updateWindSpeedFromText);
    _windDirectionController.addListener(_updateWindDirectionFromText); // Re-added listener
    
    // Check if compass is available
    _checkCompassAvailability();
  }
  
  // Method to check compass availability
  Future<void> _checkCompassAvailability() async {
    setState(() {
      _hasCompass = FlutterCompass.events != null;
    });
  }

  // Re-added method to update wind direction from text input
  void _updateWindDirectionFromText() {
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

  void _updateDistance(double delta) {
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
    if (newAngle >= 0) {
      setState(() {
        _angle = newAngle;
        _angleController.text = _angle.toStringAsFixed(1);
      });
    }
  }

  void _updateWindSpeed(double delta) {
    final newWindSpeed = _windSpeed + delta;
    if (newWindSpeed >= 0) {
      setState(() {
        _windSpeed = newWindSpeed;
        _windSpeedController.text = _windSpeed.toStringAsFixed(1);
      });
    }
  }

  // Re-added method to update wind direction
  void _updateWindDirection(double delta) {
    setState(() {
      _windDirection = (_windDirection + delta) % 360;
      if (_windDirection < 0) _windDirection += 360;
      _windDirectionController.text = _windDirection.round().toString();
    });
  }

  // Add method to open camera for angle measurement
  Future<void> _openCameraForAngle() async {
    final measuredAngle = await Navigator.push<double>(
      context,
      MaterialPageRoute(builder: (context) => const CameraAngleScreen()),
    );
    
    if (measuredAngle != null) {
      setState(() {
        _angle = measuredAngle;
        _angleController.text = _angle.toStringAsFixed(1);
      });
    }
  }

  // Add a method to handle the save action
  Future<void> _saveCalculation() async {
    // Create a new calculation from current values
    final calculation = Calculation(
      distance: _distance,
      angle: _angle,
      windSpeed: _windSpeed,
      windDirection: _windDirection,
    );
    
    // Save the calculation
    await CalculationStorage.saveCalculation(calculation);
    
    // Show feedback to user
    if (!mounted) return;
    
    final snackBar = SnackBar(
      content: const Text('Calculation saved!'),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(left: 16.0, right: 100.0),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _angleController.dispose();
    _windSpeedController.dispose();
    _windDirectionController.dispose(); // Re-added dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
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
                onCameraPressed: _openCameraForAngle, // Add this line
              ),
              const SizedBox(height: 20),
              WindSpeedInput(
                controller: _windSpeedController,
                scrollStep: 0.5,
                onUpdateWindSpeed: _updateWindSpeed,
              ),
              const SizedBox(height: 20),
              
              // Conditionally display CompassWidget or WindDirectionInput
              _hasCompass 
                ? const CompassWidget()
                : WindDirectionInput(
                    controller: _windDirectionController,
                    scrollStep: 5.0,
                    onUpdateWindDirection: _updateWindDirection,
                  ),
                  
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Add floating action button for saving
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 0.0, right: 10.0), // Move the button slightly upwards and to the left
        child: FloatingActionButton(
          onPressed: _saveCalculation,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8), // Reduce brightness by lowering opacity
          child: const Icon(Icons.save, color: Colors.white),
        ),
      ),
    );
  }
}
