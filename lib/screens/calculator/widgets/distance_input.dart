import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class DistanceInput extends StatelessWidget {
  final TextEditingController controller;
  final double scrollStep;
  final Function(double) onUpdateDistance;

  const DistanceInput({
    super.key,
    required this.controller,
    this.scrollStep = 1.0,
    required this.onUpdateDistance,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener el tema actual y verificar si es oscuro
    final ThemeData theme = Theme.of(context);
    final bool isDarkTheme = theme.brightness == Brightness.dark;
    
    // Definir colores según el tema
    final backgroundColor = isDarkTheme ? Colors.grey.shade800 : Colors.grey.shade200;
    final iconColor = isDarkTheme ? Colors.grey.shade300 : Colors.grey.shade600;
    final indicatorColor = isDarkTheme ? Colors.grey.shade700 : Colors.white;
    final shadowColor = isDarkTheme ? Colors.black.withOpacity(0.5) : Colors.grey.withOpacity(0.3);

    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          // Aumentar el factor de sensibilidad multiplicando por 5
          final delta = pointerSignal.scrollDelta.dy > 0 ? -scrollStep * 5 : scrollStep * 5;
          onUpdateDistance(delta);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Distance (meters)',
                  border: OutlineInputBorder(),
                  suffixText: 'm',
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Rueda scrolleable mejorada con interacción táctil
            GestureDetector(
              onVerticalDragUpdate: (details) {
                // Aumentar el factor de sensibilidad de 0.1 a 0.5
                double delta = -details.delta.dy * 0.5; // Factor para controlar la sensibilidad
                onUpdateDistance(delta);
              },
              child: Container(
                width: 40,
                height: 80,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Área táctil superior
                    InkWell(
                      onTap: () => onUpdateDistance(scrollStep * 5),
                      child: Container(
                        height: 30,
                        width: 40,
                        alignment: Alignment.center,
                        child: Icon(Icons.keyboard_arrow_up, color: iconColor),
                      ),
                    ),
                    // Indicador central
                    Container(
                      width: 30,
                      height: 20,
                      decoration: BoxDecoration(
                        color: indicatorColor,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    // Área táctil inferior
                    InkWell(
                      onTap: () => onUpdateDistance(-scrollStep * 5),
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
      ),
    );
  }
}