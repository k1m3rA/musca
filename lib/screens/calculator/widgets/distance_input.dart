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
    
    // Definir colores según el tema
    final iconColor = Theme.of(context).colorScheme.primary;

    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          // Aumentar el factor de sensibilidad multiplicando por 5
          final delta = pointerSignal.scrollDelta.dy > 0 ? -scrollStep * 5 : scrollStep * 5;
          onUpdateDistance(delta);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Distance',
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
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                        
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