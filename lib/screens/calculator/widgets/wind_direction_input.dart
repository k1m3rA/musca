import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

class WindDirectionInput extends StatefulWidget {
  final TextEditingController controller;
  final double scrollStep;
  final Function(double) onUpdateWindDirection;

  const WindDirectionInput({
    super.key,
    required this.controller,
    this.scrollStep = 5.0,
    required this.onUpdateWindDirection,
  });

  @override
  State<WindDirectionInput> createState() => _WindDirectionInputState();
}

class _WindDirectionInputState extends State<WindDirectionInput> {
  late double currentAngle;
  
  @override
  void initState() {
    super.initState();
    currentAngle = double.tryParse(widget.controller.text)?.roundToDouble() ?? 0;
    
    // Add listener to controller
    widget.controller.addListener(_updateFromController);
  }
  
  @override
  void dispose() {
    widget.controller.removeListener(_updateFromController);
    super.dispose();
  }
  
  void _updateFromController() {
    final newAngle = double.tryParse(widget.controller.text)?.roundToDouble() ?? 0;
    if (newAngle != currentAngle) {
      setState(() {
        currentAngle = newAngle;
      });
    }
  }
  
  String _getDirectionDescription(double angle) {
    final directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'N'];
    final index = ((angle + 22.5) % 360) ~/ 45;
    return directions[index];
  }

  // Método para actualizar el ángulo desde el dial
  void _updateAngleFromDial(double value) {
    final roundedValue = value.round();
    setState(() {
      currentAngle = value;
      // Evita ciclos recursivos al actualizar el controller solo si el valor ha cambiado
      if (widget.controller.text != roundedValue.toString()) {
        widget.controller.text = roundedValue.toString();
      }
    });
    widget.onUpdateWindDirection(0); // Notifica el cambio
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          final delta = pointerSignal.scrollDelta.dy > 0 ? -widget.scrollStep : widget.scrollStep;
          widget.onUpdateWindDirection(delta);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Wrapped in AbsorbPointer to prevent scroll from propagating
            // while still allowing direct interactions with the dial
            AbsorbPointer(
              absorbing: false, // Don't actually absorb, just creating a boundary
              child: GestureDetector(
                // This ensures the gesture detector properly captures all touch events
                behavior: HitTestBehavior.opaque,
                // Block scroll events from propagating through the dial
                onVerticalDragStart: (_) {},
                onVerticalDragUpdate: (_) {},
                onVerticalDragEnd: (_) {},
                child: WindDirectionDial(
                  currentValue: currentAngle,
                  onChanged: _updateAngleFromDial,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${currentAngle.round()}° ',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    '(${_getDirectionDescription(currentAngle)})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '0° = North',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
            ),
            // Botones para ajuste fino (opcional)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => widget.onUpdateWindDirection(-1),
                  tooltip: 'Decrease by ${widget.scrollStep.toInt()}°',
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => widget.onUpdateWindDirection(1),
                  tooltip: 'Increase by ${widget.scrollStep.toInt()}°',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WindDirectionDial extends StatefulWidget {
  final double currentValue;
  final ValueChanged<double> onChanged;

  const WindDirectionDial({
    super.key,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  State<WindDirectionDial> createState() => _WindDirectionDialState();
}

class _WindDirectionDialState extends State<WindDirectionDial> with SingleTickerProviderStateMixin {
  late double _direction;
  bool _isDragging = false;
  
  @override
  void initState() {
    super.initState();
    _direction = widget.currentValue;
  }
  
  @override
  void didUpdateWidget(WindDirectionDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentValue != oldWidget.currentValue && !_isDragging) {
      _direction = widget.currentValue;
    }
  }

  void _updateDirection(Offset position) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final center = Offset(size.width / 2, size.height / 2);
    final touchPosition = position;

    // More forgiving distance check - allow touches within 20% outside of the dial radius
    final distance = (touchPosition - center).distance;
    final maxAllowedDistance = size.width * 0.6; // 20% more than the radius
    if (distance > maxAllowedDistance) return; // Only ignore touches far outside the dial

    // Calculate angle - Corregimos el cálculo para que el gesto sea natural
    final angle = math.atan2(
      touchPosition.dy - center.dy,
      touchPosition.dx - center.dx,
    );
    
    // Convert radians to degrees and adjust to compass bearing (0° at North, clockwise)
    double degrees = (angle * 180 / math.pi + 90) % 360;  // Ajustamos para que 0 sea Norte
    if (degrees < 0) degrees += 360;  // Aseguramos valores positivos

    // Removed threshold check to make the dial more responsive
    setState(() {
      _direction = degrees;
    });
    // Comunicar el cambio
    widget.onChanged(degrees);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Making sure the gesture detector captures all events
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) {
        setState(() {
          _isDragging = true;
        });
        _updateDirection(details.localPosition);
      },
      onPanUpdate: (details) {
        // Always process pan updates while dragging
        if (_isDragging) {
          _updateDirection(details.localPosition);
        }
      },
      onPanEnd: (details) {
        setState(() {
          _isDragging = false;
        });
      },
      // También añadimos onTap para permitir toques individuales
      onTapDown: (details) {
        setState(() {
          _isDragging = true;
        });
        _updateDirection(details.localPosition);
      },
      onTapUp: (details) {
        setState(() {
          _isDragging = false;
        });
      },
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
          color: Colors.white,
        ),
        child: Stack(
          children: [
            // Compass Rose Background
            Positioned.fill(
              child: CustomPaint(
                painter: CompassRosePainter(
                  primaryColor: Theme.of(context).primaryColor,
                ),
              ),
            ),

            // Wind Direction Arrow - positioned on top of the compass
            Positioned.fill(
              child: Center(
                child: Transform.rotate(
                  angle: (_direction * math.pi / 180),
                  child: CustomPaint(
                    size: const Size(14, 100),
                    painter: WindArrowPainter(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            
            // Center dot
            Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// New class for drawing the compass rose
class CompassRosePainter extends CustomPainter {
  final Color primaryColor;
  
  CompassRosePainter({required this.primaryColor});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Paint for the main directions (N, E, S, W)
    final mainDirectionPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    
    // Paint for the secondary directions (NE, SE, SW, NW)
    final secondaryDirectionPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    // Paint for the tertiary directions
    final tertiaryDirectionPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
      
    // Draw outer circle
    canvas.drawCircle(center, radius - 2, mainDirectionPaint);
    
    // Draw inner circle
    canvas.drawCircle(center, radius * 0.7, secondaryDirectionPaint);
    
    // Draw cardinal directions (N, E, S, W)
    for (int i = 0; i < 4; i++) {
      final angle = i * 90 * math.pi / 180;
      
      // Draw main direction lines
      final outer = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle)
      );
      final inner = Offset(
        center.dx + radius * 0.6 * math.cos(angle),
        center.dy + radius * 0.6 * math.sin(angle)
      );
      
      canvas.drawLine(inner, outer, mainDirectionPaint);
      
      // Draw small tick for degree value
      final tickStart = Offset(
        center.dx + radius * 0.9 * math.cos(angle),
        center.dy + radius * 0.9 * math.sin(angle)
      );
      canvas.drawLine(tickStart, outer, mainDirectionPaint);
    }
    
    // Draw intercardinal directions (NE, SE, SW, NW)
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90 + 45) * math.pi / 180;
      
      final outer = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle)
      );
      final inner = Offset(
        center.dx + radius * 0.65 * math.cos(angle),
        center.dy + radius * 0.65 * math.sin(angle)
      );
      
      canvas.drawLine(inner, outer, secondaryDirectionPaint);
    }
    
    // Draw secondary ticks (every 30 degrees)
    for (int i = 0; i < 12; i++) {
      if (i % 3 != 0) { // Skip the main cardinal points already drawn
        final angle = i * 30 * math.pi / 180;
        
        final outer = Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle)
        );
        final inner = Offset(
          center.dx + radius * 0.85 * math.cos(angle),
          center.dy + radius * 0.85 * math.sin(angle)
        );
        
        canvas.drawLine(inner, outer, tertiaryDirectionPaint);
      }
    }
    
    // Draw minor ticks (every 10 degrees)
    for (int i = 0; i < 36; i++) {
      if (i % 3 != 0) { // Skip the points already drawn
        final angle = i * 10 * math.pi / 180;
        
        final outer = Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle)
        );
        final inner = Offset(
          center.dx + radius * 0.92 * math.cos(angle),
          center.dy + radius * 0.92 * math.sin(angle)
        );
        
        canvas.drawLine(inner, outer, tertiaryDirectionPaint);
      }
    }
    
    // Add cardinal direction labels
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
    
    _drawCompassText(canvas, center, radius, 'N', 0, textStyle);
    _drawCompassText(canvas, center, radius, 'E', 90, textStyle);
    _drawCompassText(canvas, center, radius, 'S', 180, textStyle);
    _drawCompassText(canvas, center, radius, 'W', 270, textStyle);
    
    // Add intercardinal direction labels with smaller size
    final smallerTextStyle = TextStyle(
      color: Colors.black87,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );
    
    _drawCompassText(canvas, center, radius, 'NE', 45, smallerTextStyle);
    _drawCompassText(canvas, center, radius, 'SE', 135, smallerTextStyle);
    _drawCompassText(canvas, center, radius, 'SW', 225, smallerTextStyle);
    _drawCompassText(canvas, center, radius, 'NW', 315, smallerTextStyle);
  }
  
  void _drawCompassText(Canvas canvas, Offset center, double radius, 
      String text, double angleDegrees, TextStyle style) {
    final angleRadians = angleDegrees * math.pi / 180;
    
    // Position text slightly inside the outer edge
    final textRadius = radius * 0.78;
    final textPosition = Offset(
      center.dx + textRadius * math.sin(angleRadians),
      center.dy - textRadius * math.cos(angleRadians)
    );
    
    final textSpan = TextSpan(
      text: text,
      style: style,
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout();
    
    // Center the text on the point
    final textOffset = Offset(
      textPosition.dx - textPainter.width / 2,
      textPosition.dy - textPainter.height / 2,
    );
    
    // Draw the background
    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Add padding around the text
    final padding = 4.0;
    final rect = Rect.fromLTWH(
      textOffset.dx - padding,
      textOffset.dy - padding,
      textPainter.width + (padding * 2),
      textPainter.height + (padding * 2),
    );
    
    // Draw a rounded rectangle as background
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(4.0)),
      backgroundPaint,
    );
    
    textPainter.paint(canvas, textOffset);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Pintor personalizado para dibujar la flecha del viento - mejorado para centrado
class WindArrowPainter extends CustomPainter {
  final Color color;
  
  WindArrowPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.fill;
    
    final double arrowWidth = 14.0;
    final double arrowHeight = 10.0;
    final double shaftWidth = 4.0;
    
    // Trasladar el lienzo para que (0,0) quede en el centro horizontal
    canvas.translate(size.width / 2, 0);
    
    // Crear el camino para la flecha
    final path = Path();
    
    // Dibujar la punta de flecha (en la parte inferior, apuntando al centro)
    path.moveTo(0, size.height);  // Parte inferior centro
    path.lineTo(-arrowWidth / 2, size.height - arrowHeight);  // Esquina inferior izquierda
    path.lineTo(arrowWidth / 2, size.height - arrowHeight);  // Esquina inferior derecha
    path.close();  // Cerrar el triángulo de la punta
    
    // Dibujar el eje de la flecha
    path.moveTo(-shaftWidth / 2, size.height - arrowHeight);
    path.lineTo(-shaftWidth / 2, 0);  // Lado izquierdo del eje
    path.lineTo(shaftWidth / 2, 0);   // Parte superior
    path.lineTo(shaftWidth / 2, size.height - arrowHeight);  // Lado derecho del eje
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
