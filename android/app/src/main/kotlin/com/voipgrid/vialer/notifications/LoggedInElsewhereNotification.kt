import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import androidx.compose.ui.res.integerResource
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.voipgrid.vialer.BrandIcons
import com.voipgrid.vialer.R
import java.lang.Integer.getInteger

class LoggedInElsewhereNotification(private val context: Context) {
    fun show() = context.apply {
        val channel = NotificationChannel(
            CHANNEL_ID,
            getString(R.string.logged_in_elsewhere_notification_channel_name),
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = getString(R.string.logged_in_elsewhere_notification_channel_description)
        }

        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_service)
            .setContentTitle(getString(R.string.logged_in_elsewhere_notification_message_title))
            .setContentText(getString(R.string.logged_in_elsewhere_notification_message_subtitle))
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)

        NotificationManagerCompat.from(this).apply {
            notify(NOTIFICATION_ID, notification.build())
        }

    }

    companion object {
        const val CHANNEL_ID = "logged_in_elsewhere"
        const val NOTIFICATION_ID = 100
    }
}