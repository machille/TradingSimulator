//
//  WatchListDB.swift
//  Trading
//
//  Created by Maroun Achille on 08/05/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Foundation
import SQLite3

class WatchListDB {
    static let instance = WatchListDB()
    internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var histQuotestatement: OpaquePointer?
    
    private init() {
    }
    
    func getWatchList(id: Int) throws -> WatchList {
            
        let selectSQL = """
            SELECT WATCH_LIST_ID, WATCH_LIST_NAME, SCREENER_FLAG FROM WATCH_LIST WHERE WATCH_LIST_ID = ?
            """
            
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: selectSQL)
        defer {
            sqlite3_finalize(statement)
        }
            
        guard
            sqlite3_bind_int(statement, 1, Int32(id))  == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: db.errorMessage)
        }
            
        guard sqlite3_step(statement) == SQLITE_ROW else {
            throw SQLiteError.NotFound(message: db.errorMessage)
        }

        let watchList = WatchList()
                    
        watchList.id =  Int(sqlite3_column_int(statement, 0))
        watchList.name = String(cString: (sqlite3_column_text(statement, 1)))
        watchList.screener = String(cString: (sqlite3_column_text(statement, 2)))
        
        try watchList.stockArray = getWatchListIndex(id: watchList.id)
        
        return watchList
    }
    
    func getWatchListByName(name: String) throws -> WatchList {
                 
        let selectSQL = """
            SELECT WATCH_LIST_ID, WATCH_LIST_NAME, SCREENER_FLAG FROM WATCH_LIST WHERE WATCH_LIST_NAME = ?
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
                 
        guard sqlite3_step(statement) == SQLITE_ROW else {
            throw SQLiteError.NotFound(message: db.errorMessage)
        }

        let watchList = WatchList()
                         
        watchList.id =  Int(sqlite3_column_int(statement, 0))
        watchList.name = String(cString: (sqlite3_column_text(statement, 1)))
        watchList.screener = String(cString: (sqlite3_column_text(statement, 2)))
             
        try watchList.stockArray = getWatchListIndex(id: watchList.id)
            
        return watchList
    }
    
    func getWatchList() throws -> Array<WatchList> {
        var watchListArray = [WatchList]()
               
        let selectSQL = "SELECT WATCH_LIST_ID, WATCH_LIST_NAME, SCREENER_FLAG FROM WATCH_LIST"
           
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: selectSQL)
        defer {
            sqlite3_finalize(statement)
        }
               
        while(sqlite3_step(statement)==SQLITE_ROW) {
            let watchList = WatchList()
                   
            watchList.id =  Int(sqlite3_column_int(statement, 0))
            watchList.name = String(cString: (sqlite3_column_text(statement, 1)))
            watchList.screener = String(cString: (sqlite3_column_text(statement, 2)))
            
            try watchList.stockArray = getWatchListIndex(id: watchList.id)
            
            watchListArray.append(watchList)
        }
        return watchListArray
    }

    func getWatchListScreener() throws -> Array<WatchListIndex> {
        var watchListIndexArray = [WatchListIndex]()
                  
        let selectSQL = """
                SELECT WLI.WATCH_LIST_ID, WLI.STOCK_ID, ST.STOCK_NAME, wl.WATCH_LIST_NAME
                FROM WATCH_LIST_INDEX WLI, STOCKS ST, WATCH_LIST wl
                      WHERE WLI.STOCK_ID = ST.STOCK_ID
                      AND wli.WATCH_LIST_ID = wl.WATCH_LIST_ID
                      AND wl.SCREENER_FLAG = 'Y'
            """
              
              let db = try SQLiteDB.open()
              let statement = try db.prepareStatement(sql: selectSQL)
              defer {
                  sqlite3_finalize(statement)
              }
                         
                  
              while(sqlite3_step(statement)==SQLITE_ROW) {
                  let watchListIndex = WatchListIndex()
                      
                  watchListIndex.watchListId = Int(sqlite3_column_int(statement, 0))
                  watchListIndex.stockId = String(cString: (sqlite3_column_text(statement, 1)))
                  watchListIndex.stockName = String(cString: (sqlite3_column_text(statement, 2)))
                  watchListIndex.watchListName = String(cString: (sqlite3_column_text(statement, 3)))
                
                  watchListIndexArray.append(watchListIndex)
              }
              return watchListIndexArray
          }
    
    func getWatchListIndex(id: Int) throws -> Array<WatchListIndex> {
        var watchListIndexArray = [WatchListIndex]()
            
        let selectSQL = """
                SELECT WLI.WATCH_LIST_ID, WLI.STOCK_ID, ST.STOCK_NAME FROM WATCH_LIST_INDEX WLI,STOCKS ST
                WHERE WLI.STOCK_ID = ST.STOCK_ID AND WATCH_LIST_ID = ?
                """
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: selectSQL)
        defer {
            sqlite3_finalize(statement)
        }
                   
        guard
            sqlite3_bind_int(statement, 1, Int32(id))  == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: db.errorMessage)
        }
            
        while(sqlite3_step(statement)==SQLITE_ROW) {
            let watchListIndex = WatchListIndex()
                
            watchListIndex.watchListId = Int(sqlite3_column_int(statement, 0))
            watchListIndex.stockId = String(cString: (sqlite3_column_text(statement, 1)))
            watchListIndex.stockName = String(cString: (sqlite3_column_text(statement, 2)))
                
            watchListIndexArray.append(watchListIndex)
        }
        return watchListIndexArray
    }
    
// MARK: - Update WatchList
    
    func watchListInsert(watchList: WatchList) throws {
        
        let insertSQL = """
            INSERT INTO WATCH_LIST
            (WATCH_LIST_NAME, SCREENER_FLAG, WATCH_LIST_ID)
            VALUES(?, ?, ?)
            """
        try watchListUpdateInsertUpdate(watchList: watchList, sql: insertSQL )
    }
        
    func watchListUpdate(watchList: WatchList) throws {
            
        let updateSQL = """
            UPDATE WATCH_LIST SET
                WATCH_LIST_NAME = ?, SCREENER_FLAG = ?
            WHERE WATCH_LIST_ID = ?
            """
        try watchListUpdateInsertUpdate(watchList: watchList, sql: updateSQL )
    }

    private func watchListUpdateInsertUpdate(watchList: WatchList, sql: String) throws {
            
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: sql)
        defer {
            sqlite3_finalize(statement)
        }
        
        guard
            sqlite3_bind_int(statement, 3, Int32(watchList.id)) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 1, watchList.name, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 2, watchList.screener, -1, SQLITE_TRANSIENT) == SQLITE_OK
                
        else {
            throw SQLiteError.Bind(message: db.errorMessage)
        }
            
        guard sqlite3_step(statement) == SQLITE_DONE else {
            if db.errorCode == "19" {
                throw SQLiteError.Duplicate(message: db.errorMessage + " \(watchList.id) \(watchList.name)")
            }
            throw SQLiteError.Step(message: db.errorMessage)
        }
    }
    
     func watchListIndexInsert(watchListIndex: WatchListIndex) throws {
          
          let insertSQL = """
              INSERT INTO WATCH_LIST_INDEX
              (STOCK_ID, WATCH_LIST_ID)
              VALUES(?, ?)
              """
          try watchListUpdateIndexInsertUpdate(watchListIndex: watchListIndex, sql: insertSQL )
      }
          
      func watchListIndexUpdate(watchListIndex: WatchListIndex) throws {
              
          let updateSQL = """
              UPDATE WATCH_LIST_INDEX SET
                  STOCK_ID = ?
              WHERE WATCH_LIST_ID = ?
              """
          try watchListUpdateIndexInsertUpdate(watchListIndex: watchListIndex, sql: updateSQL )
      }

      private func watchListUpdateIndexInsertUpdate(watchListIndex: WatchListIndex, sql: String) throws {
              
          let db = try SQLiteDB.open()
          let statement = try db.prepareStatement(sql: sql)
          defer {
              sqlite3_finalize(statement)
          }
          
          guard
              sqlite3_bind_int(statement, 2, Int32(watchListIndex.watchListId)) == SQLITE_OK  &&
              sqlite3_bind_text(statement, 1, watchListIndex.stockId, -1, SQLITE_TRANSIENT) == SQLITE_OK
                  
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
    
    // MARK: - Delete WatchList
    
    func watchListDelete(watchList: WatchList) throws {
        try watchListDelete(id: watchList.id)
    }
       
    func watchListDelete(id: Int) throws {
        let deleteSQL = "DELETE FROM WATCH_LIST WHERE WATCH_LIST_ID = ?"
           
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: deleteSQL)
        defer {
            sqlite3_finalize(statement)
        }
        guard
            sqlite3_bind_int(statement, 1, Int32(id)) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: db.errorMessage)
        }
           
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: db.errorMessage)
        }
        
        try watchListIndexDelete(id: id)
    }

    func watchListIndexDelete(watchListIndex: WatchListIndex) throws {
        try watchListIndexDelete(id: watchListIndex.watchListId, stockId: watchListIndex.stockId)
    }
       
    func watchListIndexDelete(id: Int) throws {
        let deleteSQL = "DELETE FROM WATCH_LIST_INDEX WHERE WATCH_LIST_ID = ?"
           
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: deleteSQL)
        defer {
            sqlite3_finalize(statement)
        }
        guard
            sqlite3_bind_int(statement, 1, Int32(id)) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: db.errorMessage)
        }
           
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: db.errorMessage)
        }
    }
    
    func watchListIndexDelete(id: Int, stockId: String) throws {
         let deleteSQL = "DELETE FROM WATCH_LIST_INDEX WHERE WATCH_LIST_ID = ? AND STOCK_ID = ?"
            
         let db = try SQLiteDB.open()
         let statement = try db.prepareStatement(sql: deleteSQL)
         defer {
             sqlite3_finalize(statement)
         }
         guard
             sqlite3_bind_int(statement, 1, Int32(id)) == SQLITE_OK  &&
             sqlite3_bind_text(statement, 2, stockId, -1, SQLITE_TRANSIENT) == SQLITE_OK
         else {
             throw SQLiteError.Bind(message: db.errorMessage)
         }
            
         guard sqlite3_step(statement) == SQLITE_DONE else {
             throw SQLiteError.Step(message: db.errorMessage)
         }
     }
    
    func watchListDeleteStock(stockId: String) throws {
        let deleteSQL = "DELETE FROM WATCH_LIST_INDEX WHERE STOCK_ID = ?"
           
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
// MARK: -- for import share
    
    func foundWatchListStock (watchListName: String, stockId: String) throws -> Bool {
        let selectSQL = """
            SELECT WL.WATCH_LIST_ID, WATCH_LIST_NAME, SCREENER_FLAG
            FROM WATCH_LIST WL, WATCH_LIST_INDEX WLI
            WHERE WL.WATCH_LIST_ID = WLI.WATCH_LIST_ID
              AND WATCH_LIST_NAME = ? AND STOCK_ID = ?
            """
                 
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: selectSQL)
        defer {
            sqlite3_finalize(statement)
        }
                 
        guard
            sqlite3_bind_text(statement, 1, watchListName, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 2, stockId, -1, SQLITE_TRANSIENT) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: db.errorMessage)
        }
                 
        guard sqlite3_step(statement) == SQLITE_ROW else {
            return false
            //throw SQLiteError.NotFound(message: db.errorMessage)
        }

        return true
    }
    
    func foundWatchListName (watchListName: String) throws -> Bool {
        let selectSQL = """
            SELECT WATCH_LIST_ID, WATCH_LIST_NAME, SCREENER_FLAG FROM WATCH_LIST WHERE WATCH_LIST_NAME = ?
            """
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: selectSQL)
        defer {
            sqlite3_finalize(statement)
        }
                 
        guard
            sqlite3_bind_text(statement, 1, watchListName, -1, SQLITE_TRANSIENT) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: db.errorMessage)
        }
                 
        guard sqlite3_step(statement) == SQLITE_ROW else {
            return false
            //throw SQLiteError.NotFound(message: db.errorMessage)
        }

        return true
    }
    
    // MARK: - Import watch list
    func insertWatchList(watchListName: String, stockId: String) throws {
        if watchListName.isEmpty || watchListName.count < 2 || watchListName == "null" {
            return
        }
            
        if (try !foundWatchListStock(watchListName: watchListName, stockId: stockId)) {
            if (try !foundWatchListName(watchListName: watchListName)) {
                let watchList = WatchList()
                watchList.setId()
                watchList.name = watchListName
                try watchListInsert(watchList: watchList)
                
                let watchListIndex = WatchListIndex()
                watchListIndex.watchListId = watchList.id
                watchListIndex.stockId = stockId
                try watchListIndexInsert(watchListIndex: watchListIndex)
            
            } else {
            
                let watchList = try getWatchListByName(name: watchListName)
                let watchListIndex = WatchListIndex()
                watchListIndex.watchListId = watchList.id
                watchListIndex.stockId = stockId
                try watchListIndexInsert(watchListIndex: watchListIndex)
            }
        }
    }
}
