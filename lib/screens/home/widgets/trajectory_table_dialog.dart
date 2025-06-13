import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../models/calculation.dart';
import '../../../models/gun_model.dart';
import '../../../models/cartridge_model.dart';
import '../../../models/scope_model.dart';
import '../../../services/ballistics_calculator.dart';

class TrajectoryTableDialog extends StatefulWidget {
  final Calculation calculation;
  final Gun? selectedGun;
  final Cartridge? selectedCartridge;
  final Scope? selectedScope;

  const TrajectoryTableDialog({
    Key? key,
    required this.calculation,
    required this.selectedGun,
    required this.selectedCartridge,
    required this.selectedScope,
  }) : super(key: key);

  @override
  State<TrajectoryTableDialog> createState() => _TrajectoryTableDialogState();
}

class _TrajectoryTableDialogState extends State<TrajectoryTableDialog> {
  int _stepSize = 50; // meters
  int _selectedUnits = 0; // 0 = cm, 1 = inches, 2 = MOA, 3 = MIL
  List<TrajectoryDataPoint> _tableData = [];
  bool _isCalculating = false;

  final List<String> _unitLabels = ['cm', 'inches', 'MOA', 'MIL'];
  final List<int> _stepOptions = [25, 50, 100, 200];

  @override
  void initState() {
    super.initState();
    _calculateTableData();
  }

  Future<void> _calculateTableData() async {
    if (widget.selectedGun == null || 
        widget.selectedCartridge == null || 
        widget.selectedScope == null) {
      return;
    }

    setState(() {
      _isCalculating = true;
      _tableData.clear();
    });

    final maxDistance = widget.calculation.distance * 1.5;
    
    for (double distance = 0; distance <= maxDistance; distance += _stepSize) {
      try {
        final result = BallisticsCalculator.calculateWithProfiles(
          distance,
          widget.calculation.windSpeed,
          widget.calculation.windDirection,
          widget.selectedGun!,
          widget.selectedCartridge!,
          widget.selectedScope!,
          temperature: widget.calculation.temperature,
          pressure: widget.calculation.pressure,
          humidity: widget.calculation.humidity,
          elevationAngle: widget.calculation.angle,
          azimuthAngle: widget.calculation.windDirection,
        );

        _tableData.add(TrajectoryDataPoint(
          distance: distance,
          dropVertical: result.dropVertical,
          driftHorizontal: result.driftHorizontal,
        ));
      } catch (e) {
        print('Error calculating trajectory at ${distance}m: $e');
      }
    }

    setState(() {
      _isCalculating = false;
    });
  }

  double _convertToSelectedUnit(double valueInMeters) {
    switch (_selectedUnits) {
      case 0: // cm
        return valueInMeters * 100;
      case 1: // inches
        return valueInMeters * 39.3701;
      case 2: // MOA
        // MOA conversion: 1 MOA = 1.047 inches at 100 yards
        return (valueInMeters * 39.3701) / 1.047;
      case 3: // MIL
        // MIL conversion: 1 MIL = 3.6 inches at 100 yards
        return (valueInMeters * 39.3701) / 3.6;
      default:
        return valueInMeters * 100;
    }
  }

  Future<void> _exportToPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Ballistics Trajectory Table',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Shot information
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Shot at ${widget.calculation.distance.toStringAsFixed(0)}m',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Wind: ${widget.calculation.windSpeed.toStringAsFixed(1)}m/s at ${widget.calculation.windDirection.toStringAsFixed(0)} degrees',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text(
                    'Angle: ${widget.calculation.angle.toStringAsFixed(1)} degrees - Temperature: ${widget.calculation.temperature.toStringAsFixed(1)} degrees C',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text(
                    'Step Size: ${_stepSize}m - Units: ${_unitLabels[_selectedUnits]}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            
            // Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(1.5),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                  ),
                  children: [
                    _buildPdfCell('Distance (m)', isHeader: true),
                    _buildPdfCell('Drop (${_unitLabels[_selectedUnits]})', isHeader: true),
                    _buildPdfCell('Drift (${_unitLabels[_selectedUnits]})', isHeader: true),
                  ],
                ),
                // Data rows
                ..._tableData.map((data) => pw.TableRow(
                  children: [
                    _buildPdfCell(data.distance.toStringAsFixed(0)),
                    _buildPdfCell(_convertToSelectedUnit(data.dropVertical).toStringAsFixed(1)),
                    _buildPdfCell(_convertToSelectedUnit(data.driftHorizontal).toStringAsFixed(1)),
                  ],
                )).toList(),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'MuscaBallisticChart.pdf',
    );
  }

  pw.Widget _buildPdfCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trajectory Table',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Step Size (m):', style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButton<int>(
                        value: _stepSize,
                        items: _stepOptions.map((step) {
                          return DropdownMenuItem(
                            value: step,
                            child: Text('${step}m'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _stepSize = value;
                            });
                            _calculateTableData();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Units:', style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButton<int>(
                        value: _selectedUnits,
                        items: _unitLabels.asMap().entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedUnits = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isCalculating)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Table(
                    border: TableBorder.all(color: Colors.grey),
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(1.5),
                      2: FlexColumnWidth(1.5),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        ),
                        children: [
                          _buildHeaderCell('Distance\n(m)'),
                          _buildHeaderCell('Drop\n(${_unitLabels[_selectedUnits]})'),
                          _buildHeaderCell('Drift\n(${_unitLabels[_selectedUnits]})'),
                        ],
                      ),
                      ..._tableData.map((data) => TableRow(
                        children: [
                          _buildDataCell(data.distance.toStringAsFixed(0)),
                          _buildDataCell(_convertToSelectedUnit(data.dropVertical).toStringAsFixed(1)),
                          _buildDataCell(_convertToSelectedUnit(data.driftHorizontal).toStringAsFixed(1)),
                        ],
                      )).toList(),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _exportToPdf,
                icon: Icon(Icons.picture_as_pdf, 
                  color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black),
                label: Text(
                  'Export to PDF',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class TrajectoryDataPoint {
  final double distance;
  final double dropVertical;
  final double driftHorizontal;

  TrajectoryDataPoint({
    required this.distance,
    required this.dropVertical,
    required this.driftHorizontal,
  });
}
