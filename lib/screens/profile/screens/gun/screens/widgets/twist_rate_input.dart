import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class TwistRateInput extends StatefulWidget {
  final TextEditingController controller;
  final double scrollStep;
  final Function(double) onUpdateTwistRate;
  final int initialTwistDirection; // -1 for unselected, 0 for left, 1 for right
  final Function(int) onUpdateTwistDirection;

  const TwistRateInput({
    super.key,
    required this.controller,
    this.scrollStep = 0.1,
    required this.onUpdateTwistRate,
    this.initialTwistDirection = -1,
    required this.onUpdateTwistDirection,
  });

  @override
  State<TwistRateInput> createState() => _TwistRateInputState();
}

class _TwistRateInputState extends State<TwistRateInput> {
  late int _selectedButtonIndex;

  @override
  void initState() {
    super.initState();
    _selectedButtonIndex = widget.initialTwistDirection;
  }

  @override
  Widget build(BuildContext context) {
    // Define colors based on theme
    final iconColor = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Listener(
          onPointerSignal: (pointerSignal) {
            if (pointerSignal is PointerScrollEvent) {
              final delta = pointerSignal.scrollDelta.dy > 0 ? -widget.scrollStep * 5 : widget.scrollStep * 5;
              widget.onUpdateTwistRate(delta);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Twist Rate',
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
                      suffixText: '1:in',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onVerticalDragUpdate: (details) {
                    double delta = -details.delta.dy * 0.5;
                    widget.onUpdateTwistRate(delta);
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
                          onTap: () => widget.onUpdateTwistRate(widget.scrollStep * 5),
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
                          onTap: () => widget.onUpdateTwistRate(-widget.scrollStep * 5),
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
        ),
        
        // Two buttons in a row
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              // First button in row
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedButtonIndex = 0;
                    });
                    widget.onUpdateTwistDirection(0); // Report left twist selected
                  },
                  child: Card(
                    elevation: 4,
                    color: _selectedButtonIndex == 0 
                      ? Theme.of(context).colorScheme.primary 
                      : null,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/icon/counterclockwise.png',
                            height: 80,
                            color: _selectedButtonIndex == 0
                              ? Theme.of(context).colorScheme.background
                              : Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Left Twist',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _selectedButtonIndex == 0
                                ? Theme.of(context).colorScheme.background
                                : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Second button in row
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedButtonIndex = 1;
                    });
                    widget.onUpdateTwistDirection(1); // Report right twist selected
                  },
                  child: Card(
                    elevation: 4,
                    color: _selectedButtonIndex == 1 
                      ? Theme.of(context).colorScheme.primary 
                      : null,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/icon/clockwise.png',
                            height: 80,
                            color: _selectedButtonIndex == 1
                              ? Theme.of(context).colorScheme.background
                              : Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Right Twist',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _selectedButtonIndex == 1
                                ? Theme.of(context).colorScheme.background
                                : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
