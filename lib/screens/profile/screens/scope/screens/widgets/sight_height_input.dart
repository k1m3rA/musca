import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class SightHeightInput extends StatelessWidget {
  final TextEditingController controller;
  final double scrollStep;
  final Function(double) onUpdateSightHeight;
  final String units; // keeping this parameter to maintain compatibility

  const SightHeightInput({
    super.key,
    required this.controller,
    this.scrollStep = 0.1,
    required this.onUpdateSightHeight,
    required this.units,
  });

  @override
  Widget build(BuildContext context) {
    // Define colors based on theme
    final iconColor = Theme.of(context).colorScheme.primary;

    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          final delta = pointerSignal.scrollDelta.dy > 0 ? -scrollStep : scrollStep;
          onUpdateSightHeight(delta);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Sight Height',
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
                  helperText: 'Min: 0 cm', // Add helper text to indicate 0 is allowed
                ),
                onChanged: (value) {
                  // Allow empty string and 0 value
                  if (value.isEmpty || value == '0' || value == '0.0') {
                    return;
                  }
                  final parsedValue = double.tryParse(value);
                  if (parsedValue != null && parsedValue >= 0) {
                    // Accept any non-negative value including 0
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onVerticalDragUpdate: (details) {
                double delta = -details.delta.dy * 0.01;
                onUpdateSightHeight(delta);
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
                      onTap: () => onUpdateSightHeight(scrollStep),
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
                      onTap: () => onUpdateSightHeight(-scrollStep),
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
