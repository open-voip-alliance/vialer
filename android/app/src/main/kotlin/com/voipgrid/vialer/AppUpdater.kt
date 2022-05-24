package com.voipgrid.vialer

import android.app.Activity
import android.util.Log
import com.google.android.play.core.appupdate.AppUpdateInfo
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.appupdate.AppUpdateOptions
import com.google.android.play.core.install.model.AppUpdateType.*
import com.google.android.play.core.install.model.InstallStatus
import com.google.android.play.core.install.model.UpdateAvailability.*

class AppUpdater(
    private val activity: Activity,
    private val onUpdateTypeKnown: (Boolean) -> Unit,
    private val onFlexibleUpdateDownloaded: () -> Unit
) {
    private val manager = AppUpdateManagerFactory.create(activity)

    var versionCodeBeingUpdatedTo: Int = -1

    fun check(): Unit = manager.run {
        appUpdateInfo.addOnSuccessListener {
            when (it.updateAvailability()) {
                UPDATE_AVAILABLE, DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS ->
                    when (val priority = it.updatePriority()) {
                        in 2..5 -> it.startUpdate(preferImmediate = priority >= 4)
                    }
                UPDATE_NOT_AVAILABLE, UNKNOWN -> {
                    onUpdateTypeKnown(false)
                    return@addOnSuccessListener
                }
            }
        }
    }

    fun completeFlexibleUpdate() {
        manager.completeUpdate()
    }

    private fun AppUpdateInfo.startUpdate(preferImmediate: Boolean) {
        if (versionCodeBeingUpdatedTo == availableVersionCode()) {
            onUpdateTypeKnown(false)
            return // Already handling the update.
        }

        versionCodeBeingUpdatedTo = availableVersionCode()

        val type = when {
            preferImmediate && isUpdateTypeAllowed(IMMEDIATE) -> IMMEDIATE
            isUpdateTypeAllowed(FLEXIBLE) -> FLEXIBLE
            else -> null
        }

        onUpdateTypeKnown(type == FLEXIBLE)

        when (type) {
            FLEXIBLE -> manager.registerListener {
                if (it.installStatus() == InstallStatus.DOWNLOADED) {
                    onFlexibleUpdateDownloaded()
                }
            }
            null -> return
        }

        manager.startUpdateFlow(
            this,
            activity,
            object : AppUpdateOptions() {
                override fun appUpdateType() = type!! // Kotlin doesn't understand it can't be null.
                override fun allowAssetPackDeletion() = false
            }
        )
    }
}