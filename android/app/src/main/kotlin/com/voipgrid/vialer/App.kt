package com.voipgrid.vialer

import io.flutter.app.FlutterApplication
import org.openvoipalliance.flutterphonelib.startPhoneLib

class App : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        startPhoneLib(MainActivity::class.java)
    }
}