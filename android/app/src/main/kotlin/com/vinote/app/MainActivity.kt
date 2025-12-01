package com.vinote.app

import android.os.Bundle
import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.vinote.app/recognition"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "recognizeLabel") {
                val imagePath: String? = call.argument("path")

                if (imagePath != null) {
                    try {
                        // Run inference logic (replace with coroutine if long-running)
                        val recognizedData = AIRunner.runInference(applicationContext, imagePath)
                        result.success(recognizedData)
                    } catch (e: Exception) {
                        Log.e("AI_ERROR", "Model execution failed", e)
                        result.error("AI_EXECUTION_ERROR", "Model execution failed.", e.message)
                    }
                } else {
                    result.error("INVALID_PATH", "Image path is null.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
