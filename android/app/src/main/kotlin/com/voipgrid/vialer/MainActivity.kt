package com.voipgrid.vialer

import SystemTones
import android.content.Intent
import android.os.Build
import android.view.WindowManager
import androidx.annotation.NonNull
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import com.voipgrid.vialer.IncomingCallActivity.Companion.INCOMING_CALL_CANCEL_INTENT
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import org.openvoipalliance.flutterphonelib.*

class MainActivity : FlutterActivity(), CallScreenBehavior {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        val binaryMessenger = flutterEngine.dartExecutor.binaryMessenger

        NativeLogging.setUp(binaryMessenger, App.logger)
        ContactSortHostApi.setUp(binaryMessenger, object : ContactSortHostApi {
            override fun getSorting(): ContactSort {
                return ContactSort(orderBy = OrderBy.FAMILYNAME)
            }
        })

        NativeIncomingCallScreen.setUp(binaryMessenger, object : NativeIncomingCallScreen {
            override fun launch(
                remotePartyHeading: String,
                remotePartySubheading: String,
                imageUri: String,
            ) {
                this@MainActivity.launchIncomingCallScreen(
                    remotePartyHeading, remotePartySubheading, when {
                        imageUri.isNullOrBlank() -> null
                        else -> imageUri
                    }
                )
            }
        })

        Tones.setUp(
            binaryMessenger,
            SystemTones(this, App.logger)
        )

        NativeMetrics.setUp(binaryMessenger, object : NativeMetrics {
            override fun initialize() {
                App.segment.initialize()
            }
        })

        CallThrough.setUp(binaryMessenger, CallThroughCalling(this, App.logger, App.segment))

        CallScreenBehavior.setUp(binaryMessenger, this)

        val androidAppUpdates = AndroidFlexibleUpdateHandler(binaryMessenger)

        val updater = AppUpdater(
            this@MainActivity,
            onUpdateTypeKnown = { isFlexible ->
                androidAppUpdates.onUpdateTypeKnown(isFlexible) { return@onUpdateTypeKnown  }
            },
            onFlexibleUpdateDownloaded = {
                androidAppUpdates.onDownloaded {
                    Result.success(Unit)
                }
            }
        )

        AppUpdates.setUp(
            binaryMessenger,
            object : AppUpdates {
                override fun check() = updater.check()
                override fun completeAndroidFlexibleUpdate() = updater.completeFlexibleUpdate()
            }
        )

        Contacts.setUp(binaryMessenger, ContactImporter(this))

        GooglePlayServices.setUp(binaryMessenger, object : GooglePlayServices {
            override fun isAvailable(): Boolean {
                val googlePlayServices = GoogleApiAvailability.getInstance()
                val status = googlePlayServices.isGooglePlayServicesAvailable(this@MainActivity)
                return status == ConnectionResult.SUCCESS
            }
        })
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

    protected override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        when (intent.action) {
            Intent.ACTION_DIAL, Intent.ACTION_CALL, Intent.ACTION_VIEW ->
                call(intent.data?.schemeSpecificPart ?: "")
        }
        setIntent(intent);
    }

    private fun call(number: String) {
        App.segment.track("call-from-os-initiated", mapOf())

        val normalizedNumber = number.replace(Regex("[^0-9\\+]"), "")
        if (normalizedNumber.isNotEmpty()) {
            startCall(normalizedNumber)
        }
    }

    protected override fun onResume() {
        super.onResume()

        val pressedNotification = getIntent()?.getBooleanExtra(PhoneLib.PRESSED_MISSED_CALL_NOTIFICATION_EXTRA, false)
        if (pressedNotification == true) {
            PhoneLib.notifyMissedCallNotificationPressed()
        }
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