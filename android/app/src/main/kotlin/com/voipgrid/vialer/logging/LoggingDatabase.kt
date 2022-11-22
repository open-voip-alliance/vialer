package com.voipgrid.vialer.logging

import android.content.ContentValues
import android.content.Context
import android.content.ContextWrapper
import android.database.DatabaseErrorHandler
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.provider.BaseColumns
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
        private const val FILE_NAME = "logging_native_db.sqlite"
    }

    /**
     * The raw database instance, this should ONLY be accessed via [db].
     */
    private lateinit var sqliteDb: SQLiteDatabase

    /**
     * The safe database instance, should always be used for accessing the database.
     */
    private val db: SQLiteDatabase?
        get() {
            if (this::sqliteDb.isInitialized) return sqliteDb

            val dbFile = FlutterDatabaseContext(context).getDatabasePath(FILE_NAME)

            // If Flutter hasn't created the db file, we will just ignore any requests for now.
            if (!dbFile.exists()) return null

            return object : SQLiteOpenHelper(
                context,
                dbFile.path,
                null,
                1
            ) {
                override fun onCreate(db: SQLiteDatabase) {}
                override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {}
                override fun onDowngrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {}
            }.writableDatabase.also {
                sqliteDb = it
            }
        }

    fun insertLog(message: String, level: PhoneLibLogLevel, loggerName: String) {
        db?.insert(
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
        val cursor = db?.query(
            TABLE_NAME,
            arrayOf(LOG_TIME, LEVEL, NAME, MESSAGE),
            null,
            null,
            null,
            null,
            LOG_TIME,
            batchSize.toString(),
        ) ?: return listOf()

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
     * Remove logs from the database, from [after] until [before].
     * Both [after] and [before] can be null, to make the range boundless in either direction.
     *
     * If both [after] and [before] are null, removes everything
     * (which case [inclusive] has no effect).
     */
    fun removeLogs(after: Long? = null, before: Long? = null, inclusive: Boolean = true) {
        val eq = if (inclusive) "=" else ""

        val whereClause = listOfNotNull(
            if (after != null) "$LOG_TIME >$eq ?" else null,
            if (before != null) "$LOG_TIME <$eq ?" else null
        )
            .joinToString(separator = " AND ")
            .ifEmpty { null }

        val whereArgs = listOfNotNull(after?.toString(), before?.toString()).toTypedArray()

        db?.delete(
            TABLE_NAME,
            whereClause,
            whereArgs
        )
    }
}

private object LogEvents : BaseColumns {
    const val TABLE_NAME = "log_events"

    object COLUMN {
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