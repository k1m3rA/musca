import 'package:flutter/material.dart';
import '../../models/calculation.dart';
import '../../services/calculation_storage.dart';
import '../../services/ballistics_calculator.dart';
import '../../services/ballistics_units.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

// New widget for just the content
class HomeContent extends StatefulWidget {
  final String title;
  final Function(int)? onNavigateTo; // Add this parameter
  
  const HomeContent({
    super.key,
    required this.title,
    this.onNavigateTo, // Add this parameter
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<Calculation> _calculations = [];
  bool _isLoading = true;
  String _selectedUnit = 'MRAD';
  
  @override
  void initState() {
    super.initState();
    _loadCalculations();
    _loadSelectedUnit();
  }
  
  Future<void> _loadSelectedUnit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedUnit = prefs.getString('selected_unit') ?? 'MRAD';
    });
  }
  
  Future<void> _loadCalculations() async {
    final calculations = await CalculationStorage.getCalculations();
    if (mounted) {
      setState(() {
        _calculations = calculations.reversed.toList(); // Show newest first
        _isLoading = false;
      });
    }
  }

  // Add a method to delete a single calculation
  Future<void> _deleteCalculation(Calculation calculation) async {
    final deleted = await CalculationStorage.deleteCalculation(calculation);
    if (deleted) {
      _loadCalculations(); // Refresh the list
    }
  }

  Widget _buildLatestBallisticsCard() {
    if (_calculations.isEmpty) return const SizedBox.shrink();
    
    final latest = _calculations.first;
    if (latest.driftHorizontal == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Latest Shot',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${latest.distance.toStringAsFixed(0)}m',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedUnit,
                          isExpanded: true,
                          underline: Container(),
                          items: _getAllAvailableUnits().map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(
                                unit,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            if (value != null) {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setString('selected_unit', value);
                              setState(() {
                                _selectedUnit = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLatestCorrectionDisplay(latest),
                // Add shot conditions summary
                const SizedBox(height: 8),
                Text(
                  'Angle: ${latest.angle.toStringAsFixed(1)}° • Wind: ${latest.windSpeed.toStringAsFixed(1)}m/s @ ${latest.windDirection.toStringAsFixed(0)}°',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLatestCorrectionDisplay(Calculation latest) {
    final corrections = _getCorrectionsForUnit(_selectedUnit, latest);
    
    return Row(
      children: [
        Expanded(
          child: _buildCorrectionCard(
            'Horizontal Drift',
            corrections['drift'] as double,
            corrections['unit'] as String,
            Icons.arrow_forward,
            corrections['drift'] > 0 ? 'Right' : 'Left',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCorrectionCard(
            'Vertical Drop',
            corrections['drop'] as double,
            corrections['unit'] as String,
            Icons.arrow_downward,
            'Up',
          ),
        ),
      ],
    );
  }

  Widget _buildCorrectionCard(String label, double value, String unit, IconData icon, String direction) {
    final bool isNegative = value < 0;
    final String displayValue = value.abs().toStringAsFixed(_getPrecisionForUnit(unit));
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNegative ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isNegative ? Colors.red : Colors.green,
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
            '$displayValue $unit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isNegative ? Colors.red : Colors.green,
            ),
          ),
          Text(
            value == 0 ? 'No correction' : 'Adjust ${isNegative && label.contains('Horizontal') ? 'Left' : direction}',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getAllAvailableUnits() {
    return [
      'MRAD',
      'MOA',
      'Inches',
      'Centimeters',
      'Meters',
    ];
  }

  Map<String, dynamic> _getCorrectionsForUnit(String unit, Calculation calculation) {
    switch (unit) {
      case 'MRAD':
        return {
          'drift': calculation.driftMrad ?? 0.0,
          'drop': calculation.dropMrad ?? 0.0,
          'unit': 'MRAD'
        };
      case 'MOA':
        return {
          'drift': calculation.driftMoa ?? 0.0,
          'drop': calculation.dropMoa ?? 0.0,
          'unit': 'MOA'
        };
      case 'Inches':
        final driftInches = (calculation.driftHorizontal ?? 0) * 39.3701;
        final dropInches = (calculation.dropVertical ?? 0) * 39.3701;
        return {
          'drift': driftInches,
          'drop': dropInches,
          'unit': 'in'
        };
      case 'Centimeters':
        final driftCm = (calculation.driftHorizontal ?? 0) * 100;
        final dropCm = (calculation.dropVertical ?? 0) * 100;
        return {
          'drift': driftCm,
          'drop': dropCm,
          'unit': 'cm'
        };
      case 'Meters':
      default:
        return {
          'drift': calculation.driftHorizontal ?? 0.0,
          'drop': calculation.dropVertical ?? 0.0,
          'unit': 'm'
        };
    }
  }

  int _getPrecisionForUnit(String unit) {
    switch (unit) {
      case 'MRAD':
      case 'MOA':
      case 'in':
        return 2;
      case 'cm':
        return 1;
      case 'm':
        return 3;
      default:
        return 2;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadCalculations,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: _calculations.isNotEmpty, // Make it floating when there are calculations
              snap: _calculations.isNotEmpty,     // Enable snapping when there are calculations
              expandedHeight: 100, // Larger expanded height when there are calculations
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  widget.title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                background: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
            // Show prominent ballistics results if available
            if (_calculations.isNotEmpty && !_isLoading)
              SliverToBoxAdapter(
                child: _buildLatestBallisticsCard(),
              ),
            // Make "New Shot" button full width and taller
            if (_calculations.isNotEmpty && !_isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: GestureDetector(
                    onTap: () {
                      final navigateTo = widget.onNavigateTo;
                      if (navigateTo != null) {
                        navigateTo(1); // Navigate to calculator (index 1)
                      }
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Container(
                        height: 100, // Set a specific height for the button
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 40, // Increased icon size
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Add New Shot',
                              style: TextStyle(
                                fontSize: 18, // Increased font size
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            _isLoading 
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _calculations.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              print('Tapped on calculator icon'); // Debug print
                              final navigateTo = widget.onNavigateTo;
                              if (navigateTo != null) {
                                print('Navigation callback is not null');
                                navigateTo(1); // Navigate to calculator (index 1)
                              } else {
                                print('Navigation callback is null');
                              }
                            },
                            // Replace the entire child with a simpler, more focused tap target
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Column(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icon/shoot.svg',
                                      height: 110,
                                      width: 110,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Add first shot',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No saved shots yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final calculation = _calculations[index];
                        return CalculationCard(
                          calculation: calculation,
                          onDelete: () => _deleteCalculation(calculation),
                        );
                      },
                      childCount: _calculations.length,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class CalculationCard extends StatefulWidget {
  final Calculation calculation;
  final VoidCallback onDelete;
  
  const CalculationCard({
    super.key,
    required this.calculation,
    required this.onDelete,
  });

  @override
  State<CalculationCard> createState() => _CalculationCardState();
}

class _CalculationCardState extends State<CalculationCard> {
  String _selectedUnit = 'MRAD'; // Default unit
  
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Dismissible(
      key: Key('calculation-${widget.calculation.timestamp.toIso8601String()}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        color: Colors.red,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => widget.onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shot Calculation',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        dateFormat.format(widget.calculation.timestamp),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: widget.onDelete,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              _buildDataRow(context, 'Distance', '${widget.calculation.distance.toStringAsFixed(1)} m'),
              _buildDataRow(context, 'Angle', '${widget.calculation.angle.toStringAsFixed(1)}°'),
              _buildDataRow(context, 'Wind Speed', '${widget.calculation.windSpeed.toStringAsFixed(1)} m/s'),
              _buildDataRow(context, 'Wind Direction', '${widget.calculation.windDirection.toStringAsFixed(1)}°'),
              
              // Add ballistics results section
              if (widget.calculation.driftHorizontal != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ballistics Results',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _selectedUnit,
                      underline: Container(),
                      items: [
                        const DropdownMenuItem(value: 'MRAD', child: Text('MRAD')),
                        const DropdownMenuItem(value: '1/20 MRAD', child: Text('1/20 MRAD')),
                        const DropdownMenuItem(value: 'MOA', child: Text('MOA')),
                        const DropdownMenuItem(value: '1/2 MOA', child: Text('1/2 MOA')),
                        const DropdownMenuItem(value: '1/3 MOA', child: Text('1/3 MOA')),
                        const DropdownMenuItem(value: '1/4 MOA', child: Text('1/4 MOA')),
                        const DropdownMenuItem(value: '1/8 MOA', child: Text('1/8 MOA')),
                        const DropdownMenuItem(value: 'Inches', child: Text('Inches')),
                        const DropdownMenuItem(value: 'Centimeters', child: Text('Centimeters')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedUnit = value!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _buildBallisticsResults(),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBallisticsResults() {
    String driftValue, dropValue, unit;
    
    switch (_selectedUnit) {
      case 'MRAD':
        driftValue = widget.calculation.driftMrad?.toStringAsFixed(2) ?? '0.00';
        dropValue = widget.calculation.dropMrad?.toStringAsFixed(2) ?? '0.00';
        unit = 'MRAD';
        break;
      case '1/20 MRAD':
        // Use MRAD values for now, as 1/20 MRAD isn't stored in calculation model yet
        driftValue = widget.calculation.driftMrad?.toStringAsFixed(2) ?? '0.00';
        dropValue = widget.calculation.dropMrad?.toStringAsFixed(2) ?? '0.00';
        unit = 'MRAD';
        break;
      case 'MOA':
        driftValue = widget.calculation.driftMoa?.toStringAsFixed(2) ?? '0.00';
        dropValue = widget.calculation.dropMoa?.toStringAsFixed(2) ?? '0.00';
        unit = 'MOA';
        break;
      case '1/2 MOA':
      case '1/3 MOA':
      case '1/4 MOA':
      case '1/8 MOA':
        // Use MOA values for fractional units for now
        driftValue = widget.calculation.driftMoa?.toStringAsFixed(2) ?? '0.00';
        dropValue = widget.calculation.dropMoa?.toStringAsFixed(2) ?? '0.00';
        unit = 'MOA';
        break;
      case 'Inches':
        // Convert from meters to inches
        final driftInches = (widget.calculation.driftHorizontal ?? 0) * 39.3701;
        final dropInches = (widget.calculation.dropVertical ?? 0) * 39.3701;
        driftValue = driftInches.toStringAsFixed(2);
        dropValue = dropInches.toStringAsFixed(2);
        unit = 'in';
        break;
      case 'Centimeters':
        // Convert from meters to centimeters
        final driftCm = (widget.calculation.driftHorizontal ?? 0) * 100;
        final dropCm = (widget.calculation.dropVertical ?? 0) * 100;
        driftValue = driftCm.toStringAsFixed(1);
        dropValue = dropCm.toStringAsFixed(1);
        unit = 'cm';
        break;
      default: // meters
        driftValue = widget.calculation.driftHorizontal?.toStringAsFixed(3) ?? '0.000';
        dropValue = widget.calculation.dropVertical?.toStringAsFixed(3) ?? '0.000';
        unit = 'm';
    }
    
    return Column(
      children: [
        _buildDataRow(context, 'Horizontal Drift', '$driftValue $unit'),
        _buildDataRow(context, 'Vertical Drop', '$dropValue $unit'),
      ],
    );
  }
  
  Widget _buildDataRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
