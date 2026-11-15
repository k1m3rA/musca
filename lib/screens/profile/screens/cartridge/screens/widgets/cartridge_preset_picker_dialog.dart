import 'package:flutter/material.dart';
import 'package:musca/l10n/app_localizations.dart';
import 'package:musca/data/cartridge_presets.dart';

/// Resultado del modal de selección de cartucho: o bien un calibre
/// precargado, o bien un nombre libre escrito por el usuario.
class CartridgePresetSelection {
  final CartridgePreset? preset;
  final String? customName;

  const CartridgePresetSelection.preset(CartridgePreset this.preset)
      : customName = null;

  const CartridgePresetSelection.custom(String this.customName)
      : preset = null;
}

/// Modal con el tema de la app que lista los calibres precargados y permite
/// escribir para filtrar la lista al mismo tiempo.
class CartridgePresetPickerDialog extends StatefulWidget {
  const CartridgePresetPickerDialog({Key? key}) : super(key: key);

  @override
  State<CartridgePresetPickerDialog> createState() =>
      _CartridgePresetPickerDialogState();
}

class _CartridgePresetPickerDialogState
    extends State<CartridgePresetPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);

    final normalizedQuery = _query.trim().toLowerCase();
    final filtered = normalizedQuery.isEmpty
        ? kCartridgePresets
        : kCartridgePresets
            .where((preset) => preset.name.toLowerCase().contains(normalizedQuery))
            .toList();
    final hasExactMatch = filtered.any(
      (preset) => preset.name.toLowerCase() == normalizedQuery,
    );
    final showCustomName = normalizedQuery.isNotEmpty && !hasExactMatch;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: media.size.width * 0.9,
        height: media.size.height * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.selectCartridgePreset,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: l10n.searchCartridgesHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2.0,
                    color: theme.colorScheme.outline,
                  ),
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  if (showCustomName)
                    ListTile(
                      leading: Icon(
                        Icons.edit,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        l10n.useCustomCartridgeName(_query.trim()),
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(
                        CartridgePresetSelection.custom(_query.trim()),
                      ),
                    ),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        l10n.noCartridgesFound,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  else
                    ...filtered.map(
                      (preset) => ListTile(
                        title: Text(preset.name),
                        subtitle: Text(
                          '${preset.bulletWeightGr.toStringAsFixed(0)} gr · '
                          'BC ${preset.ballisticCoefficient.toStringAsFixed(3)} '
                          '${preset.bcModelType == 1 ? 'G7' : 'G1'} · '
                          '${preset.muzzleVelocity.toStringAsFixed(0)} m/s',
                        ),
                        onTap: () => Navigator.of(context).pop(
                          CartridgePresetSelection.preset(preset),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
