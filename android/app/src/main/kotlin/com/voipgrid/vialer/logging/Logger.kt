package com.voipgrid.vialer.logging

import android.content.Context
import android.util.Log
import com.logentries.logger.AndroidLogger
import com.voipgrid.vialer.Pigeon
import org.openvoipalliance.flutterphonelib.PhoneLibLogLevel
import org.openvoipalliance.flutterphonelib.PhoneLibLogLevel.*
import java.io.File

typealias LogEntries = AndroidLogger

class Logger(private val context: Context) : Pigeon.NativeLogging {

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
            logToRemote(message)
        }
    }

    private fun logToConsole(message: String, level: PhoneLibLogLevel) = when(level) {
        DEBUG -> Log.i(CONSOLE_LOG_KEY, message)
        INFO -> Log.i(CONSOLE_LOG_KEY, message)
        WARNING -> Log.w(CONSOLE_LOG_KEY, message)
        ERROR -> Log.e(CONSOLE_LOG_KEY, message)
    }

    private fun logToRemote(message: String) = anonymize(message).also {
        logEntries?.log("$userIdentifier $it")
    }

    private fun anonymize(message: String) =
        anonymizationRules.asIterable().fold(message) { acc, entry ->
            acc.replace(entry.key.toRegex(), entry.value)
        }

    override fun startNativeRemoteLogging(
        token: String,
        userIdentifier: String,
        anonymizationRules: MutableMap<String, String>,
        result: Pigeon.Result<Void>
    ) {
        logEntries = createRemoteLogger(token)
        this.userIdentifier = userIdentifier
        this.anonymizationRules = anonymizationRules
        result.success(null)
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