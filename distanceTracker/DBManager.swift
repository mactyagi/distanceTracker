//
//  DBManager.swift
//  distanceTracker
//
//  Created by manukant tyagi on 20/04/22.
//

import Foundation
import SQLite3
struct Tables{
    static var run = "run"
}
class DBManager {
    init()
    {
        db = openDatabase()
        createTable()
    }

    let dbPath: String = "myDb.sqlite"
    var db:OpaquePointer?

    func openDatabase() -> OpaquePointer?
    {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK
        {
            print("error opening database")
            return nil
        }
        else
        {
            print("Successfully opened connection to database at \(dbPath)")
            return db
        }
    }
    
    func createTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS \(Tables.run)(id INTEGER PRIMARY KEY AutoIncrement,date TEXT,time TEXT, distance TEXT);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(createTableStatement) == SQLITE_DONE
            {
                print("run table created.")
            } else {
                print("run table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    
    func insert(date:String, time:String, distance: String) {
        var insertStatement: OpaquePointer? = nil
        let insertStatementString = "INSERT INTO \(Tables.run) (date, time, distance) VALUES ('\(date)', '\(time)', '\(distance)');"
        
            sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        sqlite3_finalize(insertStatement)
    }
    
    
    
    func read() -> [Run] {
        let queryStatementString = "SELECT * FROM \(Tables.run);"
        var queryStatement: OpaquePointer? = nil
        var run : [Run] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                let date = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let time = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let distance = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                run.append(Run(date: date, time: time, distance: distance))
                print("Query Result:")
                print("\(date) | \(time) | \(distance)")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return run
    }
}
