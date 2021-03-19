//
//  StockDayQuote.swift
//  Trading
//
//  Created by Maroun Achille on 01/07/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation


class StockDayQuote : StockQuote {
    
    var id: String
    var name: String
    var reference: String
    var marketPlace: String
    var currency: String
    var type: String

    var change: Double
    var varChange: Double
    
    var yearLow: Double
    var yearHigh: Double
    var yearVarChange: Double
    var yearRange: Double
    
    var status: Int
    
    init (id: String, name: String, reference: String, currency: String, marketPlace: String, type: String,
          yearLow: Double,  yearHigh: Double, yearVarChange: Double, yearRange: Double) {
    
        self.id = id;
        self.name = name;
        self.reference = reference;
        self.currency = currency ;
        self.marketPlace = marketPlace;
        self.type = type;
        
        self.change = 0.0
        self.varChange = 0.0
    
        self.yearLow = yearLow
        self.yearHigh = yearHigh
        self.yearVarChange = yearVarChange
        self.yearRange = yearRange
        if id == "AAPL" {
            print(yearLow, yearLow, yearVarChange, yearRange )
        }
        status = -1;
        super.init()
    }
    
    func updateQuote (dateQuote: Date, close: Double, change: Double, varChange: Double, open: Double, high: Double, low: Double, volume: Double) {
    
    // Status : -1 old date and old Price => no  DB   no  refresh
    //        :  0 old date and new Price => no  DB   yes refresh
    //        :  1 new date and new Price => yes DB   yes refresh
    //        :  2 new date and old Price => yes DB   no  refresh
    
        if (self.dateQuote == dateQuote) && (self.close == close)  {
            status = -1
            return
        } else if (self.dateQuote == dateQuote) && (self.close != close)  {
            status = 0
        } else if (self.dateQuote != dateQuote) && (self.close == close) {
            status = 2
        } else {
            status = 1
        }
    
        self.dateQuote = dateQuote
        self.close = close
        self.change = change
        self.varChange = varChange
        self.open = open
        self.high = high
        self.low = low
        self.volume = volume
    }
    
    func resetStatus () {
        status = -1
    }
    
    override public var description: String {
        return ("Stock : \(id)  \(name) \(close) \(change)")
    }
}
