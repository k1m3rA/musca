import 'package:flutter/material.dart';
import 'screens/gun_settings_screen.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Add this import for SVG support

class Gun {
  final String id;
  final String name;
  final String description;

  Gun({required this.id, required this.name, this.description = ''});
}

class ListGunsScreen extends StatefulWidget {
  final Gun? selectedGun;
  
  const ListGunsScreen({Key? key, this.selectedGun}) : super(key: key);

  @override
  State<ListGunsScreen> createState() => _ListGunsScreenState();
}

class _ListGunsScreenState extends State<ListGunsScreen> {
  // Sample data - replace with your actual data source
  List<Gun> guns = [
  ];

  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    
    // If we have a pre-selected gun, find and select it
    if (widget.selectedGun != null) {
      for (int i = 0; i < guns.length; i++) {
        if (guns[i].id == widget.selectedGun!.id) {
          _selectedIndex = i;
          break;
        }
      }
    }
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
    
    // If a gun was returned, add it to the list
    if (newGun != null) {
      setState(() {
        guns.add(newGun);
      });
    }
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
                              padding: const EdgeInsets.all(30.0),
                              child: Column(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icon/rifle.svg',
                                    height: 100,
                                    width: 150,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Add New Gun',
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
      floatingActionButton: _selectedIndex != null ? Material(
        color: Colors.transparent,
        elevation: 10.0,
        borderRadius: BorderRadius.circular(30),
        shadowColor: Colors.black.withOpacity(1),
        child: FloatingActionButton(
          onPressed: _confirmSelection,
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          child: Icon(Icons.check, color: Theme.of(context).scaffoldBackgroundColor)
        ),
      ) : null,
    );
  }
}
