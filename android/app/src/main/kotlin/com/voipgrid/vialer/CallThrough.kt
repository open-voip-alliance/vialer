package com.voipgrid.vialer

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import com.voipgrid.vialer.logging.Logger


class CallThrough(
    private val context: Context,
    private val log: Logger,
    private val segment: Segment,
): Pigeon.CallThrough {

    override fun startCall(number: String) {
        log.writeLog("Attempting to start call-through call.")

        val intent = Intent(Intent.ACTION_CALL).apply {
            data = Uri.parse("tel:$number")
        }

        findPhoneComponent()?.let {
            intent.component = it
        }

        context.startActivity(intent)
    }

    private fun findPhoneComponent(): ComponentName? {
        context.findPhoneApps().forEach {
            val packageName = it.activityInfo.packageName

            // We are looking for any phone app that isn't Vialer
            if (packageName != context.packageName) {
                track(true)
                log.writeLog("Found a phone app to open with directly: $packageName.")
                return ComponentName(packageName, it.activityInfo.name)
            }
        }

        track(false)
        log.writeLog("Unable to find a phone app, falling back to implicit intent.")
        return null
    }

    private fun track(foundPhone: Boolean) = segment.track(
        "call-through-intent",
        mapOf("found-native-package" to foundPhone.toString())
    )

    private fun Context.findPhoneApps() = packageManager.queryIntentActivities(
            Intent(Intent.ACTION_CALL).apply { data = Uri.parse("tel:") },
            PackageManager.MATCH_ALL
        )
}