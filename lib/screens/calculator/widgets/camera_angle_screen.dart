import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math;

class CameraAngleScreen extends StatefulWidget {
  const CameraAngleScreen({super.key});

  @override
  State<CameraAngleScreen> createState() => _CameraAngleScreenState();
}

class _CameraAngleScreenState extends State<CameraAngleScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  double _verticalAngle = 0.0;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    // Start listening to accelerometer events
    accelerometerEvents.listen((AccelerometerEvent event) {
      // Calculate angle from accelerometer data
      if (mounted) {
        setState(() {
          // Calculate inclination based only on the z-axis
          double z = event.z;

          // Map z-axis value to a vertical angle range (-90 to 90 degrees)
          _verticalAngle =  - math.atan2(z, 9.8) * (180 / math.pi);
        });
      }
    });
  }

  Future<void> _initializeCamera() async {
    try {
      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        return;
      }

      // Initialize camera controller with the first camera
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      // Initialize controller
      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _captureAngle() {
    // Return the measured angle to previous screen
    Navigator.pop(context, _verticalAngle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Measure Angle'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: _isCameraInitialized
          ? Stack(
              children: [
                // Camera preview
                SizedBox.expand(
                  child: CameraPreview(_controller!),
                ),
                
                // Crosshair overlay
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        // Horizontal line
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 60,
                            height: 2,
                            color: Colors.red,
                          ),
                        ),
                        // Vertical line
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 2,
                            height: 60,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Angle indicator
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        'Inclination: ${_verticalAngle.toStringAsFixed(1)}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isCameraInitialized
            ? FloatingActionButton.extended(
              onPressed: _captureAngle,
              icon: const Icon(Icons.camera),
              label: const Text('Capture Angle'),
                backgroundColor: const Color.fromARGB(255, 115, 59, 126),
            )
          : null,
    );
  }
}
