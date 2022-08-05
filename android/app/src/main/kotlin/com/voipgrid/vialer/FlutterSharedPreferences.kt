package com.voipgrid.vialer

import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import android.os.PowerManager
import kotlinx.coroutines.channels.Channel
import org.json.JSONArray
import org.json.JSONObject

class FlutterSharedPreferences(private val context: Context) {
    private val prefs: SharedPreferences =
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

    val systemUser: JSONObject?
        get() {
            val pref = prefs.getString(FLUTTER_SHARED_PREF_SYSTEM_USER, null) ?: return null
            return JSONObject(pref)
        }

    val voipConfig
        get() = JSONObject(prefs.getString(FLUTTER_SHARED_PREF_VOIP_CONFIG, "{}")!!)

    val middlewareUrl: String
        get() {
            val pref = prefs.getString(FLUTTER_SHARED_PREF_SERVER_CONFIG, null) ?: return context.getString(R.string.middleware_url)
            return JSONObject(pref).getString("MIDDLEWARE")
        }

    var pushToken
        get() = prefs.getString(FLUTTER_SHARED_PREF_PUSH_TOKEN, "")
        set(value) = prefs.edit().putString(FLUTTER_SHARED_PREF_PUSH_TOKEN, value).apply()

    var isLoggedInSomewhereElse
        get() = prefs.getBoolean(FLUTTER_SHARED_PREF_IS_LOGGED_IN_SOMEWHERE_ELSE, false)
        set(value) = prefs.edit().putBoolean(FLUTTER_SHARED_PREF_IS_LOGGED_IN_SOMEWHERE_ELSE, value)
            .apply()

    private val settings
        get() = JSONArray(prefs.getString(FLUTTER_SHARED_PREF_SETTINGS, "[]"))

    private var logs
        get() = prefs.getString(FLUTTER_SHARED_PREF_LOGS, "")
        set(value) = prefs.edit().putString(FLUTTER_SHARED_PREF_LOGS, value).apply()

    suspend fun appendLogs(log: String) {
        if (!isAppendingLogs) {
            startAppending()
        }

        appendLogsChannel.send(log)
    }

    private val appendLogsChannel = Channel<String>()
    private var isAppendingLogs: Boolean = false

    // We have to queue append operations, otherwise logs will be missing.
    private suspend fun startAppending() {
        isAppendingLogs = true
        while (isAppendingLogs) {
            val log = appendLogsChannel.receive()
            logs += "\n$log"
        }
    }

    private fun getSetting(name: String, defaultValue: String = ""): String {
        val settings = settings

        for (i in 0..settings.length()) {
            try {
                val item = (settings.get(i) as JSONObject)
                val settingName = item["type"] as String

                if (settingName == name) return item.getString("value")
            } catch (e: Exception) {
                continue
            }
        }

        return defaultValue
    }

    fun getBoolSetting(name: String, defaultValue: Boolean = false): Boolean =
        getSetting(name, defaultValue.toString()).toBoolean()

    companion object {
        private const val SHARED_PREF_PREFIX = "flutter."
        private const val FLUTTER_SHARED_PREF_SYSTEM_USER = "${SHARED_PREF_PREFIX}system_user"
        private const val FLUTTER_SHARED_PREF_VOIP_CONFIG = "${SHARED_PREF_PREFIX}voip_config"
        private const val FLUTTER_SHARED_PREF_SERVER_CONFIG = "${SHARED_PREF_PREFIX}server_config"
        private const val FLUTTER_SHARED_PREF_PUSH_TOKEN = "${SHARED_PREF_PREFIX}push_token"
        private const val FLUTTER_SHARED_PREF_SETTINGS = "${SHARED_PREF_PREFIX}settings"
        private const val FLUTTER_SHARED_PREF_LOGS = "${SHARED_PREF_PREFIX}logs"
        private const val FLUTTER_SHARED_PREF_IS_LOGGED_IN_SOMEWHERE_ELSE =
            "${SHARED_PREF_PREFIX}is_logged_in_somewhere_else"
    }
}

val Context.isIgnoringBatteryOptimizations: Boolean
    get() {
        val pm: PowerManager = this.getSystemService(Context.POWER_SERVICE) as PowerManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return pm.isIgnoringBatteryOptimizations(this.getPackageName())
        }
        return true;
    }