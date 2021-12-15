package com.voipgrid.vialer

import android.content.Context
import com.segment.analytics.Analytics
import com.segment.analytics.Properties
import com.voipgrid.vialer.logging.Logger
import org.json.JSONObject

class Segment(
    private val context: Context,
    private val logger: Logger,
    private val prefs: FlutterSharedPreferences,
) {
    private var instance: Analytics? = null
    private var isIdentified = false

    fun initialize(key: String? = null) {
        val metricsKey = key ?: (prefs.metricsKey ?: run {
            logger.writeLog("Unable to initialize metrics, there is no key.")
            return
        })

        instance = Analytics.Builder(context, metricsKey)
            .tag("${INSTANCE_TAG}_$metricsKey")
            .build()
    }

    fun track(event: String, properties: Map<String, String?>) {
        identifyIfNecessary()

        val segmentProperties = Properties().apply {
            properties.forEach {
                putValue(it.key, it.value)
            }
        }

        val instance = instance ?: run {
            logger.writeLog("Segment not initialized, logging event: $event with properties: ${JSONObject(properties)}")
            return
        }

        instance.track(event, segmentProperties)
    }

    /**
     * Identify the user if we haven't done so already, this needs to happen on every track call
     * as the user may be stored after the metrics are initialized.
     */
    private fun identifyIfNecessary() {
        val systemUser = prefs.systemUser ?: run {
            logger.writeLog("Unable to identify user for native metrics.")
            return
        }

        val instance = instance ?: run {
            logger.writeLog("Unable to identify user before instance is initialized")
            return
        }

        instance.identify(systemUser.getString("uuid"))
        isIdentified = true
    }

    companion object {
        const val INSTANCE_TAG = "SEGMENT_NATIVE_ANDROID"
    }
}