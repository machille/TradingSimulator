//
//  SequenceDB.swift
//  Trading
//
//  Created by Maroun Achille on 06/03/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Foundation
import SQLite3

class SequenceDB {
    
    static let instance = SequenceDB()
    internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    private let selectSQL = "SELECT LAST_NUMBER FROM SEQUENCE  WHERE SEQUENCE_ID = ?"
    private let updateSQL = "UPDATE SEQUENCE SET LAST_NUMBER = ? WHERE SEQUENCE_ID = ? "
    private let insertSQL = "INSERT INTO SEQUENCE (DESCRIPTION ,LAST_NUMBER , BEGIN_NUMBER, SEQUENCE_ID ) VALUES ( 'Auto Creation' , ?,  1 ,  ?)"
    
    private init() {
    }
    
    func nextSequence(id: String) -> Int {
        do {
            var seq = try getSequence(id: id)
            if seq == -1 {
                seq = 1
                try sequenceInsertUpdate(id: id, sequence: seq, sql: insertSQL)
                return seq
            } else {
                seq = seq + 1
                try sequenceInsertUpdate(id : id, sequence: seq, sql: updateSQL)
                return seq
            }
            
        } catch let error as SQLiteError {
            Message.messageAlert("Get Sequence Error", text: error.description)
        } catch let error {
            Message.messageAlert("Get Sequence Error", text: "Other Error \(error)")
        }
        return 0
    }
    
    private func getSequence(id: String) throws -> Int {
        var sequence: Int = -1
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: selectSQL)
        defer {
            sqlite3_finalize(statement)
        }
        
        guard
            sqlite3_bind_text(statement, 1, id, -1, SQLITE_TRANSIENT) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        guard sqlite3_step(statement) == SQLITE_ROW else {
            return sequence
        }
        
        sequence = Int(sqlite3_column_int(statement, 0))
        return sequence
    }
    
    private func sequenceInsertUpdate(id: String, sequence: Int, sql: String) throws {
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: sql)
        defer {
            sqlite3_finalize(statement)
        }
        guard
            sqlite3_bind_int(statement, 1, Int32(sequence)) == SQLITE_OK &&
            sqlite3_bind_text(statement, 2, id, -1, SQLITE_TRANSIENT) == SQLITE_OK
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
}
