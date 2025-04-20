import 'package:flutter/material.dart';
import 'screens/scope_settings_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../services/scope_storage.dart';
import '../../../../models/scope_model.dart';

class ListScopeScreen extends StatefulWidget {
  final Scope? selectedScope;
  
  const ListScopeScreen({Key? key, this.selectedScope}) : super(key: key);

  @override
  State<ListScopeScreen> createState() => _ListScopeScreenState();
}

class _ListScopeScreenState extends State<ListScopeScreen> {
  List<Scope> scopes = [];
  int? _selectedIndex;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScopes();
  }
  
  Future<void> _loadScopes() async {
    setState(() {
      _isLoading = true;
    });
    
    final loadedScopes = await ScopeStorage.getScopes();
    
    setState(() {
      scopes = loadedScopes;
      _isLoading = false;
      
      // If we have a pre-selected scope, find and select it
      if (widget.selectedScope != null) {
        for (int i = 0; i < scopes.length; i++) {
          if (scopes[i].id == widget.selectedScope!.id) {
            _selectedIndex = i;
            break;
          }
        }
      }
    });
  }

  void _selectScope(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _confirmSelection() {
    if (_selectedIndex != null) {
      // Return the selected scope to the previous screen
      Navigator.of(context).pop(scopes[_selectedIndex!]);
    }
  }

  void _addNewScope() async {
    final Scope? newScope = await Navigator.push<Scope>(
      context,
      MaterialPageRoute(
        builder: (context) => const ScopeSettingsScreen(),
      ),
    );
    
    // If a scope was returned, add it to the list and save
    if (newScope != null) {
      setState(() {
        scopes.add(newScope);
      });
      // Save the updated list
      await ScopeStorage.saveScopes(scopes);
    }
  }

  void _editSelectedScope() {
    if (_selectedIndex != null) {
      Navigator.push<Scope>(
        context,
        MaterialPageRoute(
          builder: (context) => ScopeSettingsScreen(scope: scopes[_selectedIndex!]),
        ),
      ).then((updatedScope) async {
        if (updatedScope != null) {
          setState(() {
            scopes[_selectedIndex!] = updatedScope;
          });
          // Save the updated list
          await ScopeStorage.saveScopes(scopes);
        }
      });
    }
  }
  
  void _deleteSelectedScope() async {
    if (_selectedIndex != null) {
      final scopeToDelete = scopes[_selectedIndex!];
      
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Scope'),
          content: Text('Are you sure you want to delete ${scopeToDelete.name}?'),
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
          scopes.removeAt(_selectedIndex!);
          _selectedIndex = null;
        });
        
        // Save the updated list
        await ScopeStorage.saveScopes(scopes);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while fetching scopes
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
                "Your Scopes",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          scopes.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _addNewScope,
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icon/scope.svg',
                                    height: 110,
                                    width: 110,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Add first Scope',
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
                          'No scopes added yet',
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
                      itemCount: scopes.length + 1, // Add 1 for the "Add" button
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Add New Scope button at the beginning
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: GestureDetector(
                              onTap: _addNewScope,
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
                                        'Add New Scope',
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

                        // Adjust the index for the scope list (subtract 1 because of the Add button)
                        final scopeIndex = index - 1;
                        final isSelected = _selectedIndex == scopeIndex;
                        final scope = scopes[scopeIndex];
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: GestureDetector(
                            onTap: () => _selectScope(scopeIndex),
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
                                            scope.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isSelected 
                                                ? Theme.of(context).colorScheme.background
                                                : Theme.of(context).colorScheme.primary,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Sight Height: ${scope.sightHeight.toStringAsFixed(2)} cm',
                                            style: TextStyle(
                                              color: isSelected
                                                ? Theme.of(context).colorScheme.background.withOpacity(0.8)
                                                : null,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Click Units: ${scope.getUnitsDisplayName()}',
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
                  onPressed: _deleteSelectedScope,
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
                  onPressed: _editSelectedScope,
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
