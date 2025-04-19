import 'package:flutter/material.dart';

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
  final List<Gun> guns = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Armas'),
      ),
      body: ListView.builder(
        itemCount: guns.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(guns[index].name),
              subtitle: Text(guns[index].description),
              selected: _selectedIndex == index,
              selectedTileColor: Colors.blue.withOpacity(0.1),
              onTap: () => _selectGun(index),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add navigation to create new gun screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
