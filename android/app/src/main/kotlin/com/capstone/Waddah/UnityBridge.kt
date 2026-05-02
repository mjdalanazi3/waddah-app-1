package com.capstone.Waddah

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class UnityBridge(private val activity: Activity, flutterEngine: FlutterEngine) {

    companion object {
        const val CHANNEL = "com.example.waddah_app/unity"
    }

    init {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "launchUnity" -> {
                        val sceneIndex = call.argument<Int>("sceneIndex") ?: 0
                        launchUnity(sceneIndex)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun launchUnity(sceneIndex: Int) {
        // Launch Unity APK via intent
        val packageName = "com.capstone.Waddah"
        val intent = activity.packageManager
            .getLaunchIntentForPackage(packageName)
        
        if (intent != null) {
            intent.putExtra("sceneIndex", sceneIndex)
            activity.startActivity(intent)
        } else {
            // Unity app not installed
            val marketIntent = Intent(
                Intent.ACTION_VIEW,
                Uri.parse("market://details?id=$packageName")
            )
            activity.startActivity(marketIntent)
        }
    }
}