//
//  SimuPosition.swift
//  Trading
//
//  Created by Maroun Achille on 09/06/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Foundation

class SimuPosition {
    var simuId: Int
    var stockId: String
    var indexId: String
    var startDate: Date
    var startBalance: Double
    var commission: Double
    var stopLossAction: String  // Alert - Exit
    var stopLossDefault: Double
    ///  Actual POSITION
    var positionId: Int
    var positionType: String  // Long Short
    var quantity: Double
    var averagePrice: Double
    var investedAmount : Double
    var lastDate: Date
    var lastQuote: Double
    
    var stopLoss: Double
    /// Global Position
    var totalComm: Double
    var actualBalance: Double
    
    var stockName: String
    var stockType: String
    var action: String
    /// calcutated var

    var positionVar: Double {
        if investedAmount != 0.0 {
            if positionType == "Long" {
                return ((estimatedAmount - investedAmount) / investedAmount) //* 100.0
            } else {
                return ((investedAmount - estimatedAmount) / investedAmount) //* 100.0
            }
        } else {
            return 0.0
        }
    }

    var positionProfitLoss: Double {
        if investedAmount != 0.0 {
            if positionType == "Long" {
                return estimatedAmount - investedAmount
            } else {
                return investedAmount - estimatedAmount
            }
        } else {
            return 0.0
        }
    }

    var totalVar: Double {
        if actualBalance == 0.0 {
            return 0.0
        } else if startBalance != 0.0 {
            if positionType == "Long" {
                return ((actualBalance + estimatedAmount - startBalance ) / startBalance) //* 100.0
            } else {
                return ((actualBalance - estimatedAmount - startBalance ) / startBalance) //* 100.0
            }
        } else {
            return 0.0
        }
    }
    
    var profitLossAmt: Double {
        if positionType == "Long" {
            return actualBalance + estimatedAmount - startBalance
        } else {
            return actualBalance - estimatedAmount - startBalance 
        }
    }
    
    var estimatedAmount : Double {
        if quantity != 0.0 {
            if positionType == "Long" {
                return lastQuote * quantity - commission
            } else {
                return lastQuote * quantity + commission
            }
        } else {
            return 0.0
        }
    }
       
    
    var creationDate: Date
    
    var stopPL : Double {
        get {
            if quantity == 0.0 {
                return 0.0
            } else if positionType == "Long" {
                return  (stopLoss * quantity) - investedAmount
            } else if positionType == "Short" {
                return  investedAmount - (stopLoss * quantity)
            } else {
                return 0.0
            }
        }
    }
    init () {
        simuId = 0
        stockId = ""
        indexId = "DOWJONES"
        startDate = NSCalendar.current.date(byAdding: .year, value: -7,  to: Date())!
        startBalance = 30000.0
        commission = 15.0
        stopLossAction = "Alert"
        stopLossDefault = 3.0
    ///  Actual POSITION
        positionId = 0
        positionType = "NA"
        quantity = 0.0
        averagePrice = 0.0
        investedAmount = 0.0
        lastDate = startDate
        lastQuote = 0.0
        stopLoss = 0.0
    /// Global Position
        totalComm = 0.0
        actualBalance = 0.0
        creationDate = Date()
        
        stockName = ""
        stockType = "Stock"
        action = "Start"
    }
    
    func getPositionId() -> Int {
        if quantity == 0 {
            positionId = SequenceDB.instance.nextSequence(id: "SIMPOS")
        }
        return positionId
    }
    
    func setSimuId() {
        simuId = SequenceDB.instance.nextSequence(id: "SIMID")
    }
    
    public var description: String {
        return "stockId \(stockId) simuId \(simuId) stockName \(stockName) indexId \(indexId) startDate \(startDate)  startBalance \(startBalance) lastDate \(lastDate)  actualBalance \(actualBalance)  estimatedAmount \(estimatedAmount) totalVar \(totalVar) "
    }
}
