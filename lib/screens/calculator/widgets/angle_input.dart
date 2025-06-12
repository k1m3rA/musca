import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class AngleInput extends StatelessWidget {
  final TextEditingController controller;
  final double scrollStep;
  final Function(double) onUpdateAngle;
  final VoidCallback? onCameraPressed;

  const AngleInput({
    super.key,
    required this.controller,
    this.scrollStep = 1.0,
    required this.onUpdateAngle,
    this.onCameraPressed,
  });

  // Helper method to clamp angle between -90 and 90 degrees
  double _clampAngle(double angle) {
    return angle.clamp(-90.0, 90.0);
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.primary;

    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          final currentAngle = double.tryParse(controller.text) ?? 0.0;
          final delta = pointerSignal.scrollDelta.dy > 0 ? -scrollStep : scrollStep;
          final newAngle = _clampAngle(currentAngle + delta);
          onUpdateAngle(newAngle - currentAngle);
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
                onChanged: (value) {
                  final angle = double.tryParse(value);
                  if (angle != null) {
                    final clampedAngle = _clampAngle(angle);
                    if (angle != clampedAngle) {
                      controller.text = clampedAngle.toString();
                      controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length),
                      );
                    }
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Vertical angle',
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                  helperText: 'Range: -90° to 90°',
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
                  suffixText: '°',
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onCameraPressed,
              child: Container(
                width: 40,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.camera_alt, color: iconColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
