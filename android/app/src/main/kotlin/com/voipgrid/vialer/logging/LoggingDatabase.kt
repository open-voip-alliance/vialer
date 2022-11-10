package com.voipgrid.vialer.logging

import android.content.ContentValues
import android.content.Context
import android.content.ContextWrapper
import android.database.DatabaseErrorHandler
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.provider.BaseColumns
import com.voipgrid.vialer.logging.LogEvents.COLUMN.ID
import com.voipgrid.vialer.logging.LogEvents.COLUMN.LEVEL
import com.voipgrid.vialer.logging.LogEvents.COLUMN.LOG_TIME
import com.voipgrid.vialer.logging.LogEvents.COLUMN.MESSAGE
import com.voipgrid.vialer.logging.LogEvents.COLUMN.NAME
import com.voipgrid.vialer.logging.LogEvents.TABLE_NAME
import io.flutter.util.PathUtils
import org.openvoipalliance.flutterphonelib.PhoneLibLogLevel
import java.io.File
import java.util.*


class LoggingDatabase(private val context: Context) {
    companion object {
        private const val FILE_NAME = "android_logging_db.sqlite"
    }

    private val db: SQLiteDatabase by lazy {
        object : SQLiteOpenHelper(
            context,
            FILE_NAME,
            null,
            1
        ) {

            override fun onCreate(db: SQLiteDatabase) {
                db.execSQL(
                    // language=SQL
                    """
                    CREATE TABLE $TABLE_NAME (
                       $ID INTEGER PRIMARY KEY,
                       $LOG_TIME INT,
                       $LEVEL INT,
                       $NAME TEXT,
                       $MESSAGE TEXT
                   )
                   """.trimIndent()
                )
            }

            // We don't care about these.
            override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {}
            override fun onDowngrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {}
        }.writableDatabase
    }

    fun insertLog(message: String, level: PhoneLibLogLevel, loggerName: String) {
        db.insert(
            LogEvents.TABLE_NAME,
            null,
            ContentValues().apply {
                put(LOG_TIME, Calendar.getInstance().timeInMillis)
                put(LEVEL, level.ordinal)
                put(NAME, loggerName)
                put(MESSAGE, message)
            }
        )
    }

    fun getLogs(batchSize: Long): List<Log> {
        val cursor = db.query(
            TABLE_NAME,
            arrayOf(LOG_TIME, LEVEL, NAME, MESSAGE),
            null,
            null,
            null,
            null,
            LOG_TIME,
            batchSize.toString(),
        )

        val logs = mutableListOf<Log>()

        cursor.use {
            fun columnIndexOf(column: String) = cursor.getColumnIndexOrThrow(column)

            while (it.moveToNext()) {
                logs += Log(
                    time = it.getLong(columnIndexOf(LOG_TIME)),
                    level = PhoneLibLogLevel.values()[it.getInt(columnIndexOf(LEVEL))],
                    name = it.getString(columnIndexOf(NAME)),
                    message = it.getString(columnIndexOf(MESSAGE))
                )
            }
        }

        return logs
    }

    /**
     * Remove logs from the database, from [start] to [end] time. Both are inclusive.
     */
    fun removeLogs(start: Long, end: Long) {
        val rows = db.delete(
            TABLE_NAME,
            "$LOG_TIME BETWEEN ? AND ?",
            arrayOf(start.toString(), end.toString())
        )

        println("ROWS DELETED: $rows")
    }
}

private object LogEvents : BaseColumns {
    const val TABLE_NAME = "log_events"

    object COLUMN {
        const val ID = "id"
        const val LOG_TIME = "log_time"
        const val LEVEL = "level"
        const val NAME = "name"
        const val MESSAGE = "message"
    }
}

data class Log(
    val time: Long,
    val level: PhoneLibLogLevel,
    val name: String,
    val message: String
)

// We need a context wrapper, otherwise the helper will search in the wrong
// directory for the database file.
private class FlutterDatabaseContext(base: Context?) : ContextWrapper(base) {
    override fun getDatabasePath(name: String) =
        File(PathUtils.getDataDirectory(this)).resolve(name)

    override fun openOrCreateDatabase(
        name: String,
        mode: Int,
        factory: SQLiteDatabase.CursorFactory?,
        errorHandler: DatabaseErrorHandler?
    ): SQLiteDatabase = SQLiteDatabase.openOrCreateDatabase(getDatabasePath(name), null)
}