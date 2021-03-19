//
//  SimuOrder.swift
//  Trading
//
//  Created by Maroun Achille on 09/06/2019.
//  Copyright © 2019 Maroun Achille. All rights reserved.
//

import Foundation

class SimuOrder {
    var orderId: Int
    var simuId: Int
    var positionId: Int
    var operationDate: Date
    var operationAction: String // Open Close
    var operationType: String // Long Short
    var quantity: Double
    var executionPrice: Double
    var commission: Double
    var netPrice: Double
    var amount: Double
    var netAmount: Double
    var comment: String
    
    init() {
        orderId = 0
        simuId = 0
        positionId = 0
        operationDate = Date()
        operationAction = "Open"
        operationType = "Long"
        quantity = 0.0
        executionPrice = 0.0
        commission = 0.0
        netPrice = 0.0
        amount = 0.0
        netAmount = 0.0
        comment = ""
    }
    
    func setOrderId(){
        orderId = SequenceDB.instance.nextSequence(id: "SIMORD")
     }
    
    public var description: String {
        return "orderId \(orderId) simuId \(simuId) positionId \(positionId) operationDate \(operationDate)  operationAction \(operationAction) operationType \(operationType)  quantity \(quantity)  executionPrice \(executionPrice) "
    }
}
