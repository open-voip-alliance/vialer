package com.voipgrid.vialer

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

class FlutterSharedPreferences(private val context: Context) {
    private val prefs =
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

    val systemUser
        get() = JSONObject(prefs.getString(FLUTTER_SHARED_PREF_SYSTEM_USER, "{}")!!)

    val voipConfig
        get() = JSONObject(prefs.getString(FLUTTER_SHARED_PREF_VOIP_CONFIG, "{}")!!)

    var pushToken
        get() = prefs.getString(FLUTTER_SHARED_PREF_PUSH_TOKEN, "")
        set(value) = prefs.edit().putString(FLUTTER_SHARED_PREF_PUSH_TOKEN, value).apply()

    private val settings
        get() = JSONArray(prefs.getString(FLUTTER_SHARED_PREF_SETTINGS, "[]"))

    fun getSetting(name: String, defaultValue: String = ""): String {
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
        private const val FLUTTER_SHARED_PREF_PUSH_TOKEN = "${SHARED_PREF_PREFIX}push_token"
        private const val FLUTTER_SHARED_PREF_SETTINGS = "${SHARED_PREF_PREFIX}settings"
    }
}