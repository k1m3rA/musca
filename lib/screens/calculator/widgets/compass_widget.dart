import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:async';

class CompassWidget extends StatefulWidget {
  const CompassWidget({super.key});

  @override
  State<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget> {
  double _direction = 0;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Wind Direction',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: FlutterCompass.events == null
              ? const Center(child: Text('No compass available'))
              : _buildCompassWidget(),
        ),
        const SizedBox(height: 10),
        Text('Direction: ${_direction.toStringAsFixed(1)}°'),
      ],
    );
  }

  Widget _buildCompassWidget() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
            border: Border.all(color: Colors.black, width: 1.0),
          ),
          child: CustomPaint(
            painter: CompassPainter(direction: _direction),
          ),
        ),
        const Center(
          child: Icon(Icons.navigation, size: 40, color: Colors.red),
        ),
      ],
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

    // Dibujar círculo exterior
    canvas.drawCircle(center, radius * 0.95, paint);

    // Dibujar marcas y direcciones
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final directions = ['N', 'E', 'S', 'W'];
    
    // Ajustamos el ángulo para que 'N' esté en 0 grados
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90 - direction) * (math.pi / 180);
      
      // Posición para el texto
      final labelX = center.dx + radius * 0.65 * math.sin(angle);
      final labelY = center.dy - radius * 0.65 * math.cos(angle);
      
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
