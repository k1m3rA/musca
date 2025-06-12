import 'package:flutter/material.dart';
import '../../../services/ballistics_calculator.dart';

class BallisticsResultsWidget extends StatefulWidget {
  final BallisticsResult? result;
  final double distance;

  const BallisticsResultsWidget({
    Key? key,
    this.result,
    required this.distance,
  }) : super(key: key);

  @override
  State<BallisticsResultsWidget> createState() => _BallisticsResultsWidgetState();
}

class _BallisticsResultsWidgetState extends State<BallisticsResultsWidget> {
  String _selectedUnit = 'MRAD';

  @override
  Widget build(BuildContext context) {
    if (widget.result == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.calculate,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Enter data and select profiles to see ballistics calculations',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Distance must be greater than 0m',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildUnitSelector(),
            const SizedBox(height: 16),
            _buildSelectedUnitResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Correcciones a ${widget.distance.toStringAsFixed(0)}m',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildUnitSelector() {
    final units = [
      'MRAD',
      '1/20 MRAD',
      'MOA',
      '1/2 MOA',
      '1/3 MOA',
      '1/4 MOA',
      '1/8 MOA',
      'Inches',
      'Centimeters'
    ];

    return Row(
      children: [
        const Text(
          'Unidad: ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<String>(
            value: _selectedUnit,
            isExpanded: true,
            items: units.map((String unit) {
              return DropdownMenuItem<String>(
                value: unit,
                child: Text(unit),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedUnit = newValue;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedUnitResults() {
    final result = widget.result!;
    final Map<String, dynamic> corrections = _getCorrectionsForUnit(_selectedUnit, result);

    return Column(
      children: [
        _buildCorrectionCard(
          'Deriva horizontal',
          corrections['drift'],
          corrections['unit'],
          'Ajustar ${corrections['drift'] > 0 ? 'a la derecha' : 'a la izquierda'}',
        ),
        const Divider(),
        _buildCorrectionCard(
          'Caída vertical',
          corrections['drop'],
          corrections['unit'],
          'Ajustar ${corrections['drop'] > 0 ? 'hacia arriba' : 'hacia abajo'}',
        ),
      ],
    );
  }

  Widget _buildCorrectionCard(String label, double value, String unit, String description) {
    // Determine correct icon and direction based on correction type and value
    IconData correctionIcon;
    String correctionDirection;
    Color correctionColor;
    
    if (label.contains('horizontal') || label.contains('Deriva')) {
      // For horizontal drift: positive = adjust right, negative = adjust left
      correctionIcon = value > 0 ? Icons.arrow_forward : Icons.arrow_back;
      correctionDirection = value > 0 ? 'Right' : 'Left';
      correctionColor = value > 0 ? Colors.green : Colors.red;
    } else {
      // For vertical drop: positive = adjust up, negative = adjust down
      correctionIcon = value > 0 ? Icons.arrow_upward : Icons.arrow_downward;
      correctionDirection = value > 0 ? 'Up' : 'Down';
      correctionColor = value > 0 ? Colors.green : Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value == 0 ? Colors.grey.withOpacity(0.3) : correctionColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                correctionIcon,
                color: value == 0 ? Colors.grey : correctionColor,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${value.abs().toStringAsFixed(_getPrecisionForUnit(unit))} $unit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: value == 0 ? Colors.grey : correctionColor,
            ),
          ),
          Text(
            value == 0 ? 'No correction' : description,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCorrectionsForUnit(String unit, BallisticsResult result) {
    switch (unit) {
      case 'MRAD':
        return {'drift': result.driftMrad, 'drop': result.dropMrad, 'unit': 'MRAD'};
      case '1/20 MRAD':
        return {'drift': result.driftMrad20, 'drop': result.dropMrad20, 'unit': 'MRAD'};
      case 'MOA':
        return {'drift': result.driftMoa, 'drop': result.dropMoa, 'unit': 'MOA'};
      case '1/2 MOA':
        return {'drift': result.driftMoa2, 'drop': result.dropMoa2, 'unit': 'MOA'};
      case '1/3 MOA':
        return {'drift': result.driftMoa3, 'drop': result.dropMoa3, 'unit': 'MOA'};
      case '1/4 MOA':
        return {'drift': result.driftMoa4, 'drop': result.dropMoa4, 'unit': 'MOA'};
      case '1/8 MOA':
        return {'drift': result.driftMoa8, 'drop': result.dropMoa8, 'unit': 'MOA'};
      case 'Inches':
        return {'drift': result.driftInches, 'drop': result.dropInches, 'unit': 'in'};
      case 'Centimeters':
        return {'drift': result.driftCm, 'drop': result.dropCm, 'unit': 'cm'};
      default:
        return {'drift': result.driftMrad, 'drop': result.dropMrad, 'unit': 'MRAD'};
    }
  }

  int _getPrecisionForUnit(String unit) {
    switch (unit) {
      case 'MRAD':
      case 'MOA':
      case '1/4 MOA':
      case 'in':
        return 2;
      case '1/2 MOA':
      case 'cm':
        return 1;
      case '1/3 MOA':
      case '1/8 MOA':
        return 3;
      default:
        return 2;
    }
  }

  String _getDirectionText(String label, double value) {
    if (label.contains('Deriva')) {
      if (value > 0) return 'Ajustar a la derecha';
      if (value < 0) return 'Ajustar a la izquierda';
      return 'Sin corrección horizontal';
    } else {
      if (value > 0) return 'Ajustar hacia arriba';
      if (value < 0) return 'Ajustar hacia abajo';
      return 'Sin corrección vertical';
    }
  }

  String _getClicksEstimation(double value, String unit) {
    // Estimate clicks based on typical scope values
    double clickValueMrad;
    
    if (unit.contains('MRAD')) {
      clickValueMrad = 0.1; // Typical 0.1 MRAD per click
    } else if (unit.contains('MOA')) {
      clickValueMrad = 0.25 * 0.290888; // 0.25 MOA in MRAD
    } else {
      return '0'; // Linear units don't convert to clicks directly
    }
    
    final clicks = (value / clickValueMrad).round().abs();
    return clicks.toString();
  }
}
