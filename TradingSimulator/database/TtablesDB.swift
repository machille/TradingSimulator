//
//  TtablesDB.swift
//  SQLiteTest
//
//  Created by Maroun Achille on 23/04/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

import SQLite3

class TtablesDB {
    static let instance = TtablesDB()
    internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    private init() {
    
    }
    
    func getTableItem(name: String, id: String) throws -> Ttables {
        
        let selectSQL = """
                SELECT TABLE_NAME, TABLE_ID, DESCRIPTION, VALUE_1, VALUE_2, VALUE_3, FLAG1, FLAG2
                FROM MAIN.TTABLES WHERE TABLE_NAME = ? AND TABLE_ID = ?
                """
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: selectSQL)
        defer {
            sqlite3_finalize(statement)
        }
        
        guard
            sqlite3_bind_text(statement, 1, name, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
                sqlite3_bind_text(statement, 2, id, -1, SQLITE_TRANSIENT) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        guard sqlite3_step(statement) == SQLITE_ROW else {
            throw SQLiteError.NotFound(message: "\(db.errorMessage) for Table = \(name) and Id = \(id) ")
        }
        
        let tables:Ttables = Ttables.init()
        
        tables.name = String(cString: (sqlite3_column_text(statement, 0)))
        tables.id = String(cString: (sqlite3_column_text(statement, 1)))
        tables.desc = String(cString: (sqlite3_column_text(statement, 2)))
        tables.value1 = String(cString: (sqlite3_column_text(statement, 3)))
        
        if sqlite3_column_type(statement, 4) != SQLITE_NULL {
            tables.value2 = String(cString:sqlite3_column_text(statement, 4))
        }
        if sqlite3_column_type(statement, 5) != SQLITE_NULL {
            tables.value3 =  sqlite3_column_double(statement, 5)
        }
        if sqlite3_column_type(statement, 6) != SQLITE_NULL {
            tables.flag1 = String(cString:sqlite3_column_text(statement, 6))
        }
        if sqlite3_column_type(statement, 7) != SQLITE_NULL {
            tables.flag2 = String(cString:sqlite3_column_text(statement, 7))
        }
        
        return tables
    }
    
    func getMasterTablesList() throws -> Array<Ttables> {
        return try getTablesList (name: "0")
        
    }

    func tablePopup(name: String) throws -> Array<String> {
        let items = try getTablesList(name: name)
        var popupArray = [String]()
        
        for item in items { 
            popupArray.append(item.desc)
        }
        return popupArray
    }
    
    func getTablesList(name: String) throws -> Array<Ttables> {
        var tablesArray = [Ttables]()
        
        let selectSQL = """
                SELECT TABLE_NAME, TABLE_ID, DESCRIPTION, VALUE_1, VALUE_2, VALUE_3, FLAG1, FLAG2
                FROM MAIN.TTABLES WHERE TABLE_NAME = ?
                """
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: selectSQL)
        defer {
            sqlite3_finalize(statement)
        }
        
        guard
            sqlite3_bind_text(statement, 1, name, -1, SQLITE_TRANSIENT) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        while(sqlite3_step(statement)==SQLITE_ROW) {
            
            let tables:Ttables = Ttables.init()
            
            tables.name = String(cString: (sqlite3_column_text(statement, 0)))
            tables.id = String(cString: (sqlite3_column_text(statement, 1)))
            tables.desc = String(cString: (sqlite3_column_text(statement, 2)))
            tables.value1 = String(cString: (sqlite3_column_text(statement, 3)))
            
            if sqlite3_column_type(statement, 4) != SQLITE_NULL {
                tables.value2 = String(cString:sqlite3_column_text(statement, 4))
            }
            if sqlite3_column_type(statement, 5) != SQLITE_NULL {
                tables.value3 =  sqlite3_column_double(statement, 5)
            }
            if sqlite3_column_type(statement, 6) != SQLITE_NULL {
                tables.flag1 = String(cString:sqlite3_column_text(statement, 6))
            }
            if sqlite3_column_type(statement, 7) != SQLITE_NULL {
                tables.flag2 = String(cString:sqlite3_column_text(statement, 7))
            }
            tablesArray.append(tables)
        }
        return tablesArray
    }
    
    
    func tablesInsert(tables: Ttables) throws {
        
        let insertSQL = """
            INSERT INTO TTABLES
            (DESCRIPTION, VALUE_1, VALUE_2, VALUE_3, FLAG1, FLAG2, TABLE_NAME, TABLE_ID)
            VALUES(?, ?, ?, ?, ?, ?, ?, ?)
            """
        
        try tablesInsertUpdate(tables: tables, sql: insertSQL)
    }
    
    
    func tablesUpdate(tables: Ttables) throws {
        
        let updateSQL = """
            UPDATE TTABLES SET DESCRIPTION=?, VALUE_1=?, VALUE_2=?, VALUE_3=?, FLAG1=?, FLAG2=?
            WHERE TABLE_NAME = ? AND TABLE_ID = ?
            """
        
        try tablesInsertUpdate(tables: tables, sql: updateSQL )
    }
    
    
    private func tablesInsertUpdate(tables: Ttables, sql: String) throws {
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: sql)
        defer {
            sqlite3_finalize(statement)
        }
        
        guard
            sqlite3_bind_text(statement, 1, tables.desc, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 2, tables.value1, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 3, tables.value2, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 4, tables.value3) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 5, tables.flag1, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 6, tables.flag2, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
                
            sqlite3_bind_text(statement, 7, tables.name, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(statement, 8, tables.id, -1, SQLITE_TRANSIENT) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            if db.errorCode == "19" {
                throw SQLiteError.Duplicate(message: db.errorMessage)
            }
            throw SQLiteError.Step(message: db.errorMessage)
        }
    }
    
    
    func tablesDelete(tables: Ttables) throws {
        try tablesDelete(name: tables.name, id: tables.id)
    }
    
    func tablesDelete(name: String, id: String) throws {
        let deleteSQL = "DELETE FROM TTABLES WHERE TABLE_NAME = ? AND TABLE_ID = ?"
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: deleteSQL)
        defer {
            sqlite3_finalize(statement)
        }
        guard
            sqlite3_bind_text(statement, 1, name, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(statement, 2, id, -1, SQLITE_TRANSIENT) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: db.errorMessage)
        }
    }
    
    func tablesMasterDelete(name: String) throws {
        let deleteSQL = "DELETE FROM TTABLES WHERE TABLE_NAME = ?"
        try tablesDelete(name: "0", id: name)
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: deleteSQL)
        defer {
            sqlite3_finalize(statement)
        }
        guard
            sqlite3_bind_text(statement, 1, name, -1, SQLITE_TRANSIENT) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: db.errorMessage)
        }
    }
}
