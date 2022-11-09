package com.voipgrid.vialer.logging

import android.content.Context
import android.util.Log
import com.voipgrid.vialer.FlutterSharedPreferences
import com.voipgrid.vialer.Pigeon
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import org.openvoipalliance.flutterphonelib.PhoneLibLogLevel
import org.openvoipalliance.flutterphonelib.PhoneLibLogLevel.*
import java.time.ZoneId
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter

class Logger(private val context: Context, private val prefs: FlutterSharedPreferences) :
    Pigeon.NativeLogging {

    private var anonymizationRules: Map<String, String> = mapOf()
    private var loggingDatabase = LoggingDatabase(context)
    private var userIdentifier: String? = null
    private var isConsoleLoggingEnabled = false

    internal fun writeLog(message: String, level: PhoneLibLogLevel = INFO) {
        if (isConsoleLoggingEnabled) {
            logToConsole(message, level)
        }

        logToDatabase(message, level)
    }

    private fun logToConsole(message: String, level: PhoneLibLogLevel) {
        // Format message to be consistent with Dart logs.
        val time = DateTimeFormatter.ofPattern("uuuu-MM-dd HH:mm:ss.SSSSSS")
            .format(ZonedDateTime.now(ZoneId.systemDefault()))

        val formattedMessage = "[$time] $level APL: $message"

        when (level) {
            DEBUG -> Log.d(CONSOLE_LOG_KEY, formattedMessage)
            INFO -> Log.i(CONSOLE_LOG_KEY, formattedMessage)
            WARNING -> Log.w(CONSOLE_LOG_KEY, formattedMessage)
            ERROR -> Log.e(CONSOLE_LOG_KEY, formattedMessage)
        }

        if (prefs.systemUser != null) {
            MainScope().launch { prefs.appendLogs(anonymize(formattedMessage)) }
        }
    }

    private fun logToDatabase(message: String, level: PhoneLibLogLevel) = anonymize(message).also {
        loggingDatabase?.insertLog(it, level, loggerName = "APL")
    }

    private fun anonymize(message: String) =
        anonymizationRules.asIterable().fold(message) { acc, entry ->
            acc.replace(entry.key.toRegex(), entry.value)
        }

    override fun startNativeConsoleLogging() {
        isConsoleLoggingEnabled = true
    }

    override fun stopNativeConsoleLogging() {
        isConsoleLoggingEnabled = false
    }

    override fun removeStoredLogs(keepPastDay: Boolean, result: Pigeon.Result<Void>) {
        result.success(null)
    }

    override fun uploadPendingLogs(
        batchSize: Long,
        packageName: String,
        appVersion: String,
        remoteLoggingId: String,
        url: String,
        logToken: String,
        result: Pigeon.Result<Void>
    ) {
        result.success(null)
    }

    companion object {
        private const val CONSOLE_LOG_KEY = "VIALER-PIL"
    }
}
