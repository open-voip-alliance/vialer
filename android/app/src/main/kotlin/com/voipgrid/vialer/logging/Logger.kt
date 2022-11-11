package com.voipgrid.vialer.logging

import android.content.Context
import android.util.Log as AndroidLog
import com.voipgrid.vialer.Pigeon
import kotlinx.coroutines.*
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import org.openvoipalliance.flutterphonelib.PhoneLibLogLevel
import org.openvoipalliance.flutterphonelib.PhoneLibLogLevel.*
import java.time.ZoneId
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import java.util.Calendar


class Logger(context: Context) : Pigeon.NativeLogging {
    private val ioScope = CoroutineScope(Dispatchers.IO)
    private val loggingDatabase = LoggingDatabase(context)
    private val httpClient = OkHttpClient()

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
            DEBUG -> AndroidLog.d(CONSOLE_LOG_KEY, formattedMessage)
            INFO -> AndroidLog.i(CONSOLE_LOG_KEY, formattedMessage)
            WARNING -> AndroidLog.w(CONSOLE_LOG_KEY, formattedMessage)
            ERROR -> AndroidLog.e(CONSOLE_LOG_KEY, formattedMessage)
        }
    }

    private fun logToDatabase(message: String, level: PhoneLibLogLevel) =
        loggingDatabase.insertLog(message, level, loggerName = "APL")

    override fun startNativeConsoleLogging() {
        isConsoleLoggingEnabled = true
    }

    override fun stopNativeConsoleLogging() {
        isConsoleLoggingEnabled = false
    }

    override fun removeStoredLogs(keepPastDay: Boolean, result: Pigeon.Result<Void>) {
        loggingDatabase.removeLogs(
            before = when {
                // Current time minus 24 hours.
                keepPastDay -> Calendar.getInstance().timeInMillis - (24 * 60 * 60 * 1000)
                else -> null
            },
            inclusive = false
        )

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
        ioScope.launch {
            var logs = loggingDatabase.getLogs(batchSize)
            while (logs.isNotEmpty()) {
                val logsJson = logs.joinToString(separator = ", ", prefix = "[", postfix = "]") {
                    val message = JSONObject.quote(
                        // language=JSON
                        """
                        {
                            "user": "$remoteLoggingId",
                            "logged_from": "${it.name}",
                            "message": "${it.message}",
                            "level": "${it.level.ordinal}",
                            "app_version": "$appVersion"
                        }
                        """.trimIndent()
                    )

                    // Note: `message` is surrounded in quotes already.
                    // language=JSON
                    """
                    [
                        "${it.time * 1000 * 1000}",
                        $message
                    ]
                    """.trimIndent()
                }

                // language=JSON
                val json =
                    """
                    {
                        "token": "$logToken",
                        "app_id": "$packageName",
                        "logs": $logsJson
                    }
                    """.trimIndent()

                val response = httpClient
                    .newCall(
                        Request.Builder()
                            .url(url)
                            .post(json.toRequestBody("application/json".toMediaType()))
                            .build()
                    )
                    .execute()

                if (!response.isSuccessful) {
                    result.error(ApiException(response))
                    return@launch
                }

                loggingDatabase.removeLogs(
                    after = logs.first().time,
                    before = logs.last().time
                )

                logs = loggingDatabase.getLogs(batchSize)
            }

            // All logs are processed.
            result.success(null)
        }
    }

    companion object {
        private const val CONSOLE_LOG_KEY = "VIALER-APL"
    }
}

private class ApiException(response: Response) : Exception() {
    override val message = "API call failed (${response.code}), body: ${response.message}"
}
