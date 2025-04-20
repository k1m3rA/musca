import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class LengthInput extends StatelessWidget {
  final TextEditingController controller;
  final double scrollStep;
  final Function(double) onUpdateLength;

  const LengthInput({
    super.key,
    required this.controller,
    this.scrollStep = 0.001,
    required this.onUpdateLength,
  });

  @override
  Widget build(BuildContext context) {
    // Define colors based on theme
    final iconColor = Theme.of(context).colorScheme.primary;

    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          final delta = pointerSignal.scrollDelta.dy > 0 ? -scrollStep : scrollStep;
          onUpdateLength(delta);
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
                  labelText: 'Length',
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
                  suffixText: 'cm',
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onVerticalDragUpdate: (details) {
                double delta = -details.delta.dy * 0.01; // Smaller multiplier for more precise control
                onUpdateLength(delta);
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
                    InkWell(
                      onTap: () => onUpdateLength(scrollStep),
                      child: Container(
                        height: 30,
                        width: 40,
                        alignment: Alignment.center,
                        child: Icon(Icons.keyboard_arrow_up, color: iconColor),
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    InkWell(
                      onTap: () => onUpdateLength(-scrollStep),
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
