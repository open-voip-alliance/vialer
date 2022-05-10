package com.voipgrid.vialer

import SystemTones
import android.content.Intent
import android.os.Build
import android.view.WindowManager
import androidx.annotation.NonNull
import com.voipgrid.vialer.IncomingCallActivity.Companion.INCOMING_CALL_CANCEL_INTENT
import com.voipgrid.vialer.Pigeon.ContactSort
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity(), Pigeon.CallScreenBehavior {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

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

        Pigeon.CallScreenBehavior.setup(flutterEngine.dartExecutor.binaryMessenger, this)

        Pigeon.Tones.setup(flutterEngine.dartExecutor.binaryMessenger, SystemTones(this));
    }

    override fun enable() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(legacyFlags)
        }
    }

    override fun disable() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(false)
            setTurnScreenOn(false)
        } else {
            window.clearFlags(legacyFlags)
        }

        // We will make sure the incoming call screen has also finished
        sendBroadcast(Intent(INCOMING_CALL_CANCEL_INTENT))
    }

    companion object {
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
