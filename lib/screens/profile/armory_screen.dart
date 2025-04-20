import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'screens/scope/scope_settings_screen.dart';
import 'screens/cartridge/list_cartridge_screen.dart';
import 'screens/gun/list_gun_screen.dart';
import '../../models/gun_model.dart';
import '../../models/cartridge_model.dart';
import '../../services/calculation_storage.dart'; // Add import for CalculationStorage
import '../../services/cartridge_storage.dart'; // Add import for CartridgeStorage

class ProfileScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const ProfileScreen({
    Key? key,
    required this.onNavigate,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Gun? selectedGun;
  Cartridge? selectedCartridge;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedSelections();
  }

  Future<void> _loadSavedSelections() async {
    setState(() {
      _isLoading = true;
    });

    // Load saved gun
    try {
      final Gun? gun = await CalculationStorage.getSelectedGun();
      if (gun != null) {
        setState(() {
          selectedGun = gun;
        });
      }
    } catch (e) {
      print('Error loading selected gun: $e');
    }

    // Load saved cartridge
    try {
      final Cartridge? cartridge = await CartridgeStorage.getSelectedCartridge();
      if (cartridge != null) {
        setState(() {
          selectedCartridge = cartridge;
        });
      }
    } catch (e) {
      print('Error loading selected cartridge: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                "Armory",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 25),
                // First button - Gun Settings
                GestureDetector(
                  onTap: () async {
                    final Gun? result = await Navigator.push<Gun>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListGunsScreen(selectedGun: selectedGun),
                      ),
                    );
                    
                    if (result != null) {
                      setState(() {
                        selectedGun = result;
                      });
                      // Save the selected gun
                      await CalculationStorage.saveSelectedGunId(result.id);
                    }
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icon/rifle.svg',
                            height: 50,
                            width: 50,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            selectedGun?.name ?? 'Gun',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          if (selectedGun != null)
                            Text(
                              selectedGun!.getDescription(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                // Second button - Scope Settings
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScopeSettingsScreen(),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icon/scope.svg',
                            height: 50,
                            width: 50,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Scope',
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
                const SizedBox(height: 25),
                // Third button - Cartridge settings
                GestureDetector(
                  onTap: () async {
                    final Cartridge? result = await Navigator.push<Cartridge>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListCartridgeScreen(selectedCartridge: selectedCartridge),
                      ),
                    );
                    
                    if (result != null) {
                      setState(() {
                        selectedCartridge = result;
                      });
                      // Save the selected cartridge
                      await CartridgeStorage.saveSelectedCartridgeId(result.id);
                    }
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icon/bullet.svg',
                            height: 50,
                            width: 50,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            selectedCartridge?.name ?? 'Cartridge',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          if (selectedCartridge != null)
                            Column(
                              children: [
                                Text(
                                  'Diameter: ${selectedCartridge!.diameter} in · Weight: ${selectedCartridge!.bulletWeight} gr',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'BC: ${selectedCartridge!.ballisticCoefficient.toStringAsFixed(3)} ${selectedCartridge!.bcModelType == 0 ? "G1" : "G7"}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25), // Add some padding at the bottom
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
