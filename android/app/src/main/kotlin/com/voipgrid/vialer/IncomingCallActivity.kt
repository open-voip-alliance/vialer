package com.voipgrid.vialer

import android.app.Activity
import android.app.KeyguardManager
import android.content.*
import android.media.AudioManager
import android.os.Build
import android.os.Bundle
import android.view.Window
import android.view.WindowInsets
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView

class IncomingCallActivity : Activity() {

    private lateinit var receiver: BroadcastReceiver

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestWindowFeature(Window.FEATURE_NO_TITLE)
        setContentView(R.layout.activity_incoming_call)
        setupIncomingCallScreen()
        populateDataUsingIntent()

        findViewById<Button>(R.id.answer).setOnClickListener {
            performAction(Action.ANSWER)
        }

        findViewById<Button>(R.id.decline).setOnClickListener {
            performAction(Action.DECLINE)
        }

        receiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    finish()
                }
            }

        registerReceiver(receiver, IntentFilter(
                "org.openvoipalliance.androidphoneintegration.INCOMING_CALL_CANCEL"
            )
        )
    }

    override fun onStop() {
        super.onStop()
        unregisterReceiver(receiver)
    }

    private fun populateDataUsingIntent() {
        findViewById<TextView>(R.id.heading).text = intent.getStringExtra("remote_party_heading")
        findViewById<TextView>(R.id.subheading).text =
            intent.getStringExtra("remote_party_subheading")
    }

    private fun setupIncomingCallScreen() {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            getSystemService(KeyguardManager::class.java).requestDismissKeyguard(this, null)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                        or WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                        or WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                        or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
                        or WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON
            )
        }
        volumeControlStream = AudioManager.STREAM_VOICE_CALL
    }

    private fun performAction(action: Action) {
        Intent().also {
            it.action = action.name
            it.component = ComponentName(
                packageName,
                "org.openvoipalliance.androidphoneintegration.service.NotificationButtonReceiver"
            )
            sendBroadcast(it)
        }
    }

    private enum class Action {
        ANSWER, DECLINE
    }
}