package com.voipgrid.vialer

import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import android.view.WindowManager
import androidx.test.rule.ActivityTestRule
import dev.flutter.plugins.integration_test.FlutterTestRunner
import org.junit.Rule;
import org.junit.runner.RunWith;

@RunWith(FlutterTestRunner::class)
class MainActivityTest {
    @Rule
    @JvmField
    val rule: ActivityTestRule<MainActivity> =
        ActivityTestRule(MainActivity::class.java, true, false)
}