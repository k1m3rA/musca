import 'package:flutter/material.dart';
import 'widgets/twist_rate_input.dart';
import 'widgets/muzzle_velocity_input.dart';
import 'widgets/zero_range_input.dart';
import 'widgets/name_input.dart';
import '../../../../../models/gun_model.dart'; // Import the new Gun model

class GunSettingsScreen extends StatefulWidget {
  final Gun? gun; // Now uses the proper Gun model
  
  const GunSettingsScreen({Key? key, this.gun}) : super(key: key);

  @override
  State<GunSettingsScreen> createState() => _GunSettingsScreenState();
}

class _GunSettingsScreenState extends State<GunSettingsScreen> {
  late TextEditingController _nameController;
  late String _name;

  late TextEditingController _twistRateController;
  late double _twistRate;
  late int _twistDirection;
  
  late TextEditingController _muzzleVelocityController;
  late double _muzzleVelocity;
  
  late TextEditingController _zeroRangeController;
  late double _zeroRange;
  
  String? _gunId;

  @override
  void initState() {
    super.initState();
    
    // Initialize values based on whether we're editing an existing gun
    if (widget.gun != null) {
      _gunId = widget.gun!.id;
      _name = widget.gun!.name;
      _twistRate = widget.gun!.twistRate;
      _twistDirection = widget.gun!.twistDirection;
      _muzzleVelocity = widget.gun!.muzzleVelocity;
      _zeroRange = widget.gun!.zeroRange;
    } else {
      // Default values for new gun
      _name = "My Gun";
      _twistRate = 10.0;
      _muzzleVelocity = 800.0;
      _zeroRange = 100.0;
      _twistDirection = 1; // Default to right twist
    }
    
    _nameController = TextEditingController(text: _name);
    _twistRateController = TextEditingController(text: _twistRate.toStringAsFixed(1));
    _muzzleVelocityController = TextEditingController(text: _muzzleVelocity.toStringAsFixed(0));
    _zeroRangeController = TextEditingController(text: _zeroRange.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _twistRateController.dispose();
    _muzzleVelocityController.dispose();
    _zeroRangeController.dispose();
    super.dispose();
  }

  void _updateName(String newName) {
    setState(() {
      _name = newName;
    });
  }

  void _updateTwistRate(double delta) {
    setState(() {
      _twistRate += delta;
      if (_twistRate < 0) _twistRate = 0;
      _twistRateController.text = _twistRate.toStringAsFixed(1);
    });
  }
  
  void _updateTwistDirection(int direction) {
    setState(() {
      _twistDirection = direction;
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
    // Create a Gun object with the current values using the new model
    final gun = Gun(
      id: _gunId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name,
      twistRate: _twistRate,
      twistDirection: _twistDirection,
      muzzleVelocity: _muzzleVelocity,
      zeroRange: _zeroRange,
    );
    
    // Show feedback to user
    final snackBar = SnackBar(
      content: Text(widget.gun != null ? 'Gun updated!' : 'Gun created!'),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(
        left: 20, 
        bottom: 20.0,
        right: 20.0,
      ),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    
    // Return the gun to the previous screen
    Navigator.of(context).pop(gun);
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
                widget.gun != null ? "Edit Gun" : "Gun Settings",
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
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  const SizedBox(height: 10),
                  NameInput(
                    controller: _nameController,
                    onUpdateName: _updateName,
                  ),
                  const SizedBox(height: 16),
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
                    initialTwistDirection: _twistDirection,
                    onUpdateTwistDirection: _updateTwistDirection,
                  ),
                  const SizedBox(height: 24),
                  // Additional settings can be added here
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Material(
        color: Colors.transparent,
        elevation: 10.0,
        borderRadius: BorderRadius.circular(30),
        shadowColor: Colors.black.withOpacity(1),
        child: FloatingActionButton(
          onPressed: _saveAndNavigateBack,
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          child: Icon(Icons.save, color: Theme.of(context).scaffoldBackgroundColor)
        ),
      ),
    );
  }
}
