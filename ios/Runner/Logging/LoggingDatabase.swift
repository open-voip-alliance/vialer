import Foundation
import sqlite3

class LoggingDatabase {
    init() {
        db = openDatabase()
    }
    
    let dbPath = "logging_db.sqlite"
    let tableName = "log_events"
    
    var db:OpaquePointer?
    
    func openDatabase() -> OpaquePointer? {
        let filePath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        
        if sqlite3_open(filePath.path, &db) != SQLITE_OK {
            debugPrint("Cannot open the sqlite database.")
            return nil
        } else {
            debugPrint("Successfully created connection to sqlite database at \(dbPath).")
            return db
        }
    }
    
    func insertLog(message:String, logLevel: LogLevel = .info, loggerName:String) {
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
}
  
//TODO: Implement log levels in iOSPhoneLib log messages and logger.writelog. On Pil's LogLevel add the : Int so the rawValue can be used and remove this LogLevel here.
enum LogLevel: Int {
    case debug
    case info
    case warning
    case error
}
