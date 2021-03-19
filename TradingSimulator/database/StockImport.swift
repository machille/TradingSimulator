//
//  StockImport.swift
//  Trading
//
//  Created by Maroun Achille on 30/05/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class StockImport {
    var indexId: String
    var action: String
    var stock: Stock
    var watchListName: String
    
     public var description: String {
        return "Stocks: \(stock.id) Name: \(stock.name) Type: \(stock.type) Market Place: \(stock.marketPlace) Index Id: \(indexId) Action \(action) watchListName \(watchListName)"
    }
    
    init() {
        stock = Stock()
        indexId = ""
        action = ""
        watchListName = ""
    }
}
