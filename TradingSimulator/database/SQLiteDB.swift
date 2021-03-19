//
//  SQLiteDB.swift
//  SQLiteTest
//
//  Created by Maroun Achille on 09/04/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation
import SQLite3

class SQLiteDB {
    
    fileprivate let dbPointer: OpaquePointer?
    fileprivate static var first: Bool = true
    fileprivate static var dbURL: String = "db"
    
    var errorMessage: String {
        if let errorPointer = sqlite3_errmsg(dbPointer) {
            let errorCode = sqlite3_errcode(dbPointer)
            let errorMessage = String(errorCode) + " : " + String(cString: errorPointer)
            return errorMessage
        } else {
            return "No error message provided from sqlite."
        }
    }
    
    var errorCode: String {
        return String( sqlite3_errcode(dbPointer))
    }
    
    fileprivate init(dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
    }
    
    /// Whether or not the database was opened in a read-only state.
    public var readonly: Bool { return sqlite3_db_readonly(dbPointer, nil) == 1 }
    
    deinit {
        sqlite3_close(dbPointer)
    }
        
    static func open() throws -> SQLiteDB {

        let dbFileName: String = try checkDatabaseFile()
        var db: OpaquePointer? = nil
        
        if sqlite3_open_v2(dbFileName, &db, SQLITE_OPEN_CREATE | SQLITE_OPEN_NOMUTEX | SQLITE_OPEN_READWRITE | SQLITE_OPEN_SHAREDCACHE, nil)  == SQLITE_OK {
            return SQLiteDB(dbPointer: db)
        } else {
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }

            if let errorPointer = sqlite3_errmsg(db) {
                let message = String.init(cString: errorPointer)
                throw SQLiteError.OpenDatabase(message: message)
            } else {
                throw SQLiteError.OpenDatabase(message: "No error message provided from sqlite.")
            }
        }
    }

    fileprivate static func checkDatabaseFile() throws -> String {
        if first {
            dbURL = try DirectoryFiles.prepareDatabaseFile()
            first = false
        }
        return dbURL
    }
    
    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: "Error : \(errorMessage) \n SQL : \(sql)")
            }
        return statement
    }
 
    func beginTransaction() throws {
        guard sqlite3_exec(dbPointer, "BEGIN DEFERRED TRANSACTION", nil, nil, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: "BEGIN TRANSACTION : \(errorMessage)")
        }
    }
    
    func commit() throws  {
        guard sqlite3_exec(dbPointer, "COMMIT", nil, nil, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: "COMMIT TRANSACTION : \(errorMessage)")
        }
    }
    
    func rollback() throws  {
        guard sqlite3_exec(dbPointer, "ROLLBACK", nil, nil, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: "ROLLBACK TRANSACTION : \(errorMessage)")
        }
    }
    
    func checkTransaction() throws -> Int {
        return Int(sqlite3_get_autocommit(dbPointer))
    }
}

