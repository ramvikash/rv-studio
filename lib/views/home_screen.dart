import 'package:flutter/material.dart';
import 'create_page.dart';
import 'gallery_page.dart';
import 'models_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RV Studio')),
      body: SafeArea(
        child: IndexedStack(
          index: _i,
          children: const [CreatePage(), GalleryPage(), ModelsPage()],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (i) => setState(() => _i = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: 'Create'),
          NavigationDestination(icon: Icon(Icons.photo_library_outlined), label: 'Gallery'),
          NavigationDestination(icon: Icon(Icons.download_for_offline_outlined), label: 'Models'),
        ],
      ),
    );
  }
}
