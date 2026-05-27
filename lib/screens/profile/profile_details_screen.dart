import 'package:flutter/material.dart';
import 'package:musca/l10n/app_localizations.dart';
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
            expandedHeight: 100,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                AppLocalizations.of(context)!.profileDetails,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
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
                      AppLocalizations.of(context)!.noProfilesSelected,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.goToTheArmoryToSelectYourProfiles,
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
                        AppLocalizations.of(context)!.gunProfile,
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
            _buildDetailRow(AppLocalizations.of(context)!.twistRate, '${selectedGun!.twistRate.toStringAsFixed(1)}" (${selectedGun!.twistDirection == 1 ? AppLocalizations.of(context)!.right : AppLocalizations.of(context)!.left})'),
            _buildDetailRow(AppLocalizations.of(context)!.muzzleVelocity, '${selectedGun!.muzzleVelocity.toStringAsFixed(0)} m/s'),
            _buildDetailRow(AppLocalizations.of(context)!.zeroRangeLabel, '${selectedGun!.zeroRange.toStringAsFixed(0)} m'),
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
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgPicture.asset(
                    'assets/icon/bullet.svg',
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
                        AppLocalizations.of(context)!.cartridgeProfile,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
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
            _buildDetailRow(AppLocalizations.of(context)!.diameter, selectedCartridge!.diameter),
            _buildDetailRow(AppLocalizations.of(context)!.bulletWeight, '${selectedCartridge!.bulletWeight.toStringAsFixed(1)} ${AppLocalizations.of(context)!.grains}'),
            _buildDetailRow(AppLocalizations.of(context)!.bulletLength, selectedCartridge!.bulletLength.toString()),
            _buildDetailRow(AppLocalizations.of(context)!.ballisticCoefficient, selectedCartridge!.ballisticCoefficient.toStringAsFixed(3)),
            if (selectedCartridge!.bcModelType != null)
              _buildDetailRow(AppLocalizations.of(context)!.bcModel, selectedCartridge!.bcModelType == 0 ? AppLocalizations.of(context)!.g1 : AppLocalizations.of(context)!.g7),
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
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgPicture.asset(
                    'assets/icon/scope.svg',
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
                        AppLocalizations.of(context)!.scopeProfile,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
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
            _buildDetailRow(AppLocalizations.of(context)!.sightHeight, '${selectedScope!.sightHeight.toStringAsFixed(2)} ${selectedScope!.units == 0 ? AppLocalizations.of(context)!.inches : AppLocalizations.of(context)!.centimeters.toLowerCase()}'),
            _buildDetailRow(AppLocalizations.of(context)!.unitsTitle, selectedScope!.getUnitsDisplayName()),
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
