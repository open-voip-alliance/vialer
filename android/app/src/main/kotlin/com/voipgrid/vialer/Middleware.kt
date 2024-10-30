package com.voipgrid.vialer

import LoggedInElsewhereNotification
import android.content.Context
import android.os.Build
import com.google.firebase.messaging.RemoteMessage
import com.voipgrid.vialer.logging.Logger
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import org.openvoipalliance.flutterphonelib.NativeMiddleware
import org.openvoipalliance.flutterphonelib.NativeMiddlewareUnavailableReason
import java.io.IOException
import java.math.BigDecimal

class Middleware(
    private val context: Context,
    private val logger: Logger,
    private val prefs: FlutterSharedPreferences,
    private val segment: Segment,
    private val loggedInElsewhereNotification: LoggedInElsewhereNotification,
) : NativeMiddleware {
    private val client = OkHttpClient()

    /**
     * Store the information from the push message that was received so we can submit this at the
     * end of the call to provide better metrics regarding our reliability.
     */
    var currentCallInfo: CurrentCallInfo? = null

    /**
     * We want to make sure to not process multiple push notifications for the same call (as the
     * middleware will send up to 8). So we'll track the calls we are currently handling and make
     * sure to ignore any with the same id in the future.
     */
    private var callIdsBeingHandled = mutableListOf<String>()

    val baseUrl: String
        get() {
            val base = prefs.user?.client?.voip?.middlewareUrl
                ?: context.getString(R.string.middleware_url)
            return "$base/api"
        }

    override fun tokenReceived(token: String) {
        prefs.pushToken = token

        val middlewareCredentials = middlewareCredentials

        if (middlewareCredentials == null) {
            log("Registration cancelled: Middleware credentials are not set.")
            return
        }

        val jsonObject = JSONObject().apply {
            put("name", middlewareCredentials.email)
            put("token", token)
            put("sip_user_id", middlewareCredentials.sipUserId)
            put("os_version", Build.VERSION.RELEASE)
            put("client_version", BuildConfig.VERSION_NAME.split('-').first())
            put("app", context.packageName)
            put("dnd", false)
            put("app_startup_timestamp", prefs.loginTime)
        }

        val requestBody = jsonObject.toString().toRequestBody("application/json".toMediaType())

        val request = createMiddlewareRequest(
            middlewareCredentials.email,
            middlewareCredentials.loginToken,
            url = "${baseUrl}/android-device/",
        )
            .post(requestBody)
            .build()

        client.newCall(request).enqueue(
            object : Callback {
                override fun onFailure(call: Call, e: IOException) {
                    log("Registration failed: ${e.localizedMessage}")
                }

                override fun onResponse(call: Call, response: Response) = response.use {
                    when (response.isSuccessful) {
                        true -> log("Registration successful")
                        false -> {
                            log("Registration failed: response code was ${response.code}")
                        }
                    }
                }
            }
        )
    }

    override fun respond(
        remoteMessage: RemoteMessage,
        available: Boolean,
        reason: NativeMiddlewareUnavailableReason?,
    ) {
        val middlewareCredentials = middlewareCredentials
        val callId = remoteMessage.callId!!
        val correlationId = remoteMessage.correlationId!!
        val callStartTime = remoteMessage.messageStartTime!!
        val pushSentTime = remoteMessage.pushSentTime
        val pushResponseTime = remoteMessage.secondsSincePushWasSent
        val responseUrl = remoteMessage.responseUrl!!

        log("Middleware Respond: Attempting for call=$callId, correlationId=$correlationId, available=$available, sent at=$pushSentTime, response time=$pushResponseTime")

        if (middlewareCredentials == null) {
            log("Middleware credentials are not set, not responding.")
            return
        }

        if (pushResponseTime > MIDDLEWARE_SECONDS_BEFORE_REJECTED) {
            log("The response time is $pushResponseTime, it is likely we are too late for this call.")
        }

        val data = FormBody.Builder().apply {
            add("unique_key", callId)
            add("available", available.toString())
            add("message_start_time", callStartTime)
            add("sip_user_id", middlewareCredentials.sipUserId)
        }.build()

        val request = createMiddlewareRequest(
            middlewareCredentials.email,
            middlewareCredentials.loginToken,
            url = responseUrl,
        )
            .post(data)
            .build()

        // Capturing as a callback just to cut down on some code duplication.
        val track: (middlewareResponse: String) -> Unit = {
            trackNotificationResult(
                remoteMessage,
                it,
                available,
                reason,
                pushResponseTime,
            )
        }

        client.newCall(request).enqueue(
            object : Callback {
                override fun onFailure(call: Call, e: IOException) {
                    track("error")
                    log("Middleware respond Failed: with ${e.localizedMessage}")
                }

                override fun onResponse(call: Call, response: Response) {
                    track(response.code.toString())

                    when (response.isSuccessful) {
                        true -> log("Middleware respond success: $callId")
                        false -> log("Middleware respond failed: response code was ${response.code}")
                    }
                }
            }
        )

        // If we are responding as available, we are going to store this data to submit at the
        // end of the call. We don't want to update this when available=false because this would
        // overwrite the data if we have an ongoing call.
        if (available) {
            currentCallInfo = remoteMessage.toCurrentCallInfo()
        }
    }

    override fun inspect(remoteMessage: RemoteMessage): Boolean {
        if (remoteMessage.isLoggedInSomewhereElse) {
            log("User has logged in somewhere else, marking as such..")
            loggedInElsewhereNotification.show()
            prefs.isLoggedInSomewhereElse = true
            return false
        }

        if (!remoteMessage.isCall) return false

        if (isCallAlreadyBeingHandled(remoteMessage)) {
            log("Ignoring push message as we are already handling it: ${remoteMessage.callId}")
            return false
        }

        return true.also {
            segment.track(
                "middleware-notification-received", remoteMessage.trackingProperties + mapOf(
                    "seconds_from_call_to_received" to remoteMessage.secondsSincePushWasSent.toString(),
                    "is_ignoring_battery_optimizations" to context.isIgnoringBatteryOptimizations.toString(),
                    "middleware_url" to baseUrl,
                )
            )
        }
    }

    private fun trackNotificationResult(
        remoteMessage: RemoteMessage,
        middlewareResponse: String,
        available: Boolean,
        reason: NativeMiddlewareUnavailableReason? = null,
        responseTime: Long,
    ) =
        segment.track(
            "middleware-responded", remoteMessage.trackingProperties + mapOf(
                "middleware_response" to middlewareResponse,
                "available" to available.toString(),
                "unavailable_reason" to (reason?.name ?: ""),
                "seconds_from_call_to_responded" to responseTime.toString(),
                "is_ignoring_battery_optimizations" to context.isIgnoringBatteryOptimizations.toString(),
                "middleware_url" to baseUrl,
            )
        )

    /**
     * Check to see if a call is being handled currently, if we are handling the call already
     * we do not want to process future push notifications.
     *
     * The id being tracked will also be updated here.
     */
    private fun isCallAlreadyBeingHandled(remoteMessage: RemoteMessage) =
        callIdsBeingHandled.contains(remoteMessage.callId).also {
            log("Handling inbound call: ${remoteMessage.callId}")
            remoteMessage.callId?.let { callIdsBeingHandled.add(it) }
        }

    private fun createMiddlewareRequest(email: String, token: String, url: String) =
        Request.Builder().url(url).addHeader("Authorization", "Token $email:$token")

    private fun log(message: String) = logger.writeLog("NATIVE-MIDDLEWARE: $message")

    private val middlewareCredentials
        get() = prefs.user?.let { user ->
            user.voip?.let { voip ->
                MiddlewareCredentials(
                    sipUserId = voip.sipUserId,
                    email = user.email,
                    loginToken = user.token
                )
            }
        }

    companion object {
        /**
         * The number of seconds that the Middleware will wait for us to respond before the call
         * will be rejected.
         */
        private const val MIDDLEWARE_SECONDS_BEFORE_REJECTED = 8
    }

    private data class MiddlewareCredentials(
        val email: String,
        val loginToken: String,
        val sipUserId: String
    )

    data class CurrentCallInfo(
        val callId: String,
        val correlationId: String,
        val pushReceivedTime: String,
    )
}

private val RemoteMessage.message
    get() = data["message"]

private val RemoteMessage.isLoggedInSomewhereElse
    get() = message?.startsWith("An other device has registered for the same account") == true

private val RemoteMessage.callId
    get() = data["unique_key"]

private val RemoteMessage.correlationId
    get() = data["vg_cid"]

private val RemoteMessage.messageStartTime
    get() = data["message_start_time"]

private val RemoteMessage.isCall
    get() = data["type"] == "call"

private val RemoteMessage.responseUrl
    get() = data["response_api"]

private val RemoteMessage.pushSentTime
    get() = try {
        val startTime = messageStartTime

        when {
            startTime == null -> 0
            else -> BigDecimal(messageStartTime).toLong()
        }
    } catch (e: Throwable) {
        0
    }

private val RemoteMessage.secondsSincePushWasSent
    get() = (System.currentTimeMillis() / 1000) - pushSentTime

private val RemoteMessage.trackingProperties
    get() = mapOf(
        "call_id" to callId,
        "correlation_id" to correlationId,
        "message_start_time" to messageStartTime,
        "push_sent_time" to pushSentTime.toString(),
        "response_url" to responseUrl,
    )

private fun RemoteMessage.toCurrentCallInfo() = Middleware.CurrentCallInfo(
    callId ?: "",
    correlationId ?: "",
    System.currentTimeMillis().toString()
)