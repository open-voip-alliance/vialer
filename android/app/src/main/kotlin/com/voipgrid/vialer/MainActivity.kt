package com.voipgrid.vialer

import android.content.Intent
import android.os.Build
import android.view.WindowManager
import androidx.annotation.NonNull
import com.voipgrid.vialer.Pigeon.ContactSort
import com.voipgrid.vialer.logging.Logger
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CALL_SCREEN_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enableCallScreenBehavior" -> enableCallScreenBehavior()
                    "disableCallScreenBehavior" -> disableCallScreenBehavior()
                    else -> result.notImplemented()
                }
            }

        Pigeon.NativeLogging.setup(flutterEngine.dartExecutor.binaryMessenger, App.logger)
        Pigeon.ContactSortHostApi.setup(flutterEngine.dartExecutor.binaryMessenger
        ) { ContactSort().apply { orderBy = Pigeon.OrderBy.familyName } }

        Pigeon.NativeIncomingCallScreen.setup(flutterEngine.dartExecutor.binaryMessenger) {
                remotePartyHeading, remotePartySubheading, imageUri ->
            this.launchIncomingCallScreen(remotePartyHeading, remotePartySubheading, when {
                imageUri.isNullOrBlank() -> null
                else -> imageUri
            })
        }

        Pigeon.NativeMetrics.setup(flutterEngine.dartExecutor.binaryMessenger) {
             App.segment.initialize()
        }
    }

    private fun enableCallScreenBehavior() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(legacyFlags)
        }
    }

    private fun disableCallScreenBehavior() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(false)
            setTurnScreenOn(false)
        } else {
            window.clearFlags(legacyFlags)
        }
    }

    companion object {

        private const val CALL_SCREEN_CHANNEL = "com.voipgrid.vialer/callScreen"

        /**
         * These are the flags required for call screen behaviour in <= Android 8.0
         */
        const val legacyFlags = (WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                or WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                or WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
                or WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON)
    }
}
