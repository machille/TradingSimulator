//
//  StockDayQuoteDB.swift
//  Trading
//
//  Created by Maroun Achille on 01/07/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Cocoa
import SQLite3

class StockDayQuoteDB {
    
    static let instance = StockDayQuoteDB()
    let question = "Stock Day Quote"
    
    internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    var stockRefArray = [StockReference]()
    fileprivate var stockQuoteCache = [String : StockDayQuote]()
    fileprivate var mappingIdDict = [String : String]()
    fileprivate var workReferenceDict = [String : String]()

    var stockDayQuoteArra: [StockDayQuote] {
       return Array(stockQuoteCache.values)
    }
    
    private init() {
        var dailyReferenceTable: TableComboDB!
        do {
            try dailyReferenceTable = TableComboDB.init(tableName: "QOTREF")
            let qrefTable = dailyReferenceTable.tableArray
            for table in qrefTable! {
                let stockRef = StockReference(referenceId: table.id, referenceUrl: table.value1)
                loadStockQuote(stockRef: stockRef)
                stockRefArray.append(stockRef)
            }
            
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
        
        workReferenceDict.removeAll()
    }
    
    func dspAlert(text: String) {
        Message.messageAlert(question, text: text)
    }
    
    fileprivate func loadStockQuote(stockRef: StockReference) {
        let selectSQL = """
            SELECT STOCK_ID, DAILY_CODE, MARKET_PLACE, STOCK_NAME, STOCK_CURRENCY, STOCK_TYPE,
                   QUOTE_DATE, QUOTE_CLOSE, CHG1DAY, VAR1DAY, QUOTE_OPEN, QUOTE_HIGH,
                   QUOTE_LOW, VOLUME, LOW_YEAR, HIGH_YEAR, VAR1YEAR, VAR1RANGE
            FROM VSTOCK_QUOTE WHERE DAILY_REFERENCE = ?
            """
        
        do {
            let db = try SQLiteDB.open()
            let statement = try db.prepareStatement(sql: selectSQL)
            defer {
                sqlite3_finalize(statement)
            }
            workReferenceDict.removeAll()
            
            guard
                sqlite3_bind_text(statement, 1, stockRef.referenceId, -1, SQLITE_TRANSIENT) == SQLITE_OK
                else {
                    dspAlert(text: db.errorMessage)
                    return
                }
            
            var qDate: Date
            var stockId, refCode, mktPlace: String
            
            while(sqlite3_step(statement)==SQLITE_ROW) {
                stockId = String(cString: (sqlite3_column_text(statement, 0)))
                refCode = String(cString: (sqlite3_column_text(statement, 1)))
                mktPlace = String(cString: (sqlite3_column_text(statement, 2)))
                
                let stockdq = StockDayQuote.init(id: stockId,
                                                 name: String(cString: (sqlite3_column_text(statement, 3))),
                                                 reference: refCode,
                                                 currency: String(cString: (sqlite3_column_text(statement, 4))),
                                                 marketPlace: mktPlace,
                                                 type: String(cString: (sqlite3_column_text(statement, 5))),
                                                 yearLow: sqlite3_column_double(statement, 14),
                                                 yearHigh: sqlite3_column_double(statement, 15),
                                                 yearVarChange: sqlite3_column_double(statement, 16),
                                                 yearRange: sqlite3_column_double(statement, 17))
                
                if sqlite3_column_type(statement, 6) != SQLITE_NULL {
                    qDate = CDate.dateFromDB(String(cString:sqlite3_column_text(statement, 6)))!
                } else {
                    qDate = Date()
                }
                
                stockdq.updateQuote(dateQuote: qDate,
                                    close: sqlite3_column_double(statement, 7),
                                    change: sqlite3_column_double(statement, 8),
                                    varChange: sqlite3_column_double(statement, 9),
                                    open: sqlite3_column_double(statement, 10),
                                    high: sqlite3_column_double(statement, 11),
                                    low: sqlite3_column_double(statement, 12),
                                    volume: sqlite3_column_double(statement, 13))
                
                stockdq.resetStatus()
                
                stockQuoteCache[refCode] = stockdq
                mappingIdDict[stockId] = refCode
                
                if let value = workReferenceDict[mktPlace] {
                    let mktUrl = value + "," + refCode
                    workReferenceDict[mktPlace] =  mktUrl
                } else {
                    workReferenceDict[mktPlace] = refCode
                }
            }
            
            if stockRef.referenceId == "YAHDLY" {
                let maxRef = 135;
                stockRef.clearUrl()
                var urlSplit: String = ""
                
                for (key, value) in workReferenceDict {
                    let refArray = value.components(separatedBy: ",")
                    var j: Int = 0
                    for url in refArray {
                        j = (j+1) % maxRef
                        if j == 0 {
                            let index = urlSplit.index(urlSplit.startIndex, offsetBy: urlSplit.count - 1)
                            let urlStr: String = stockRef.referenceUrl + String(urlSplit[..<index])
                            stockRef.addUrl(marketPlace: key, urlStr: urlStr)
                            urlSplit = ""
                        }
                        urlSplit = urlSplit + url + ",";
                    }
                    if (urlSplit.count > 1 ) {
                        let index = urlSplit.index(urlSplit.startIndex, offsetBy: urlSplit.count - 1)
                        let urlStr: String = stockRef.referenceUrl + String(urlSplit[..<index])
                        stockRef.addUrl(marketPlace: key, urlStr: urlStr)
                        urlSplit = ""
                    }
                }
            }
            
        } catch let error as SQLiteError {
            dspAlert(text: error.description)
        } catch let error {
            dspAlert(text: "Other Error \(error)")
        }
    }
    
    func getStockDayQuote(stockId: String) -> StockDayQuote? {
        if let stockRef = mappingIdDict[stockId] {
            if let sdq = stockQuoteCache[stockRef] {
                return sdq
            }
        }
        return nil
    }
    
    func updateDayQuote (stockRef: String, dateQuote: Date, last: Double, change: Double, varChange: Double, open: Double, high: Double, low: Double, volume: Double) {
    
        if let sharedp = stockQuoteCache[stockRef] {
            sharedp.updateQuote (dateQuote: dateQuote, close: last, change: change, varChange: varChange, open: open, high: high, low: low, volume: volume)
        } else {
            dspAlert(text: "updateDayQuote: RefCode Not Found \(stockRef)")
        }
    }
    
    func resetStatus () {
        for (_, stockdp) in stockQuoteCache {
            stockdp.resetStatus()
        }
    }
    
}
