//
//  WatchList.swift
//  Trading
//
//  Created by Maroun Achille on 08/05/2020.
//  Copyright © 2020 Maroun Achille. All rights reserved.
//

import Foundation

class WatchList {
    var id: Int
    var name: String
    var screener: String
    var stockArray:[WatchListIndex]
    
    public var description: String {
        return "WatchList : \(name) with \(stockArray.count) Stock(s)"
    }
    
    init() {
        id = 0
        name = ""
        screener = "N"
        stockArray = [WatchListIndex]()
    }
    
    func setId() {
        id = SequenceDB.instance.nextSequence(id: "WTHLST")
    }
}

class WatchListIndex {
    var watchListId: Int
    var stockId: String
    var stockName: String
    var watchListName: String?
    
    public var description: String {
        return "Stock: \(stockId) : \(stockName)"
    }
    
    init() {
        watchListId = 0
        stockId = ""
        stockName = ""
        
    }
}
