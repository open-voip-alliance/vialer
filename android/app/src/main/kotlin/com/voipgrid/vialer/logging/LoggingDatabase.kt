package com.voipgrid.vialer.logging

import android.content.ContentValues
import android.content.Context
import android.content.ContextWrapper
import android.database.DatabaseErrorHandler
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.os.Environment
import android.provider.BaseColumns
import android.util.Log
import io.flutter.util.PathUtils
import org.openvoipalliance.flutterphonelib.PhoneLibLogLevel
import java.io.File
import java.util.*


class LoggingDatabase(private val context: Context) {
    private var db: SQLiteDatabase = object : SQLiteOpenHelper(
        FlutterDatabaseContext(context),
        "logging_db.sqlite",
        null,
        1
    ) {
        // We don't care about these.
        override fun onCreate(db: SQLiteDatabase) {}
        override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {}
        override fun onDowngrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {}
    }.writableDatabase

    fun insertLog(message: String, level: PhoneLibLogLevel, userIdentifier: String?, loggerName: String) {
        db.insert(
            LogEvents.TABLE_NAME,
            null,
            with(LogEvents.COLUMN) {
                ContentValues().apply {
                    put(LOG_TIME, Calendar.getInstance().timeInMillis)
                    put(LEVEL, level.ordinal) // TODO: does this match with LogLevel?
                    put(UUID, userIdentifier)
                    put(NAME, loggerName)
                    put(MESSAGE, message)
                }
            }
        )
    }
}

private object LogEvents : BaseColumns {
    const val TABLE_NAME = "log_events"

    object COLUMN {
        const val ID = "id"
        const val LOG_TIME = "log_time"
        const val LEVEL = "level"
        const val UUID = "uuid"
        const val NAME = "name"
        const val MESSAGE = "message"
    }
}

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