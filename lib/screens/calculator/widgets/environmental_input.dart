import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:musca/config/api_keys.dart';

class EnvironmentalInput extends StatefulWidget {
  final TextEditingController temperatureController;
  final TextEditingController pressureController;
  final TextEditingController humidityController;
  final TextEditingController latitudeController;
  final double scrollStep;
  final Function(double) onUpdateTemperature;
  final Function(double) onUpdatePressure;
  final Function(double) onUpdateHumidity;
  final Function(double)? onUpdateLatitude; // Add callback for latitude updates
  const EnvironmentalInput({
    super.key,
    required this.temperatureController,
    required this.pressureController,
    required this.humidityController,
    required this.latitudeController,
    this.scrollStep = 0.5,
    required this.onUpdateTemperature,
    required this.onUpdatePressure,
    required this.onUpdateHumidity,
    this.onUpdateLatitude, // Add this parameter
  });

  @override
  State<EnvironmentalInput> createState() => _EnvironmentalInputState();
}

class _EnvironmentalInputState extends State<EnvironmentalInput> {
  bool _isLoading = false;
  String _errorMessage = '';
  double _latitude = 0.0; // Add state variable for latitude
  
  @override
  void initState() {
    super.initState();
    // Automatically get location data when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getLocationWeatherData();
    });
  }
  
  Future<void> _getLocationWeatherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }
      
      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
        // Update latitude and notify parent
      setState(() {
        _latitude = position.latitude;
      });
      
      // Update latitude controller with the fetched value
      widget.latitudeController.text = _latitude.toStringAsFixed(6);
      
      // Notify parent component about latitude change
      if (widget.onUpdateLatitude != null) {
        widget.onUpdateLatitude!(_latitude);
      }
      
      // Fetch weather data using WeatherAPI.com
      final apiKey = ApiKeys.weatherApi;
      final response = await http.get(
        Uri.parse('http://api.weatherapi.com/v1/current.json?key=$apiKey&q=${position.latitude},${position.longitude}&aqi=no'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Update controller values with fetched data
        widget.temperatureController.text = data['current']['temp_c'].toStringAsFixed(1);
        widget.pressureController.text = data['current']['pressure_mb'].toString();
        widget.humidityController.text = data['current']['humidity'].toString();
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
    @override
  Widget build(BuildContext context) {    
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [// Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Environmental Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(child: CircularProgressIndicator()),
            ),
            
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                _errorMessage,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          
          const SizedBox(height: 10),
          
          // Temperature input
          _buildInputRow(
            controller: widget.temperatureController,
            label: 'Temperature',
            suffix: '°C',
            onIncrease: () => widget.onUpdateTemperature(widget.scrollStep),
            onDecrease: () => widget.onUpdateTemperature(-widget.scrollStep),
            onDrag: (delta) => widget.onUpdateTemperature(-delta * 0.2),
            context: context,
          ),
          
          const SizedBox(height: 10),
          
          // Pressure input
          _buildInputRow(
            controller: widget.pressureController,
            label: 'Pressure',
            suffix: 'mbar',
            onIncrease: () => widget.onUpdatePressure(widget.scrollStep * 2),
            onDecrease: () => widget.onUpdatePressure(-widget.scrollStep * 2),
            onDrag: (delta) => widget.onUpdatePressure(-delta * 0.5),
            context: context,
          ),
          
          const SizedBox(height: 10),
            // Humidity input
          _buildInputRow(
            controller: widget.humidityController,
            label: 'Humidity',
            suffix: '%',
            onIncrease: () => widget.onUpdateHumidity(widget.scrollStep),
            onDecrease: () => widget.onUpdateHumidity(-widget.scrollStep),
            onDrag: (delta) => widget.onUpdateHumidity(-delta * 0.2),
            context: context,
          ),
          
          const SizedBox(height: 10),
          
          // Latitude input
          _buildInputRow(
            controller: widget.latitudeController,
            label: 'Latitude',
            suffix: '°',
            onIncrease: () {
              final currentValue = double.tryParse(widget.latitudeController.text) ?? 0.0;
              final newValue = currentValue + 0.000001;
              widget.latitudeController.text = newValue.toStringAsFixed(6);
              if (widget.onUpdateLatitude != null) {
                widget.onUpdateLatitude!(newValue);
              }
            },
            onDecrease: () {
              final currentValue = double.tryParse(widget.latitudeController.text) ?? 0.0;
              final newValue = currentValue - 0.000001;
              widget.latitudeController.text = newValue.toStringAsFixed(6);
              if (widget.onUpdateLatitude != null) {
                widget.onUpdateLatitude!(newValue);
              }
            },
            onDrag: (delta) {
              final currentValue = double.tryParse(widget.latitudeController.text) ?? 0.0;
              final newValue = currentValue + (-delta * 0.000001);
              widget.latitudeController.text = newValue.toStringAsFixed(6);
              if (widget.onUpdateLatitude != null) {
                widget.onUpdateLatitude!(newValue);
              }
            },
            context: context,
          ),
        ],
      ),
    );
  }
  
  Widget _buildInputRow({
    required TextEditingController controller,
    required String label,
    required String suffix,
    String? hint,
    required VoidCallback onIncrease,
    required VoidCallback onDecrease,
    required Function(double) onDrag,
    required BuildContext context,
  }) {
    final iconColor = Theme.of(context).colorScheme.primary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2.0,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2.0,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  suffixText: suffix,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onVerticalDragUpdate: (details) {
                double delta = details.delta.dy;
                onDrag(delta);
              },
              child: Container(
                width: 40,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Upper touch area
                    InkWell(
                      onTap: onIncrease,
                      child: Container(
                        height: 30,
                        width: 40,
                        alignment: Alignment.center,
                        child: Icon(Icons.keyboard_arrow_up, color: iconColor),
                      ),
                    ),
                    // Center indicator
                    Container(
                      width: 30,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    // Lower touch area
                    InkWell(
                      onTap: onDecrease,
                      child: Container(
                        height: 30,
                        width: 40,
                        alignment: Alignment.center,
                        child: Icon(Icons.keyboard_arrow_down, color: iconColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (hint != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 12.0),
            child: Text(
              hint,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
      ],
    );
  }
}
