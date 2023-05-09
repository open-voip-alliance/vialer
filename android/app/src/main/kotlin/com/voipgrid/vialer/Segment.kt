package com.voipgrid.vialer

import android.content.Context
import com.segment.analytics.Analytics
import com.segment.analytics.Properties
import com.voipgrid.vialer.logging.Logger
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.json.JSONObject

class Segment(
    private val context: Context,
    private val logger: Logger,
    private val prefs: FlutterSharedPreferences,
) {
    private var isIdentified = false

    fun initialize() {
        if (instance != null) return

        val metricsKey = context.getString(R.string.segment_android_key)
        isIdentified = false

        if (metricsKey.isBlank()) {
            logger.writeLog("Unable to initialize metrics, there is no key.")
            return
        }

        instance = Analytics.Builder(context, metricsKey)
            .tag("${INSTANCE_TAG}_$metricsKey")
            .build()

        Analytics.setSingletonInstance(instance)
        Analytics.with(context).analyticsContext.apply {
            putValue("ip", "0.0.0.0")
            device().apply {
                putValue("advertisingId", "")
                putValue("id", "")
                putValue("token", "")
            }
        }
    }

    fun track(event: String, properties: Map<String, String?>) = identifyIfNecessary {
        assert(event.matches("[a-z]+(-[a-z]+)*".toRegex())) { "Event name not in param-casing." }

        val segmentProperties = Properties().apply {
            properties.forEach {
                putValue(it.key, it.value)
            }
        }

        val instance = instance ?: run {
            logger.writeLog("Segment not initialized, logging event: $event with properties: ${JSONObject(properties)}")
            return@identifyIfNecessary
        }

        instance.track(event, segmentProperties)
    }

    /**
     * Identify the user if we haven't done so already, this needs to happen on every track call
     * as the user may be stored after the metrics are initialized.
     *
     * @return TRUE if the user had to be identified, in this case we should delay future events.
     */
    private fun identifyIfNecessary(callback: () -> Unit) {
        if (isIdentified) {
            callback()
            return
        }

        val user = prefs.user ?: run {
            logger.writeLog("Unable to identify user for native metrics.")
            return
        }

        val instance = instance ?: run {
            logger.writeLog("Unable to identify user before instance is initialized")
            return
        }

        instance.identify(user.uuid)
        isIdentified = true
        logger.writeLog("Identifying user so waiting for ${DELAY_AFTER_IDENTIFY}ms to track")

        CoroutineScope(Dispatchers.IO).launch {
            delay(DELAY_AFTER_IDENTIFY)
            logger.writeLog("Executing delayed track")
            callback()
        }
    }

    companion object {
        const val INSTANCE_TAG = "SEGMENT_NATIVE_ANDROID"

        private var instance: Analytics? = null

        /**
         * The amount of time to wait after identification before sending a track event.
         *
         * This is to prevent a race condition where a track would be received by Segment before
         * the identify and would therefore not be tracked.
         */
        const val DELAY_AFTER_IDENTIFY = 5000L
    }
}