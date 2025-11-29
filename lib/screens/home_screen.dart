import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'journal_screen.dart';
import 'scanner_screen.dart';
import 'map_screen.dart';
import 'pairing_screen.dart';

class HomeScreen extends StatefulWidget {
  // La caméra est passée depuis main.dart
  final CameraDescription? camera;

  const HomeScreen({super.key, this.camera});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Initialisation des écrans
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Les écrans sont construits ici, le Scanner a besoin de l'objet CameraDescription
    _screens = <Widget>[
      const JournalScreen(),
      ScannerScreen(camera: widget.camera),
      const MapScreen(),
      const PairingScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Le titre change selon l'écran sélectionné
        title: Text(['Journal', 'Scanner', 'Carte', 'Accords'][_selectedIndex]),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: _screens.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Carte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Accords',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Empêche l'animation de décalage
      ),
    );
  }
}