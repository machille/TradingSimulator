//
//  SimulatorDB.swift
//  Trading
//
//  Created by Maroun Achille on 09/06/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Foundation
import SQLite3

class SimulatorDB {
    static let instance = SimulatorDB()
    internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    private init() {
       
    }
    
    func getSimuPosId(id: Int ) throws -> SimuPosition {
        
        let selectSQL = """
                SELECT
                SIMU_ID, STOCK_ID, INDEX_ID, START_DATE, START_BALANCE, COMMISSION, STOP_LOSS_ACTION,
                STOP_LOSS_DEFAULT, POSITION_ID, POSITION_TYPE, QUANTITY, LAST_DATE, LAST_QUOTE,
                INVESTED_AMOUNT, STOP_LOSS, TOTAL_COMM, ACTUAL_BALANCE, CREATION_DATE, AVERAGE_PRICE
                FROM SIMU_POSITION WHERE SIMU_ID = ?
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
        
        let simuPos = SimuPosition()
        
        simuPos.simuId = Int(sqlite3_column_int(statement, 0))
        simuPos.stockId = String(cString: (sqlite3_column_text(statement, 1)))
        simuPos.indexId = String(cString: (sqlite3_column_text(statement, 2)))
        
        let stock = try StockDB.instance.getStocksId(id: simuPos.stockId)
        simuPos.stockName = stock.name
        
        if let checkValue = CDate.dateFromDB(String(cString: (sqlite3_column_text(statement, 3)))) {
            simuPos.startDate = checkValue
        } else {
            throw SQLiteError.DataErrror(message: "Start Date")
        }
        
        simuPos.startBalance = sqlite3_column_double(statement, 4)
        simuPos.commission = sqlite3_column_double(statement, 5)
        simuPos.stopLossAction = String(cString: (sqlite3_column_text(statement, 6)))
        simuPos.stopLossDefault = sqlite3_column_double(statement, 7)
        
        simuPos.positionId = Int(sqlite3_column_int(statement, 8))
        simuPos.positionType = String(cString: (sqlite3_column_text(statement, 9)))
        simuPos.quantity = sqlite3_column_double(statement, 10)
        
        if let checkValue = CDate.dateFromDB(String(cString: (sqlite3_column_text(statement, 11)))) {
            simuPos.lastDate = checkValue
        } else {
            throw SQLiteError.DataErrror(message: "Last Date")
        }
        
        simuPos.lastQuote = sqlite3_column_double(statement, 12)
        simuPos.investedAmount = sqlite3_column_double(statement, 13)
        simuPos.stopLoss = sqlite3_column_double(statement, 14)
        simuPos.totalComm = sqlite3_column_double(statement, 15)
        simuPos.actualBalance = sqlite3_column_double(statement, 16)
        
        if let checkValue = CDate.dateFromDB(String(cString: (sqlite3_column_text(statement, 17)))) {
            simuPos.creationDate = checkValue
        } else {
            throw SQLiteError.DataErrror(message: "Creation Date")
        }
        simuPos.averagePrice = sqlite3_column_double(statement, 18)
        
        return simuPos
    }
    
    func getSimuPosId(simuPos: SimuPosition) throws -> SimuPosition {
        return try getSimuPosId(id: simuPos.simuId)
    }
    
    func simuPosInsert(simuPos: SimuPosition) throws {
        
        let insertSQL = """
            INSERT INTO SIMU_POSITION
            (STOCK_ID, INDEX_ID, START_DATE, START_BALANCE, COMMISSION, STOP_LOSS_ACTION,
            STOP_LOSS_DEFAULT, POSITION_ID, POSITION_TYPE, QUANTITY, LAST_DATE, LAST_QUOTE,
            INVESTED_AMOUNT, STOP_LOSS, TOTAL_COMM, ACTUAL_BALANCE, CREATION_DATE, AVERAGE_PRICE, 
            SIMU_ID)
            VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """
        
        try simuPosInsertUpdate(simuPos: simuPos, sql: insertSQL)
    }
    
    
    func simuPosUpdate(simuPos: SimuPosition) throws {
        
        let updateSQL = """
            UPDATE SIMU_POSITION SET
            STOCK_ID = ?, INDEX_ID = ?, START_DATE = ?, START_BALANCE = ?, COMMISSION = ?,
            STOP_LOSS_ACTION = ?, STOP_LOSS_DEFAULT = ?, POSITION_ID = ?, POSITION_TYPE = ?,
            QUANTITY = ?, LAST_DATE = ?, LAST_QUOTE = ?, INVESTED_AMOUNT = ?, STOP_LOSS = ?,
            TOTAL_COMM = ?, ACTUAL_BALANCE = ?, CREATION_DATE = ?, AVERAGE_PRICE = ?
            WHERE SIMU_ID = ?
            """
        try simuPosInsertUpdate(simuPos: simuPos, sql: updateSQL)
    }
    
    private func simuPosInsertUpdate(simuPos: SimuPosition, sql: String) throws {
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: sql)
        defer {
            sqlite3_finalize(statement)
        }
        
        let startDate: String! = CDate.dateToDB(simuPos.startDate)
        let lastDate: String! = CDate.dateToDB(simuPos.lastDate)
        let creationDate: String! = CDate.dateToDB(simuPos.creationDate)
        
        guard
            sqlite3_bind_int(statement, 19, Int32(simuPos.simuId)) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 1, simuPos.stockId, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 2, simuPos.indexId, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 3, startDate, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 4, simuPos.startBalance) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 5, simuPos.commission) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 6, simuPos.stopLossAction, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 7, simuPos.stopLossDefault) == SQLITE_OK  &&
            sqlite3_bind_int(statement, 8, Int32(simuPos.positionId)) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 9, simuPos.positionType, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 10, simuPos.quantity) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 11, lastDate, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 12, simuPos.lastQuote) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 13, simuPos.investedAmount) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 14, simuPos.stopLoss) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 15, simuPos.totalComm) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 16, simuPos.actualBalance) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 17, creationDate, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_double(statement, 18, simuPos.averagePrice) == SQLITE_OK
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

    func simuPosDelete(simuPos: SimuPosition) throws {
        try simuPosDelete(id: simuPos.simuId)
    }
    
    func simuPosDelete(id: Int) throws {
        let deleteSQL = "DELETE FROM SIMU_POSITION WHERE SIMU_ID = ?"
        
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
    
    func getSimuList() throws -> Array<SimuPosition> {
        var simuArray = [SimuPosition]()
        
        let selectSQL = """
                SELECT  a.STOCK_ID, a.STOCK_NAME, a.STOCK_TYPE, b.SIMU_ID, b.START_DATE,
                        b.START_BALANCE, b.LAST_DATE, b.ACTUAL_BALANCE,
                        CASE
                            WHEN b.ACTUAL_BALANCE IS NULL THEN
                            'Start'
                        ELSE
                            'Continue'
                        END AS action,
                        b.QUANTITY,
                        b.LAST_QUOTE,
                        b.POSITION_TYPE
                FROM STOCKS a LEFT OUTER JOIN SIMU_POSITION b ON a.STOCK_ID = b.STOCK_ID
                WHERE a.STOCK_STATUS = 'Active'
                """
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: selectSQL)
        defer {
            sqlite3_finalize(statement)
        }
        
        while(sqlite3_step(statement)==SQLITE_ROW) {
            let simuPos = SimuPosition()
            
            simuPos.stockId = String(cString: (sqlite3_column_text(statement, 0)))
            simuPos.stockName = String(cString: (sqlite3_column_text(statement, 1)))
            simuPos.stockType = String(cString: (sqlite3_column_text(statement, 2)))
            simuPos.simuId = Int(sqlite3_column_int(statement, 3))
            
            if sqlite3_column_type(statement, 4) != SQLITE_NULL {
                if let checkValue = CDate.dateFromDB(String(cString: (sqlite3_column_text(statement, 4)))) {
                    simuPos.startDate = checkValue
                }
            }
            
            if sqlite3_column_type(statement, 5) != SQLITE_NULL {
                simuPos.startBalance = sqlite3_column_double(statement, 5)
            } else {
                simuPos.startBalance = 0
            }
            
            if sqlite3_column_type(statement, 6) != SQLITE_NULL {
                if let checkValue = CDate.dateFromDB(String(cString: (sqlite3_column_text(statement, 6)))) {
                    simuPos.lastDate = checkValue
                }
            }
            
            if sqlite3_column_type(statement, 7) != SQLITE_NULL {
                simuPos.actualBalance = sqlite3_column_double(statement, 7)
            }
            
            simuPos.action = String(cString: (sqlite3_column_text(statement, 8)))
            
            if sqlite3_column_type(statement, 9) != SQLITE_NULL {
                simuPos.quantity = sqlite3_column_double(statement, 9)
            }
            
            if sqlite3_column_type(statement, 10) != SQLITE_NULL {
                simuPos.lastQuote = sqlite3_column_double(statement, 10)
            }
            
            if sqlite3_column_type(statement, 11) != SQLITE_NULL {
                simuPos.positionType = String(cString: (sqlite3_column_text(statement, 11)))
            }
            simuArray.append(simuPos)
        }
        
        return simuArray
    }
    
    //MARK: ---  Order  ---
    func simuOrderInsert(simuOrd: SimuOrder) throws {
        
        let insertSQL = """
            INSERT INTO SIMU_ORDER
            (SIMU_ID, POSITION_ID, OPERATION_DATE, OPERATION_ACTION, OPERATION_TYPE, QUANTITY,
            EXECUTION_PRICE, COMMISSION, NET_PRICE, AMOUNT, NET_AMOUNT, COMMENT, ORDER_ID)
            VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """
        
        try simuOrderInsertUpdate(simuOrd: simuOrd, sql: insertSQL)
    }
    
    private func simuOrderInsertUpdate(simuOrd: SimuOrder, sql: String) throws {
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: sql)
        defer {
            sqlite3_finalize(statement)
        }
        
        let operationDate: String! = CDate.dateToDB(simuOrd.operationDate)
        
        guard
            sqlite3_bind_int(statement, 13, Int32(simuOrd.orderId)) == SQLITE_OK  &&
            sqlite3_bind_int(statement, 1, Int32(simuOrd.simuId)) == SQLITE_OK  &&
            sqlite3_bind_int(statement, 2, Int32(simuOrd.positionId)) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 3, operationDate, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 4, simuOrd.operationAction, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 5, simuOrd.operationType, -1, SQLITE_TRANSIENT) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 6, simuOrd.quantity) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 7, simuOrd.executionPrice) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 8, simuOrd.commission) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 9, simuOrd.netPrice) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 10, simuOrd.amount) == SQLITE_OK  &&
            sqlite3_bind_double(statement, 11, simuOrd.netAmount) == SQLITE_OK  &&
            sqlite3_bind_text(statement, 12, simuOrd.comment, -1, SQLITE_TRANSIENT) == SQLITE_OK
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
    
    
    func simuOrderDelete(simuPos: SimuPosition) throws {
        try simuOrderDelete(id: simuPos.simuId)
    }
    
    func simuOrderDelete(id: Int) throws {
        let deleteSQL = "DELETE FROM SIMU_ORDER WHERE SIMU_ID = ?"
        
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
    
    func getOrderList(simuPos: SimuPosition) throws -> Array<SimuOrder> {
          return try getOrderList(id: simuPos.simuId)
      }
      
    func getOrderList(id: Int) throws -> Array<SimuOrder> {
        var simuArray = [SimuOrder]()
        
        let selectSQL = """
                SELECT ORDER_ID, SIMU_ID, POSITION_ID, OPERATION_DATE, OPERATION_ACTION, OPERATION_TYPE, QUANTITY,
                      EXECUTION_PRICE, COMMISSION, NET_PRICE, AMOUNT, NET_AMOUNT, COMMENT
                FROM SIMU_ORDER
                WHERE SIMU_ID = ?
                ORDER BY OPERATION_DATE
                """
        
        let db = try SQLiteDB.open()
        let statement = try db.prepareStatement(sql: selectSQL)
        defer {
            sqlite3_finalize(statement)
        }
        
        guard
            sqlite3_bind_int(statement, 1, Int32(id)) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: db.errorMessage)
            }
        
        while(sqlite3_step(statement)==SQLITE_ROW) {
            let simuOrd = SimuOrder()
            
            simuOrd.orderId = Int(sqlite3_column_int(statement, 0))
            simuOrd.simuId = Int(sqlite3_column_int(statement, 1))
            simuOrd.positionId = Int(sqlite3_column_int(statement, 2))
           
            if let checkValue = CDate.dateFromDB(String(cString: (sqlite3_column_text(statement, 3)))) {
                simuOrd.operationDate = checkValue
            }
            simuOrd.operationAction = String(cString: (sqlite3_column_text(statement, 4)))
            simuOrd.operationType = String(cString: (sqlite3_column_text(statement, 5)))
            simuOrd.quantity = sqlite3_column_double(statement, 6)
            simuOrd.executionPrice = sqlite3_column_double(statement, 7)
            simuOrd.commission = sqlite3_column_double(statement, 8)
            simuOrd.netPrice = sqlite3_column_double(statement, 9)
            simuOrd.amount = sqlite3_column_double(statement, 10)
            simuOrd.netAmount = sqlite3_column_double(statement, 11)
            simuOrd.comment = String(cString: (sqlite3_column_text(statement, 12)))
            
            simuArray.append(simuOrd)
        }
        
        return simuArray
    }
    
    /// --------------------- Manage Position ---------------------- //
    func updatePosition(simuPos: SimuPosition, sQuote: StockQuote ) throws  {
        simuPos.lastDate = sQuote.dateQuote
        simuPos.lastQuote = sQuote.close
        try simuPosUpdate(simuPos: simuPos)
    }
    
    func updatePosition(simuPos: SimuPosition, simuOrd: SimuOrder) throws {
        if simuOrd.quantity == 0.0 {
            return
        }
      
        simuPos.totalComm = simuPos.totalComm + simuOrd.commission
      
        if simuOrd.operationType == "Long" {
            if simuOrd.operationAction == "Open" {
                simuPos.quantity += simuOrd.quantity
                simuPos.actualBalance -= simuOrd.netAmount
                simuPos.investedAmount += simuOrd.netAmount
                
                if simuPos.quantity > 0 {
                    simuPos.averagePrice = simuPos.investedAmount / simuPos.quantity
                }
                
            } else {
                simuPos.quantity -= simuOrd.quantity
                simuPos.actualBalance += simuOrd.netAmount
                simuPos.investedAmount = simuPos.averagePrice * simuPos.quantity
            }
        } else { // SHORT
            if simuOrd.operationAction == "Open" {
                simuPos.quantity += simuOrd.quantity
                simuPos.actualBalance += simuOrd.netAmount
                simuPos.investedAmount += simuOrd.netAmount
                
                if simuPos.quantity > 0 {
                    simuPos.averagePrice = simuPos.investedAmount / simuPos.quantity
                }
                
            } else {
                simuPos.quantity -= simuOrd.quantity
                simuPos.actualBalance -= simuOrd.netAmount 
                simuPos.investedAmount = simuPos.averagePrice * simuPos.quantity
            }
        }
        
         if simuPos.quantity == 0 {
            simuPos.positionType = "NA"
            simuPos.stopLoss = 0
            simuPos.investedAmount = 0
            simuPos.averagePrice = 0
        } else {
            simuPos.positionType = simuOrd.operationType
        }
    
        try simuOrderInsert(simuOrd: simuOrd)
        try simuPosUpdate(simuPos: simuPos)
    }
    
    func checkStop(simuPos: SimuPosition, sQuote: StockQuote ) -> Bool {
        if simuPos.quantity == 0.0 {
            return false
        }
        if simuPos.stopLoss == 0.0 {
            // Stop Loss not checked
            return false
        } else {
            if (simuPos.positionType == "Long" && simuPos.stopLoss >= sQuote.low) || (simuPos.positionType == "Short" && simuPos.stopLoss <= sQuote.high ) {
                return true
            } else {
                return false
            }
        }
    }
    
    func closePosition(simuPos: SimuPosition, sQuote: StockQuote) throws -> String {
        
        let simuOrd = SimuOrder()
        simuOrd.setOrderId()
        simuOrd.simuId = simuPos.simuId
        simuOrd.positionId = simuPos.getPositionId()
        simuOrd.operationDate = simuPos.lastDate
        
        simuOrd.operationType = simuPos.positionType
        simuOrd.operationAction = "Close"
        simuOrd.quantity = simuPos.quantity
        
        if (simuPos.positionType == "Long" && simuPos.stopLoss >= sQuote.high) || (simuPos.positionType == "Short" && simuPos.stopLoss <= sQuote.low) {
            simuOrd.executionPrice = simuPos.lastQuote
            simuOrd.comment = "Exit on stop with GAP at \(simuOrd.executionPrice)"
        } else {
            simuOrd.executionPrice = simuPos.stopLoss
            simuOrd.comment = "Exit on stop at \(simuOrd.executionPrice)"
        }
        
        simuOrd.amount = simuOrd.quantity * simuOrd.executionPrice
        simuOrd.commission = simuPos.commission
        
        if simuPos.positionType == "Long" {
            simuOrd.netAmount = simuOrd.amount - simuOrd.commission
        } else {
            simuOrd.netAmount = simuOrd.amount + simuOrd.commission
        }
        
        simuOrd.netPrice = simuOrd.netAmount  / simuOrd.quantity
        try updatePosition(simuPos: simuPos, simuOrd: simuOrd)
        return simuOrd.comment
    }
    
    /// ********************* performance ************************ //
    
    func getSimuPerformance(id: Int ) throws -> Array<SimuPerformance> {
        var simuArray = [SimuPerformance]()
        
        let selectSQL = """
                SELECT
                SIMU_ID, POSITION_ID, OPERATION_TYPE, STOCK_ID, INVESTED_AMOUNT, ESTIMED_AMOUNT,
                RESULT, VAR, QUANTIY, COMMISSION, DATE_FROM, DATE_TO, DAYS_NUMBER
                FROM VSIMU2 WHERE SIMU_ID = ?
                ORDER BY DATE_FROM
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
            let simuPerf = SimuPerformance()
        
            simuPerf.simuId = Int(sqlite3_column_int(statement, 0))
            simuPerf.positionId = Int(sqlite3_column_int(statement, 1))
            simuPerf.operationType = String(cString: (sqlite3_column_text(statement, 2)))
            simuPerf.stockId = String(cString: (sqlite3_column_text(statement, 3)))
 
            simuPerf.investedAmount = sqlite3_column_double(statement, 4)
            simuPerf.estimatedAmount = sqlite3_column_double(statement, 5)
            simuPerf.result = sqlite3_column_double(statement, 6)
            simuPerf.varPer = sqlite3_column_double(statement, 7)
            simuPerf.quantity = sqlite3_column_double(statement, 8)
            simuPerf.commission = sqlite3_column_double(statement, 9)
        
            if let checkValue = CDate.dateFromDB(String(cString: (sqlite3_column_text(statement, 10)))) {
                simuPerf.dateFrom = checkValue
            }
            if let checkValue = CDate.dateFromDB(String(cString: (sqlite3_column_text(statement, 11)))) {
                simuPerf.dateTo = checkValue
            }
            simuPerf.dayNumbers = Int(sqlite3_column_int(statement, 12))
            simuArray.append(simuPerf)
        }
        return simuArray
    }
    
    func getSimuPerformance(simuPerf: SimuPerformance) throws -> Array<SimuPerformance> {
        return try getSimuPerformance(id: simuPerf.simuId)
    }
}
