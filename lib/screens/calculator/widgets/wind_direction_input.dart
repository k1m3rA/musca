import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

class WindDirectionInput extends StatefulWidget {
  final TextEditingController controller;
  final double scrollStep;
  final Function(double) onUpdateWindDirection;

  const WindDirectionInput({
    Key? key,
    required this.controller,
    this.scrollStep = 5.0,
    required this.onUpdateWindDirection,
  }) : super(key: key);

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
            WindDirectionDial(
              currentValue: currentAngle,
              onChanged: _updateAngleFromDial, // Usamos el nuevo método para mayor claridad
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
    Key? key,
    required this.currentValue,
    required this.onChanged,
  }) : super(key: key);

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

    // Verificamos si el toque está dentro del dial
    final distance = (touchPosition - center).distance;
    if (distance > size.width / 2) return; // Ignorar toques fuera del círculo

    // Calculate angle - Corregimos el cálculo para que el gesto sea natural
    final angle = math.atan2(
      touchPosition.dy - center.dy,  // Cambiamos la inversión
      touchPosition.dx - center.dx,
    );
    
    // Convert radians to degrees and adjust to compass bearing (0° at North, clockwise)
    double degrees = (angle * 180 / math.pi + 90) % 360;  // Ajustamos para que 0 sea Norte
    if (degrees < 0) degrees += 360;  // Aseguramos valores positivos

    // Solo actualizamos si el valor ha cambiado significativamente
    if ((_direction - degrees).abs() > 0.5) {
      setState(() {
        _direction = degrees;
      });
      // Comunicar el cambio
      widget.onChanged(degrees);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _isDragging = true;
        });
        _updateDirection(details.localPosition);
      },
      onPanUpdate: (details) {
        _updateDirection(details.localPosition);
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
          // Eliminamos las sombras condicionales
        ),
        child: Stack(
          children: [
            // Indicador visual de interacción (opcional)
            if (_isDragging)
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                ),
              ),
              
            // Compass markings
            ...List.generate(12, (index) {
              final angle = index * 30 * math.pi / 180;
              return Transform.rotate(
                angle: angle,
                origin: const Offset(0, 0),
                child: Center(
                  child: Container(
                    height: 200,
                    width: 2,
                    color: index % 3 == 0 ? Colors.black : Colors.grey.shade300,
                    margin: const EdgeInsets.only(bottom: 100),
                  ),
                ),
              );
            }),
            
            // Direction labels
            Positioned(
              top: 5,
              left: 0,
              right: 0,
                child: Center(
                child: Text(
                  'N',
                  style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                    color: Colors.black,
                  backgroundColor: Colors.white,
                  ),
                ),
                ),
              ),
              Positioned(
                bottom: 5,
                left: 0,
                right: 0,
                child: Center(
                child: Text(
                  'S',
                  style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                  backgroundColor: Colors.white,
                  ),
                ),
                ),
              ),
              Positioned(
                right: 5,
                top: 0,
                bottom: 0,
                child: Center(
                child: Text(
                  'E',
                  style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                  backgroundColor: Colors.white,
                  ),
                ),
                ),
              ),
              Positioned(
                left: 5,
                top: 0,
                bottom: 0,
                child: Center(
                child: Text(
                  'W',
                  style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                  backgroundColor: Colors.white,
                  ),
                ),
                ),
              ),
            
            // Pointer con flecha para indicar de dónde viene el viento - ahora centrado
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
