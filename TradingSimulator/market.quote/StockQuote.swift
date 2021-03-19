//
//  StockQuote.swift
//  Trading
//
//  Created by Maroun Achille on 01/07/2018.
//  Copyright © 2018 Maroun Achille. All rights reserved.
//

import Foundation

class StockQuote {
    var dateQuote: Date
    var close: Double
    var open: Double
    var high: Double
    var low: Double
    var volume: Double
    
    init (dateQuote: Date, close: Double, open: Double, high: Double, low: Double, volume: Double) {
        self.dateQuote = dateQuote
        self.close = close
        self.open = open
        self.high = high
        self.low = low
        self.volume = volume
    }
    
    init() {
        self.dateQuote = Date()
        self.close = 0.0
        self.open = 0.0
        self.high = 0.0
        self.low = 0.0
        self.volume = 0.0
    }
    
    public var description: String {
        return "dateQuote: \(dateQuote) Close: \(close) open: \(open) high: \(high) low: \(low) volume \(volume)"
    }
}
