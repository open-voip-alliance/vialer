package com.voipgrid.vialer

import android.app.Activity
import android.content.*
import android.content.res.Resources
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.Window
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.FloatingActionButton
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.res.integerResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.*
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.rememberImagePainter
import com.voipgrid.vialer.IncomingCallActivity.Companion.EXTRA_HEADING
import com.voipgrid.vialer.IncomingCallActivity.Companion.EXTRA_IMAGE_URI
import com.voipgrid.vialer.IncomingCallActivity.Companion.EXTRA_SUBHEADING
import java.util.*
import kotlin.concurrent.schedule
import androidx.core.content.ContextCompat

class IncomingCallActivity : ComponentActivity() {

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            finish()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        registerReceiver(receiver, IntentFilter(INCOMING_CALL_CANCEL_INTENT), ContextCompat.RECEIVER_NOT_EXPORTED)
        requestWindowFeature(Window.FEATURE_NO_TITLE)
        // Although the title is not shown visually, we still set it for screen readers.
        title = getString(R.string.main_call_incoming_subtitle_with, getString(R.string.app_name))
        ensureScreenShowsWhilePhoneIsLocked()

        setContent {
            IncomingCallPage(
                callHeaderInformation = CallHeaderInformation(
                    intent.getStringExtra(EXTRA_HEADING) ?: "",
                    intent.getStringExtra(EXTRA_SUBHEADING) ?: "",
                    when (intent.hasExtra(EXTRA_IMAGE_URI)) {
                        true -> Uri.parse(intent.getStringExtra(EXTRA_IMAGE_URI))
                        false -> null
                    }
                ),
                onAnswer = { performAction(Action.ANSWER) },
                onDecline = { performAction(Action.DECLINE) },
            )
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(receiver)
    }

    private fun ensureScreenShowsWhilePhoneIsLocked() {
        // Although these are a deprecated flags, some SDK >= 27 devices still require to set
        // these flags for the screen to turn on.
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                    or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
                    or WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                    or WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                    or WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }
    }

    private fun performAction(action: Action) {
        Intent().also {
            it.action = action.name
            it.component = ComponentName(packageName, ACTION_RECEIVER)
            sendBroadcast(it)
        }

        // Provide a fail-safe to kill this activity after the user has pressed a button, just
        // in-case the event isn't received for some reason they won't be stuck on this screen.
        Timer().schedule(3000) {
            if (!isFinishing) {
                finish()
            }
        }
    }

    companion object {
        private const val ACTION_RECEIVER =
            "org.openvoipalliance.androidphoneintegration.service.NotificationButtonReceiver"

        const val EXTRA_HEADING = "remote_party_heading"
        const val EXTRA_SUBHEADING = "remote_party_subheading"
        const val EXTRA_IMAGE_URI = "remote_party_image_uri"
        const val INCOMING_CALL_CANCEL_INTENT =
            "org.openvoipalliance.androidphoneintegration.INCOMING_CALL_CANCEL"
    }

    private enum class Action {
        ANSWER, DECLINE
    }
}

fun Activity.launchIncomingCallScreen(
    remotePartyHeading: String,
    remotePartySubheading: String,
    imageUri: String?,
) =
    startActivity(Intent(this, IncomingCallActivity::class.java).apply {
        putExtra(EXTRA_HEADING, remotePartyHeading)
        putExtra(EXTRA_SUBHEADING, remotePartySubheading)
        imageUri?.let {
            putExtra(EXTRA_IMAGE_URI, it)
        }
    })

private val textStyle = TextStyle(color = Color.White)

@Composable
fun IncomingCallPage(
    callHeaderInformation: CallHeaderInformation,
    onAnswer: () -> Unit,
    onDecline: () -> Unit,
) {
    RadialGradientBackground {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(bottom = 64.dp, top = 88.dp),
            verticalArrangement = Arrangement.SpaceBetween,
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            ConcentricCircleGraphic(size = 250.dp) {
                Icon(
                    icon = BrandIcons(integerResource(R.integer.brand_icon)),
                    size = 60.sp,
                    color = LocalContext.current.primary,
                )
            }

            CallHeader(callHeaderInformation)

            Row(
                Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceAround,
            ) {
                AnswerButton(onAnswer)
                DeclineButton(onDecline)
            }
        }
    }
}

/**
 * A container with a radial gradient as the background. This background is automatically
 * positioned at the top of the screen.
 *
 * @param content
 */
@Composable
fun RadialGradientBackground(content: @Composable() () -> Unit) {
    val configuration = LocalConfiguration.current
    val screenHeight = with(LocalDensity.current) { configuration.screenHeightDp.dp.toPx() }
    val screenWidth = with(LocalDensity.current) { configuration.screenWidthDp.dp.toPx() }
    val primaryColor = LocalContext.current.primary

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.White)
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.radialGradient(
                        0f to primaryColor,
                        0.9f to primaryColor.copy(alpha = 0.2f),
                        1f to primaryColor.copy(alpha = 0.1f),
                        center = Offset((screenWidth / 2), (screenHeight * 0.25).toFloat()),
                        radius = (screenHeight * 0.8).toFloat(),
                    ),
                ),
        ) {
            content()
        }
    }
}

/**
 * Generates a graphic made up of concentric circles with the provided content in the center.
 *
 * @param size The initial size of the graphic.
 * @param layerWidth The size of each individual layer.
 * @param layers The number of layers to generate.
 * @param content The content within the most-inner circle.
 */
@Composable
fun ConcentricCircleGraphic(
    size: Dp,
    layerWidth: Dp = 75.dp,
    layers: Int = 3,
    content: @Composable() () -> Unit,
) {
    Box(
        modifier = Modifier
            .size(size)
            .clip(CircleShape)
            .background(Color.White.copy(alpha = 0.2f)),
        contentAlignment = Alignment.Center,
    ) {
        when {
            layers != 1 -> ConcentricCircleGraphic(
                size = size - layerWidth,
                layers = layers - 1,
                content = content,
            )
            else -> Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.Center,
            ) {
                content()
            }
        }
    }
}

@Composable
fun CallHeader(callHeaderInformation: CallHeaderInformation, fontSize: TextUnit = 22.sp) {
    Column(
        Modifier
            .fillMaxWidth()
            .padding(10.dp)
            .semantics(mergeDescendants = true) {},
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Avatar(callHeaderInformation = callHeaderInformation)
            Spacer(modifier = Modifier.size(20.dp))
            Column {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        FontAwesome.PHONE_ARROW_DOWN_LEFT,
                        size = fontSize * 0.6,
                        color = textStyle.color,
                    )

                    Spacer(modifier = Modifier.padding(horizontal = 4.dp))

                    Text(
                        stringResource(
                            R.string.main_call_incoming_subtitle_with,
                            stringResource(R.string.app_name)
                        ),
                        fontSize = fontSize * 0.6,
                        style = textStyle,
                        // This is read out as the activity title screen.
                        modifier = Modifier.clearAndSetSemantics {  }
                    )
                }

                Text(
                    callHeaderInformation.title,
                    fontWeight = FontWeight.Bold,
                    fontSize = fontSize,
                    style = textStyle,
                )

                Text(
                    callHeaderInformation.subtitle,
                    fontSize = fontSize * 0.8,
                    style = textStyle,
                )
            }
        }
    }
}

/**
 * Generate the text that will appear inside the avatar on the call screen, this will be the
 * initials from the [callHeaderInformation] or if that is not appropriate then the [fallback].
 *
 */
fun generateAvatarContent(
    callHeaderInformation: CallHeaderInformation,
    fallback: String = "#",
): String {
    val title = callHeaderInformation.title

    if (title.isEmpty()) return fallback

    if (!title.first().isLetter()) return fallback

    val words = title.split(" ")

    return when (words.size) {
        1 -> words.first().first().uppercase()
        else -> "${words.first().first().uppercase()}${words.last().first().uppercase()}"
    }
}

@Composable
fun Avatar(callHeaderInformation: CallHeaderInformation) {
    val displayContactImage = callHeaderInformation.imageUri != null

    Box(
        modifier = Modifier
            .size(
                when (displayContactImage) {
                    true -> 64.dp
                    false -> 36.dp
                }
            )
            .clip(CircleShape)
            .background(Color.White)
            .border(2.dp, Color.White, CircleShape),
        contentAlignment = Alignment.Center,
    ) {
        when (displayContactImage) {
            true -> Image(
                painter = rememberImagePainter(data = callHeaderInformation.imageUri),
                contentDescription = null,
            )
            false -> Text(
                generateAvatarContent(callHeaderInformation = callHeaderInformation),
                style = TextStyle(color = LocalContext.current.primary,
                    fontWeight = FontWeight.Bold),
                modifier = Modifier.clearAndSetSemantics {}
            )
        }
    }
}

@Composable
fun AnswerButton(onClick: () -> Unit) {
    ActionButton(
        onClick = onClick,
        backgroundColor = colorResource(R.color.green_1),
        text = stringResource(R.string.main_call_incoming_answer),
        textColor = colorResource(R.color.primary_dark),
    ) {
        Icon(icon = FontAwesome.SOLID_PHONE)
    }
}

@Composable
fun DeclineButton(onClick: () -> Unit) {
    ActionButton(
        onClick = onClick,
        backgroundColor = colorResource(R.color.red_1),
        text = stringResource(R.string.main_call_incoming_decline),
        textColor = colorResource(R.color.primary_dark),
    ) {
        Icon(icon = FontAwesome.SOLID_PHONE_HANGUP)
    }
}

@Composable
fun Icon(icon: Icon, size: TextUnit = 26.sp, color: Color = Color.Unspecified) {
    val fontFamily = when (icon) {
        is BrandIcons -> R.font.brand_icons
        is FontAwesome -> when {
            icon.solid -> R.font.fa_solid_900
            else -> R.font.fa_regular_400
        }
    }

    Text(
        text = String(charArrayOf(icon.character.toChar())),
        fontFamily = FontFamily(Font(fontFamily)),
        fontSize = size,
        color = color,
        modifier = Modifier.clearAndSetSemantics {},
    )
}

@Composable
fun ActionButton(
    onClick: () -> Unit,
    backgroundColor: Color,
    textColor: Color,
    text: String,
    content: @Composable() () -> Unit,
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.clearAndSetSemantics {
            contentDescription = text
            role = Role.Button
            onClick { onClick(); true }
        }
    ) {
        Text(
            text.uppercase(),
            modifier = Modifier.padding(bottom = 12.dp),
            style = textStyle.copy(
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp,
                        color = textColor,
                    ),
        )
        FloatingActionButton(
            onClick = onClick,
            backgroundColor = backgroundColor,
            contentColor = Color.White,
            modifier = Modifier.size(70.dp),
        ) {
            content()
        }
    }
}

sealed interface Icon {
    val character: Int
}

@JvmInline
value class BrandIcons(override val character: Int) : Icon

data class FontAwesome(override val character: Int, val solid: Boolean) : Icon {
    companion object {
        val SOLID_PHONE_HANGUP = FontAwesome(0xE225, solid = true)
        val SOLID_PHONE = FontAwesome(0xF095, solid = true)
        val PHONE_ARROW_DOWN_LEFT = FontAwesome(0xE223, solid = false)
    }
}

data class CallHeaderInformation(
    val title: String = "",
    val subtitle: String = "",
    val imageUri: Uri? = null,
)

/**
 * The color palette doesn't match perfectly between brands and for this screen, we want to use
 * the darker color for Vialer and the lighter color for other brands.
 */
val Context.primary: Color
    get() = Color(
        when (getString(R.string.identifier).contains("vialer")) {
            true -> getColor(R.color.primary_dark)
            false -> getColor(R.color.primary)
        }
    )