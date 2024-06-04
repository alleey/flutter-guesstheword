package io.alleey.development.guess_the_word

import android.content.pm.PackageManager
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "android.native"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {

        GeneratedPluginRegistrant.registerWith(flutterEngine);
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->

            if (call.method == "isAndroidTV") {
                result.success(
                    hasSystemFeature(PackageManager.FEATURE_LEANBACK) ||
                    hasSystemFeature(PackageManager.FEATURE_LEANBACK_ONLY) ||
                    hasSystemFeature(PackageManager.FEATURE_TELEVISION)
                )
            } else {
                result.notImplemented()
            }
        }
    }

    fun hasSystemFeature(feature: String): Boolean {
        return this.packageManager.hasSystemFeature(feature)
    }
}