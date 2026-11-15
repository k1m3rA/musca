import 'package:flutter/material.dart';
import 'package:musca/l10n/app_localizations.dart';
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

  List<String> get _unitLabels => ['cm', AppLocalizations.of(context)!.inches.toLowerCase(), 'MOA', 'MIL'];
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

    // UNA sola simulación del modelo v5 para toda la tabla (antes se
    // re-simulaba por fila).
    try {
      final results = BallisticsCalculator.generateBallisticTable(
        _stepSize.toDouble(),
        maxDistance,
        _stepSize.toDouble(),
        widget.calculation.windSpeed,
        widget.calculation.windDirection,
        widget.selectedGun!,
        widget.selectedCartridge!,
        widget.selectedScope!,
        temperature: widget.calculation.temperature,
        pressure: widget.calculation.pressure,
        humidity: widget.calculation.humidity,
        elevationAngle: widget.calculation.angle,
        azimuthAngle: widget.calculation.azimuth,
        latitude: widget.calculation.latitude,
        altitude: widget.calculation.altitude,
      );

      for (int i = 0; i < results.length; i++) {
        final result = results[i];
        final distance = (i + 1) * _stepSize.toDouble();
        double dropValue, driftValue;

        // Determine values based on selected units
        switch (_selectedUnits) {
          case 0: // cm - linear displacement
            dropValue = -result.dropMrad * distance / 10.0;
            driftValue = result.driftMrad * distance / 10.0;
            break;
          case 1: // inches - linear displacement
            dropValue = -result.dropMrad * distance * 39.37 / 1000.0;
            driftValue = result.driftMrad * distance * 39.37 / 1000.0;
            break;
          case 2: // MOA - angular correction
            dropValue = -result.dropMoa;
            driftValue = result.driftMoa;
            break;
          case 3: // MIL - angular correction
            dropValue = -result.dropMrad;
            driftValue = result.driftMrad;
            break;
          default:
            dropValue = -result.dropMrad * distance / 10.0;
            driftValue = result.driftMrad * distance / 10.0;
        }

        _tableData.add(TrajectoryDataPoint(
          distance: distance,
          dropVertical: dropValue,
          driftHorizontal: driftValue,
          velocityMs: result.speedMs,
          energyJ: result.energyJ,
          timeS: result.timeS,
        ));
      }
    } catch (e) {
      print('Error calculando la tabla balística (modelo v5): $e');
    }

    setState(() {
      _isCalculating = false;
    });
  }  double _convertToSelectedUnit(double value) {
    // Values are already in the correct units based on _selectedUnits
    // No conversion needed - just return the value
    return value;
  }
  Future<void> _exportToPdf() async {
    final pdf = pw.Document();
    
    // Load the logo image
    final logoData = await rootBundle.load('assets/icon/iconos/android/res/mipmap-xxxhdpi/ic_launcher.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context pdfContext) {
          return [            // App header with logo and name
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Image(logoImage, width: 40, height: 40),
                pw.SizedBox(width: 12),
                pw.Text(
                  AppLocalizations.of(context)!.musca,
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            // Developer subtitle
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                AppLocalizations.of(context)!.developedByMiguelBenetAkaK1m3ra,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.grey600,
                ),
              ),
            ),
            pw.SizedBox(height: 15),
            pw.Header(
              level: 0,
              child: pw.Text(
                AppLocalizations.of(context)!.correctionTable,
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
                crossAxisAlignment: pw.CrossAxisAlignment.start,                children: [
                  pw.Text(
                    AppLocalizations.of(context)!.profilesLabel(widget.selectedGun?.name ?? AppLocalizations.of(context)!.unknownGun, widget.selectedCartridge?.name ?? AppLocalizations.of(context)!.unknownCartridge, widget.selectedScope?.name ?? AppLocalizations.of(context)!.unknownScope),
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    AppLocalizations.of(context)!.windInfoPdf(widget.calculation.windSpeed.toStringAsFixed(1), widget.calculation.windDirection.toStringAsFixed(0)),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text(
                    AppLocalizations.of(context)!.angleTempInfoPdf(widget.calculation.angle.toStringAsFixed(1), widget.calculation.temperature.toStringAsFixed(1)),
                    style: const pw.TextStyle(fontSize: 12),
                  ),                  pw.Text(
                    AppLocalizations.of(context)!.stepSizeUnitsPdf(_stepSize.toString(), _unitLabels[_selectedUnits]),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    AppLocalizations.of(context)!.notePositiveDropBulletHitsBelowLineOfSightPositiveDriftBulletHitsToTheRight,
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
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
                1: const pw.FlexColumnWidth(1.4),
                2: const pw.FlexColumnWidth(1.4),
                3: const pw.FlexColumnWidth(1.4),
                4: const pw.FlexColumnWidth(1.2),
                5: const pw.FlexColumnWidth(1.2),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                  ),
                  children: [
                    _buildPdfCell(AppLocalizations.of(context)!.distanceM, isHeader: true),
                    _buildPdfCell(AppLocalizations.of(context)!.dropUnits(_unitLabels[_selectedUnits]), isHeader: true),
                    _buildPdfCell(AppLocalizations.of(context)!.driftUnits(_unitLabels[_selectedUnits]), isHeader: true),
                    _buildPdfCell(AppLocalizations.of(context)!.velocityMsHeader, isHeader: true),
                    _buildPdfCell(AppLocalizations.of(context)!.energyJHeader, isHeader: true),
                    _buildPdfCell(AppLocalizations.of(context)!.tofSHeader, isHeader: true),
                  ],
                ),
                // Data rows
                ..._tableData.map((data) => pw.TableRow(
                  children: [
                    _buildPdfCell(data.distance.toStringAsFixed(0)),
                    _buildPdfCell(_convertToSelectedUnit(data.dropVertical).toStringAsFixed(1)),
                    _buildPdfCell(_convertToSelectedUnit(data.driftHorizontal).toStringAsFixed(1)),
                    _buildPdfCell(data.velocityMs.toStringAsFixed(1)),
                    _buildPdfCell(data.energyJ.toStringAsFixed(0)),
                    _buildPdfCell(data.timeS.toStringAsFixed(3)),
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
    final media = MediaQuery.of(context);
    final isLandscape = media.orientation == Orientation.landscape;
    final gap = isLandscape ? 6.0 : 16.0;

    return Dialog(
      // En horizontal el diálogo usa casi toda la pantalla: la altura
      // disponible es pequeña y con los márgenes por defecto la tabla no se ve.
      insetPadding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 16 : 40,
        vertical: isLandscape ? 8 : 24,
      ),
      child: Container(
        width: media.size.width * (isLandscape ? 0.96 : 0.9),
        height: media.size.height * (isLandscape ? 0.95 : 0.8),
        padding: EdgeInsets.all(isLandscape ? 10.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.correctionTable,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isLandscape)
                  IconButton(
                    tooltip: AppLocalizations.of(context)!.exportToPdf,
                    icon: const Icon(Icons.picture_as_pdf),
                    onPressed: _exportToPdf,
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: isLandscape ? 4 : 8),
            Container(
              padding: EdgeInsets.all(isLandscape ? 8 : 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.correctionsRelativeToLineOfSightPositiveDropBulletHitsBelowLineOfSightPositiveDriftBulletHitsToTheRight,
                style: TextStyle(
                  fontSize: isLandscape ? 11 : 12,
                  color: Theme.of(context).colorScheme.primary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            SizedBox(height: gap),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.stepSizeMLabel, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isLandscape ? 12 : 14)),
                      DropdownButton<int>(
                        value: _stepSize,
                        isDense: isLandscape,
                        items: _stepOptions.map((step) {
                          return DropdownMenuItem(
                            value: step,
                            child: Text(AppLocalizations.of(context)!.stepMLabel(step.toString())),
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
                      Text(AppLocalizations.of(context)!.unitsLabel, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isLandscape ? 12 : 14)),
                      DropdownButton<int>(
                        value: _selectedUnits,
                        isDense: isLandscape,
                        items: _unitLabels.asMap().entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedUnits = value;
                            });
                            _calculateTableData(); // Recalculate when units change
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: gap),
            if (_isCalculating)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Table(
                    border: TableBorder.all(color: Colors.grey),
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(1.4),
                      2: FlexColumnWidth(1.4),
                      3: FlexColumnWidth(1.3),
                      4: FlexColumnWidth(1.1),
                      5: FlexColumnWidth(1.1),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        ),
                        children: [
                          _buildHeaderCell(AppLocalizations.of(context)!.distanceMTable),
                          _buildHeaderCell(AppLocalizations.of(context)!.dropUnitsTable(_unitLabels[_selectedUnits])),
                          _buildHeaderCell(AppLocalizations.of(context)!.driftUnitsTable(_unitLabels[_selectedUnits])),
                          _buildHeaderCell(AppLocalizations.of(context)!.velocityMsHeader),
                          _buildHeaderCell(AppLocalizations.of(context)!.energyJHeader),
                          _buildHeaderCell(AppLocalizations.of(context)!.tofSHeader),
                        ],
                      ),
                      ..._tableData.map((data) => TableRow(
                        children: [
                          _buildDataCell(data.distance.toStringAsFixed(0)),
                          _buildDataCell(_convertToSelectedUnit(data.dropVertical).toStringAsFixed(1)),
                          _buildDataCell(_convertToSelectedUnit(data.driftHorizontal).toStringAsFixed(1)),
                          _buildDataCell(data.velocityMs.toStringAsFixed(1)),
                          _buildDataCell(data.energyJ.toStringAsFixed(0)),
                          _buildDataCell(data.timeS.toStringAsFixed(3)),
                        ],
                      )).toList(),
                    ],
                  ),
                ),
              ),
            // En horizontal el botón de exportar va en la barra de título
            // para dejar toda la altura disponible a la tabla.
            if (!isLandscape) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _exportToPdf,
                  icon: Icon(Icons.picture_as_pdf, 
                    color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.grey[900]),
                  label: Text(
                    AppLocalizations.of(context)!.exportToPdf,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.grey[900],
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Padding(
      padding: EdgeInsets.all(isLandscape ? 6.0 : 12.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(String text) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Padding(
      padding: EdgeInsets.all(isLandscape ? 6.0 : 12.0),
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
  final double velocityMs;
  final double energyJ;
  final double timeS;

  TrajectoryDataPoint({
    required this.distance,
    required this.dropVertical,
    required this.driftHorizontal,
    required this.velocityMs,
    required this.energyJ,
    required this.timeS,
  });
}
