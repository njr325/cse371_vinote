package com.vinote.app

import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.vinote.app/recognition"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "recognizeLabel") {

                val imagePath: String? = call.argument("path")

                if (imagePath == null) {
                    result.error("INVALID_PATH", "Image path is null.", null)
                    return@setMethodCallHandler
                }

                try {
                    val recognizedData =
                        AIRunner.runInference(applicationContext, imagePath)

                    result.success(recognizedData)

                } catch (e: Exception) {
                    Log.e("AI_ERROR", "Model execution failed", e)
                    result.error("AI_EXECUTION_ERROR", "Model execution failed.", e.message)
                }

            } else {
                result.notImplemented()
            }
        }
    }
}
