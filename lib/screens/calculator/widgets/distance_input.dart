import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class DistanceInput extends StatelessWidget {
  final TextEditingController controller;
  final double scrollStep;
  final Function(double) onUpdateDistance;

  const DistanceInput({
    Key? key,
    required this.controller,
    this.scrollStep = 1.0, // Valor predeterminado de 1.0
    required this.onUpdateDistance,
  }) : super(key: key);

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
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: () => onUpdateDistance(1.0), // Cambiado a 1.0
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: () => onUpdateDistance(-1.0), // Cambiado a -1.0
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}