import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/gun_model.dart';
import '../../models/cartridge_model.dart';
import '../../models/scope_model.dart';
import '../../services/gun_storage.dart';
import '../../services/cartridge_storage.dart';
import '../../services/scope_storage.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  Gun? selectedGun;
  Cartridge? selectedCartridge;
  Scope? selectedScope;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSelectedProfiles();
  }

  Future<void> _loadSelectedProfiles() async {
    setState(() {
      _isLoading = true;
    });

    // Load saved gun
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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 150,
            flexibleSpace: const FlexibleSpaceBar(
              centerTitle: true,
              title: Text("Profile Details"),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (selectedGun == null && selectedCartridge == null && selectedScope == null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No profiles selected',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Go to the Armory to select your profiles',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (selectedGun != null) _buildGunCard(),
                  if (selectedGun != null) const SizedBox(height: 16),
                  if (selectedCartridge != null) _buildCartridgeCard(),
                  if (selectedCartridge != null) const SizedBox(height: 16),
                  if (selectedScope != null) _buildScopeCard(),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGunCard() {
    if (selectedGun == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgPicture.asset(
                    'assets/icon/rifle.svg',
                    height: 30,
                    width: 30,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gun Profile',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        selectedGun!.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Twist Rate', '${selectedGun!.twistRate.toStringAsFixed(1)}" (${selectedGun!.twistDirection == 1 ? 'Right' : 'Left'})'),
            _buildDetailRow('Muzzle Velocity', '${selectedGun!.muzzleVelocity.toStringAsFixed(0)} m/s'),
            _buildDetailRow('Zero Range', '${selectedGun!.zeroRange.toStringAsFixed(0)} m'),
          ],
        ),
      ),
    );
  }

  Widget _buildCartridgeCard() {
    if (selectedCartridge == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgPicture.asset(
                    'assets/icon/bullet.svg',
                    height: 30,
                    width: 30,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cartridge Profile',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        selectedCartridge!.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Diameter', selectedCartridge!.diameter),
            _buildDetailRow('Bullet Weight', '${selectedCartridge!.bulletWeight.toStringAsFixed(1)} grains'),
            _buildDetailRow('Bullet Length', selectedCartridge!.bulletLength.toString()),
            _buildDetailRow('Ballistic Coefficient', selectedCartridge!.ballisticCoefficient.toStringAsFixed(3)),
            if (selectedCartridge!.bcModelType != null)
              _buildDetailRow('BC Model', selectedCartridge!.bcModelType == 0 ? 'G1' : 'G7'),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeCard() {
    if (selectedScope == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgPicture.asset(
                    'assets/icon/scope.svg',
                    height: 30,
                    width: 30,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scope Profile',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        selectedScope!.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Sight Height', '${selectedScope!.sightHeight.toStringAsFixed(2)} ${selectedScope!.units == 0 ? 'inches' : 'cm'}'),
            _buildDetailRow('Units', selectedScope!.getUnitsDisplayName()),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
