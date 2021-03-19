//
//  Stock.swift
//  SQLiteTest
//
//  Created by Maroun Achille on 09/04/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class Stock {
    var id: String
    var name: String
    var status: String
    var type: String
    var industry: String
    var closingDate: Date!
    var currency: String
    var marketPlace: String
    var creationDate :Date
    var dailyReference: String
    var dailyCode: String
    var historicReference: String
    var historicCode: String

     public var description: String {
        return "Stocks: \(id) : \(name) Type: \(type) Market Place: \(marketPlace)"
    }
    
    init() {
        id = ""
        name = ""
        status = "Active"
        type = "Stock"
        industry = ""
        closingDate = nil
        currency = "USD"
        marketPlace = ""
        creationDate = Date()
        dailyReference = ""
        dailyCode = ""
        historicReference = ""
        historicCode = ""
    }
}
