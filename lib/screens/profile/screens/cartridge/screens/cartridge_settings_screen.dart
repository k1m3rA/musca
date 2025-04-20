import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../../models/cartridge_model.dart'; // Import the proper Cartridge model

class CartridgeSettingsScreen extends StatefulWidget {
  final Cartridge? cartridge;
  
  const CartridgeSettingsScreen({Key? key, this.cartridge}) : super(key: key);

  @override
  State<CartridgeSettingsScreen> createState() => _CartridgeSettingsScreenState();
}

class _CartridgeSettingsScreenState extends State<CartridgeSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _caliberController;
  late TextEditingController _bulletWeightController;
  late TextEditingController _muzzleVelocityController;
  late TextEditingController _ballisticCoefficientController;
  
  late String _name;
  late String _caliber;
  late double _bulletWeight;
  late double _muzzleVelocity;
  late double _ballisticCoefficient;
  
  String? _cartridgeId;

  @override
  void initState() {
    super.initState();
    
    // Initialize values based on whether we're editing an existing cartridge
    if (widget.cartridge != null) {
      _cartridgeId = widget.cartridge!.id;
      _name = widget.cartridge!.name;
      _caliber = widget.cartridge!.caliber;
      _bulletWeight = widget.cartridge!.bulletWeight;
      _muzzleVelocity = widget.cartridge!.muzzleVelocity;
      _ballisticCoefficient = widget.cartridge!.ballisticCoefficient;
    } else {
      // Default values for new cartridge
      _name = "My Cartridge";
      _caliber = ".308";
      _bulletWeight = 168.0;
      _muzzleVelocity = 2700.0;
      _ballisticCoefficient = 0.5;
    }
    
    _nameController = TextEditingController(text: _name);
    _caliberController = TextEditingController(text: _caliber);
    _bulletWeightController = TextEditingController(text: _bulletWeight.toStringAsFixed(1));
    _muzzleVelocityController = TextEditingController(text: _muzzleVelocity.toStringAsFixed(0));
    _ballisticCoefficientController = TextEditingController(text: _ballisticCoefficient.toStringAsFixed(3));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caliberController.dispose();
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

  void _updateCaliber(String value) {
    setState(() {
      _caliber = value;
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
  
  void _updateBallisticCoefficient(String value) {
    final bc = double.tryParse(value);
    if (bc != null) {
      setState(() {
        _ballisticCoefficient = bc;
      });
    }
  }

  void _saveAndNavigateBack() {
    // Create a Cartridge object with the current values
    final cartridge = Cartridge(
      id: _cartridgeId ?? Uuid().v4(),
      name: _name,
      caliber: _caliber,
      bulletWeight: _bulletWeight,
      muzzleVelocity: _muzzleVelocity,
      ballisticCoefficient: _ballisticCoefficient,
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
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cartridge Name',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nameController,
                            onChanged: _updateName,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter cartridge name',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Caliber Input
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Caliber',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _caliberController,
                            onChanged: _updateCaliber,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter caliber (e.g., .308, 6.5mm)',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Bullet Weight Input
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bullet Weight (grains)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _bulletWeightController,
                            onChanged: _updateBulletWeight,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter bullet weight',
                              suffixText: 'grains',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Muzzle Velocity Input
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Muzzle Velocity (fps)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _muzzleVelocityController,
                            onChanged: _updateMuzzleVelocity,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter muzzle velocity',
                              suffixText: 'fps',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Ballistic Coefficient Input
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ballistic Coefficient',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _ballisticCoefficientController,
                            onChanged: _updateBallisticCoefficient,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter ballistic coefficient',
                            ),
                          ),
                        ],
                      ),
                    ),
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
