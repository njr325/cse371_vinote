import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ai_recognition_service.dart';
import '../models/wine.dart';

// Note: Vous devez appeler 'availableCameras()' dans main() et la passer ici.
// Pour la simplicité, nous allons simuler la détection de caméra.

class ScannerScreen extends StatefulWidget {
  final CameraDescription? camera; // La caméra détectée

  const ScannerScreen({super.key, this.camera});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final AIRecognitionService _aiService = AIRecognitionService();
  Wine? _recognizedWine;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }
  
  // Initialise la caméra
  void _initializeCamera() async {
    // Dans une vraie application, vous obtiendrez la liste des caméras disponibles au lancement
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
        // Gérer le cas où aucune caméra n'est disponible
        return;
    }

    _controller = CameraController(
      cameras.first, // Utiliser la première caméra disponible
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  // Capture l'image et lance le processus d'IA
  Future<void> _takePictureAndScan() async {
    try {
      await _initializeControllerFuture;
      if (_controller == null || _isProcessing) return;

      setState(() {
        _isProcessing = true;
        _recognizedWine = null;
      });

      // Capture l'image et obtient l'objet XFile
      final XFile imageFile = await _controller!.takePicture();
      
      // Lance l'analyse de l'IA via le service
      final Wine? result = await _aiService.scanLabel(imageFile.path);

      setState(() {
        _isProcessing = false;
        _recognizedWine = result;
      });
      
      // Optionnel: Naviguer vers l'écran d'ajout de journal avec les données pré-remplies
      // if (result != null) {
      //   // Navigator.push(context, MaterialPageRoute(...AddEntryScreen(wine: result)...))
      // }

    } catch (e) {
      print('Erreur de capture ou d\'analyse : $e');
      setState(() {
        _isProcessing = false;
        _recognizedWine = null;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. Aperçu de la Caméra
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),
          
          // 2. Zone de Cadre (Aide l'utilisateur à cadrer l'étiquette)
          Center(
            child: Container(
              width: 300,
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.redAccent, width: 3.0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          
          // 3. Indicateur de Chargement / Résultat
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(color: Colors.redAccent)
            )
          else if (_recognizedWine != null)
            _buildRecognitionResult(_recognizedWine!),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePictureAndScan,
        child: const Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  
  // Affiche les résultats de la reconnaissance
  Widget _buildRecognitionResult(Wine wine) {
    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: Card(
        color: Colors.black54,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(wine.labelName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Région: ${wine.region} - Millésime: ${wine.vintage}', style: const TextStyle(color: Colors.white70)),
              Text('Cépage: ${wine.grapeVariety}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                   // Logique pour continuer vers l'ajout au journal
                },
                icon: const Icon(Icons.book),
                label: const Text('Ajouter au Journal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}