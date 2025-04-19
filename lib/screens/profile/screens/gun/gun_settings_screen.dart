import 'package:flutter/material.dart';
import 'widgets/twist_rate_input.dart';
import 'widgets/muzzle_velocity_input.dart';
import 'widgets/zero_range_input.dart';

class GunSettingsScreen extends StatefulWidget {
  const GunSettingsScreen({Key? key}) : super(key: key);

  @override
  State<GunSettingsScreen> createState() => _GunSettingsScreenState();
}

class _GunSettingsScreenState extends State<GunSettingsScreen> {
  late TextEditingController _twistRateController;
  double _twistRate = 10.0; // Default value for twist rate (1:10)
  
  late TextEditingController _muzzleVelocityController;
  double _muzzleVelocity = 800.0; // Default value for muzzle velocity (800 m/s)
  
  late TextEditingController _zeroRangeController;
  double _zeroRange = 100.0; // Default value for zero range (100 m)

  @override
  void initState() {
    super.initState();
    _twistRateController = TextEditingController(text: _twistRate.toStringAsFixed(1));
    _muzzleVelocityController = TextEditingController(text: _muzzleVelocity.toStringAsFixed(0));
    _zeroRangeController = TextEditingController(text: _zeroRange.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _twistRateController.dispose();
    _muzzleVelocityController.dispose();
    _zeroRangeController.dispose();
    super.dispose();
  }

  void _updateTwistRate(double delta) {
    setState(() {
      _twistRate += delta;
      if (_twistRate < 0) _twistRate = 0;
      _twistRateController.text = _twistRate.toStringAsFixed(1);
    });
  }
  
  void _updateMuzzleVelocity(double delta) {
    setState(() {
      _muzzleVelocity += delta;
      if (_muzzleVelocity < 0) _muzzleVelocity = 0;
      _muzzleVelocityController.text = _muzzleVelocity.toStringAsFixed(0);
    });
  }
  
  void _updateZeroRange(double delta) {
    setState(() {
      _zeroRange += delta;
      if (_zeroRange < 0) _zeroRange = 0;
      _zeroRangeController.text = _zeroRange.toStringAsFixed(0);
    });
  }

  void _saveAndNavigateBack() {
    // Here you would save any changes to persistent storage if needed
    
    // Show feedback to user
    final snackBar = SnackBar(
      content: const Text('Gun settings saved!'),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(left: 16.0, right: 16.0),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    
    // Navigate back to the ProfileScreen
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "Gun Settings",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: true,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  MuzzleVelocityInput(
                    controller: _muzzleVelocityController,
                    onUpdateMuzzleVelocity: _updateMuzzleVelocity,
                  ),
                  const SizedBox(height: 16),
                  ZeroRangeInput(
                    controller: _zeroRangeController,
                    onUpdateZeroRange: _updateZeroRange,
                  ),
                  const SizedBox(height: 16),
                  TwistRateInput(
                    controller: _twistRateController,
                    onUpdateTwistRate: _updateTwistRate,
                  ),
                  const SizedBox(height: 24),
                  // Additional settings can be added here
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 0.0, right: 7.0),
        child: FloatingActionButton(
          onPressed: _saveAndNavigateBack,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
          child: Icon(Icons.save, color: Theme.of(context).scaffoldBackgroundColor),
        ),
      ),
    );
  }
}
