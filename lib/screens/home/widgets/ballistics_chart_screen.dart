import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../../../models/calculation.dart';
import '../../../services/ballistics_calculator.dart';
import '../../../services/gun_storage.dart';
import '../../../services/cartridge_storage.dart';
import '../../../services/scope_storage.dart';
import '../../../models/gun_model.dart';
import '../../../models/cartridge_model.dart';
import '../../../models/scope_model.dart';
import 'trajectory_table_dialog.dart';

class BallisticsChartScreen extends StatefulWidget {
  final Calculation calculation;

  const BallisticsChartScreen({
    Key? key,
    required this.calculation,
  }) : super(key: key);

  @override
  State<BallisticsChartScreen> createState() => _BallisticsChartScreenState();
}

class _BallisticsChartScreenState extends State<BallisticsChartScreen> {
  List<FlSpot> trajectorySpots = [];
  List<FlSpot> lineOfSightSpots = [];
  Gun? _selectedGun;
  Cartridge? _selectedCartridge;
  Scope? _selectedScope;
  bool _isLoading = true;
  double _maxDistance = 0;
  double _maxDrop = 0;
  double _minDrop = 0;

  @override
  void initState() {
    super.initState();
    _loadProfilesAndCalculateTrajectory();
  }

  Future<void> _loadProfilesAndCalculateTrajectory() async {
    try {
      final gun = await GunStorage.getSelectedGun();
      final cartridge = await CartridgeStorage.getSelectedCartridge();
      final scope = await ScopeStorage.getSelectedScope();

      if (gun != null && cartridge != null && scope != null) {
        setState(() {
          _selectedGun = gun;
          _selectedCartridge = cartridge;
          _selectedScope = scope;
        });

        await _calculateTrajectoryData();
      }
    } catch (e) {
      print('Error loading profiles: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _calculateTrajectoryData() async {
    if (_selectedGun == null || _selectedCartridge == null || _selectedScope == null) {
      return;
    }

    List<FlSpot> trajectory = [];
    List<FlSpot> lineOfSight = [];

    // Calculate trajectory points from 0 to target distance + 20%
    final targetDistance = widget.calculation.distance;
    final maxCalcDistance = targetDistance * 1.2;
    final step = maxCalcDistance / 100; // 100 points for smooth curve

    // Calculate scope height in meters
    final double sightHeightValue = _selectedScope!.sightHeight;
    final int sightHeightUnits = _selectedScope!.units;
    final double visorHeight = sightHeightUnits == 0 
        ? sightHeightValue * 0.0254  // inches to meters
        : sightHeightValue * 0.01;   // cm to meters

    // Zero range for line of sight calculation
    final double zeroRange = _selectedGun!.zeroRange;
    
    // Handle special cases for line of sight calculation
    double losSlope = 0.0;
    bool useSimpleCalculation = false;
    
    if (zeroRange == 0.0) {
      // When zero range is 0, line of sight is horizontal (no zeroing)
      losSlope = 0.0;
      useSimpleCalculation = true;
      print('Special case: Zero range = 0, LOS is horizontal at scope height');
    } else {
      // Normal case: calculate bullet trajectory at zero range to find intersection point
      double bulletHeightAtZero = 0.0;
      try {
        final zeroResult = BallisticsCalculator.calculateWithProfiles(
          zeroRange,
          widget.calculation.windSpeed,
          widget.calculation.windDirection,
          _selectedGun!,
          _selectedCartridge!,
          _selectedScope!,
          temperature: widget.calculation.temperature,
          pressure: widget.calculation.pressure,
          humidity: widget.calculation.humidity,
          elevationAngle: widget.calculation.angle,
          azimuthAngle: widget.calculation.windDirection,
        );
        bulletHeightAtZero = zeroResult.dropVertical;
      } catch (e) {
        print('Error calculating zero point: $e');
        // Fallback: use simple ballistic approximation
        final muzzleVelocity = _selectedGun!.muzzleVelocity;
        bulletHeightAtZero = 0.5 * 9.81 * pow(zeroRange / muzzleVelocity, 2); // Positive = downward drop
      }

      // Calculate line of sight slope: from scope height at x=0 to bullet height at zero range
      losSlope = (bulletHeightAtZero - visorHeight) / zeroRange;
    }

    for (int i = 0; i <= 100; i++) {
      final distance = i * step;
      
      if (distance == 0) {
        // At muzzle: bullet is at bore height (0), line of sight starts at scope height
        trajectory.add(FlSpot(0, 0));
        lineOfSight.add(FlSpot(0, visorHeight));
        continue;
      }

      if (useSimpleCalculation) {
        // Use simple ballistic calculation when zero range is 0
        final muzzleVelocity = _selectedGun!.muzzleVelocity;
        if (muzzleVelocity > 0) {
          final timeOfFlight = distance / muzzleVelocity;
          final simpleDrop = 0.5 * 9.81 * timeOfFlight * timeOfFlight;
          
          // Bullet drops downward (positive Y value)
          trajectory.add(FlSpot(distance, simpleDrop));
        }
        
        // Line of sight is horizontal at scope height
        lineOfSight.add(FlSpot(distance, visorHeight));
        
      } else {
        // Normal calculation for non-zero zero range
        try {
          final result = BallisticsCalculator.calculateWithProfiles(
            distance,
            widget.calculation.windSpeed,
            widget.calculation.windDirection,
            _selectedGun!,
            _selectedCartridge!,
            _selectedScope!,
            temperature: widget.calculation.temperature,
            pressure: widget.calculation.pressure,
            humidity: widget.calculation.humidity,
            elevationAngle: widget.calculation.angle,
            azimuthAngle: widget.calculation.windDirection,
          );

          // Validate and use ballistics result
          if (result.dropVertical.isFinite && result.driftHorizontal.isFinite) {
            final bulletDrop = result.dropVertical;
            trajectory.add(FlSpot(distance, bulletDrop));
          } else {
            // Fallback to simple calculation
            final muzzleVelocity = _selectedGun!.muzzleVelocity;
            final timeOfFlight = distance / muzzleVelocity;
            final simpleDrop = 0.5 * 9.81 * timeOfFlight * timeOfFlight;
            trajectory.add(FlSpot(distance, simpleDrop));
          }

          // Line of sight: straight line from scope height with calculated slope
          final sightLineHeight = visorHeight + (distance * losSlope);
          lineOfSight.add(FlSpot(distance, sightLineHeight));

        } catch (e) {
          print('Error calculating ballistics at distance $distance: $e');
          // Use simple fallback
          final muzzleVelocity = _selectedGun!.muzzleVelocity;
          final timeOfFlight = distance / muzzleVelocity;
          final simpleDrop = 0.5 * 9.81 * timeOfFlight * timeOfFlight;
          trajectory.add(FlSpot(distance, simpleDrop));
          
          final sightLineHeight = visorHeight + (distance * losSlope);
          lineOfSight.add(FlSpot(distance, sightLineHeight));
        }
      }
    }

    // Ensure we have reasonable data
    if (trajectory.isEmpty) {
      // Emergency fallback
      final muzzleVelocity = _selectedGun?.muzzleVelocity ?? 800.0;
      for (int i = 0; i <= 100; i++) {
        final distance = i * step;
        final timeOfFlight = distance / muzzleVelocity;
        final simpleDrop = 0.5 * 9.81 * timeOfFlight * timeOfFlight;
        trajectory.add(FlSpot(distance, simpleDrop));
        lineOfSight.add(FlSpot(distance, visorHeight + (distance * losSlope)));
      }
    }

    // Find the min and max values for chart scaling with safety checks
    double maxDrop = trajectory.fold<double>(-double.infinity, (max, spot) => 
        spot.y.isFinite && spot.y > max ? spot.y : max);
    double minDrop = trajectory.fold<double>(double.infinity, (min, spot) => 
        spot.y.isFinite && spot.y < min ? spot.y : min);
    
    // Include line of sight in min/max calculation
    maxDrop = lineOfSight.fold<double>(maxDrop, (max, spot) => 
        spot.y.isFinite && spot.y > max ? spot.y : max);
    minDrop = lineOfSight.fold<double>(minDrop, (min, spot) => 
        spot.y.isFinite && spot.y < min ? spot.y : min);

    // Ensure we have reasonable bounds to prevent division by zero
    if (!maxDrop.isFinite || !minDrop.isFinite || maxDrop == minDrop) {
      maxDrop = 0.1;  // 10cm
      minDrop = -0.05; // -5cm (scope height)
    }

    // Ensure minimum range for grid intervals
    final range = maxDrop - minDrop;
    if (range < 0.01) { // Less than 1cm range
      final center = (maxDrop + minDrop) / 2;
      maxDrop = center + 0.01;
      minDrop = center - 0.01;
    }

    // Add padding to the chart
    final padding = (maxDrop - minDrop) * 0.1;
    maxDrop += padding;
    minDrop -= padding;

    setState(() {
      trajectorySpots = trajectory;
      lineOfSightSpots = lineOfSight;
      _maxDistance = maxCalcDistance;
      _maxDrop = maxDrop;
      _minDrop = minDrop;
    });

    // Debug information
    print('Chart bounds: minDrop=${minDrop.toStringAsFixed(4)}m, maxDrop=${maxDrop.toStringAsFixed(4)}m');
    print('Range: ${(maxDrop - minDrop).toStringAsFixed(4)}m');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ballistics Trajectory',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart),
            onPressed: _showTrajectoryTable,
            tooltip: 'Generate Trajectory Table',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : trajectorySpots.isEmpty
              ? const Center(
                  child: Text(
                    'Unable to calculate trajectory.\nPlease ensure all profiles are selected.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildChartHeader(),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 400,
                        child: _buildChart(),
                      ),
                      const SizedBox(height: 20),
                      _buildLegend(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildChartHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shot at ${widget.calculation.distance.toStringAsFixed(0)}m',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Wind: ${widget.calculation.windSpeed.toStringAsFixed(1)}m/s @ ${widget.calculation.windDirection.toStringAsFixed(0)}°',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Angle: ${widget.calculation.angle.toStringAsFixed(1)}° • Temperature: ${widget.calculation.temperature.toStringAsFixed(1)}°C',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (widget.calculation.driftHorizontal != null)
              Text(
                'Impact: ${(widget.calculation.dropVertical! * 100).toStringAsFixed(1)}cm drop, ${(widget.calculation.driftHorizontal! * 100).toStringAsFixed(1)}cm drift',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              // Ensure intervals are never zero
              horizontalInterval: (_maxDrop - _minDrop) > 0 ? (_maxDrop - _minDrop) / 10 : 0.01,
              verticalInterval: _maxDistance > 0 ? _maxDistance / 10 : 10,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.3),
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.3),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: (_maxDrop - _minDrop) > 0 ? (_maxDrop - _minDrop) / 5 : 0.02,
                  getTitlesWidget: (value, meta) {
                    final cmValue = value * 100;
                    return Text(
                      '${cmValue.toStringAsFixed(0)}cm',
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                  reservedSize: 50,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: _maxDistance > 0 ? _maxDistance / 5 : 20,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toStringAsFixed(0)}m',
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                  reservedSize: 30,
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
            ),
            minX: 0,
            maxX: _maxDistance,
            minY: _minDrop,
            maxY: _maxDrop,
            lineBarsData: [
              // Line of sight
              LineChartBarData(
                spots: lineOfSightSpots,
                isCurved: false,
                color: Colors.blue,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
              // Bullet trajectory
              LineChartBarData(
                spots: trajectorySpots,
                isCurved: true,
                color: Colors.red,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  checkToShowDot: (spot, barData) {
                    // Show dot at target distance
                    return (spot.x - widget.calculation.distance).abs() < _maxDistance * 0.01;
                  },
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: Colors.orange,
                      strokeWidth: 2,
                      strokeColor: Colors.red,
                    );
                  },
                ),
                belowBarData: BarAreaData(show: false),
              ),
            ],
            extraLinesData: ExtraLinesData(
              verticalLines: [
                // Target distance line
                VerticalLine(
                  x: widget.calculation.distance,
                  color: Colors.orange.withOpacity(0.7),
                  strokeWidth: 2,
                  dashArray: [5, 5],
                  label: VerticalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    labelResolver: (line) => 'Target\n${widget.calculation.distance.toStringAsFixed(0)}m',
                  ),
                ),
                // Only show zero range line if it's greater than 0
                if ((_selectedGun?.zeroRange ?? 0) > 0)
                  VerticalLine(
                    x: _selectedGun!.zeroRange,
                    color: Colors.green.withOpacity(0.6),
                    strokeWidth: 1,
                    dashArray: [3, 3],
                    label: VerticalLineLabel(
                      show: true,
                      alignment: Alignment.topLeft,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                      labelResolver: (line) => 'Zero\n${_selectedGun!.zeroRange.toStringAsFixed(0)}m',
                    ),
                  ),
              ],
              horizontalLines: [
                // Zero line (bore axis)
                HorizontalLine(
                  y: 0,
                  color: Colors.grey.withOpacity(0.8),
                  strokeWidth: 1,
                  dashArray: [3, 3],
                ),
              ],
            ),
            // ...existing other properties...
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Legend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 3,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(_buildLegendText()),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 3,
                  color: Colors.red,
                ),
                const SizedBox(width: 8),
                const Text('Bullet trajectory'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 3,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                const Text('Target distance'),
              ],
            ),
            if ((_selectedGun?.zeroRange ?? 0) > 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 3,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  const Text('Zero range'),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              _buildDescriptionText(),
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildLegendText() {
    final double visorHeight = (_selectedScope?.units == 0) 
        ? (_selectedScope?.sightHeight ?? 0) * 0.0254
        : (_selectedScope?.sightHeight ?? 0) * 0.01;
    final double zeroRange = _selectedGun?.zeroRange ?? 0;

    if (visorHeight == 0.0 && zeroRange == 0.0) {
      return 'Line of sight (bore axis)';
    } else if (zeroRange == 0.0) {
      return 'Line of sight (horizontal)';
    } else {
      return 'Line of sight (zeroed)';
    }
  }

  String _buildDescriptionText() {
    final double visorHeight = (_selectedScope?.units == 0) 
        ? (_selectedScope?.sightHeight ?? 0) * 0.0254
        : (_selectedScope?.sightHeight ?? 0) * 0.01;
    final double zeroRange = _selectedGun?.zeroRange ?? 0;

    String description = 'X-axis: Distance (m) • Y-axis: Height relative to bore (cm)\nPositive values = bullet drop below bore axis';
    
    if (visorHeight == 0.0 && zeroRange == 0.0) {
      description += '\nLine of sight coincides with bore axis';
    } else if (zeroRange == 0.0) {
      description += '\nLine of sight is horizontal at scope height';
    } else {
      description += '\nLine of sight intersects trajectory at zero range';
    }

    return description;
  }

  void _showTrajectoryTable() {
    showDialog(
      context: context,
      builder: (context) => TrajectoryTableDialog(
        calculation: widget.calculation,
        selectedGun: _selectedGun,
        selectedCartridge: _selectedCartridge,
        selectedScope: _selectedScope,
      ),
    );
  }
}
