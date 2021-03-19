//
//  SimuPerformance.swift
//  Trading
//
//  Created by Maroun Achille on 21/08/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Foundation

class SimuPerformance {
    var simuId: Int
    var positionId: Int
    var stockId: String
    var operationType: String // Long Short

    var investedAmount: Double
    var estimatedAmount: Double
    var result: Double
    var varPer: Double
    var quantity: Double
    var commission: Double

    var dateFrom: Date
    var dateTo: Date
    var dayNumbers: Int
    
    init () {
        simuId = 0
        positionId = 0
        stockId = ""
        operationType = ""
        investedAmount = 0
        estimatedAmount = 0
        result = 0
        varPer = 0
        quantity = 0
        commission = 0
        dateFrom = Date()
        dateTo = Date()
        dayNumbers = 0
    }
    
    public var description: String {
        return "stockId \(stockId) simuId \(simuId) positionId \(positionId) operationType \(operationType) investedAmount \(investedAmount)  estimatedAmount \(estimatedAmount) result \(result)  varPer \(varPer)  fromDate \(dateFrom) toDate \(dateTo) "
    }
}

