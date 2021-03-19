//
//  StockDB.swift
//  SQLiteTest
//
//  Created by Maroun Achille on 09/04/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation
import SQLite3

class StockDB {
    static let instance = StockDB()
    internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var histQuotestatement: OpaquePointer?
    
    private init() {

    }

    func getStocksId(id: String ) throws -> Stock {
        
        let selectSQL = """
                SELECT STOCK_ID, STOCK_NAME, STOCK_STATUS, STOCK_TYPE, STOCK_INDUSTRY, 
                CLOSING_DATE, STOCK_CURRENCY, MARKET_PLACE, CREATION_DATE, DAILY_REFERENCE, DAILY_CODE,
                HISTORIC_REFERENCE, HISTORIC_CODE FROM MAIN.STOCKS WHERE STOCK_ID = ?
                """
        
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
            throw SQLiteError.NotFound(message: db.errorMessage)
        }

        let stock:Stock = Stock.init()
                
        stock.id = String(cString: (sqlite3_column_text(statement, 0)))
        stock.name = String(cString: (sqlite3_column_text(statement, 1)))
        stock.status = String(cString: (sqlite3_column_text(statement, 2)))
        stock.type = String(cString: (sqlite3_column_text(statement, 3)))
        stock.industry = String(cString: (sqlite3_column_text(statement, 4)))
        
        if sqlite3_column_type(statement, 5) != SQLITE_NULL {
            stock.closingDate = CDate.dateFromDB(String(cString:sqlite3_column_text(statement, 5)))
        }
        
        stock.currency = String(cString: (sqlite3_column_text(statement, 6)))
        stock.marketPlace = String(cString: (sqlite3_column_text(statement, 7)))
        
        if sqlite3_column_type(statement, 8) != SQLITE_NULL {
            stock.creationDate = CDate.dateFromDB(String(cString:sqlite3_column_text(statement, 8))) ?? Date()
        }

        stock.dailyReference = String(cString: (sqlite3_column_text(statement, 9)))
        stock.dailyCode = String(cString: (sqlite3_column_text(statement, 10)))
        stock.historicReference = String(cString: (sqlite3_column_text(statement, 11)))
        stock.historicCode = String(cString: (sqlite3_column_text(statement, 12)))
                
        return stock
    }
    
    func getIndexList()  throws -> Array<Stock> {
        return try getStocksSelectList(otherWhere: "WHERE STOCK_TYPE = 'Index'")
    }
    
    func getCurrencyList()  throws -> Array<Stock> {
        return try getStocksSelectList(otherWhere: "WHERE STOCK_TYPE = 'Currency'")
    }
    
    func getStocksList() throws -> Array<Stock> {
        return try getStocksSelectList(otherWhere: "")
    }
    
    func getStocksSelectList(otherWhere: String) throws -> Array<Stock> {
        var stocksArray = [Stock]()
        
        let selectSQL = """
            SELECT STOCK_ID, STOCK_NAME, STOCK_STATUS, STOCK_TYPE, STOCK_INDUSTRY,
            CLOSING_DATE, STOCK_CURRENCY, MARKET_PLACE, CREATION_DATE, DAILY_REFERENCE, DAILY_CODE,
            HISTORIC_REFERENCE, HISTORIC_CODE FROM MAIN.STOCKS
        """ +  " " + otherWhere +  " ORDER BY 1"
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: selectSQL)
        defer {
            sqlite3_finalize(statement)
        }
        
        while(sqlite3_step(statement)==SQLITE_ROW) {
            let stock:Stock = Stock.init()
            
            stock.id = String(cString: (sqlite3_column_text(statement, 0)))
            stock.name = String(cString: (sqlite3_column_text(statement, 1)))
            stock.status = String(cString: (sqlite3_column_text(statement, 2)))
            stock.type = String(cString: (sqlite3_column_text(statement, 3)))
            stock.industry = String(cString: (sqlite3_column_text(statement, 4)))
            
            if sqlite3_column_type(statement, 5) != SQLITE_NULL {
                stock.closingDate = CDate.dateFromDB(String(cString:sqlite3_column_text(statement, 5)))
            }
            
            stock.currency = String(cString: (sqlite3_column_text(statement, 6)))
            stock.marketPlace = String(cString: (sqlite3_column_text(statement, 7)))
            
            if sqlite3_column_type(statement, 8) != SQLITE_NULL {
                stock.creationDate = CDate.dateFromDB(String(cString:sqlite3_column_text(statement, 8))) ?? Date()
            }

            stock.dailyReference = String(cString: (sqlite3_column_text(statement, 9)))
            stock.dailyCode = String(cString: (sqlite3_column_text(statement, 10)))
            stock.historicReference = String(cString: (sqlite3_column_text(statement, 11)))
            stock.historicCode = String(cString: (sqlite3_column_text(statement, 12)))
            
            stocksArray.append(stock)
        }
        return stocksArray
    }

    
    func stockInsert(stock: Stock) throws {
    
        let insertSQL = """
            INSERT INTO STOCKS
            (STOCK_NAME, STOCK_STATUS, STOCK_TYPE, STOCK_INDUSTRY, CLOSING_DATE, STOCK_CURRENCY,
            MARKET_PLACE, CREATION_DATE, DAILY_REFERENCE, DAILY_CODE, HISTORIC_REFERENCE, HISTORIC_CODE,
            STOCK_ID)
            VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """
        
        try stockInsertUpdate(stock: stock, sql: insertSQL )
    }
    
    
    func stockUpdate(stock: Stock) throws {
        
        let updateSQL = """
            UPDATE STOCKS SET
                STOCK_NAME = ?, STOCK_STATUS = ?, STOCK_TYPE = ?, STOCK_INDUSTRY = ?,
                CLOSING_DATE = ?, STOCK_CURRENCY = ?, MARKET_PLACE = ?, CREATION_DATE = ?,
                DAILY_REFERENCE = ?, DAILY_CODE = ?, HISTORIC_REFERENCE = ?, HISTORIC_CODE = ?
            WHERE STOCK_ID = ?
            """
        try stockInsertUpdate(stock: stock, sql: updateSQL )
    }

    private func stockInsertUpdate(stock: Stock, sql: String) throws {
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: sql)
        defer {
            sqlite3_finalize(statement)
        }
        
        
        var closingDate: String?
        if let closingDatecheck = stock.closingDate {
            closingDate = CDate.dateToDB(closingDatecheck)
        } else {
            closingDate = nil
        }
        let creationDate: String? = CDate.dateToDB(stock.creationDate)
        
        guard
            sqlite3_bind_text(statement, 13, stock.id, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 1, stock.name, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 2, stock.status, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 3, stock.type, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 4, stock.industry, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            
            sqlite3_bind_text(statement, 5, closingDate, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 6, stock.currency, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 7, stock.marketPlace, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 8, creationDate, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
                
            sqlite3_bind_text(statement, 9, stock.dailyReference, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 10, stock.dailyCode, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 11, stock.historicReference, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 12, stock.historicCode, -1, SQLITE_TRANSIENT) == SQLITE_OK
            
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
    
    
    func stockDelete(stock: Stock) throws {
        try stockDelete(id: stock.id)
    }
    
    func stockDelete(id: String) throws {
        let deleteSQL = "DELETE FROM STOCKS WHERE STOCK_ID = ?"
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: deleteSQL)
        defer {
            sqlite3_finalize(statement)
        }
        guard
            sqlite3_bind_text(statement, 1, id, -1, SQLITE_TRANSIENT) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: db.errorMessage)
        }
    }
    
// MARK: -- Index Mumber -----------
    func getIndexMember(indexId: String, stockId: String ) throws -> IndexMember {
        
        let selectSQL = "SELECT INDEX_ID, STOCK_ID, INDEX_WEIGHT FROM  INDEX_MEMBER WHERE INDEX_ID = ? STOCK_ID = ?"
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: selectSQL)
        defer {
            sqlite3_finalize(statement)
        }
        guard
            sqlite3_bind_text(statement, 1, indexId, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 2, stockId, -1, SQLITE_TRANSIENT) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        guard sqlite3_step(statement) == SQLITE_ROW else {
            throw SQLiteError.Step(message: db.errorMessage)
        }
        
        let indexM: IndexMember = IndexMember.init()
                
        indexM.indexId = String(cString: (sqlite3_column_text(statement, 0)))
        indexM.stockId = String(cString: (sqlite3_column_text(statement, 1)))
        indexM.weight = Int(sqlite3_column_int(statement, 2))
                
        return indexM
    }
    
    
    func getIndexMember(indexId: String) throws -> Array<IndexMember> {
        var indexMArray = [IndexMember]()
        let selectSQL = "SELECT INDEX_ID, STOCK_ID, STOCK_NAME, INDEX_WEIGHT FROM VINDEX_STOCKS WHERE INDEX_ID = ?"
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: selectSQL)
        defer {
            sqlite3_finalize(statement)
        }
        
        guard
            sqlite3_bind_text(statement, 1, indexId, -1, SQLITE_TRANSIENT) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: db.errorMessage)
        }
    
        while(sqlite3_step(statement)==SQLITE_ROW) {
            let indexM: IndexMember = IndexMember()
                
            indexM.indexId = String(cString: (sqlite3_column_text(statement, 0)))
            indexM.stockId = String(cString: (sqlite3_column_text(statement, 1)))
            indexM.stockName = String(cString: (sqlite3_column_text(statement, 2)))
            indexM.weight = Int(sqlite3_column_int(statement, 3))
                
            indexMArray.append(indexM)
        }
        return indexMArray
    }
        
    func getIndexMember(stockId: String) throws -> Array<IndexMember> {
        
        var indexMArray = [IndexMember]()
        let selectSQL = "SELECT INDEX_ID, STOCK_ID, STOCK_NAME, INDEX_WEIGHT FROM VINDEX_STOCKS WHERE STOCK_ID = ?"
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: selectSQL)
        defer {
            sqlite3_finalize(statement)
        }
        
        guard
            sqlite3_bind_text(statement, 1, stockId, -1, SQLITE_TRANSIENT) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        while(sqlite3_step(statement)==SQLITE_ROW) {
            let indexM: IndexMember = IndexMember()
                
            indexM.indexId = String(cString: (sqlite3_column_text(statement, 0)))
            indexM.stockId = String(cString: (sqlite3_column_text(statement, 1)))
            indexM.stockName = String(cString: (sqlite3_column_text(statement, 2)))
            indexM.weight = Int(sqlite3_column_int(statement, 3))
                
            indexMArray.append(indexM)
        }
        return indexMArray
    }
    
    func indexMemberInsert(indexM: IndexMember) throws {
        try indexMemberInsert (indexId: indexM.indexId, stockId: indexM.stockId, weight: indexM.weight )
    }
    
    func indexMemberInsert (indexId: String, stockId: String, weight: Int )  throws {
        let insertSQL = """
                INSERT INTO INDEX_MEMBER
                (INDEX_ID, STOCK_ID, INDEX_WEIGHT)
                VALUES(?, ?, ?)
                """
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: insertSQL)
        defer {
            sqlite3_finalize(statement)
        }
        
        guard
            sqlite3_bind_text(statement, 1, indexId, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 2, stockId, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_int(statement, 3, Int32(weight)) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: db.errorMessage)
        }
    }
    
    
    func indexMemberDelete (indexM: IndexMember) throws {
        try indexMemberDelete(indexId: indexM.indexId, stockId: indexM.stockId)
    }
    
    func indexMemberDelete (indexId: String, stockId: String) throws {
        
        let deleteSQL = "DELETE FROM INDEX_MEMBER WHERE INDEX_ID = ? AND STOCK_ID = ?"
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: deleteSQL)
        defer {
            sqlite3_finalize(statement)
        }
        guard
            sqlite3_bind_text(statement, 1, indexId, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 2, stockId, -1, SQLITE_TRANSIENT) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: db.errorMessage)
        }
    }
    
    
    func indexMemberDelete (indexId: String) throws {
        
        let deleteSQL = "DELETE FROM INDEX_MEMBER WHERE INDEX_ID = ?"
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: deleteSQL)
        defer {
            sqlite3_finalize(statement)
        }
        
        guard
            sqlite3_bind_text(statement, 1, indexId, -1, SQLITE_TRANSIENT) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: db.errorMessage)
        }
    }
    
    func indexMemberDelete (stockId: String) throws {
        
        let deleteSQL = "DELETE FROM INDEX_MEMBER WHERE STOCK_ID = ?"
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: deleteSQL)
        defer {
            sqlite3_finalize(statement)
        }
        guard
            sqlite3_bind_text(statement, 1, stockId, -1, SQLITE_TRANSIENT) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: db.errorMessage)
        }
    }
}
