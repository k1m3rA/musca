import 'package:flutter/material.dart';
import 'screens/cartridge_settings_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../services/cartridge_storage.dart';
import '../../../../models/cartridge_model.dart'; // Import the Cartridge model

class ListCartridgeScreen extends StatefulWidget {
  final Cartridge? selectedCartridge;
  
  const ListCartridgeScreen({Key? key, this.selectedCartridge}) : super(key: key);

  @override
  State<ListCartridgeScreen> createState() => _ListCartridgeScreenState();
}

class _ListCartridgeScreenState extends State<ListCartridgeScreen> {
  List<Cartridge> cartridges = [];
  int? _selectedIndex;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartridges();
  }
  
  Future<void> _loadCartridges() async {
    setState(() {
      _isLoading = true;
    });
    
    final loadedCartridges = await CartridgeStorage.getCartridges();
    
    setState(() {
      cartridges = loadedCartridges;
      _isLoading = false;
      
      // If we have a pre-selected cartridge, find and select it
      if (widget.selectedCartridge != null) {
        for (int i = 0; i < cartridges.length; i++) {
          if (cartridges[i].id == widget.selectedCartridge!.id) {
            _selectedIndex = i;
            break;
          }
        }
      }
    });
  }

  void _selectCartridge(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _confirmSelection() {
    if (_selectedIndex != null) {
      // Return the selected cartridge to the previous screen
      Navigator.of(context).pop(cartridges[_selectedIndex!]);
    }
  }

  void _addNewCartridge() async {
    final Cartridge? newCartridge = await Navigator.push<Cartridge>(
      context,
      MaterialPageRoute(
        builder: (context) => const CartridgeSettingsScreen(),
      ),
    );
    
    // If a cartridge was returned, add it to the list and save
    if (newCartridge != null) {
      setState(() {
        cartridges.add(newCartridge);
      });
      // Save the updated list
      await CartridgeStorage.saveCartridges(cartridges);
    }
  }

  void _editSelectedCartridge() {
    if (_selectedIndex != null) {
      Navigator.push<Cartridge>(
        context,
        MaterialPageRoute(
          builder: (context) => CartridgeSettingsScreen(cartridge: cartridges[_selectedIndex!]),
        ),
      ).then((updatedCartridge) async {
        if (updatedCartridge != null) {
          setState(() {
            cartridges[_selectedIndex!] = updatedCartridge;
          });
          // Save the updated list
          await CartridgeStorage.saveCartridges(cartridges);
        }
      });
    }
  }
  
  void _deleteSelectedCartridge() async {
    if (_selectedIndex != null) {
      final cartridgeToDelete = cartridges[_selectedIndex!];
      
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Cartridge'),
          content: Text('Are you sure you want to delete ${cartridgeToDelete.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ) ?? false;
      
      if (confirmed) {
        setState(() {
          cartridges.removeAt(_selectedIndex!);
          _selectedIndex = null;
        });
        
        // Save the updated list
        await CartridgeStorage.saveCartridges(cartridges);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while fetching cartridges
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
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
                "Your Cartridges",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          cartridges.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _addNewCartridge,
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icon/bullet.svg',
                                    height: 110,
                                    width: 110,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Add first Cartridge',
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
                          'No cartridges added yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverFillRemaining(
                  hasScrollBody: true,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 0),
                    child: ListView.builder(
                      itemCount: cartridges.length + 1, // Add 1 for the "Add" button
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Add New Cartridge button at the beginning
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: GestureDetector(
                              onTap: _addNewCartridge,
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: Container(
                                  height: 100, 
                                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        size: 40,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        'Add New Cartridge',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        // Adjust the index for the cartridge list (subtract 1 because of the Add button)
                        final cartridgeIndex = index - 1;
                        final isSelected = _selectedIndex == cartridgeIndex;
                        final cartridge = cartridges[cartridgeIndex];
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: GestureDetector(
                            onTap: () => _selectCartridge(cartridgeIndex),
                            child: Card(
                              elevation: 4,
                              color: isSelected 
                                ? Theme.of(context).colorScheme.primary 
                                : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cartridge.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isSelected 
                                                ? Theme.of(context).colorScheme.background
                                                : Theme.of(context).colorScheme.primary,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Diameter: ${cartridge.diameter} in · Weight: ${cartridge.bulletWeight} gr',
                                                style: TextStyle(
                                                  color: isSelected
                                                    ? Theme.of(context).colorScheme.background.withOpacity(0.8)
                                                    : null,
                                                ),
                                              ),
                                              Text(
                                                'Length: ${cartridge.bulletLength.toStringAsFixed(3)} in · BC: ${cartridge.ballisticCoefficient.toStringAsFixed(3)} ${cartridge.bcModelType == 0 ? "G1" : "G7"}',
                                                style: TextStyle(
                                                  color: isSelected
                                                    ? Theme.of(context).colorScheme.background.withOpacity(0.8)
                                                    : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: _selectedIndex != null 
        ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(width: 30), // Push the buttons to the right
              Material(
                color: Colors.transparent,
                elevation: 10.0,
                borderRadius: BorderRadius.circular(30),
                shadowColor: Colors.black.withOpacity(1),
                child: FloatingActionButton(
                  heroTag: "delete_button",
                  onPressed: _deleteSelectedCartridge,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  child: Icon(Icons.delete, color: Theme.of(context).scaffoldBackgroundColor)
                ),
              ),
              const SizedBox(width: 16),
              Material(
                color: Colors.transparent,
                elevation: 10.0,
                borderRadius: BorderRadius.circular(30),
                shadowColor: Colors.black.withOpacity(1),
                child: FloatingActionButton(
                  heroTag: "edit_button",
                  onPressed: _editSelectedCartridge,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  child: Icon(Icons.edit, color: Theme.of(context).scaffoldBackgroundColor)
                ),
              ),
              const SizedBox(width: 16),
              Material(
                color: Colors.transparent,
                elevation: 10.0,
                borderRadius: BorderRadius.circular(30),
                shadowColor: Colors.black.withOpacity(1),
                child: FloatingActionButton(
                  heroTag: "select_button",
                  onPressed: _confirmSelection,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  child: Icon(Icons.check, color: Theme.of(context).scaffoldBackgroundColor)
                ),
              ),
            ],
          )
        : null,
    );
  }
}
