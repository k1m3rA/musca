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
  double _lastStoredDirection = 0;
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
        Text(_isListening 
            ? 'Current Direction: ${_direction.toStringAsFixed(1)}°'
            : 'Stored Direction: ${_lastStoredDirection.toStringAsFixed(1)}°'),
      ],
    );
  }

  Widget _buildCompassWidget() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Reemplazamos el GestureDetector con Material+InkWell para tener efecto de pulsación
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge, // Asegura que el efecto de splash se recorte en el círculo
          child: InkWell(
            onTap: () {
              _toggleListening();
              // No necesitamos código adicional aquí ya que InkWell maneja automáticamente
              // el efecto visual de pulsación (splash) y su desaparición
            },
            splashColor: _isListening ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3),
            highlightColor: Colors.white.withOpacity(0.1),
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
        ),
        const Center(
          child: Icon(Icons.navigation, size: 40, color: Colors.red),
        ),
        // Botón para detener/iniciar la brújula (se mantiene como alternativa)
        Positioned(
          top: 0,
          right: 0,
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
