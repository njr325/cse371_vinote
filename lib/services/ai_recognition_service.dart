import 'package:flutter/services.dart';
import '../models/wine.dart';

// Définition du Method Channel pour communiquer avec la plateforme native
const MethodChannel _channel = MethodChannel('com.vinote.app/recognition');

class AIRecognitionService {
  
  /// Appelle la fonction native pour scanner une image et la traiter par l'IA.
  /// 
  /// [imagePath] est le chemin d'accès au fichier image de l'étiquette.
  Future<Wine?> scanLabel(String imagePath) async {
    try {
      // 1. Appel de la méthode native 'recognizeLabel'
      // La plateforme native (Android/iOS) va:
      // a. Charger le fichier image.
      // b. Exécuter le modèle TFLite/ML Kit sur l'image.
      // c. Retourner les résultats (nom, région, millésime) sous forme de Map.
      final Map<dynamic, dynamic>? results = await _channel.invokeMethod(
        'recognizeLabel', 
        {'path': imagePath}
      );

      if (results == null) {
        return null;
      }
      
      // 2. Traitement des résultats de l'IA (Simulation de l'intégration API)
      // Normalement, vous utiliseriez ces résultats pour appeler une API (ex: Vivino, ou votre propre backend)
      // pour obtenir les notes de dégustation complètes.
      
      // Simulation:
      final String labelName = results['labelName'] ?? 'Vin Non Identifié';
      final String region = results['region'] ?? 'Inconnue';
      final String grapeVariety = results['grapeVariety'] ?? 'Non Spécifié';
      final int vintage = results['vintage'] ?? 0;
      final String tastingNotesAI = results['tastingNotes'] ?? 'Notes de dégustation génériques (IA).';
      
      // 3. Retourner le modèle Wine
      return Wine(
        labelName: labelName,
        grapeVariety: grapeVariety,
        region: region,
        vintage: vintage,
        tastingNotesAI: tastingNotesAI,
      );

    } on PlatformException catch (e) {
      print("Erreur native de reconnaissance : ${e.message}");
      return null;
    }
  }
}