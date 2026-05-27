import 'package:flutter/material.dart';
import 'package:musca/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'screens/scope/list_scope_screen.dart';
import 'screens/cartridge/list_cartridge_screen.dart';
import 'screens/gun/list_gun_screen.dart';
import '../../models/gun_model.dart';
import '../../models/cartridge_model.dart';
import '../../models/scope_model.dart'; // Add import for Scope model
import '../../services/gun_storage.dart';
import '../../services/cartridge_storage.dart';
import '../../services/scope_storage.dart'; // Add import for ScopeStorage

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
  Scope? selectedScope; // Add selected scope
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedSelections();
  }

  Future<void> _loadSavedSelections() async {
    setState(() {
      _isLoading = true;
    });    // Load saved gun
    try {
      final Gun? gun = await GunStorage.getSelectedGun();
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

    // Load saved scope
    try {
      final Scope? scope = await ScopeStorage.getSelectedScope();
      if (scope != null) {
        setState(() {
          selectedScope = scope;
        });
      }
    } catch (e) {
      print('Error loading selected scope: $e');
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
                AppLocalizations.of(context)!.armory,
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
                      await GunStorage.saveSelectedGunId(result.id);
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
                            selectedGun?.name ?? AppLocalizations.of(context)!.gunProfile.replaceAll('Profile', '').trim(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          if (selectedGun != null)
                            Text(
                              AppLocalizations.of(context)!.gunDescriptionFormat(
                                selectedGun!.twistDirection == 1 ? AppLocalizations.of(context)!.rightTwist : AppLocalizations.of(context)!.leftTwist,
                                selectedGun!.twistRate.toStringAsFixed(1),
                                selectedGun!.muzzleVelocity.toStringAsFixed(0),
                                selectedGun!.zeroRange.toStringAsFixed(0),
                              ),
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
                  onTap: () async {
                    final Scope? result = await Navigator.push<Scope>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListScopeScreen(selectedScope: selectedScope),
                      ),
                    );
                    
                    if (result != null) {
                      setState(() {
                        selectedScope = result;
                      });
                      // Save the selected scope
                      await ScopeStorage.saveSelectedScopeId(result.id);
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
                            'assets/icon/scope.svg',
                            height: 50,
                            width: 50,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            selectedScope?.name ?? AppLocalizations.of(context)!.scopeProfile.replaceAll('Profile', '').trim(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          if (selectedScope != null) 
                            Column(
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.sightHeightFormat(selectedScope!.sightHeight.toStringAsFixed(2), selectedScope!.units <= 1 ? 'cm' : 'cm'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.clickUnitsFormat(selectedScope!.getUnitsDisplayName()),
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
                            selectedCartridge?.name ?? AppLocalizations.of(context)!.cartridgeProfile.replaceAll('Profile', '').trim(),
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
                                  AppLocalizations.of(context)!.diameterWeightFormat(selectedCartridge!.diameter.toString(), selectedCartridge!.bulletWeight.toString()),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.bcFormat(selectedCartridge!.ballisticCoefficient.toStringAsFixed(3), selectedCartridge!.bcModelType == 0 ? "G1" : "G7"),
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
