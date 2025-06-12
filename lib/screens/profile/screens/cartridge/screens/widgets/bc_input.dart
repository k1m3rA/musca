import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

class BCTypeInput extends StatefulWidget {
  final TextEditingController controller;
  final double scrollStep;
  final Function(double) onUpdateBCValue;
  final int initialBCType; 
  final Function(int) onUpdateBCType;

  const BCTypeInput({
    super.key,
    required this.controller,
    this.scrollStep = 1, 
    required this.onUpdateBCValue,
    this.initialBCType = -1,
    required this.onUpdateBCType,
  });

  @override
  State<BCTypeInput> createState() => _BCTypeInputState();
}

class _BCTypeInputState extends State<BCTypeInput> {
  late int _selectedButtonIndex;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _selectedButtonIndex = widget.initialBCType;
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the widget is disposed
    _focusNode.dispose();
    super.dispose();
  }

  // Helper method to update BC value with proper formatting
  void _updateBCValue(double delta) {
    // Ensure we're working with a valid number
    String currentValue = widget.controller.text;
    double? numValue = double.tryParse(currentValue);
    
    if (numValue != null) {
      double newValue = numValue + delta;
      // Ensure we don't go below zero
      newValue = newValue > 0 ? newValue : 0;
      
      // Format to 3 decimal places for better readability
      widget.controller.text = newValue.toStringAsFixed(3);
      widget.onUpdateBCValue(delta);
    } else {
      // If current value isn't a number, set a default
      widget.controller.text = '0.500';
      widget.onUpdateBCValue(0);
    }
  }
  
  // Helper method to get the current BC profile text
  String _getCurrentProfileText() {
    switch (_selectedButtonIndex) {
      case 0:
        return 'G1';
      case 1:
        return 'G7';
      default:
        return 'BC';
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Listener(
          onPointerSignal: (pointerSignal) {
            if (pointerSignal is PointerScrollEvent) {
              final delta = pointerSignal.scrollDelta.dy > 0 ? -0.001 : 0.001;
              _updateBCValue(delta);
              debugPrint('Scroll delta: $delta');
            }
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
                    ],
                    onTap: () {
                      // Request unfocus and then focus to reset keyboard state
                      _focusNode.unfocus();
                      Future.delayed(const Duration(milliseconds: 50), () {
                        _focusNode.requestFocus();
                      });
                    },
                    onChanged: (value) {
                      // Prevent callback loops by only triggering when actual edits happen
                      if (value.isNotEmpty && double.tryParse(value) != null) {
                        debugPrint('Text changed to: $value');
                        // Don't call onUpdateBCValue here as it will create a loop
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Ballistic Coefficient',
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
                      suffixText: _getCurrentProfileText(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onVerticalDragUpdate: (details) {
                    double delta = -details.delta.dy * 0.001;
                    _updateBCValue(delta);
                    debugPrint('Drag delta: $delta');
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
                          onTap: () {
                            _updateBCValue(0.001);
                            debugPrint('Button up pressed: +0.001');
                          },
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
                          onTap: () {
                            _updateBCValue(-0.001);
                            debugPrint('Button down pressed: -0.001');
                          },
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
                    widget.onUpdateBCType(0); // Report G1 selected
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
                          Text(
                            'G1',
                            style: TextStyle(
                              fontSize: 32,
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
                    widget.onUpdateBCType(1); // Report G7 selected
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
                          Text(
                            'G7',
                            style: TextStyle(
                              fontSize: 32,
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
