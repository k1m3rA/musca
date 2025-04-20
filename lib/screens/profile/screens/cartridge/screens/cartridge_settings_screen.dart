import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../../models/cartridge_model.dart'; // Import the proper Cartridge model
import 'widgets/bc_input.dart'; // Import the BC input widget
import 'widgets/name_input.dart'; // Import the name input widget
import 'widgets/diameter_input.dart'; // Import the diameter input widget

class CartridgeSettingsScreen extends StatefulWidget {
  final Cartridge? cartridge;
  
  const CartridgeSettingsScreen({Key? key, this.cartridge}) : super(key: key);

  @override
  State<CartridgeSettingsScreen> createState() => _CartridgeSettingsScreenState();
}

class _CartridgeSettingsScreenState extends State<CartridgeSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _diameterController;
  late TextEditingController _bulletWeightController;
  late TextEditingController _muzzleVelocityController;
  late TextEditingController _ballisticCoefficientController;
  
  late String _name;
  late String _diameter;
  late double _bulletWeight;
  late double _muzzleVelocity;
  late double _ballisticCoefficient;
  late int _bcModelType; // 0 for G1, 1 for G7
  
  String? _cartridgeId;

  @override
  void initState() {
    super.initState();
    
    // Initialize values based on whether we're editing an existing cartridge
    if (widget.cartridge != null) {
      _cartridgeId = widget.cartridge!.id;
      _name = widget.cartridge!.name;
      _diameter = widget.cartridge!.diameter;
      _bulletWeight = widget.cartridge!.bulletWeight;
      _muzzleVelocity = widget.cartridge!.muzzleVelocity;
      _ballisticCoefficient = widget.cartridge!.ballisticCoefficient;
      _bcModelType = widget.cartridge!.bcModelType ?? 0; // Default to G1 if not specified
    } else {
      // Default values for new cartridge
      _name = "My Cartridge";
      _diameter = "0.356";
      _bulletWeight = 168.0;
      _muzzleVelocity = 2700.0;
      _ballisticCoefficient = 0.5;
      _bcModelType = 0; // Default to G1
    }
    
    _nameController = TextEditingController(text: _name);
    _diameterController = TextEditingController(text: _diameter);
    _bulletWeightController = TextEditingController(text: _bulletWeight.toStringAsFixed(1));
    _muzzleVelocityController = TextEditingController(text: _muzzleVelocity.toStringAsFixed(0));
    _ballisticCoefficientController = TextEditingController(text: _ballisticCoefficient.toStringAsFixed(3));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _diameterController.dispose();
    _bulletWeightController.dispose();
    _muzzleVelocityController.dispose();
    _ballisticCoefficientController.dispose();
    super.dispose();
  }

  void _updateName(String value) {
    setState(() {
      _name = value;
    });
  }

  void _updateBulletWeight(String value) {
    final weight = double.tryParse(value);
    if (weight != null) {
      setState(() {
        _bulletWeight = weight;
      });
    }
  }
  
  void _updateMuzzleVelocity(String value) {
    final velocity = double.tryParse(value);
    if (velocity != null) {
      setState(() {
        _muzzleVelocity = velocity;
      });
    }
  }
    
  void _updateBCDelta(double delta) {
    final currentValue = double.tryParse(_ballisticCoefficientController.text) ?? _ballisticCoefficient;
    final newValue = (currentValue + delta).clamp(0.001, 1.0);
    setState(() {
      _ballisticCoefficient = newValue;
      _ballisticCoefficientController.text = newValue.toStringAsFixed(3);
    });
  }
  
  void _updateBCModelType(int modelType) {
    setState(() {
      _bcModelType = modelType;
    });
  }

  void _updateDiameterDelta(double delta) {
    double currentValue;
    try {
      // Try to parse the controller text first
      currentValue = double.tryParse(_diameterController.text) ?? 0.356;
    } catch (e) {
      // Fallback to a default value if parsing fails
      currentValue = 0.356;
    }
    
    final newValue = (currentValue + delta).clamp(0.01, 20.0); // Reasonable range for bullet diameters in cm
    setState(() {
      _diameter = newValue.toStringAsFixed(3);
      _diameterController.text = _diameter;
    });
  }

  void _saveAndNavigateBack() {
    // Create a Cartridge object with the current values
    final cartridge = Cartridge(
      id: _cartridgeId ?? Uuid().v4(),
      name: _name,
      diameter: _diameter,
      bulletWeight: _bulletWeight,
      muzzleVelocity: _muzzleVelocity,
      ballisticCoefficient: _ballisticCoefficient,
      bcModelType: _bcModelType,
    );
    
    // Show feedback to user
    final snackBar = SnackBar(
      content: Text(widget.cartridge != null ? 'Cartridge updated!' : 'Cartridge created!'),
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
    
    // Return the cartridge to the previous screen
    Navigator.of(context).pop(cartridge);
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
                widget.cartridge != null ? "Edit Cartridge" : "New Cartridge",
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
                  
                  // Name Input
                  NameInput(
                    controller: _nameController,
                    onUpdateName: _updateName,
                  ),
                  const SizedBox(height: 16),
                  
                  // Diameter Input - using our updated DiameterInput widget
                  DiameterInput(
                    controller: _diameterController,
                    scrollStep: 0.001,
                    onUpdateDiameter: _updateDiameterDelta,
                  ),
                  const SizedBox(height: 16),
                  
                  // Bullet Weight Input
                  TextField(
                    controller: _bulletWeightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Bullet Weight',
                      border: OutlineInputBorder(),
                      suffixText: 'gr',
                    ),
                    onChanged: _updateBulletWeight,
                  ),
                  const SizedBox(height: 16),
                  
                  // Muzzle Velocity Input
                  TextField(
                    controller: _muzzleVelocityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Muzzle Velocity',
                      border: OutlineInputBorder(),
                      suffixText: 'fps',
                    ),
                    onChanged: _updateMuzzleVelocity,
                  ),
                  const SizedBox(height: 16),
                  
                  // Ballistic Coefficient Input
                  BCTypeInput(
                    controller: _ballisticCoefficientController,
                    scrollStep: 0.001,
                    onUpdateBCType: (int value) => _updateBCDelta(value.toDouble()),
                    initialBCType: _bcModelType,
                    onUpdateBCValue: (double value) => _updateBCModelType(value.toInt()),
                  ),
                  
                  const SizedBox(height: 24),
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
