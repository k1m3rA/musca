import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/calculation.dart';
import '../../../services/ballistics_calculator.dart';
import '../../../services/gun_storage.dart';
import '../../../services/cartridge_storage.dart';
import '../../../services/scope_storage.dart';
import '../../../models/gun_model.dart';
import '../../../models/cartridge_model.dart';
import '../../../models/scope_model.dart';

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

    for (int i = 0; i <= 100; i++) {
      final distance = i * step;
      
      if (distance == 0) {
        // At muzzle: bullet is at bore height, sight line is at sight height
        trajectory.add(FlSpot(0, 0));
        lineOfSight.add(FlSpot(0, visorHeight));
        continue;
      }

      try {
        // Calculate ballistics for this distance
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

        // Bullet trajectory point (relative to bore axis)
        final bulletDrop = -result.dropVertical; // Negative because drop is downward
        trajectory.add(FlSpot(distance, bulletDrop));

        // Line of sight calculation
        // At zero range, line of sight and bullet trajectory intersect
        // Line of sight drops by scope height over zero range, then continues linearly
        final sightLineDrop = visorHeight - (visorHeight * distance / zeroRange);
        lineOfSight.add(FlSpot(distance, sightLineDrop));

      } catch (e) {
        print('Error calculating ballistics at distance $distance: $e');
      }
    }

    // Find the min and max values for chart scaling
    double maxDrop = trajectory.fold<double>(0, (max, spot) => spot.y > max ? spot.y : max);
    double minDrop = trajectory.fold<double>(0, (min, spot) => spot.y < min ? spot.y : min);
    
    // Include line of sight in min/max calculation
    maxDrop = lineOfSight.fold<double>(maxDrop, (max, spot) => spot.y > max ? spot.y : max);
    minDrop = lineOfSight.fold<double>(minDrop, (min, spot) => spot.y < min ? spot.y : min);

    // Add some padding to the chart
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
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChartHeader(),
                      const SizedBox(height: 20),
                      Expanded(
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
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: (_maxDrop - _minDrop) / 10,
              verticalInterval: _maxDistance / 10,
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
                  interval: (_maxDrop - _minDrop) / 5,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${(value * 100).toStringAsFixed(0)}cm',
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                  reservedSize: 50,
                ),
                axisNameWidget: const RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    'Height (cm)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: _maxDistance / 5,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toStringAsFixed(0)}m',
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                  reservedSize: 30,
                ),
                axisNameWidget: const Text(
                  'Distance (m)',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
              ],
              horizontalLines: [
                // Zero line
                HorizontalLine(
                  y: 0,
                  color: Colors.grey.withOpacity(0.8),
                  strokeWidth: 1,
                  dashArray: [3, 3],
                ),
              ],
            ),
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
                const Text('Line of sight'),
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
          ],
        ),
      ),
    );
  }
}
