import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';  // Add this import

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
  double _windDirection = 0; // Wind direction angle
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
    // Calculate relative angle and normalize to 0-360
    double relativeAngle = (_direction - _windDirection) % 360;
    if (relativeAngle < 0) relativeAngle += 360;
    
    return relativeAngle;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Wind Direction',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
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
                  maxWidth: 300,
                  child: _buildCompassWidget(),
                ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Compass: ${_direction.toStringAsFixed(1)}°'),
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
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border.all(color: Theme.of(context).colorScheme.primary, width: 4),
                ),
                child: CustomPaint(
                  painter: CompassPainter(
                    direction: _direction,
                    isDarkMode: Theme.of(context).brightness == Brightness.dark,
                  ),
                ),
              ),
            ),

            // Replace the compass direction arrow with SVG bullet and rotate it 30 degrees counterclockwise
            Center(
              child: Transform.rotate(
                angle: - math.pi / 4, // 30 degrees counterclockwise
                child: SvgPicture.asset(
                  'assets/icon/bullet.svg',
                  height: 50,
                  width: 50,
                  colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
                ),
              ),
            ),
            
            // Wind direction arrow (blue, rotatable by user)
            Transform.rotate(
              angle: -_windDirection * (math.pi / 180),
              child: SizedBox(
                width: 35, // Reduced from 40
                height: 145, // Reduced from 180
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    CustomPaint(
                      size: const Size(15, 15), // Reduced from 20x20
                      painter: ArrowHeadPainter(color: const Color.fromARGB(192, 21, 101, 192)),
                    ),
                    Expanded(
                      child: Container(
                        width: 6, // Reduced from 6
                        color: const Color.fromARGB(192, 21, 101, 192),
                      ),
                    ),
                  ],
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
  final bool isDarkMode;

  CompassPainter({required this.direction, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isDarkMode ? const Color.fromARGB(255, 255, 255, 255) : Colors.black;

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
      paint.color = directions[i] == 'N' ? Colors.red : 
                    (isDarkMode ? const Color.fromARGB(255, 255, 255, 255) : Colors.black);
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
          color: directions[i] == 'N' ? Colors.red : 
                (isDarkMode ? const Color.fromARGB(255, 255, 255, 255) : Colors.black), 
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
    paint.color = isDarkMode ? const Color.fromARGB(255, 255, 255, 255) : Colors.black;
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
  bool shouldRepaint(CompassPainter oldDelegate) => 
      oldDelegate.direction != direction || oldDelegate.isDarkMode != isDarkMode;
}

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
    path.lineTo(centerX - 8, 15); // Bottom left (reduced from 10,20)
    path.lineTo(centerX + 8, 15); // Bottom right (reduced from 10,20)
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
