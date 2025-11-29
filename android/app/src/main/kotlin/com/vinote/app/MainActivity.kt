package com.vinote.app

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.vinote.app/recognition"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            
            if (call.method == "recognizeLabel") {
                val imagePath = call.argument<String>("path")
                
                if (imagePath != null) {
                    // --- APPEL DE LA LOGIQUE D'IA RÉELLE ---
                    
                    // Assurez-vous que l'exécution se fait en arrière-plan si elle est longue
                    // (Ici, nous l'appelons directement pour la simplicité, mais utilisez Coroutines dans une vraie app)
                    try {
                        val recognizedData = AIRunner.runInference(applicationContext, imagePath)
                        result.success(recognizedData) // Retourne les résultats à Dart
                    } catch (e: Exception) {
                        result.error("AI_EXECUTION_ERROR", "Échec de l'exécution du modèle IA.", e.message)
                    }

                } else {
                    result.error("INVALID_PATH", "Le chemin de l'image est nul.", null)
                }

            } else {
                result.notImplemented()
            }
        }
    }
}