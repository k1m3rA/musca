import 'package:flutter/material.dart';

class UnitOption {
  final String id;
  final String displayName;
  
  const UnitOption(this.id, this.displayName);
}

class UnitsInput extends StatefulWidget {
  final String initialUnit;
  final Function(String) onUpdateUnits;

  const UnitsInput({
    super.key,
    required this.initialUnit,
    required this.onUpdateUnits,
  });

  @override
  State<UnitsInput> createState() => _UnitsInputState();
}

class _UnitsInputState extends State<UnitsInput> {
  late String _selectedUnitId;
  bool _isExpanded = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  
  // List of available units
  final List<UnitOption> _units = const [
    UnitOption('mrad', 'MRAD'),
    UnitOption('mrad_10', '1/10 MRAD'),
    UnitOption('mrad_20', '1/20 MRAD'),
    UnitOption('moa', 'MOA'),
    UnitOption('moa_2', '1/2 MOA'),
    UnitOption('moa_3', '1/3 MOA'),
    UnitOption('moa_4', '1/4 MOA'),
    UnitOption('moa_8', '1/8 MOA'),
    UnitOption('in', 'Inches'),
    UnitOption('cm', 'Centimeters'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedUnitId = widget.initialUnit;
  }
  
  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  // Get the display name of the currently selected unit
  String get _selectedUnitDisplayName {
    return _units.firstWhere((unit) => unit.id == _selectedUnitId).displayName;
  }
  
  void _toggleDropdown() {
    setState(() {
      _isExpanded = !_isExpanded;
      
      if (_isExpanded) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }
  
  void _showOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    
    // Calculate available space
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;
    
    // Calculate space above and below the widget
    final spaceAbove = offset.dy - topPadding;
    final spaceBelow = screenHeight - offset.dy - size.height - bottomPadding;
    
    // Determine if dropdown should appear above or below
    final showBelow = spaceBelow >= spaceAbove || spaceBelow >= 200;
    
    // Calculate max height based on available space (with safety margin)
    final maxHeight = (showBelow ? spaceBelow : spaceAbove) - 20;
    final safeMaxHeight = maxHeight.clamp(100.0, 300.0);
    
    // Calculate dropdown offset based on position
    final verticalOffset = showBelow ? size.height : -safeMaxHeight;
    
    // Define horizontal margins for dropdown
    const double horizontalMargin = 35.0;
    
    // Calculate new width with margins
    final dropdownWidth = size.width - (horizontalMargin * 3);
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Full screen touch detector to close dropdown when tapping outside
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleDropdown,
              behavior: HitTestBehavior.translucent,
            ),
          ),
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(horizontalMargin - 45, verticalOffset - 35),
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: dropdownWidth,
                  constraints: BoxConstraints(
                    maxHeight: safeMaxHeight,
                    minHeight: 0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _units.length,
                      itemBuilder: (context, index) {
                        final unit = _units[index];
                        final isSelected = unit.id == _selectedUnitId;
                        
                        if (isSelected) {
                          return const SizedBox.shrink();
                        }
                        
                        return ListTile(
                          title: Text(unit.displayName),
                          leading: const Icon(Icons.circle_outlined),
                          onTap: () {
                            setState(() {
                              _selectedUnitId = unit.id;
                            });
                            widget.onUpdateUnits(unit.id);
                            _toggleDropdown();
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }
  
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              'Click Units',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 13,
              ),
            ),
          ),
          CompositedTransformTarget(
            link: _layerLink,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: ListTile(
                title: Text(
                  _selectedUnitDisplayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                trailing: IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: _toggleDropdown,
                ),
                
              ),
            ),
          ),
        ],
      ),
    );
  }
}
