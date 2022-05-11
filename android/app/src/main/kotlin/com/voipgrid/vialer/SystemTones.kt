import android.content.Context
import android.media.AudioManager
import android.media.ToneGenerator
import android.util.Log
import kotlin.concurrent.schedule
import java.util.*
import com.voipgrid.vialer.Pigeon.Tones

class SystemTones(context: Context): Tones {

    private val audioManager = context.getSystemService(AudioManager::class.java)

    override fun playForDigit(digit: String) {
        val tone = toTone(digit.first()) ?: return

        ToneGenerator(STREAM, audioManager.getStreamVolumeAsPercentage(STREAM)).apply {
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
        const val STREAM = AudioManager.STREAM_DTMF
        const val DURATION = 150
    }
}

fun ToneGenerator.startToneAndReleaseAfterPlayed(tone: Int, duration: Int) {
    startTone(tone, duration)

    Timer().schedule((duration + 500).toLong()) {
        release()
    }
}

fun AudioManager.getStreamVolumeAsPercentage(streamType: Int) =
    ((getStreamVolume(streamType).toDouble() / 15) * 100).toInt()