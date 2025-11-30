import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Pour la gestion des clés API

// Imports des écrans
import 'screens/home_screen.dart'; 
import 'screens/age_gate_screen.dart'; // L'écran de vérification

// Variable globale pour stocker les caméras disponibles (nécessaire pour le Scanner)
late List<CameraDescription> _cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. CHARGEMENT DU FICHIER .ENV (pour charger la clé Google Maps)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Erreur de chargement du fichier .env: $e");
  }

  // 2. Initialisation de la caméra (pour le ScannerScreen)
  try {
    _cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Erreur lors de la récupération des caméras : $e');
    _cameras = []; 
  }

  runApp(const VinoteApp());
}

class VinoteApp extends StatelessWidget {
  const VinoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vinote',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Démarrage avec le Wrapper de vérification d'âge
      home: const AgeGateWrapper(), 
    );
  }
}

// -----------------------------------------------------------------------------
// GESTION DU FLUX DE VÉRIFICATION D'ÂGE
// -----------------------------------------------------------------------------

class AgeGateWrapper extends StatefulWidget {
  const AgeGateWrapper({super.key});

  @override
  State<AgeGateWrapper> createState() => _AgeGateWrapperState();
}

class _AgeGateWrapperState extends State<AgeGateWrapper> {
  // L'état qui détermine si l'utilisateur a passé la vérification
  // Dans une vraie application, ceci serait persistant (ex: SharedPreferences)
  bool _isAgeVerified = false;

  void _onAgeVerified() {
    setState(() {
      _isAgeVerified = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isAgeVerified) {
      // Âge vérifié : affiche l'application principale
      return HomeScreen(
        // Passe la première caméra disponible au HomeScreen
        camera: _cameras.isNotEmpty ? _cameras.first : null,
      );
    } else {
      // Âge non vérifié : affiche l'écran de vérification d'âge
      return AgeGateScreen(onVerificationSuccess: _onAgeVerified);
    }
  }
}