import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const ProfileScreen({
    Key? key,
    required this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Text(
          'This is the Profile Screen - Example Text',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
