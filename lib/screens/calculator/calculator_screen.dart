import 'package:flutter/material.dart';
import 'widgets/distance_input.dart';
import 'widgets/angle_input.dart';
import 'widgets/wind_speed_input.dart';
import 'widgets/compass_widget.dart';
import 'widgets/wind_direction_input.dart';
import 'widgets/camera_angle_screen.dart';
import 'widgets/environmental_input.dart';
import 'widgets/ballistics_results_widget.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../models/calculation.dart';
import '../../services/calculation_storage.dart';
import '../../services/ballistics_calculator.dart';

class CalculatorScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  
  const CalculatorScreen({super.key, this.onNavigate});

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
  final TextEditingController _windDirectionController = TextEditingController(text: '0.0');  double _windDirection = 0.0;
  bool _hasCompass = false;
  BallisticsResult? _ballisticsResult;

  // Add new controllers and variables for environmental data
  final TextEditingController _temperatureController = TextEditingController(text: '20.0');
  double _temperature = 20.0;
  final TextEditingController _pressureController = TextEditingController(text: '1013.0');
  double _pressure = 1013.0;
  final TextEditingController _humidityController = TextEditingController(text: '50.0');
  double _humidity = 50.0;

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
    
    // Check if compass is available
    _checkCompassAvailability();
  }

  Future<void> _checkCompassAvailability() async {
    setState(() {
      _hasCompass = FlutterCompass.events != null;
    });
  }
  void _updateWindDirectionFromText() {
    if (_windDirectionController.text.isNotEmpty) {
      try {
        final newValue = double.parse(_windDirectionController.text);
        setState(() => _windDirection = newValue);
        _calculateBallistics();
      } catch (_) {}
    }
  }
  void _updateDistanceFromText() {
    if (_distanceController.text.isNotEmpty) {
      try {
        final newValue = double.parse(_distanceController.text);
        setState(() => _distance = newValue);
        _calculateBallistics();
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
        _calculateBallistics();
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
  }
  void _updateDistance(double delta) {
    final newDistance = _distance + delta;
    if (newDistance >= 0) {
      setState(() {
        _distance = newDistance;
        _distanceController.text = _distance.toStringAsFixed(1);
      });
      _calculateBallistics();
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
      _calculateBallistics();
    }
  }
  void _updateWindDirection(double delta) {
    setState(() {
      _windDirection = (_windDirection + delta) % 360;
      if (_windDirection < 0) _windDirection += 360;
      _windDirectionController.text = _windDirection.round().toString();
    });
    _calculateBallistics();
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
      setState(() {
        _angle = measuredAngle;
        _angleController.text = _angle.toStringAsFixed(1);
      });
    }
  }  Future<void> _saveCalculation() async {
    // Use existing ballistics result or calculate if not available
    final ballisticsResult = _ballisticsResult ?? BallisticsCalculator.calculate(
      _distance,
      _windSpeed,
      _windDirection,
    );
    
    final calculation = Calculation(
      distance: _distance,
      angle: _angle,
      windSpeed: _windSpeed,
      windDirection: _windDirection,
      temperature: _temperature,
      pressure: _pressure,
      humidity: _humidity,
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
      content: const Text('Shot saved with ballistics calculations!'),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(left: 16.0, right: 16.0),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    
    if (widget.onNavigate != null) {
      widget.onNavigate!(0);
    }
  }

  void _calculateBallistics() {
    if (_distance > 0) {
      final result = BallisticsCalculator.calculate(
        _distance,
        _windSpeed,
        _windDirection,
      );
      setState(() {
        _ballisticsResult = result;
      });
    } else {
      setState(() {
        _ballisticsResult = null;
      });
    }
  }

  @override
  void dispose() {
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
                    scrollStep: 0.5,
                    onUpdateWindSpeed: _updateWindSpeed,
                  ),
                  const SizedBox(height: 20),
                    _hasCompass 
                    ? CompassWidget(
                        onWindDirectionChanged: (direction) {
                          setState(() {
                            _windDirection = direction;
                            _windDirectionController.text = _windDirection.round().toString();
                          });
                          _calculateBallistics();
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
                  ),
                    const SizedBox(height: 20),
                  
                  // Ballistics Results Display
                  BallisticsResultsWidget(
                    result: _ballisticsResult,
                    distance: _distance,
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
          child: Icon(Icons.save, color: Theme.of(context).scaffoldBackgroundColor),
        ),
      ),
    );
  }
}
