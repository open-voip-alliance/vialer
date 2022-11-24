import Foundation
import sqlite3

class LoggingDatabase {
    init() {
        establishDatabaseConnection()
    }
    
    let dbPath = "logging_native_db.sqlite"
    let tableName = "log_events"
    
    var db: OpaquePointer?
    
    private func establishDatabaseConnection() {
        if db == nil {
            db = openDatabase()
        }
    }
    
    //This will just open the database and will not create it if it does not already exist
    private func openDatabase() -> OpaquePointer? {
        let filePath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        
        if sqlite3_open_v2(filePath.path, &db, SQLITE_OPEN_READWRITE, nil) != SQLITE_OK {
            debugPrint("Cannot open the sqlite database.")
            return nil
        } else {
            debugPrint("Successfully created connection to sqlite database at \(dbPath).")
            return db
        }
    }
    
    func insertLog(message:String, logLevel: LogLevel = .info, loggerName:String) {
        establishDatabaseConnection()
        
        let insertStatementString = "INSERT INTO \(tableName) (id, log_time, level, name, message) VALUES (?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer? = nil
                
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int64(insertStatement, 2,  Int64((Date().timeIntervalSince1970 * 1000.0).rounded()))
            sqlite3_bind_int(insertStatement, 3, Int32(logLevel.rawValue))
            sqlite3_bind_text(insertStatement, 4, (loggerName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, (message as NSString).utf8String, -1, nil)
                        
            if sqlite3_step(insertStatement) != SQLITE_DONE {
                debugPrint("Could not insert row in logging table.")
            }
        } else {
            debugPrint("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    func getLogs(batchSize: NSNumber) -> [LogEvent] {
        establishDatabaseConnection()
        
        let queryStatementString = "SELECT * FROM \(tableName) LIMIT \(batchSize.stringValue);"
        var queryStatement: OpaquePointer? = nil
        var logs : [LogEvent] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                let log_time = sqlite3_column_int64(queryStatement, 1)
                let level = sqlite3_column_int(queryStatement, 2)
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let message = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let logEvent = LogEvent(id: Int(id), log_time: log_time, level: LogLevel.init(rawValue: Int(level)) ?? .debug, name: name, message: message)
                logs.append(logEvent)
            }
        } else {
            debugPrint("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return logs
    }
    
    func deleteLog(id:Int) {
        establishDatabaseConnection()
        
        let deleteStatementString = "DELETE FROM \(tableName) WHERE Id = ?;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, Int32(id))
            if sqlite3_step(deleteStatement) != SQLITE_DONE {
                debugPrint("Could not delete row with id = \(id).")
            }
        } else {
            debugPrint("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }
    
    func deleteLogs(keepPastDay: Bool) {
        establishDatabaseConnection()
        
        var deleteStatementString = "DELETE FROM \(tableName);"
        let pastDayDateInMilSecs = Int64(Date().timeIntervalSince1970.rounded() - (60 * 60)) * 1000
        if (keepPastDay) {
            deleteStatementString = "DELETE FROM \(tableName) WHERE (log_time < \(pastDayDateInMilSecs));"
        }
        
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            if (keepPastDay) {
                sqlite3_bind_int64(deleteStatement, 1, pastDayDateInMilSecs)
            }
            if sqlite3_step(deleteStatement) != SQLITE_DONE {
                debugPrint("Could not delete rows from \(tableName)")
            }
        } else {
            debugPrint("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }
}
  
//TODO: Implement log levels in iOSPhoneLib log messages and logger.writelog. On Pil's LogLevel add the : Int so the rawValue can be used and remove this LogLevel here.
enum LogLevel: Int {
    case debug
    case info
    case warning
    case error
}

class LogEvent {
    let id: Int
    let log_time: Int64
    let level: LogLevel
    let name: String
    let message: String
      
    init(id:Int, log_time:Int64, level:LogLevel, name:String, message:String)
    {
        self.id = id
        self.log_time = log_time
        self.level = level
        self.name = name
        self.message = message
    }
}
