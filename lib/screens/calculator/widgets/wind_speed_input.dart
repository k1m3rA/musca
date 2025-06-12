import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class WindSpeedInput extends StatelessWidget {
  final TextEditingController controller;
  final double scrollStep;
  final Function(double) onUpdateWindSpeed;

  const WindSpeedInput({
    super.key,
    required this.controller,
    this.scrollStep = 0.1, // Changed from 0.25 to 0.1 for m/s precision
    required this.onUpdateWindSpeed,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.primary;
    
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          final delta = pointerSignal.scrollDelta.dy > 0 ? -scrollStep : scrollStep;
          onUpdateWindSpeed(delta);
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
                  labelText: 'Wind Speed',
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
                  suffixText: 'm/s', // Changed from 'km/h' to 'm/s'
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onVerticalDragUpdate: (details) {
                // Reduced sensitivity for m/s values
                double delta = -details.delta.dy * 0.05; // Reduced from 0.2
                onUpdateWindSpeed(delta);
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
                    // Upper touch area
                    InkWell(
                      onTap: () => onUpdateWindSpeed(scrollStep * 1),
                      child: Container(
                        height: 30,
                        width: 40,
                        alignment: Alignment.center,
                        child: Icon(Icons.keyboard_arrow_up, color: iconColor),
                      ),
                    ),
                    // Center indicator
                    Container(
                      width: 30,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    // Lower touch area
                    InkWell(
                      onTap: () => onUpdateWindSpeed(-scrollStep * 1),
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
