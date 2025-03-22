import 'package:flutter/material.dart';

// Main widget - kept for backwards compatibility
class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.onThemeChanged,
  });

  final String title;
  final Function(ThemeMode) onThemeChanged;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return HomeContent(title: widget.title);
  }
}

// New widget for just the content
class HomeContent extends StatelessWidget {
  final String title;
  
  const HomeContent({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(title),
            ),
          ),
          SliverFillRemaining(
            child: Center(
              child: Text(
                'Main content goes here',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}