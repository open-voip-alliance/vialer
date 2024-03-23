package com.voipgrid.vialer

import SystemTones
import android.content.ClipboardManager
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import android.view.textclassifier.TextClassifier
import androidx.annotation.NonNull
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import com.google.firebase.ktx.Firebase
import com.google.firebase.messaging.ktx.messaging
import com.voipgrid.vialer.IncomingCallActivity.Companion.INCOMING_CALL_CANCEL_INTENT
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import org.openvoipalliance.flutterphonelib.PhoneLib

class MainActivity : FlutterActivity(), CallScreenBehavior {
    private lateinit var nativeToFlutter: NativeToFlutter

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        val binaryMessenger = flutterEngine.dartExecutor.binaryMessenger

        NativeLogging.setUp(binaryMessenger, App.logger)
        ContactSortHostApi.setUp(binaryMessenger, object : ContactSortHostApi {
            override fun getSorting(): ContactSort {
                return ContactSort(orderBy = OrderBy.FAMILY_NAME)
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

        SharedContacts.setUp(binaryMessenger, object : SharedContacts {
            override fun processSharedContacts(contacts: List<NativeSharedContact>) {}
            override fun isCallDirectoryExtensionEnabled(callback: (Result<Boolean>) -> Unit) = callback(Result.success(false))
            override fun directUserToConfigureCallDirectoryExtension() {}
        })

        MiddlewareRegistrar.setUp(binaryMessenger, object : MiddlewareRegistrar {
            override fun register(token: String) = App.middleware.tokenReceived(token)
        })

        nativeToFlutter = NativeToFlutter(binaryMessenger);

        NativeClipboard.setUp(binaryMessenger, object : NativeClipboard {
            override fun hasPhoneNumber(callback: (Result<Boolean>) -> Unit) {
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
                    callback(Result.success(false))
                    return
                }

                val clipboard = context.getSystemService(ClipboardManager::class.java)
                val confidenceScore = clipboard.primaryClipDescription?.getConfidenceScore(
                    TextClassifier.TYPE_PHONE)
                callback(Result.success(confidenceScore != null && confidenceScore > 0.8))
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
        intent.onCallAction { number -> call(number) }
        setIntent(intent);
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        intent.onCallAction { number -> call(number) }
    }

    private fun call(number: String) {
        val normalizedNumber = number.replace(Regex("[^0-9\\+]"), "")
        if (normalizedNumber.isNotEmpty()) {
            nativeToFlutter.launchDialerAndPopulateNumber(normalizedNumber) {}
        }
    }

    protected override fun onResume() {
        super.onResume()

        val pressedNotification = intent?.getBooleanExtra(PhoneLib.PRESSED_MISSED_CALL_NOTIFICATION_EXTRA, false)
        if (pressedNotification == true) {
            PhoneLib.notifyMissedCallNotificationPressed()
        }

        Firebase.messaging.token.addOnSuccessListener {
            it?.let {
                App.middleware.tokenReceived(it)
            }
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

fun Intent.onCallAction(callback: (number: String) -> Unit) = when (action) {
    Intent.ACTION_DIAL, Intent.ACTION_CALL, Intent.ACTION_VIEW -> callback(data?.schemeSpecificPart ?: "")
    else -> {}
}