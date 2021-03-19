//
//  StockHist.swift
//  Trading
//
//  Created by Maroun Achille on 03/06/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class StockHist {
    var id: String
    var name: String
    var type: String
    var marketPlace: String
    var historicReference: String
    var historicCode: String
    var quoteDate: Date!
    var upToDate: String
    
    public var description: String {
        return "Stocks: \(id) Name: \(name) Type: \(type) Market Place: \(marketPlace) Quote Date: \(String(describing: quoteDate)) upToDate : \(upToDate)"
    }
    
    init() {
        id = ""
        name = ""
        type = ""
        marketPlace = ""
        historicReference = ""
        historicCode = ""
        quoteDate = nil
        upToDate = "No"
    }
}
