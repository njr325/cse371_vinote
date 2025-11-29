package com.vinote.app

import android.content.Context
import android.graphics.BitmapFactory
import android.util.Log
import java.io.File
import org.tensorflow.lite.task.vision.detector.ObjectDetector
import org.tensorflow.lite.support.image.TensorImage
import org.tensorflow.lite.support.image.ImageProcessor
import org.tensorflow.lite.support.image.ops.ResizeOp
// Importations supplémentaires pour l'OCR pourraient être nécessaires
// (ex: Google ML Kit Text Recognition si vous ne le faites pas via TFLite)

object AIRunner {
    
    // Nom du fichier modèle TFLite stocké dans android/app/src/main/assets/
    private const val MODEL_FILE = "label_recognition_model.tflite"

    /**
     * Exécute l'inférence du modèle d'IA sur l'image de l'étiquette fournie.
     * @param context Contexte Android pour accéder aux assets.
     * @param imagePath Chemin d'accès du fichier image (généralement depuis la caméra Flutter).
     * @return Map<String, Any?> contenant les données reconnues.
     */
    fun runInference(context: Context, imagePath: String): Map<String, Any?> {
        
        val imageFile = File(imagePath)
        if (!imageFile.exists()) {
            Log.e("VinoteIA", "Fichier image non trouvé: $imagePath")
            return createErrorMap("Fichier non trouvé")
        }

        try {
            // 1. Charger et préparer l'image
            val bitmap = BitmapFactory.decodeFile(imagePath)
            
            // Note: La taille doit correspondre à l'entrée attendue par votre modèle (ex: 300x300)
            val imageProcessor = ImageProcessor.Builder()
                .add(ResizeOp(300, 300, ResizeOp.ResizeMethod.NEAREST_NEIGHBOR))
                .build()

            val tensorImage = imageProcessor.process(TensorImage.fromBitmap(bitmap))

            // 2. Charger et exécuter le modèle de Détection d'Objets (TFLite)
            val options = ObjectDetector.ObjectDetectorOptions.builder()
                .setMaxResults(10) // Nombre max de détections
                .setScoreThreshold(0.5f) // Seuil de confiance
                .build()
                
            val detector = ObjectDetector.createFromFileAndOptions(context, MODEL_FILE, options)

            // Exécuter l'inférence
            val results = detector.detect(tensorImage)

            // 3. Post-traitement (Logique de reconnaissance personnalisée)
            // L'objectif ici est de:
            // a) Identifier les boîtes englobantes (Bounding Boxes) des éléments clés (Nom, Millésime, Cépage).
            // b) Exécuter un OCR ciblé sur ces zones (non inclus ici, mais essentiel).
            
            // --- SIMULATION AVEC LES RÉSULTATS DU MODÈLE ---
            
            // Dans un cas réel, vous utiliseriez les détections (results) pour lire le texte
            val recognizedName = "Vin Reconnu TFLite" 
            val recognizedVintage = 2020 
            val recognizedGrape = "Syrah/Grenache" 
            val recognizedRegion = "Vallée du Rhône"

            if (results.isEmpty()) {
                return createErrorMap("Aucune étiquette détectée ou modèle non entraîné.")
            }
            
            // Retourner les données structurées
            return mapOf(
                "labelName" to recognizedName, 
                "region" to recognizedRegion, 
                "grapeVariety" to recognizedGrape, 
                "vintage" to recognizedVintage,
                "tastingNotes" to "Données extraites par le moteur TFLite natif."
            )
            
        } catch (e: Exception) {
            Log.e("VinoteIA", "Erreur d'exécution de l'IA: ${e.message}", e)
            return createErrorMap("Erreur d'exécution de l'IA: ${e.message}")
        }
    }
    
    private fun createErrorMap(message: String): Map<String, Any?> {
        return mapOf(
            "labelName" to "Erreur de Scan",
            "region" to "N/A",
            "grapeVariety" to "N/A",
            "vintage" to 0,
            "tastingNotes" to message
        )
    }
}