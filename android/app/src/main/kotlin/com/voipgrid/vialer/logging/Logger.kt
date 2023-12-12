package com.voipgrid.vialer.logging

import android.content.Context
import android.util.Log
import com.logentries.logger.AndroidLogger
import com.voipgrid.vialer.FlutterSharedPreferences
import com.voipgrid.vialer.NativeLogging
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import org.openvoipalliance.flutterphonelib.PhoneLibLogLevel
import org.openvoipalliance.flutterphonelib.PhoneLibLogLevel.*
import java.io.File
import java.time.ZoneId
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter

typealias LogEntries = AndroidLogger

class Logger(private val context: Context, private val prefs: FlutterSharedPreferences) :
    NativeLogging {

    private var anonymizationRules: Map<String, String> = mapOf()
    private var logEntries: LogEntries? = null
    private var userIdentifier: String? = null
    private var isConsoleLoggingEnabled = false
    private val isRemoteLoggingEnabled
        get() = logEntries != null

    internal fun writeLog(message: String, level: PhoneLibLogLevel = INFO) {
        if (isConsoleLoggingEnabled) {
            logToConsole(message, level)
        }

        if (isRemoteLoggingEnabled) {
            logToRemote(message, level)
        }
    }

    private fun logToConsole(message: String, level: PhoneLibLogLevel) {
        // Format message to be consistent with Dart logs.
        val time = DateTimeFormatter.ofPattern("uuuu-MM-dd HH-mm-ss.SSSSSS")
            .format(ZonedDateTime.now(ZoneId.systemDefault()))

        val formattedMessage = "[$time] $level APL: $message"

        when (level) {
            DEBUG -> Log.i(CONSOLE_LOG_KEY, formattedMessage)
            INFO -> Log.i(CONSOLE_LOG_KEY, formattedMessage)
            WARNING -> Log.w(CONSOLE_LOG_KEY, formattedMessage)
            ERROR -> Log.e(CONSOLE_LOG_KEY, formattedMessage)
        }

        if (prefs.user != null) {
            // Temporarily disabled due to OOM issues. Should be re-enabled and use a file backing
            // rather than storing logs in memory.
            //MainScope().launch { prefs.appendLogs(anonymize(formattedMessage)) }
        }
    }

    private fun logToRemote(message: String, level: PhoneLibLogLevel) = anonymize(message).also {
        logEntries?.log("$userIdentifier $level $it")
    }

    private fun anonymize(message: String) =
        anonymizationRules.asIterable().fold(message) { acc, entry ->
            acc.replace(entry.key.toRegex(), entry.value)
        }

    override fun startNativeRemoteLogging(
        token: String,
        userIdentifier: String,
        anonymizationRules: Map<String, String>,
        callback: (Result<Unit>) -> Unit
    ) {
        logEntries = createRemoteLogger(token)
        this.userIdentifier = userIdentifier
        this.anonymizationRules = anonymizationRules
        callback(Result.success(Unit))
    }

    override fun startNativeConsoleLogging() {
        isConsoleLoggingEnabled = true
    }

    override fun stopNativeRemoteLogging() {
        logEntries = null
        userIdentifier = null
    }

    override fun stopNativeConsoleLogging() {
        isConsoleLoggingEnabled = false
    }

    private fun createRemoteLogger(token: String) = File(context.filesDir, LOG_FILE).apply {
        if (!exists()) {
            createNewFile()
        }
    }.run {
        AndroidLogger.createInstance(
            context,
            false,
            true,
            false,
            null,
            0,
            token,
            false,
        )
    }

    companion object {
        private const val CONSOLE_LOG_KEY = "VIALER-PIL"
        private const val LOG_FILE = "LogentriesLogStorage.log"
    }
}