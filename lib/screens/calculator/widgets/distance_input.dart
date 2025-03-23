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
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          final delta = pointerSignal.scrollDelta.dy > 0 ? -scrollStep : scrollStep;
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
                // Actualizar según la dirección del arrastre (negativo hacia arriba, positivo hacia abajo)
                double delta = -details.delta.dy * 0.1; // Factor para controlar la sensibilidad
                onUpdateDistance(delta);
              },
              child: Container(
                width: 40,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Área táctil superior
                    InkWell(
                      onTap: () => onUpdateDistance(scrollStep),
                      child: Container(
                        height: 30,
                        width: 40,
                        alignment: Alignment.center,
                        child: Icon(Icons.keyboard_arrow_up, color: Colors.grey.shade600),
                      ),
                    ),
                    // Indicador central
                    Container(
                      width: 30,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    // Área táctil inferior
                    InkWell(
                      onTap: () => onUpdateDistance(-scrollStep),
                      child: Container(
                        height: 30,
                        width: 40,
                        alignment: Alignment.center,
                        child: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
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