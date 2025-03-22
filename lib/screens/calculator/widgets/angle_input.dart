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

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          final delta = pointerSignal.scrollDelta.dy > 0 ? -scrollStep : scrollStep;
          onUpdateAngle(delta);
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
                  labelText: 'Vertical angle (degrees)',
                  border: OutlineInputBorder(),
                  suffixText: '°',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: () => onUpdateAngle(scrollStep),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: () => onUpdateAngle(-scrollStep),
                ),
                const SizedBox(height: 5), // Add some spacing
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: onCameraPressed,
                  tooltip: 'Measure angle with camera',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
