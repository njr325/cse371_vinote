import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Pour la gestion des clés API
import 'package:firebase_core/firebase_core.dart';

// Import des écrans principaux
import 'screens/home_screen.dart'; 
import 'screens/age_gate_screen.dart'; 

// Variable globale pour stocker les caméras disponibles (nécessaire pour le Scanner)
late List<CameraDescription> _cameras;

void main() async {
  // 1. Initialisation obligatoire des plugins Flutter (caméra, dotenv, etc.)
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. CHARGEMENT DU FICHIER .ENV (pour charger la clé Google Maps, etc.)
  try {
    await dotenv.load(fileName: ".env");
    print("Fichier .env chargé avec succès.");
  } catch (e) {
    print("ATTENTION: Erreur de chargement du fichier .env: $e");
  }

  // 3. Initialisation de la caméra (pour le ScannerScreen)
  try {
    _cameras = await availableCameras();
    print("Caméras disponibles : ${_cameras.length}");
  } on CameraException catch (e) {
    print('Erreur lors de la récupération des caméras : $e');
    _cameras = []; // Empêcher un crash si aucune caméra n'est trouvée
  }

  // 4. Lancement de l'application
  runApp(const VinoteApp());
}

class VinoteApp extends StatelessWidget {
  const VinoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vinote: A Smart Wine Tasting App',
      theme: ThemeData(
        // Thème principal de l'application
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
      ),
      // Le point d'entrée qui gère la logique de la vérification d'âge
      home: const AgeGateWrapper(), 
    );
  }
}

// -----------------------------------------------------------------------------
// LOGIQUE DE VÉRIFICATION D'ÂGE
// -----------------------------------------------------------------------------

// Wrapper pour gérer l'affichage de l'écran de vérification d'âge ou de l'application principale
class AgeGateWrapper extends StatefulWidget {
  const AgeGateWrapper({super.key});

  @override
  State<AgeGateWrapper> createState() => _AgeGateWrapperState();
}

class _AgeGateWrapperState extends State<AgeGateWrapper> {
  // Dans une vraie application, cet état serait chargé depuis un stockage local (SharedPreferences)
  bool _isAgeVerified = false;

  void _onAgeVerified() {
    setState(() {
      _isAgeVerified = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isAgeVerified) {
      // Si l'âge est vérifié, affiche l'application principale (HomeScreen avec BottomNavigationBar)
      return HomeScreen(
        // Passe la première caméra disponible au HomeScreen (qui la passera au ScannerScreen)
        camera: _cameras.isNotEmpty ? _cameras.first : null,
      );
    } else {
      // Affiche l'écran de vérification d'âge
      return AgeGateScreen(onVerificationSuccess: _onAgeVerified);
    }
  }
}

// --- Écran de Vérification d'Âge (Minimal) ---
// Ce code est inclus ici à titre de rappel/placeholder. Il doit correspondre au fichier
// lib/screens/age_gate_screen.dart, qui doit appeler le callback après vérification.
// La version réelle doit contenir la logique Geolocator et l'entrée de Date de Naissance.
/*
class AgeGateScreen extends StatelessWidget {
  final VoidCallback onVerificationSuccess;

  const AgeGateScreen({super.key, required this.onVerificationSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vérification d'Âge")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Veuillez vérifier votre âge et votre localisation légale."),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onVerificationSuccess, // Simuler la réussite
              child: const Text("J'ai l'âge légal (Simuler la vérification)"),
            ),
          ],
        ),
      ),
    );
  }
}
*/