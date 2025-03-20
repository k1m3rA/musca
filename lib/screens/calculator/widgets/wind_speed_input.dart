import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class WindSpeedInput extends StatelessWidget {
  final TextEditingController controller;
  final double scrollStep;
  final Function(double) onUpdateWindSpeed;

  const WindSpeedInput({
    Key? key,
    required this.controller,
    this.scrollStep = 0.5,
    required this.onUpdateWindSpeed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          final delta = pointerSignal.scrollDelta.dy > 0 ? -scrollStep : scrollStep;
          onUpdateWindSpeed(delta);
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
                  labelText: 'Wind Speed',
                  border: OutlineInputBorder(),
                  suffixText: 'm/s',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: () => onUpdateWindSpeed(scrollStep),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: () => onUpdateWindSpeed(-scrollStep),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
