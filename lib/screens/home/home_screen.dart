import 'package:flutter/material.dart';
import '../../models/calculation.dart';
import '../../services/calculation_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Add this import for SVG support

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
  
  @override
  void initState() {
    super.initState();
    _loadCalculations();
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
  String _selectedUnit = 'meters'; // Default unit
  
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
                      items: const [
                        DropdownMenuItem(value: 'meters', child: Text('Meters')),
                        DropdownMenuItem(value: 'mrad', child: Text('MRAD')),
                        DropdownMenuItem(value: 'moa', child: Text('MOA')),
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
      case 'mrad':
        driftValue = widget.calculation.driftMrad?.toStringAsFixed(2) ?? '0.00';
        dropValue = widget.calculation.dropMrad?.toStringAsFixed(2) ?? '0.00';
        unit = 'mrad';
        break;
      case 'moa':
        driftValue = widget.calculation.driftMoa?.toStringAsFixed(2) ?? '0.00';
        dropValue = widget.calculation.dropMoa?.toStringAsFixed(2) ?? '0.00';
        unit = 'MOA';
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