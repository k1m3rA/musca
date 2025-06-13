import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

class ZeroRangeInput extends StatelessWidget {
  final TextEditingController controller;
  final double scrollStep;
  final Function(double) onUpdateZeroRange;

  const ZeroRangeInput({
    super.key,
    required this.controller,
    this.scrollStep = 10.0,
    required this.onUpdateZeroRange,
  });

  void _handleZeroRangeUpdate(double delta) {
    final currentValue = double.tryParse(controller.text) ?? 0.0;
    final newValue = currentValue + delta;
    final finalValue = newValue == 0.0 ? 99999.0 : newValue;
    onUpdateZeroRange(finalValue - currentValue);
  }

  @override
  Widget build(BuildContext context) {
    // Define colors based on theme
    final iconColor = Theme.of(context).colorScheme.primary;

    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          final delta = pointerSignal.scrollDelta.dy > 0 ? -scrollStep * 5 : scrollStep * 5;
          _handleZeroRangeUpdate(delta);
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
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    // Check if the new value is "0" and replace with "99999"
                    if (newValue.text == '0' || newValue.text == '0.0') {
                      return const TextEditingValue(
                        text: '99999',
                        selection: TextSelection.collapsed(offset: 5),
                      );
                    }
                    return newValue;
                  }),
                ],
                decoration: InputDecoration(
                  labelText: 'Zero Range',
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
            GestureDetector(
              onVerticalDragUpdate: (details) {
                double delta = -details.delta.dy * 0.5;
                _handleZeroRangeUpdate(delta);
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
                      onTap: () => _handleZeroRangeUpdate(scrollStep * 5),
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
                      onTap: () => _handleZeroRangeUpdate(-scrollStep * 5),
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
