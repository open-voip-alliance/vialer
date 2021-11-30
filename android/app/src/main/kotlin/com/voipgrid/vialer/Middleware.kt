package com.voipgrid.vialer

import android.content.Context
import android.os.Build
import com.google.firebase.messaging.RemoteMessage
import com.voipgrid.vialer.logging.Logger
import okhttp3.*
import org.openvoipalliance.flutterphonelib.NativeMiddleware
import java.io.IOException

class Middleware(private val context: Context, private val logger: Logger) : NativeMiddleware {

    private val client = OkHttpClient()
    private val flutterSharedPreferences = FlutterSharedPreferences(context)
    private var lastRegisteredToken: String? = null

    override fun tokenReceived(token: String) {
        if (lastRegisteredToken == token) {
            return
        }

        lastRegisteredToken = token

        if (flutterSharedPreferences.getBoolSetting("DndSetting")) {
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

        flutterSharedPreferences.pushToken = token
    }

    override fun respond(remoteMessage: RemoteMessage, available: Boolean) {
        val middlewareCredentials = middlewareCredentials
        val callId = remoteMessage.data["unique_key"]!!
        val callStartTime = remoteMessage.data["message_start_time"]!!

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
    }

    override suspend fun inspect(remoteMessage: RemoteMessage) = remoteMessage.data["type"] == "call"

    private fun createMiddlewareRequest(email: String, token: String, url: String = REGISTER_URL) =
        Request.Builder().url(url).addHeader("Authorization", "Token $email:$token")

    private val middlewareCredentials
        get() = MiddlewareCredentials(
                sipUserId = flutterSharedPreferences.voipConfig.getString("appaccount_account_id"),
                email = flutterSharedPreferences.systemUser.getString("email"),
                loginToken = flutterSharedPreferences.systemUser.getString("token")
        )

    companion object {
        private const val BASE_URL = "https://vialerpush-staging.voipgrid.nl/api/"
        private const val RESPONSE_URL = "${BASE_URL}call-response/"
        private const val REGISTER_URL = "${BASE_URL}android-device/"
    }

    private data class MiddlewareCredentials(
        val email: String,
        val loginToken: String,
        val sipUserId: String
    )
}