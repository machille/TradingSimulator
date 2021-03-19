//
//  IndexDailyQuoteDB.swift
//  Trading
//
//  Created by Maroun Achille on 26/07/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Cocoa
import SQLite3


class IndexDailyQuoteDB {
    static let instance = IndexDailyQuoteDB()
    private let stockdpDB = StockDayQuoteDB.instance
    internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    private let question = "Index Daily Quote DB"
    
    var firstIndex: String?
    
    private init() {

    }
    
    func getStockIndex (indexId: String) -> [StockDayQuote] {
       
        let readIndexMember = """
            SELECT INDEX_MEMBER.STOCK_ID FROM INDEX_MEMBER, STOCKS
            WHERE INDEX_ID = ? AND  INDEX_MEMBER.STOCK_ID = STOCKS.STOCK_ID
            """
        var stockIndex = [StockDayQuote]()
        do {
            let db = try SQLiteDB.open()
            let statement = try db.prepareStatement(sql: readIndexMember)
            defer {
                sqlite3_finalize(statement)
            }
            
            guard
                sqlite3_bind_text(statement, 1, indexId, -1, SQLITE_TRANSIENT) == SQLITE_OK
                else {
                    dspAlert(text:"\(db.errorMessage)  \(#function)" )
                    return stockIndex
            }
           
            while(sqlite3_step(statement)==SQLITE_ROW) {
                let stockId = String(cString: (sqlite3_column_text(statement, 0)))
                if let stockdq = stockdpDB.getStockDayQuote(stockId: stockId) {
                    stockIndex.append(stockdq)
                }
            }
        } catch let error as SQLiteError {
            dspAlert(text: "\(error.description)   \(#function)" )
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
        return stockIndex
    }

    func getAllIndex () -> [StockDayQuote] {
        return readStockType (stockType: "Index")
    }

    func getCurrency () -> [StockDayQuote] {
        return readStockType (stockType: "Currency")
    }

    func readStockType (stockType: String) -> [StockDayQuote] {
        let readStockType = "SELECT STOCK_ID FROM STOCKS WHERE STOCK_TYPE = ? ORDER BY STOCK_NAME "
        var stockIndex = [StockDayQuote]()
        var first = true
        
        do {
            let db = try SQLiteDB.open()
            let statement = try db.prepareStatement(sql: readStockType)
            defer {
                sqlite3_finalize(statement)
            }
        
            guard
                sqlite3_bind_text(statement, 1, stockType, -1, SQLITE_TRANSIENT) == SQLITE_OK
                else {
                    dspAlert(text:"\(db.errorMessage)  \(#function)" )
                    return stockIndex
            }

            while(sqlite3_step(statement)==SQLITE_ROW) {
                
                let stockId = String(cString: (sqlite3_column_text(statement, 0)))
                // for init QuoteStockViewController
                if stockType == "Index" && first {
                    firstIndex = stockId
                    first = false
                }
                
                if let stockdq = stockdpDB.getStockDayQuote(stockId: stockId) {
                    stockIndex.append(stockdq)
                }
            }

        } catch let error as SQLiteError {
            dspAlert(text: "\(error.description)   \(#function)" )
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
        return stockIndex
    }
    
    func getWatchListStock (id: Int) -> [StockDayQuote] {
        let readWatListIndex = """
            SELECT WATCH_LIST_INDEX.STOCK_ID, STOCKS.STOCK_NAME FROM WATCH_LIST_INDEX, STOCKS
            WHERE WATCH_LIST_ID = ? AND  WATCH_LIST_INDEX.STOCK_ID = STOCKS.STOCK_ID
            ORDER BY STOCK_NAME
            """
        var stockIndex = [StockDayQuote]()
        
        do {
            let db = try SQLiteDB.open()
            let statement = try db.prepareStatement(sql: readWatListIndex)
            defer {
                sqlite3_finalize(statement)
            }
           
            guard
                sqlite3_bind_int(statement, 1, Int32(id))  == SQLITE_OK
                else {
                    dspAlert(text:"\(db.errorMessage)  \(#function)" )
                    return stockIndex
                }

            while(sqlite3_step(statement)==SQLITE_ROW) {
                let stockId = String(cString: (sqlite3_column_text(statement, 0)))
                if let stockdq = stockdpDB.getStockDayQuote(stockId: stockId) {
                    stockIndex.append(stockdq)
                }
            }

        } catch let error as SQLiteError {
            dspAlert(text: "\(error.description)   \(#function)" )
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
        return stockIndex
    }

    func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }
}

