import 'package:flutter/material.dart';
import 'screens/gun_settings_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../services/calculation_storage.dart'; // Import the storage service

class Gun {
  final String id;
  final String name;
  final String description;

  Gun({required this.id, required this.name, this.description = ''});
  
  // Add serialization methods
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
  
  factory Gun.fromJson(Map<String, dynamic> json) {
    return Gun(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
    );
  }
}

class ListGunsScreen extends StatefulWidget {
  final Gun? selectedGun;
  
  const ListGunsScreen({Key? key, this.selectedGun}) : super(key: key);

  @override
  State<ListGunsScreen> createState() => _ListGunsScreenState();
}

class _ListGunsScreenState extends State<ListGunsScreen> {
  List<Gun> guns = [];
  int? _selectedIndex;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGuns();
  }
  
  Future<void> _loadGuns() async {
    setState(() {
      _isLoading = true;
    });
    
    final loadedGuns = await CalculationStorage.getGuns();
    
    setState(() {
      guns = loadedGuns;
      _isLoading = false;
      
      // If we have a pre-selected gun, find and select it
      if (widget.selectedGun != null) {
        for (int i = 0; i < guns.length; i++) {
          if (guns[i].id == widget.selectedGun!.id) {
            _selectedIndex = i;
            break;
          }
        }
      }
    });
  }

  void _selectGun(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _confirmSelection() {
    if (_selectedIndex != null) {
      // Return the selected gun to the previous screen
      Navigator.of(context).pop(guns[_selectedIndex!]);
    }
  }

  void _addNewGun() async {
    final Gun? newGun = await Navigator.push<Gun>(
      context,
      MaterialPageRoute(
        builder: (context) => const GunSettingsScreen(),
      ),
    );
    
    // If a gun was returned, add it to the list and save
    if (newGun != null) {
      setState(() {
        guns.add(newGun);
      });
      // Save the updated list
      await CalculationStorage.saveGuns(guns);
    }
  }

  void _editSelectedGun() {
    if (_selectedIndex != null) {
      Navigator.push<Gun>(
        context,
        MaterialPageRoute(
          builder: (context) => GunSettingsScreen(gun: guns[_selectedIndex!]),
        ),
      ).then((updatedGun) async {
        if (updatedGun != null) {
          setState(() {
            guns[_selectedIndex!] = updatedGun;
          });
          // Save the updated list
          await CalculationStorage.saveGuns(guns);
        }
      });
    }
  }
  
  void _deleteSelectedGun() async {
    if (_selectedIndex != null) {
      final gunToDelete = guns[_selectedIndex!];
      
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Gun'),
          content: Text('Are you sure you want to delete ${gunToDelete.name}?'),
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
          guns.removeAt(_selectedIndex!);
          _selectedIndex = null;
        });
        
        // Save the updated list
        await CalculationStorage.saveGuns(guns);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while fetching guns
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
                "Your Guns",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          guns.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _addNewGun,
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icon/rifle.svg',
                                    height: 110,
                                    width: 110,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Add first Gun',
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
                          'No guns added yet',
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
                      itemCount: guns.length + 1, // Add 1 for the "Add" button
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Add New Gun button at the beginning
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: GestureDetector(
                              onTap: _addNewGun,
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
                                        'Add New Gun',
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

                        // Adjust the index for the gun list (subtract 1 because of the Add button)
                        final gunIndex = index - 1;
                        final isSelected = _selectedIndex == gunIndex;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: GestureDetector(
                            onTap: () => _selectGun(gunIndex),
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
                                            guns[gunIndex].name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isSelected 
                                                ? Theme.of(context).colorScheme.background
                                                : Theme.of(context).colorScheme.primary,
                                              fontSize: 16,
                                            ),
                                          ),
                                          if (guns[gunIndex].description.isNotEmpty)
                                            Text(
                                              guns[gunIndex].description,
                                              style: TextStyle(
                                                color: isSelected
                                                  ? Theme.of(context).colorScheme.background.withOpacity(0.8)
                                                  : null,
                                              ),
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
                  onPressed: _deleteSelectedGun,
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
                  onPressed: _editSelectedGun,
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
