package com.voipgrid.vialer.logging

import android.content.ContentValues
import android.content.Context
import android.content.ContextWrapper
import android.database.DatabaseErrorHandler
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.provider.BaseColumns
import io.flutter.util.PathUtils
import org.openvoipalliance.flutterphonelib.PhoneLibLogLevel
import java.io.File
import java.util.*


class LoggingDatabase(private val context: Context) {
    private val databaseFilename = "logging_db.sqlite"

    private val flutterDatabaseContext = FlutterDatabaseContext(context)

    private val dbFile
        get() = flutterDatabaseContext.getDatabasePath(databaseFilename)

    private val db: SQLiteDatabase
        get() = object : SQLiteOpenHelper(
            flutterDatabaseContext,
            databaseFilename,
            null,
            1
        ) {
            // We don't care about these.
            override fun onCreate(db: SQLiteDatabase) {}
            override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {}
            override fun onDowngrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {}
        }.writableDatabase

    fun insertLog(message: String, level: PhoneLibLogLevel, loggerName: String) {
        // We will drop logs until the database table has been created in Flutter
        if (!dbFile.exists() || true) return

//        db.insert(
//            LogEvents.TABLE_NAME,
//            null,
//            with(LogEvents.COLUMN) {
//                ContentValues().apply {
//                    put(LOG_TIME, Calendar.getInstance().timeInMillis)
//                    put(LEVEL, level.ordinal)
//                    put(NAME, loggerName)
//                    put(MESSAGE, message)
//                }
//            }
//        )
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