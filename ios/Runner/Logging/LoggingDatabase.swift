import Foundation
import sqlite3

class LoggingDatabase {
    init() {
        db = openDatabase()
//wip        createTable()
    }
  
    let dbPath: String = "logging_db.sqlite"
    var db:OpaquePointer?
  
    func openDatabase() -> OpaquePointer? {
        let filePath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        
        if sqlite3_open(filePath.path, &db) != SQLITE_OK
        {
            debugPrint("Cannot open the logging database")
            return nil
        }
        else
        {
            print("Successfully created connection to logging database at \(dbPath)")
            return db
        }
    }
    
    func insertLog(message:String) { //wip Add LogLevel param?
        
        debugPrint("//wip FAKE inserting log: \(message).")
        
        //WIP
//        let persons = read()
//        for p in persons
//        {
//            if p.id == id
//            {
//                return
//            }
//        }
//        let insertStatementString = "INSERT INTO person (Id, name, age) VALUES (?, ?, ?);"
//        var insertStatement: OpaquePointer? = nil
//        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
//            sqlite3_bind_int(insertStatement, 1, Int32(id))
//            sqlite3_bind_text(insertStatement, 2, (name as NSString).utf8String, -1, nil)
//            sqlite3_bind_int(insertStatement, 3, Int32(age))
//
//            if sqlite3_step(insertStatement) == SQLITE_DONE {
//                print("Successfully inserted row.")
//            } else {
//                print("Could not insert row.")
//            }
//        } else {
//            print("INSERT statement could not be prepared.")
//        }
//        sqlite3_finalize(insertStatement)
    }
  
    //wip
//    func createTable() {
//        let createTableString = "CREATE TABLE IF NOT EXISTS person(Id INTEGER PRIMARY KEY,name TEXT,age INTEGER);"
//        var createTableStatement: OpaquePointer? = nil
//        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
//        {
//            if sqlite3_step(createTableStatement) == SQLITE_DONE
//            {
//                print("person table created.")
//            } else {
//                print("person table could not be created.")
//            }
//        } else {
//            print("CREATE TABLE statement could not be prepared.")
//        }
//        sqlite3_finalize(createTableStatement)
//    }
      
      
//    func insert(id:Int, name:String, age:Int)
//    {
//        let persons = read()
//        for p in persons
//        {
//            if p.id == id
//            {
//                return
//            }
//        }
//        let insertStatementString = "INSERT INTO person (Id, name, age) VALUES (?, ?, ?);"
//        var insertStatement: OpaquePointer? = nil
//        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
//            sqlite3_bind_int(insertStatement, 1, Int32(id))
//            sqlite3_bind_text(insertStatement, 2, (name as NSString).utf8String, -1, nil)
//            sqlite3_bind_int(insertStatement, 3, Int32(age))
//
//            if sqlite3_step(insertStatement) == SQLITE_DONE {
//                print("Successfully inserted row.")
//            } else {
//                print("Could not insert row.")
//            }
//        } else {
//            print("INSERT statement could not be prepared.")
//        }
//        sqlite3_finalize(insertStatement)
//    }
      
//wip
//    func read() -> [Employee] {
//        let queryStatementString = "SELECT * FROM person;"
//        var queryStatement: OpaquePointer? = nil
//        var emps : [Employee] = []
//        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
//            while sqlite3_step(queryStatement) == SQLITE_ROW {
//                let id = sqlite3_column_int(queryStatement, 0)
//                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
//                let year = sqlite3_column_int(queryStatement, 2)
//                emps.append(Employee(id: Int(id), name: name, age: Int(year)))
//                print("Query Result:")
//                print("\(id) | \(name) | \(year)")
//            }
//        } else {
//            print("SELECT statement could not be prepared")
//        }
//        sqlite3_finalize(queryStatement)
//        return emps
//    }
      
//    func deleteByID(id:Int) {
//        let deleteStatementStirng = "DELETE FROM person WHERE Id = ?;"
//        var deleteStatement: OpaquePointer? = nil
//        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
//            sqlite3_bind_int(deleteStatement, 1, Int32(id))
//            if sqlite3_step(deleteStatement) == SQLITE_DONE {
//                print("Successfully deleted row.")
//            } else {
//                print("Could not delete row.")
//            }
//        } else {
//            print("DELETE statement could not be prepared")
//        }
//        sqlite3_finalize(deleteStatement)
//    }
      
}



