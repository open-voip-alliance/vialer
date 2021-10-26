package com.voipgrid.vialer

import com.voipgrid.vialer.logging.Logger
import io.flutter.app.FlutterApplication
import org.openvoipalliance.flutterphonelib.startPhoneLib

class App : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        logger = Logger(this)
        startPhoneLib(MainActivity::class.java) { message, level ->
            logger.writeLog(message, level)
        }
    }

    companion object {
        lateinit var logger: Logger
    }
}