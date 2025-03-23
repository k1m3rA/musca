import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:async';

class CompassWidget extends StatefulWidget {
  final Function(double)? onWindDirectionChanged; // Add callback function
  
  const CompassWidget({
    super.key,
    this.onWindDirectionChanged, // Add parameter
  });

  @override
  State<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget> {
  double _direction = 0;
  double _lastStoredDirection = 0;
  double _windDirection = 0; // Wind direction angle
  bool _isListening = true;
  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  void _startListening() {
    if (FlutterCompass.events == null) {
      // El dispositivo no tiene sensor de brújula
      return;
    }

    _compassSubscription = FlutterCompass.events!.listen((event) {
      if (!_isListening) return;
      
      setState(() {
        // Asegurar que la dirección siempre sea un valor positivo entre 0 y 360
        double heading = event.heading ?? 0;
        
        // Normalizamos al rango 0-360
        heading = heading % 360;
        if (heading < 0) heading += 360;
        
        _direction = heading;
      });
    });
  }

  void _stopListening() {
    _compassSubscription?.cancel();
    _compassSubscription = null;
  }
  
  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (!_isListening) {
        // Almacenar la última dirección cuando se detiene
        _lastStoredDirection = _direction;
      }
    });
  }

  // Calculate angle from drag position - fixed for natural rotation
  double _calculateAngle(Offset position, Offset center) {
    // Calculate angle in radians
    final double angleRadians = math.atan2(
      position.dx - center.dx,
      -(position.dy - center.dy),
    );
    
    // Convert to degrees and normalize to 0-360
    // We use 360 - degrees to make the rotation direction feel natural
    double angleDegrees = 360 - ((angleRadians * (180 / math.pi)) % 360);
    if (angleDegrees < 0) angleDegrees += 360;
    
    return angleDegrees;
  }

  // Add method to update wind direction and notify parent
  void _updateWindDirectionValue(double newDirection) {
    setState(() {
      _windDirection = newDirection;
    });
    
    // Call the callback function with the relative wind direction
    if (widget.onWindDirectionChanged != null) {
      widget.onWindDirectionChanged!(_getRelativeWindDirection());
    }
  }

  // Calculate wind direction relative to current north
  double _getRelativeWindDirection() {
    // Use current compass direction or last stored direction if paused
    double currentNorth = _isListening ? _direction : _lastStoredDirection;
    
    // Calculate relative angle and normalize to 0-360
    double relativeAngle = (currentNorth - _windDirection) % 360;
    if (relativeAngle < 0) relativeAngle += 360;
    
    return relativeAngle;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Wind Direction',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // Se cambia la construcción del widget de la brújula:
        SizedBox(
          height: 200,
          width: 200, // ancho reducido
          child: FlutterCompass.events == null
              ? const Center(child: Text('No compass available'))
              : OverflowBox(
                  alignment: Alignment.center,
                  minWidth: 200,
                  maxWidth: 200,
                  child: _buildCompassWidget(),
                ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(_isListening 
                ? 'Compass: ${_direction.toStringAsFixed(1)}°'
                : 'Compass: ${_lastStoredDirection.toStringAsFixed(1)}°'),
          
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            
            Text('Wind: ${_getRelativeWindDirection().toStringAsFixed(1)}°'),
          ],
        ),
      ],
    );
  }

  Widget _buildCompassWidget() {
    return NotificationListener<ScrollNotification>(
      // Prevent scroll notifications from propagating to parent widgets
      onNotification: (scrollNotification) => false,
      child: GestureDetector(
        // Explicitly handle all gestures to prevent scroll interference
        behavior: HitTestBehavior.translucent,
        
        // Handle tap on the compass area
        onTapDown: (details) {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final Offset center = Offset(renderBox.size.width / 2, renderBox.size.height / 2);
          final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
          
          // Calculate distance from center to determine if we're inside the compass
          final double distance = (localPosition - center).distance;
          if (distance <= 100) { // Changed from 150 to 100 for a smaller detection area
            _updateWindDirectionValue(_calculateAngle(localPosition, center));
          }
        },
        
        // Add pan gesture handling for better dragging experience
        onPanStart: (details) {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final Offset center = Offset(renderBox.size.width / 2, renderBox.size.height / 2);
          final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
          
          final double distance = (localPosition - center).distance;
          if (distance <= 100) { // Changed from 150 to 100 for a smaller detection area
            _updateWindDirectionValue(_calculateAngle(localPosition, center));
          }
        },
        
        onPanUpdate: (details) {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final Offset center = Offset(renderBox.size.width / 2, renderBox.size.height / 2);
          final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
          
          // Process any pan updates regardless of direction
          final double distance = (localPosition - center).distance;
          if (distance <= 100) { // Changed from 150 to 100 for a smaller detection area
            _updateWindDirectionValue(_calculateAngle(localPosition, center));
          }
        },
        
        // Make sure vertical drags are captured by this widget and not the parent scroll
        onVerticalDragStart: (_) {},
        onVerticalDragUpdate: (details) {
          // Handle vertical drag as part of pan gesture
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final Offset center = Offset(renderBox.size.width / 2, renderBox.size.height / 2);
          final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
          
          final double distance = (localPosition - center).distance;
          if (distance <= 100) { // Changed from 150 to 100 for a smaller detection area
            _updateWindDirectionValue(_calculateAngle(localPosition, center));
          }
        },
        
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Compass background
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.hardEdge,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.black, width: 1.0),
                ),
                child: CustomPaint(
                  painter: CompassPainter(direction: _isListening ? _direction : _lastStoredDirection),
                ),
              ),
            ),

            // Compass direction arrow (red)
            const Center(
              child: Icon(Icons.navigation, size: 40, color: Colors.red),
            ),
            
            // Wind direction arrow (blue, rotatable by user) - removed redundant GestureDetector
            Transform.rotate(
              angle: -_windDirection * (math.pi / 180),
              child: SizedBox(
                width: 40,
                height: 180,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    CustomPaint(
                      size: const Size(20, 20),
                      painter: ArrowHeadPainter(color: Colors.blue.shade800),
                    ),
                    Expanded(
                      child: Container(
                        width: 4,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Pause/play button - moved from right to left
            Positioned(
              top: 0,
              left: -20, // Changed from right: 0 to left: 0
              child: ElevatedButton(
                onPressed: _toggleListening,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                  minimumSize: const Size(48, 48),
                  elevation: 4,
                ),
                child: Icon(
                  _isListening ? Icons.pause : Icons.play_arrow,
                  color: _isListening ? Colors.red : Colors.green,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompassPainter extends CustomPainter {
  final double direction;

  CompassPainter({required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.black;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Removed the circle drawing here for a cleaner design

    // Dibujar marcas y direcciones
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final directions = ['N', 'E', 'S', 'W'];
    
    // Ajustamos el ángulo para que 'N' esté en 0 grados
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90 - direction) * (math.pi / 180);
      
      // Posición para el texto - changed from 0.65 to 0.55 to move labels inward
      final labelX = center.dx + radius * 0.55 * math.sin(angle);
      final labelY = center.dy - radius * 0.55 * math.cos(angle);
      
      // Dibujar marca
      paint.color = directions[i] == 'N' ? Colors.red : Colors.black;
      paint.strokeWidth = directions[i] == 'N' ? 3.0 : 2.0;
      canvas.drawLine(
        Offset(center.dx + radius * 0.7 * math.sin(angle), center.dy - radius * 0.7 * math.cos(angle)),
        Offset(center.dx + radius * 0.9 * math.sin(angle), center.dy - radius * 0.9 * math.cos(angle)),
        paint,
      );
      
      // Dibujar texto
      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: directions[i] == 'N' ? Colors.red : Colors.black, 
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas, 
        Offset(labelX - textPainter.width / 2, labelY - textPainter.height / 2),
      );
    }

    // Marcas menores cada 30 grados
    paint.color = Colors.black;
    paint.strokeWidth = 1.5;
    for (int i = 0; i < 12; i++) {
      if (i % 3 != 0) {  // Saltamos los puntos cardinales principales
        final angle = (i * 30 - direction) * (math.pi / 180);
        canvas.drawLine(
          Offset(center.dx + radius * 0.8 * math.sin(angle), center.dy - radius * 0.8 * math.cos(angle)),
          Offset(center.dx + radius * 0.9 * math.sin(angle), center.dy - radius * 0.9 * math.cos(angle)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CompassPainter oldDelegate) => oldDelegate.direction != direction;
}

// Add this new painter class at the end of the file
class ArrowHeadPainter extends CustomPainter {
  final Color color;
  
  ArrowHeadPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    final double centerX = size.width / 2;
    
    // Create a triangle path for the arrow head
    final Path path = Path();
    path.moveTo(centerX, 0); // Top center
    path.lineTo(centerX - 10, 20); // Bottom left
    path.lineTo(centerX + 10, 20); // Bottom right
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
