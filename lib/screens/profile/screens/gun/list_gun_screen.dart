import 'package:flutter/material.dart';
import 'screens/gun_settings_screen.dart';

class Gun {
  final String id;
  final String name;
  final String description;

  Gun({required this.id, required this.name, this.description = ''});
}

class ListGunsScreen extends StatefulWidget {
  const ListGunsScreen({Key? key}) : super(key: key);

  @override
  State<ListGunsScreen> createState() => _ListGunsScreenState();
}

class _ListGunsScreenState extends State<ListGunsScreen> {
  // Sample data - replace with your actual data source
  List<Gun> guns = [
    Gun(id: '1', name: 'Glock 19', description: '9mm Pistol'),
    Gun(id: '2', name: 'AR-15', description: 'Rifle'),
    Gun(id: '3', name: 'Remington 870', description: 'Shotgun'),
    Gun(id: '4', name: 'Sig Sauer P320', description: 'Pistol'),
    Gun(id: '5', name: 'Ruger 10/22', description: 'Rifle'),
  ];

  int? _selectedIndex;

  void _selectGun(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Here you can add what happens when a gun is selected
    // For example, navigate to detail page:
    // Navigator.push(context, MaterialPageRoute(builder: (_) => GunDetailScreen(gun: guns[index])));
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
                "Mis Armas",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          SliverFillRemaining(
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
                              Icon(
                                Icons.arrow_forward_ios,
                                color: isSelected 
                                  ? Theme.of(context).colorScheme.background
                                  : Theme.of(context).colorScheme.primary,
                                size: 18,
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
    );
  }
}
