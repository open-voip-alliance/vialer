package com.voipgrid.vialer

import com.voipgrid.vialer.logging.Logger
import io.flutter.app.FlutterApplication
import org.openvoipalliance.flutterphonelib.startPhoneLib
import org.openvoipalliance.flutterphonelib.NativeMiddleware

class App : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        logger = Logger(this)
        middleware = Middleware(this, logger)
        startPhoneLib(
            activityClass = MainActivity::class.java,
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