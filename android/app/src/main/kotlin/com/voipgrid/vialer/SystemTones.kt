import android.content.Context
import android.media.AudioManager
import android.media.ToneGenerator
import android.provider.Settings
import com.voipgrid.vialer.Tones
import com.voipgrid.vialer.logging.Logger
import java.util.*
import kotlin.concurrent.schedule

class SystemTones(private val context: Context, private val log: Logger): Tones {

    /**
     * This is the native system setting that can be found under `Dialling keypad (sound)` (Samsung)
     * or `Dial pad tones` (Stock Android)
     */
    private val isDiallingKeypadSoundEnabled: Boolean
        get() = Settings.System.getInt(
            context.contentResolver,
            Settings.System.DTMF_TONE_WHEN_DIALING,
            1
        ) != 0

    override fun playForDigit(digit: String) {
        val tone = toTone(digit.first()) ?: return

        if (!isDiallingKeypadSoundEnabled) {
            log.writeLog("Not playing tone as it is disabled by the operating system")
            return
        }

        ToneGenerator(STREAM, VOLUME_PERCENTAGE).apply {
            startToneAndReleaseAfterPlayed(tone, DURATION)
        }
    }

    private fun toTone(char: Char): Int? = when(char) {
        '0' -> ToneGenerator.TONE_DTMF_0
        '1' -> ToneGenerator.TONE_DTMF_1
        '2' -> ToneGenerator.TONE_DTMF_2
        '3' -> ToneGenerator.TONE_DTMF_3
        '4' -> ToneGenerator.TONE_DTMF_4
        '5' -> ToneGenerator.TONE_DTMF_5
        '6' -> ToneGenerator.TONE_DTMF_6
        '7' -> ToneGenerator.TONE_DTMF_7
        '8' -> ToneGenerator.TONE_DTMF_8
        '9' -> ToneGenerator.TONE_DTMF_9
        '#' -> ToneGenerator.TONE_DTMF_P
        '*' -> ToneGenerator.TONE_DTMF_S
        else -> null
    }

    companion object {
        const val STREAM = AudioManager.STREAM_SYSTEM
        const val DURATION = 150
        const val VOLUME_PERCENTAGE = 50
    }
}

fun ToneGenerator.startToneAndReleaseAfterPlayed(tone: Int, duration: Int) {
    startTone(tone, duration)

    Timer().schedule((duration + 500).toLong()) {
        release()
    }
}