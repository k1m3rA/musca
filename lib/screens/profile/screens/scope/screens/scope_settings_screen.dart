import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../../models/scope_model.dart';
import 'widgets/name_input.dart';
import 'widgets/sight_height_input.dart';
import 'widgets/units_input.dart';

class ScopeSettingsScreen extends StatefulWidget {
  final Scope? scope;
  
  const ScopeSettingsScreen({Key? key, this.scope}) : super(key: key);

  @override
  State<ScopeSettingsScreen> createState() => _ScopeSettingsScreenState();
}

class _ScopeSettingsScreenState extends State<ScopeSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _sightHeightController;
  
  late String _name;
  late double _sightHeight;
  late String _units; // Using string identifiers in the UI
  
  String? _scopeId;
  
  // Helper methods to convert between string unit IDs and integer values
  String _unitIntToString(int unitInt) {
    switch(unitInt) {
      case 0: return 'in';
      case 1: return 'cm';
      case 2: return 'moa';
      case 3: return 'moa_2';
      case 4: return 'moa_3';
      case 5: return 'moa_4';
      case 6: return 'moa_8';
      case 7: return 'mrad';
      case 8: return 'mrad_10';
      case 9: return 'mrad_20';
      default: return 'moa'; // Default to MOA
    }
  }
  
  int _unitStringToInt(String unitString) {
    switch(unitString) {
      case 'in': return 0;
      case 'cm': return 1;
      case 'moa': return 2;
      case 'moa_2': return 3;
      case 'moa_3': return 4;
      case 'moa_4': return 5;
      case 'moa_8': return 6;
      case 'mrad': return 7;
      case 'mrad_10': return 8;
      case 'mrad_20': return 9;
      default: return 2; // Default to MOA
    }
  }

  @override
  void initState() {
    super.initState();
    
    // Initialize values based on whether we're editing an existing scope
    if (widget.scope != null) {
      _scopeId = widget.scope!.id;
      _name = widget.scope!.name;
      _sightHeight = widget.scope!.sightHeight;
      _units = _unitIntToString(widget.scope!.units); // Convert int to string
    } else {
      // Default values for new scope
      _name = "My Scope";
      _sightHeight = 1.5;  // Default sight height (inches)
      _units = "moa";  // Default to MOA
    }
    
    _nameController = TextEditingController(text: _name);
    _sightHeightController = TextEditingController(text: _sightHeight.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sightHeightController.dispose();
    super.dispose();
  }

  void _updateName(String value) {
    setState(() {
      _name = value;
    });
  }
  
  void _updateSightHeightDelta(double delta) {
    final currentHeight = double.tryParse(_sightHeightController.text) ?? _sightHeight;
    final newHeight = (currentHeight + delta).clamp(0.1, 10.0);  // Reasonable range for sight height
    setState(() {
      _sightHeight = newHeight;
      _sightHeightController.text = newHeight.toStringAsFixed(2);
    });
  }
  
  void _updateUnits(String units) {
    setState(() {
      _units = units;
    });
  }

  void _saveAndNavigateBack() {
    // Create a Scope object with the current values
    final scope = Scope(
      id: _scopeId ?? const Uuid().v4(),
      name: _name,
      sightHeight: _sightHeight,
      units: _unitStringToInt(_units), // Convert string to int for the model
    );
    
    // Show feedback to user
    final snackBar = SnackBar(
      content: Text(widget.scope != null ? 'Scope updated!' : 'Scope created!'),
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
    
    // Return the scope to the previous screen
    Navigator.of(context).pop(scope);
  }

  @override
  Widget build(BuildContext context) {
    // Determine units label for sight height
    String unitsLabel;
    if (_units == "in") {
      unitsLabel = "in";
    } else if (_units == "cm") {
      unitsLabel = "cm";
    } else {
      unitsLabel = "in"; // Default to inches for sight height
    }

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
                widget.scope != null ? "Edit Scope" : "New Scope",
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
                  
                  // Units Input
                  UnitsInput(
                    initialUnit: _units,
                    onUpdateUnits: _updateUnits,
                  ),
                  const SizedBox(height: 16),
                  
                  // Sight Height Input
                  SightHeightInput(
                    controller: _sightHeightController,
                    onUpdateSightHeight: _updateSightHeightDelta,
                    units: unitsLabel,
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
