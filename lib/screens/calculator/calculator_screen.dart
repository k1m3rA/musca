import 'package:flutter/material.dart';
import 'widgets/distance_input.dart';
import 'widgets/angle_input.dart';
import 'widgets/wind_speed_input.dart';
import 'widgets/wind_direction_input.dart'; // Importamos el nuevo widget

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

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
  final TextEditingController _windDirectionController = TextEditingController(text: '0.0');
  double _windDirection = 0.0;

  @override
  void initState() {
    super.initState();
    _distanceController.addListener(_updateDistanceFromText);
    _angleController.addListener(_updateAngleFromText);
    _windSpeedController.addListener(_updateWindSpeedFromText);
    _windDirectionController.addListener(_updateWindDirectionFromText);
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

  void _updateWindDirectionFromText() {
    if (_windDirectionController.text.isNotEmpty) {
      try {
        double newValue = double.parse(_windDirectionController.text);
        // Asegurar que el valor esté en el rango 0-360
        newValue = newValue % 360;
        if (newValue < 0) newValue += 360;
        setState(() => _windDirection = newValue);
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

  void _updateWindDirection(double delta) {
    double newDirection = _windDirection + delta;
    // Mantener la dirección del viento dentro del rango 0-360
    newDirection = newDirection % 360;
    if (newDirection < 0) newDirection += 360;
    
    setState(() {
      _windDirection = newDirection;
      _windDirectionController.text = _windDirection.toStringAsFixed(1);
    });
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _angleController.dispose();
    _windSpeedController.dispose();
    _windDirectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora'),
        centerTitle: true,
      ),
      body: Padding(
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
            ),
            const SizedBox(height: 20),
            WindSpeedInput(
              controller: _windSpeedController,
              scrollStep: 0.5,
              onUpdateWindSpeed: _updateWindSpeed,
            ),
            const SizedBox(height: 20),
            WindDirectionInput(
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
    );
  }
}
