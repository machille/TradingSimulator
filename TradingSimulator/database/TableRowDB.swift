//
//  TableRowDB.swift
//  SQLiteTest
//
//  Created by Maroun Achille on 16/04/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation
import SQLite3

class TableRowDB {
    
    var columns:     [String]
    var tableName:    String
    var whereExpr:    String? = nil
    var orderBy:      String? = nil
    
    var rowCount: Int = 0
    var rowTable = [Any?]()
    
    init(columns: [String], tableName: String, whereExpr: String? = nil, orderBy: String? = nil) {
        self.columns =   columns
        self.tableName = tableName
        self.whereExpr = whereExpr
        self.orderBy = orderBy
    }
    
    private func prepareSelectFrom() -> String {
        
        var fragments = [ "SELECT" ]
        fragments.append(columns.joined(separator: ","))
        
        fragments.append("FROM")
        fragments.append(tableName)
        
        if whereExpr != nil {
            fragments.append("WHERE")
            fragments.append(whereExpr!)
        }
        
        if orderBy != nil {
            fragments.append("ORDER BY")
            fragments.append(orderBy!)
        }
        
        return fragments.joined(separator: " ")
    }
    
    public func setWhere (whereExpr: String? = nil) {
        self.whereExpr = whereExpr
    }


    public func countRows() throws -> Int {
        var count:Int = 0
        var fragments = [ "SELECT COUNT (*)" ]
        
        fragments.append("FROM")
        fragments.append(tableName)
        
        if whereExpr != nil {
            fragments.append("WHERE")
            fragments.append(whereExpr!)
        }
        
        let countExpr = fragments.joined(separator: " ")

        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: countExpr)
        defer {
            sqlite3_finalize(statement)
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            count = 0
        } else {
            count = Int(sqlite3_column_int(statement, 0))
        }
        return count
    }
    
    
    public func readTable() throws {
        rowTable.removeAll()
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: prepareSelectFrom())
        defer {
            sqlite3_finalize(statement)
        }
        
        rowCount = try countRows()
        
        while(sqlite3_step(statement)==SQLITE_ROW) {
            var rowData = [Any?]()
            for columnIndex in 0..<(columns.count) {
                switch sqlite3_column_type(statement, Int32(columnIndex)) {
                case SQLITE_NULL:
                    rowData.append(nil)
                case SQLITE_INTEGER:
                    rowData.append(Int(sqlite3_column_int64(statement, Int32(columnIndex))))
                case SQLITE_FLOAT:
                    rowData.append (Double(sqlite3_column_double(statement, Int32(columnIndex))))
                default:
                    rowData.append(String(String(cString: sqlite3_column_text(statement, Int32(columnIndex)))))
                }
            }
            rowTable.append(rowData)
        }
    }
    
    public func getValue(_ fname: String, at:Int)-> Any? {
        if let i = columns.firstIndex(of: fname) {
            if let rowData = rowTable[at] as? [Any?] {
                if let value = rowData[i] {
                    return value
                }
            }
        }
        print ("index for fname not found --\(fname)--")

        return nil
    }
    
    public func getDoubleValue(_ fname: String, at:Int = 0)-> Double {
        guard let value = getValue(fname, at: at) else {
            return 0.0
        }
        if let doubleValue = value as? Double {
            return doubleValue
        }
        
        if let intValue = value as? Int {
            return Double(intValue)
        }
        return 0.0
    }

    public func getStringValue(_ fname: String, at:Int = 0)-> String {
        guard let value = getValue(fname, at: at) else {
            return "..."
        }
        if let stringValue = value as? String {
            return stringValue
        }
        
        return "\(value)"
    }
}
