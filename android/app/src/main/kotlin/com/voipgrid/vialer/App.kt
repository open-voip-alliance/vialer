package com.voipgrid.vialer

import com.voipgrid.vialer.logging.Logger
import io.flutter.app.FlutterApplication
import org.openvoipalliance.flutterphonelib.*

class App : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        prefs = FlutterSharedPreferences(this)
        logger = Logger(this, prefs)
        segment = Segment(this, logger, prefs)
        middleware = Middleware(this, logger, prefs, segment)

        startPhoneLib(
            activityClass = MainActivity::class.java,
            incomingCallActivityClass = IncomingCallActivity::class.java,
            nativeMiddleware = middleware,
            // We need a standardized way to track that an incoming call has ended so it is done here
            // instead of in Flutter as voip calls can end before Flutter is ready.
            onCallEnded = { reason ->
                middleware.currentCallInfo?.let {
                    segment.track("voip-call-ended", mapOf(
                        "call_id" to it.callId,
                        "correlation_id" to it.correlationId,
                        "push_received_time" to it.pushReceivedTime,
                        "reason" to reason,
                    ))
                }

                middleware.currentCallInfo = null
            }
        ) { message, level ->
            logger.writeLog(message, level)
        }

        segment.initialize()
    }

    companion object {
        lateinit var logger: Logger
        lateinit var middleware: Middleware
        lateinit var segment: Segment
        lateinit var prefs: FlutterSharedPreferences
    }
}