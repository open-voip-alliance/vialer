package com.voipgrid.vialer

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkInfo
import android.os.Build
import com.google.firebase.messaging.RemoteMessage
import com.voipgrid.vialer.logging.Logger
import okhttp3.*
import org.openvoipalliance.flutterphonelib.NativeMiddleware
import org.openvoipalliance.flutterphonelib.PhoneLibLogLevel
import java.io.IOException

class Middleware(
    private val context: Context,
    private val logger: Logger,
    private val prefs: FlutterSharedPreferences,
    private val segment: Segment,
) : NativeMiddleware {

    private val client = OkHttpClient()

    /**
     * Used to reduce the number of requests made to the middleware, we'll only re-register if the
     * token actually changes.
     */
    private var lastRegisteredToken: String? = null

    /**
     * Store the information from the push message that was received so we can submit this at the
     * end of the call to provide better metrics regarding our reliability.
     */
    var currentCallInfo: CurrentCallInfo? = null

    /**
     * We want to make sure to not process multiple push notifications for the same call (as the
     * middleware will send up to 8). So we'll track the call we are currently handling and make
     * sure to ignore any with the same id in the future.
     */
    private var callIdBeingHandled: String? = null

    private val activeNetworkInfo: NetworkInfo?
        get() = context.getSystemService(ConnectivityManager::class.java).activeNetworkInfo

    override fun tokenReceived(token: String) {
        if (lastRegisteredToken == token) {
            return
        }

        lastRegisteredToken = token

        if (prefs.getBoolSetting("DndSetting")) {
            logger.writeLog("Registration cancelled: do not disturb is enabled")
            return
        }

        val middlewareCredentials = middlewareCredentials

        val data = FormBody.Builder().apply {
            add("name", middlewareCredentials.email)
            add("token", token)
            add("sip_user_id", middlewareCredentials.sipUserId)
            add("os_version", Build.VERSION.RELEASE)
            add("client_version", BuildConfig.VERSION_NAME)
            add("app", context.packageName)
        }.build()

        val request =
            createMiddlewareRequest(middlewareCredentials.email, middlewareCredentials.loginToken)
                .post(data)
                .build()

        client.newCall(request).enqueue(
            object : Callback {
                override fun onFailure(call: Call, e: IOException) {
                    logger.writeLog("Registration failed: ${e.localizedMessage}")
                    lastRegisteredToken = null
                }

                override fun onResponse(call: Call, response: Response) {
                    if (response.isSuccessful) {
                        logger.writeLog("Registration successful")
                    } else {
                        logger.writeLog("Registration failed: response code was ${response.code}")
                        lastRegisteredToken = null
                    }
                }
            }
        )

        prefs.pushToken = token
    }

    override fun respond(remoteMessage: RemoteMessage, available: Boolean) {
        val middlewareCredentials = middlewareCredentials
        val callId = remoteMessage.callId!!
        val callStartTime = remoteMessage.messageStartTime!!

        logger.writeLog("Middleware Respond: Attempting for call=$callId, available=$available")

        val data = FormBody.Builder().apply {
            add("unique_key", callId)
            add("available", available.toString())
            add("message_start_time", callStartTime)
            add("sip_user_id", middlewareCredentials.sipUserId)
        }.build()

        val request = createMiddlewareRequest(
            middlewareCredentials.email,
            middlewareCredentials.loginToken,
            url = RESPONSE_URL
        )
            .post(data)
            .build()

        client.newCall(request).enqueue(
            object : Callback {
                override fun onFailure(call: Call, e: IOException) {
                    logger.writeLog("Middleware respond Failed: with ${e.localizedMessage}")
                }

                override fun onResponse(call: Call, response: Response) {
                    if (response.isSuccessful) {
                        logger.writeLog("Middleware respond success: $callId")
                    } else {
                        logger.writeLog("Middleware respond failed: response code was ${response.code}")
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
        if (!remoteMessage.isCall) return false

        activeNetworkInfo?.let {
            if (it.state == NetworkInfo.State.DISCONNECTED && it.detailedState == NetworkInfo.DetailedState.BLOCKED) {
                logger.writeLog("Network is in a bad state...", PhoneLibLogLevel.ERROR)
            }
            logger.writeLog("Network state: ${it.state.name}, detailed state: ${it.detailedState.name}")
        }

        if (isCallAlreadyBeingHandled(remoteMessage)) {
            logger.writeLog("Ignoring push message as we are already handling it: ${remoteMessage.callId}")
            return false
        }

        return true.also {
            segment.track("notification-received", mapOf(
                "call_id" to remoteMessage.callId,
                "correlation_id" to remoteMessage.correlationId,
            ))
        }
    }

    /**
     * Check to see if a call is being handled currently, if we are handling the call already
     * we do not want to process future push notifications.
     *
     * The id being tracked will also be updated here.
     */
    private fun isCallAlreadyBeingHandled(remoteMessage: RemoteMessage) = when {
        callIdBeingHandled != null && remoteMessage.callId == callIdBeingHandled -> true
        else -> {
            logger.writeLog("Handling inbound call: ${remoteMessage.callId}")
            callIdBeingHandled = remoteMessage.callId
            false
        }
    }

    private fun createMiddlewareRequest(email: String, token: String, url: String = REGISTER_URL) =
        Request.Builder().url(url).addHeader("Authorization", "Token $email:$token")

    private val middlewareCredentials
        get() = MiddlewareCredentials(
            sipUserId = prefs.voipConfig.getString("appaccount_account_id"),
            email = prefs.systemUser!!.getString("email"),
            loginToken = prefs.systemUser!!.getString("token")
        )

    companion object {
        private const val BASE_URL = "https://vialerpush.voipgrid.nl/api/"
        private const val RESPONSE_URL = "${BASE_URL}call-response/"
        private const val REGISTER_URL = "${BASE_URL}android-device/"
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

private val RemoteMessage.callId
    get() = data["unique_key"]

private val RemoteMessage.correlationId
    get() = data["vg_cid"]

private val RemoteMessage.messageStartTime
    get() = data["message_start_time"]

private val RemoteMessage.isCall
    get() = data["type"] == "call"

private fun RemoteMessage.toCurrentCallInfo() = Middleware.CurrentCallInfo(
    callId ?: "",
    correlationId ?: "",
    System.currentTimeMillis().toString()
)