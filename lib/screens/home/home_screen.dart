import 'package:flutter/material.dart';
import '../../models/calculation.dart';
import '../../services/calculation_storage.dart';
import 'package:intl/intl.dart';

// Main widget - kept for backwards compatibility
class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.onThemeChanged,
  });

  final String title;
  final Function(ThemeMode) onThemeChanged;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return HomeContent(title: widget.title);
  }
}

// New widget for just the content
class HomeContent extends StatefulWidget {
  final String title;
  
  const HomeContent({
    super.key,
    required this.title,
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadCalculations,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(widget.title),
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
                          Icon(
                            Icons.calculate_outlined, 
                            size: 64, 
                            color: Colors.grey[400]
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No saved calculations yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Go to the calculator to create one',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final calculation = _calculations[index];
                        return CalculationCard(calculation: calculation);
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

class CalculationCard extends StatelessWidget {
  final Calculation calculation;
  
  const CalculationCard({
    super.key,
    required this.calculation,
  });
  
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Card(
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
                  'Calculation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dateFormat.format(calculation.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const Divider(),
            _buildDataRow(context, 'Distance', '${calculation.distance.toStringAsFixed(1)} m'),
            _buildDataRow(context, 'Angle', '${calculation.angle.toStringAsFixed(1)}°'),
            _buildDataRow(context, 'Wind Speed', '${calculation.windSpeed.toStringAsFixed(1)} m/s'),
            _buildDataRow(context, 'Wind Direction', '${calculation.windDirection.toStringAsFixed(1)}°'),
          ],
        ),
      ),
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