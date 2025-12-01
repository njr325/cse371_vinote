package com.vinote.app

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import java.io.File

import org.tensorflow.lite.task.vision.detector.ObjectDetector
import org.tensorflow.lite.support.image.TensorImage
import org.tensorflow.lite.support.image.ImageProcessor
import org.tensorflow.lite.support.image.ops.ResizeOp

object AIRunner {

    private const val MODEL_FILE = "label_recognition_model.tflite"

    fun runInference(context: Context, imagePath: String): Map<String, Any?> {

        val imageFile = File(imagePath)
        if (!imageFile.exists()) {
            Log.e("VinoteIA", "Fichier image non trouvé: $imagePath")
            return createErrorMap("Fichier non trouvé")
        }

        try {
            // Load image
            val bitmap = BitmapFactory.decodeFile(imagePath)

            val imageProcessor = ImageProcessor.Builder()
                .add(ResizeOp(300, 300, ResizeOp.ResizeMethod.NEAREST_NEIGHBOR))
                .build()

            val tensorImage = imageProcessor.process(TensorImage.fromBitmap(bitmap))

            // Load TF Lite model
            val options = ObjectDetector.ObjectDetectorOptions.builder()
                .setMaxResults(10)
                .setScoreThreshold(0.5f)
                .build()

            val detector = ObjectDetector.createFromFileAndOptions(context, MODEL_FILE, options)

            val results = detector.detect(tensorImage)

            if (results.isEmpty()) {
                return createErrorMap("Aucune étiquette détectée ou modèle non entraîné.")
            }

            // Dummy return structure
            return mapOf(
                "labelName" to "Vin Reconnu TFLite",
                "region" to "Vallée du Rhône",
                "grapeVariety" to "Syrah/Grenache",
                "vintage" to 2020,
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
