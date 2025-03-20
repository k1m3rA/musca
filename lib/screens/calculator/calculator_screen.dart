import 'package:flutter/material.dart';
import 'widgets/distance_input.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _distanceController = TextEditingController(text: '0.0');
  double _distance = 0.0;
  final double _scrollStep = 0.5;

  @override
  void initState() {
    super.initState();
    _distanceController.addListener(_updateDistanceFromText);
  }

  void _updateDistanceFromText() {
    if (_distanceController.text.isNotEmpty) {
      try {
        final newValue = double.parse(_distanceController.text);
        setState(() => _distance = newValue);
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

  @override
  void dispose() {
    _distanceController.dispose();
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
