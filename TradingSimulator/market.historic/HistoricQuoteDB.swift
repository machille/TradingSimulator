//
//  HistoricQuoteDB.swift
//  Trading
//
//  Created by Maroun Achille on 23/10/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Cocoa
import SQLite3

class HistoricQuoteDB {
    
    static let instance = HistoricQuoteDB()
    let question = "Historic Quote"
    var sdb = StockDB.instance
    
    internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    let selectSQL: String = "SELECT QUOTE_DATE, QUOTE_CLOSE, QUOTE_OPEN, QUOTE_HIGH, " +
                            "QUOTE_LOW, VOLUME FROM HISTORIC_QUOTE WHERE  STOCK_ID = ?"
    
    private init() {
    
    }
    
    func getHistoricQuote(id: String) -> HistoricQuote? {
        do {
            return try getHistoricQuote(id: id, selection: selectSQL)
        } catch SQLiteError.NotFound( _) {
            //no message 
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
        return nil
    }
    
    func getRecentHistoricQuote(id: String) -> HistoricQuote? {
        
        var date = Date()
        do {
            date = CDate.subDate(date, "17 Months")
            let startDate = CDate.dateToDB(date)!
            return try getHistoricQuote(id: id, selection: selectSQL + " AND QUOTE_DATE > '" + startDate + "'")
            
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
        return nil
    }
    
    func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }
    
    private func getHistoricQuote(id: String,  selection: String) throws -> HistoricQuote {
        var hQuote: HistoricQuote
        
        let stock = try sdb.getStocksId(id: id)
        hQuote = HistoricQuote(id: id, name: stock.name, type: stock.type , marketPlace: stock.marketPlace)
       
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: selection + " ORDER BY QUOTE_DATE")
        defer {
            sqlite3_finalize(statement)
        }
    
        guard
            sqlite3_bind_text(statement, 1, id, -1, SQLITE_TRANSIENT) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: db.errorMessage)
            }
    
        while(sqlite3_step(statement)==SQLITE_ROW) {
            
    
            if let quoteDate = CDate.dateFromDB(String(cString:sqlite3_column_text(statement, 0))) {
                let sQuote = StockQuote(dateQuote: quoteDate, close: sqlite3_column_double(statement, 1), open: sqlite3_column_double(statement, 2), high: sqlite3_column_double(statement, 3), low: sqlite3_column_double(statement, 4), volume: sqlite3_column_double(statement, 5))
                hQuote.addQuote(sQuote: sQuote)
            }
        }
// MARK: - Add last Quote
        if let sdQuote = StockDayQuoteDB.instance.getStockDayQuote(stockId: id), let maxDate = hQuote.maxDate {
            
            let order = Calendar.current.compare(maxDate, to: sdQuote.dateQuote, toGranularity: .day)

            switch order {
            case .orderedDescending: break
            case .orderedAscending:
                let sQuote =  StockQuote(dateQuote: sdQuote.dateQuote, close: sdQuote.close, open: sdQuote.open, high: sdQuote.high, low: sdQuote.low, volume: sdQuote.volume)
                hQuote.addQuote(sQuote: sQuote)
            case .orderedSame: break
            }
        }

        return hQuote
    }
}
