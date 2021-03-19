//
//  HistQuoteDB.swift
//  Trading
//
//  Created by Maroun Achille on 03/06/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation
import SQLite3

class StockQuoteDB {
    static let instance = StockQuoteDB()
    internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    let dateFormatter = DateFormatter()
    let currentCalendar = Calendar.current
    
    var histQuotestatement: OpaquePointer?
    
    private init() {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMD")
    }
    
    func stockHistList() throws -> Array<StockHist> {
        var stockHistArray = [StockHist]()
        let lastUpdateDate = CDate.lastOpenDate(date: Date())
        
        let selectSQL = """
            SELECT STOCK_ID, STOCK_NAME, STOCK_TYPE, MARKET_PLACE, HISTORIC_REFERENCE, HISTORIC_CODE, QUOTE_DATE
            FROM VSTOCK_HISTORIC
            ORDER BY 1
        """
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: selectSQL)
        defer {
            sqlite3_finalize(statement)
        }
        
        while(sqlite3_step(statement)==SQLITE_ROW) {
            let stockHist:StockHist = StockHist.init()
            
            stockHist.id = String(cString: (sqlite3_column_text(statement, 0)))
            stockHist.name = String(cString: (sqlite3_column_text(statement, 1)))
            stockHist.type = String(cString: (sqlite3_column_text(statement, 2)))
            stockHist.marketPlace = String(cString: (sqlite3_column_text(statement, 3)))
            stockHist.historicReference = String(cString: (sqlite3_column_text(statement, 4)))
            stockHist.historicCode = String(cString: (sqlite3_column_text(statement, 5)))
            
            if sqlite3_column_type(statement, 6) != SQLITE_NULL {
                if let quoteDate = dateFormatter.date(from: String(cString:sqlite3_column_text(statement, 6))) {
                    stockHist.quoteDate = quoteDate

                    let comp = currentCalendar.compare(quoteDate, to: lastUpdateDate, toGranularity: .day)
                    
                    switch comp {
                    case .orderedDescending: break
                    case .orderedAscending: break
                    case .orderedSame:
                        stockHist.upToDate = "Yes"
                    }
                }
            } else {
                stockHist.quoteDate  = CDate.startDate()
                stockHist.upToDate = "New"
            }
          
            stockHistArray.append(stockHist)
        }
        return stockHistArray
    }
    
    // MARK: ------ Historic Batch ------
    func deleteOrphanQuote() throws {
        let deleteSQL = """
                DELETE FROM HISTORIC_QUOTE
                WHERE STOCK_ID NOT IN (SELECT STOCK_ID FROM STOCKS)
                """
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: deleteSQL)
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: db.errorMessage)
        }
    }
    
    func deleteOldQuote() throws {
        let deleteSQL = """
                DELETE FROM HISTORIC_QUOTE
                WHERE  DATE(QUOTE_DATE) < DATE('now' , '-10 year')
                """
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: deleteSQL)
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: db.errorMessage)
        }
    }
    
    func truncateStockQuote() throws {
        let deleteSQL = """
                DELETE FROM STOCK_QUOTE
                """
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: deleteSQL)
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: db.errorMessage)
        }
    }
    
    func updateStockQuote() throws {
        try truncateStockQuote()
        let insertSQL = """
                INSERT INTO STOCK_QUOTE ( STOCK_ID, QUOTE_DATE, QUOTE_CLOSE, QUOTE_OPEN, QUOTE_HIGH,
                                        QUOTE_LOW, VOLUME, DATE1_DAY, QUOTE1_DAY, DATE1_YEAR, QUOTE1_YEAR, HIGH_YEAR, LOW_YEAR  )
                    SELECT HIST.STOCK_ID,
                           HIST.QUOTE_DATE,
                           HIST.QUOTE_CLOSE,
                           HIST.QUOTE_OPEN,
                           HIST.QUOTE_HIGH,
                           HIST.QUOTE_LOW,
                           HIST.VOLUME,
                           DAY1_QUOTE.QUOTE_DATE,
                           DAY1_QUOTE.QUOTE_CLOSE,
                           YEAR_QUOTE.QUOTE_DATE,
                           YEAR_QUOTE.QUOTE_CLOSE,
                           QUOTE52.HIGH52_QUOTE,
                           QUOTE52.LOW52_QUOTE
                    FROM HISTORIC_QUOTE AS HIST,
                
                    (SELECT STOCK_ID, MAX(QUOTE_DATE) AS MAX_DATE_QUOTE
                     FROM HISTORIC_QUOTE
                     GROUP BY STOCK_ID) AS HISTMAX,

                    (SELECT HIST.STOCK_ID,
                            MAX(HIST.QUOTE_DATE) AS QUOTE_DATE,
                            HIST.QUOTE_CLOSE
                    FROM HISTORIC_QUOTE AS HIST,
                         (SELECT STOCK_ID, MAX(QUOTE_DATE) AS MAX_DATE_QUOTE
                          FROM HISTORIC_QUOTE
                          GROUP BY STOCK_ID) AS HISTMAX
                    WHERE DATE(HIST.QUOTE_DATE) <= DATE(MAX_DATE_QUOTE , '-1 day')
                      AND DATE(HIST.QUOTE_DATE) > DATE(MAX_DATE_QUOTE , '-250 day')
                      AND HIST.STOCK_ID = HISTMAX.STOCK_ID
                    GROUP BY HIST.STOCK_ID ) AS DAY1_QUOTE

                   LEFT JOIN (
                        SELECT HIST_YEAR.STOCK_ID,
                               MAX(HIST_YEAR.QUOTE_DATE) AS QUOTE_DATE,
                               HIST_YEAR.QUOTE_CLOSE
                        FROM HISTORIC_QUOTE AS HIST_YEAR,
                             (SELECT STOCK_ID, MAX(QUOTE_DATE) AS MAX_DATE_QUOTE
                              FROM HISTORIC_QUOTE
                              GROUP BY STOCK_ID) AS HISTMAX_YEAR
                        WHERE DATE(HIST_YEAR.QUOTE_DATE) <= DATE(HISTMAX_YEAR.MAX_DATE_QUOTE , '-365 day')
                          AND DATE(HIST_YEAR.QUOTE_DATE) > DATE(HISTMAX_YEAR.MAX_DATE_QUOTE , '-370 day')
                          AND HIST_YEAR.STOCK_ID = HISTMAX_YEAR.STOCK_ID
                        GROUP BY HIST_YEAR.STOCK_ID) AS YEAR_QUOTE
                   ON HIST.STOCK_ID = YEAR_QUOTE.STOCK_ID

                   LEFT JOIN (
                        SELECT HIST_TOPYEAR.STOCK_ID,
                               MAX(HIST_TOPYEAR.QUOTE_CLOSE) AS HIGH52_QUOTE,
                               MIN(HIST_TOPYEAR.QUOTE_CLOSE) AS LOW52_QUOTE
                        FROM HISTORIC_QUOTE AS HIST_TOPYEAR,
                             (SELECT STOCK_ID, MAX(QUOTE_DATE) AS MAX_DATE_QUOTE
                             FROM HISTORIC_QUOTE
                             GROUP BY STOCK_ID) AS HISTMAX_TOPYEAR
                        WHERE DATE(HIST_TOPYEAR.QUOTE_DATE) >= DATE(HISTMAX_TOPYEAR.MAX_DATE_QUOTE , '-365 day')
                          AND HIST_TOPYEAR.STOCK_ID = HISTMAX_TOPYEAR.STOCK_ID
                        GROUP BY HIST_TOPYEAR.STOCK_ID ) AS QUOTE52
                   ON HIST.STOCK_ID = QUOTE52.STOCK_ID

                WHERE HIST.STOCK_ID = HISTMAX.STOCK_ID
                  AND HIST.STOCK_ID = DAY1_QUOTE.STOCK_ID
                  AND HIST.QUOTE_DATE = HISTMAX.MAX_DATE_QUOTE
                """
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: insertSQL)
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: db.errorMessage)
        }
    }
    //--------------------------- Historic Stock ------------------------------------------------
    func histQuoteInsert (stockId: String, quoteDate: Date, quoteOpen: Double, quoteHigh: Double, quoteLow :Double, quoteClose :Double, volume :Double )  throws {
        
        let insertSQL = """
                INSERT INTO HISTORIC_QUOTE
                (STOCK_ID, QUOTE_DATE, QUOTE_CLOSE, QUOTE_OPEN, QUOTE_HIGH, QUOTE_LOW, VOLUME)
                VALUES(?, ?, ?, ?, ?, ?, ?)
                """
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: insertSQL)
        defer {
            sqlite3_finalize(statement)
        }
        
        let quoteDateStr:String = dateFormatter.string(from: quoteDate)
        
        guard
            sqlite3_bind_text(statement, 1, stockId, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 2, quoteDateStr, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 3, quoteClose) == SQLITE_OK &&
            sqlite3_bind_double(statement, 4, quoteOpen) == SQLITE_OK &&
            sqlite3_bind_double(statement, 5, quoteHigh) == SQLITE_OK &&
            sqlite3_bind_double(statement, 6, quoteLow) == SQLITE_OK &&
            sqlite3_bind_double(statement, 7, volume) == SQLITE_OK
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
    
    func histQuoteDelete (stockId: String )  throws {
        let deleteSQL = "DELETE FROM HISTORIC_QUOTE WHERE STOCK_ID = ?"
        
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
//MARK: -- download Quote
    func histQuoteBeginStatement() throws -> SQLiteDB {
        let insertSQL = """
                INSERT INTO HISTORIC_QUOTE
                (STOCK_ID, QUOTE_DATE, QUOTE_CLOSE, QUOTE_OPEN, QUOTE_HIGH, QUOTE_LOW, VOLUME)
                VALUES(?, ?, ?, ?, ?, ?, ?)
                """
        
        let db = try SQLiteDB.open()
        histQuotestatement = try db.prepareStatement(sql: insertSQL)
        return db
    }
    
    func histQuoteInsertBatch(db: SQLiteDB, stockId: String, quoteDate: Date, quoteOpen: Double, quoteHigh: Double, quoteLow :Double, quoteClose :Double, volume :Double )  throws {
        
        let quoteDateStr = CDate.dateToDB(quoteDate)!
        sqlite3_reset(histQuotestatement)
        
        guard
            sqlite3_bind_text(histQuotestatement, 1, stockId, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(histQuotestatement, 2, quoteDateStr, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_double(histQuotestatement, 3, quoteClose) == SQLITE_OK &&
            sqlite3_bind_double(histQuotestatement, 4, quoteOpen) == SQLITE_OK &&
            sqlite3_bind_double(histQuotestatement, 5, quoteHigh) == SQLITE_OK &&
            sqlite3_bind_double(histQuotestatement, 6, quoteLow) == SQLITE_OK &&
            sqlite3_bind_double(histQuotestatement, 7, volume) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: db.errorMessage)
        }
        
        guard sqlite3_step(histQuotestatement) == SQLITE_DONE else {
            if db.errorCode == String(SQLITE_CONSTRAINT) { // "19"
                throw SQLiteError.Duplicate(message: db.errorMessage)
            }
            throw SQLiteError.Step(message: db.errorMessage)
        }
    }
    
    func histQuoteEndStatement(db: SQLiteDB) throws {
        let ct = try db.checkTransaction()
        sqlite3_finalize(histQuotestatement)
        if ct == 0 {
            try db.commit()
        }
    }
  
    
}
