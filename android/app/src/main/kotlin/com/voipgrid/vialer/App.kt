package com.voipgrid.vialer

import com.voipgrid.vialer.logging.Logger
import io.flutter.app.FlutterApplication
import org.openvoipalliance.flutterphonelib.startPhoneLib
import org.openvoipalliance.flutterphonelib.NativeMiddleware

class App : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        val sharedPrefs = FlutterSharedPreferences(this)
        logger = Logger(this, sharedPrefs)
        middleware = Middleware(this, logger, sharedPrefs)
        startPhoneLib(
            activityClass = MainActivity::class.java,
            incomingCallActivityClass = IncomingCallActivity::class.java,
            nativeMiddleware = middleware
        ) { message, level ->
            logger.writeLog(message, level)
        }
    }

    companion object {
        lateinit var logger: Logger
        lateinit var middleware: NativeMiddleware
    }
}