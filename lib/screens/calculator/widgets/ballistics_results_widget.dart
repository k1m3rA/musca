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
  bool _showAllUnits = false;

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
            if (_showAllUnits) _buildAllUnitsTable() else _buildSelectedUnitResults(),
            const SizedBox(height: 16),
            _buildToggleButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.my_location,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          'Correcciones a ${widget.distance.toStringAsFixed(0)}m',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
        _buildCorrectionRow(
          'Deriva horizontal',
          corrections['drift'],
          corrections['unit'],
          Icons.arrow_forward,
        ),
        const Divider(),
        _buildCorrectionRow(
          'Caída vertical',
          corrections['drop'],
          corrections['unit'],
          Icons.arrow_downward,
        ),
      ],
    );
  }

  Widget _buildCorrectionRow(String label, double value, String unit, IconData icon) {
    final bool isNegative = value < 0;
    final String displayValue = value.abs().toStringAsFixed(_getPrecisionForUnit(unit));
    final String direction = _getDirectionText(label, value);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: isNegative ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  direction,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$displayValue $unit',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!['Inches', 'Centimeters'].contains(_selectedUnit))
                Text(
                  '${_getClicksEstimation(value, _selectedUnit)} clicks',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllUnitsTable() {
    final result = widget.result!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Todas las unidades',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildUnitsTable(result),
      ],
    );
  }

  Widget _buildUnitsTable(BallisticsResult result) {
    final allUnits = [
      {'name': 'MRAD', 'drift': result.driftMrad, 'drop': result.dropMrad},
      {'name': '1/20 MRAD', 'drift': result.driftMrad20, 'drop': result.dropMrad20},
      {'name': 'MOA', 'drift': result.driftMoa, 'drop': result.dropMoa},
      {'name': '1/2 MOA', 'drift': result.driftMoa2, 'drop': result.dropMoa2},
      {'name': '1/3 MOA', 'drift': result.driftMoa3, 'drop': result.dropMoa3},
      {'name': '1/4 MOA', 'drift': result.driftMoa4, 'drop': result.dropMoa4},
      {'name': '1/8 MOA', 'drift': result.driftMoa8, 'drop': result.dropMoa8},
      {'name': 'Inches', 'drift': result.driftInches, 'drop': result.dropInches},
      {'name': 'Centimeters', 'drift': result.driftCm, 'drop': result.dropCm},
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Unidad',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Deriva',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Caída',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Data rows
          ...allUnits.asMap().entries.map((entry) {
            final index = entry.key;
            final unit = entry.value;
            final precision = _getPrecisionForUnit(unit['name'] as String);
            
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: index % 2 == 0 ? null : Colors.grey[50],
                border: index < allUnits.length - 1
                    ? Border(bottom: BorderSide(color: Colors.grey[200]!))
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(unit['name'] as String),
                  ),
                  Expanded(
                    child: Text(
                      (unit['drift'] as double).toStringAsFixed(precision),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      (unit['drop'] as double).toStringAsFixed(precision),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildToggleButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _showAllUnits = !_showAllUnits;
          });
        },
        icon: Icon(_showAllUnits ? Icons.visibility_off : Icons.visibility),
        label: Text(_showAllUnits ? 'Mostrar menos' : 'Ver todas las unidades'),
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
