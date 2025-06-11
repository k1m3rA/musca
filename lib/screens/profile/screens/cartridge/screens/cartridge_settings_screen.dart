import 'package:flutter/material.dart';
import 'package:musca/screens/profile/screens/cartridge/screens/widgets/length_input.dart';
import 'package:uuid/uuid.dart';
import '../../../../../models/cartridge_model.dart'; // Import the proper Cartridge model
import '../../../../../services/cartridge_storage.dart'; // Import the cartridge storage service
import 'widgets/bc_input.dart'; // Import the BC input widget
import 'widgets/name_input.dart'; // Import the name input widget
import 'widgets/diameter_input.dart'; // Import the diameter input widget
import 'widgets/weight_input.dart'; // Import the weight input widget

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
  late TextEditingController _bulletLengthController;
  late TextEditingController _ballisticCoefficientController;
  
  late String _name;
  late String _diameter;
  late double _bulletWeight;
  late String _bulletLength;
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
      _bulletLength = widget.cartridge!.bulletLength.toStringAsFixed(3);
      _ballisticCoefficient = widget.cartridge!.ballisticCoefficient;
      _bcModelType = widget.cartridge!.bcModelType ?? 0; // Default to G1 if not specified
    } else {
      // Default values for new cartridge
      _name = "My Cartridge";
      _diameter = "0.356";
      _bulletWeight = 168.0;
      _bulletLength = "3.550";
      _ballisticCoefficient = 0.5;
      _bcModelType = 0; // Default to G1
    }
      _nameController = TextEditingController(text: _name);
    _diameterController = TextEditingController(text: _diameter);
    _bulletWeightController = TextEditingController(text: _bulletWeight.toStringAsFixed(1));
    _bulletLengthController = TextEditingController(text: _bulletLength);
    _ballisticCoefficientController = TextEditingController(text: _ballisticCoefficient.toStringAsFixed(3));
    
    // Add listeners for text fields
    _nameController.addListener(_updateNameFromText);
    _diameterController.addListener(_updateDiameterFromText);
    _bulletWeightController.addListener(_updateBulletWeightFromText);
    _bulletLengthController.addListener(_updateBulletLengthFromText);
    _ballisticCoefficientController.addListener(_updateBallisticCoefficientFromText);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _diameterController.dispose();
    _bulletWeightController.dispose();
    _bulletLengthController.dispose();
    _ballisticCoefficientController.dispose();
    super.dispose();
  }
  void _updateName(String value) {
    setState(() {
      _name = value;
    });
  }

  void _updateNameFromText() {
    if (_nameController.text.isNotEmpty) {
      setState(() {
        _name = _nameController.text;
      });
    }
  }

  void _updateDiameterFromText() {
    if (_diameterController.text.isNotEmpty) {
      setState(() {
        _diameter = _diameterController.text;
      });
    }
  }

  void _updateBulletWeightFromText() {
    if (_bulletWeightController.text.isNotEmpty) {
      try {
        final newValue = double.parse(_bulletWeightController.text);
        setState(() {
          _bulletWeight = newValue.clamp(1.0, 1000.0);
        });
      } catch (_) {}
    }
  }

  void _updateBulletLengthFromText() {
    if (_bulletLengthController.text.isNotEmpty) {
      setState(() {
        _bulletLength = _bulletLengthController.text;
      });
    }
  }

  void _updateBallisticCoefficientFromText() {
    if (_ballisticCoefficientController.text.isNotEmpty) {
      try {
        final newValue = double.parse(_ballisticCoefficientController.text);
        setState(() {
          _ballisticCoefficient = newValue.clamp(0.1, 2.0);
        });
      } catch (_) {}
    }
  }

  
  // Add method to handle weight delta updates
  void _updateBulletWeightDelta(double delta) {
    final currentWeight = double.tryParse(_bulletWeightController.text) ?? _bulletWeight;
    final newWeight = (currentWeight + delta).clamp(1.0, 1000.0); // Reasonable range for bullet weights
    setState(() {
      _bulletWeight = newWeight;
      _bulletWeightController.text = newWeight.toStringAsFixed(1);
    });
  }

  void _updateBulletLengthDelta(double delta) {
    double currentValue;
    try {
      // Try to parse the controller text first
      currentValue = double.tryParse(_bulletLengthController.text) ?? 0.356;
    } catch (e) {
      // Fallback to a default value if parsing fails
      currentValue = 0.356;
    }
    
    final newValue = (currentValue + delta).clamp(0.01, 20.0); // Reasonable range for bullet diameters in cm
    setState(() {
      _bulletLength = newValue.toStringAsFixed(3);
      _bulletLengthController.text = _bulletLength;
    });
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
  void _saveAndNavigateBack() async {
    // Create a Cartridge object with the current values
    final cartridge = Cartridge(
      id: _cartridgeId ?? Uuid().v4(),
      name: _name,
      diameter: _diameter,
      bulletWeight: _bulletWeight,
      bulletLength: double.parse(_bulletLength),
      ballisticCoefficient: _ballisticCoefficient,
      bcModelType: _bcModelType,
    );
    
    // Save the cartridge to permanent storage
    await CartridgeStorage.saveCartridge(cartridge);
    
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
                  
                  // Diameter Input - using our updated DiameterInput widget
                  LengthInput(
                    controller: _bulletLengthController,
                    scrollStep: 0.001,
                    onUpdateLength: _updateBulletLengthDelta,
                  ),
                  const SizedBox(height: 16),

                  // Replace TextField with WeightInput widget
                  WeightInput(
                    controller: _bulletWeightController,
                    scrollStep: 0.5,
                    onUpdateWeight: _updateBulletWeightDelta,
                  ),
                  const SizedBox(height: 16),
                  
                  // Ballistic Coefficient Input
                  BCTypeInput(
                    controller: _ballisticCoefficientController,
                    scrollStep: 0.001,
                    onUpdateBCType: _updateBCModelType, // Fix this parameter
                    initialBCType: _bcModelType,
                    onUpdateBCValue: _updateBCDelta, // Fix this parameter
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
